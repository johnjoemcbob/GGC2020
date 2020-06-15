--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Serverside
--

-- LUA Downloads
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "includes/modules/3d2dvgui.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_billboard.lua" )
AddCSLuaFile( "cl_modelcache.lua" )
AddCSLuaFile( "cl_player.lua" )
AddCSLuaFile( "cl_moduleeditor.lua" )
AddCSLuaFile( "cl_shipeditor.lua" )
AddCSLuaFile( "cl_outsiderender.lua" )
AddCSLuaFile( "cl_scene.lua" )
AddCSLuaFile( "cl_2dmap.lua" )

-- LUA Includes
include( "shared.lua" )

include( "sv_2dmap.lua" )

-- Resources
resource.AddFile( "materials/playersheet.png" )
resource.AddFile( "materials/guns_future.png" )
resource.AddFile( "materials/muzzleflash.png" )

sound.Add( {
	name = HOOK_PREFIX .. "JUMP",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 80,
	pitch = { 80, 120 },
	sound = "thrusters/rocket04.wav"
} )

-- Net


------------------------
  -- Gamemode Hooks --
------------------------
function GM:Initialize()
	
end

function GM:InitPostEntity()
	
end

hook.Add( "PlayerInitialSpawn", HOOK_PREFIX .. "PlayerInitialSpawn", function( ply )
	ply.InitialFOV = ply:GetFOV()
	ply:SwitchState( STATE_JOINED )
end )

hook.Add( "PlayerSpawn", HOOK_PREFIX .. "PlayerSpawn", function( ply )
	timer.Simple( 0, function()
		ply:SetWalkSpeed( 250 )
		ply:SetRunSpeed( 250 )
		-- ply:SetBloodColor( BLOOD_COLOR_MECH )
		ply:SetBloodColor( BLOOD_COLOR_ANTLION_WORKER )

		if ( !DEBUG_NOSTRIP ) then
			ply:StripWeapons()
		end
		ply:GiveAmmo( 2000, "Pistol" )
		ply:Give( "ggcj_weapon_pistol" )
		ply:Give( "ggcj_weapon_shotgun" )
		ply:Give( "ggcj_weapon_machinegun" )
		ply:Give( "ggcj_weapon_laser" )
		ply:Give( "ggcj_weapon_rocketlauncher" )

		local ship = ply:GetNWInt( "CurrentShip", -1 )
		if ( ship >= 0 ) then
			ply:SetPos( Ship.Ship[ship].SpawnPoint )
		end
	end )
end )

function GM:Think()
	
end

hook.Add( "PlayerDeathThink", HOOK_PREFIX .. "PlayerDeathThink", function( ply )
	-- Don't show human ragdolls!
	if ( ply:GetRagdollEntity() and ply:GetRagdollEntity():IsValid() ) then
		ply:GetRagdollEntity():Remove()
	end
end )

function GM:HandlePlayerJumping( ply, vel )
	if ( vel.z != 0 and !ply.JumpSound ) then
		ply.JumpSound = ply:StartLoopingSound( HOOK_PREFIX .. "JUMP" )

		ply:ViewPunch( Angle( -5, 0, 0 ) )
		util.Decal( "Scorch", ply:EyePos(), ply:GetPos() + Vector( 0, 0, -10 ), ply )
		GAMEMODE.AddWorldText( ply:GetPos() + Vector( 0, 0, 5 ), Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), 0.3, "pffffft", 1, false )
	
		-- If moving at the same time, draw view backwards
		local hor = Vector( vel.x, vel.y, 0 ):LengthSqr()
		if ( hor > 0 ) then
			ply:SetFOV( ply.InitialFOV + 5, 0.5 )
		end
	elseif ( vel.z == 0 and ply.JumpSound != nil ) then
		ply:StopLoopingSound( ply.JumpSound )
		ply.JumpSound = nil

		-- ply:EmitSound( "physics/metal/metal_canister_impact_soft2.wav", 75, math.random( 80, 120 ), 0.4 )
		ply:EmitSound( "physics/metal/metal_barrel_impact_soft1.wav", 75, math.random( 40, 70 ), 0.4 )
		ply:ViewPunch( Angle( 5, 0, 0 ) )
		ply:SetFOV( ply.InitialFOV, 0.5 )
	end
end

function GM:PlayerDisconnected( ply )
	
end
-------------------------
  -- /Gamemode Hooks --
-------------------------

concommand.Add( "ggcj_testbutton", function( ply, cmd, args )
	local tr = util.TraceLine( {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
		filter = ply,
	} )
	local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis( ang:Up(), 180 )
		ang:RotateAroundAxis( ang:Forward(), 180 )
		ang:RotateAroundAxis( ang:Right(), 90 )
	local ent = GAMEMODE.CreateEnt( "ggcj_button", "models/maxofs2d/button_04.mdl", tr.HitPos, ang, false )
	ent:SetIsToggle( true )
	ent.OnTurnOn = function( self, ply )
		local ship = ply:GetNWInt( "CurrentShip", -1 )
		if ( ship >= 0 ) then
			local ship = Ship.Ship[ship]
			if ( ship and ship:IsValid() ) then
				for k, part in pairs( ship.Parts ) do
					if ( part and part:IsValid() ) then
						part:SetColor( COLOUR_LIT )
					end
				end
			end
		end
	end
	ent.OnTurnOff = function( self, ply )
		local ship = ply:GetNWInt( "CurrentShip", -1 )
		if ( ship >= 0 ) then
			local ship = Ship.Ship[ship]
			if ( ship and ship:IsValid() ) then
				for k, part in pairs( ship.Parts ) do
					if ( part and part:IsValid() ) then
						part:SetColor( COLOUR_UNLIT )
					end
				end
			end
		end
	end
end )
