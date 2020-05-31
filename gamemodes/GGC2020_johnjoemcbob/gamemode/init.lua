--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Serverside
--

-- LUA Downloads
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_modelcache.lua" )
AddCSLuaFile( "cl_shipeditor.lua" )

-- LUA Includes
include( "shared.lua" )

-- Resources
resource.AddFile( "materials/playersheet.png" )
resource.AddFile( "materials/gun_future.png" )
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
util.AddNetworkString( NET_SHIPEDITOR_SPAWN )
net.Receive( NET_SHIPEDITOR_SPAWN, function( len, ply )
	-- Load ship data
	local json = file.Read( HOOK_PREFIX .. "/ship.txt" )
	local tab = util.JSONToTable( json )

	-- Clear old
	if ( ply.Ship ) then
		for k, part in pairs( ply.Ship ) do
			if ( part and part:IsValid() ) then
				part:Remove()
			end
		end
	end

	-- Generate new
	local first = nil
	ply.Ship = {}
	for k, v in pairs ( tab ) do
		local part = SHIPPARTS[v.Name]
			v.Collisions = part[2]
			if ( v.Rotation % 2 != 0 ) then
				v.Collisions = Vector( v.Collisions.y, v.Collisions.x )
			end
		local ent = GAMEMODE.CreateProp(
			part[1],
			SHIPEDITOR_ORIGIN( ply ) +
				Vector(
					v.Grid.x + math.floor( v.Collisions.x / 2 ) + part[3].x,
					-v.Grid.y - math.floor( v.Collisions.y / 2 ) + part[3].y
				) * SHIPPART_SIZE,
			Angle( 0, 90 * v.Rotation, 0 ),
			false
		)
		ent:SetColor( COLOUR_UNLIT )
		table.insert( ply.Ship, ent )

		-- Temp testing
		if ( math.random( 1, 2 ) == 1 ) then
			local npc = GAMEMODE.CreateEnt( "npc_combine_s", nil, ent:GetPos(), Angle( 0, 0, 0 ) )
				npc:Give( "weapon_ar2" )
				npc:SetHealth( 20 )
				-- npc:SetNoDraw( true )
				-- npc:GiveAmmo( 2000, "AR2" )
			table.insert( ply.Ship, npc )
		else
			ply.SpawnPoint = ent:GetPos() - Vector( 0, 0, 32 )
			ply:SetPos( ply.SpawnPoint )
			ply:SetHealth( ply:GetMaxHealth() )
		end

		if ( first ) then
			-- ent:SetParent( first )
		else
			first = ent
		end
	end
end )

------------------------
  -- Gamemode Hooks --
------------------------
function GM:Initialize()
	
end

function GM:InitPostEntity()
	
end

hook.Add( "PlayerInitialSpawn", HOOK_PREFIX .. "PlayerInitialSpawn", function( ply )
	ply.InitialFOV = ply:GetFOV()
end )

hook.Add( "PlayerSpawn", HOOK_PREFIX .. "PlayerSpawn", function( ply )
	timer.Simple( 0, function()
		ply:SetWalkSpeed( 250 )
		ply:SetRunSpeed( 250 )
		-- ply:SetBloodColor( BLOOD_COLOR_MECH )
		ply:SetBloodColor( BLOOD_COLOR_ANTLION_WORKER )

		ply:StripWeapons()
		ply:Give( "weapon_ar2" )
		ply:GiveAmmo( 2000, "AR2" )

		if ( ply.SpawnPoint ) then
			ply:SetPos( ply.SpawnPoint )
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

-- engine.LightStyle( 0, "m" )
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
	-- local tr =
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
		if ( ply.Ship ) then
			for k, part in pairs( ply.Ship ) do
				if ( part and part:IsValid() ) then
					part:SetColor( COLOUR_LIT )
				end
			end
		end
	end
	ent.OnTurnOff = function( self, ply )
		if ( ply.Ship ) then
			for k, part in pairs( ply.Ship ) do
				if ( part and part:IsValid() ) then
					part:SetColor( COLOUR_UNLIT )
				end
			end
		end
	end
end )
