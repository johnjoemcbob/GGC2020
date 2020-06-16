--
-- GGC2020_johnjoemcbob
-- 16/06/20
--
-- State: Wave Defense
--

STATE_WAVE_DEFENSE = "WAVE_DEFENSE"

local enemies = 5
local POS_PLATFORM = Vector( 0, 0, -12288 )
local size = 800

GM.AddPlayerState( STATE_WAVE_DEFENSE, {
	OnStart = function( self, ply )
		ply:SetPos( POS_PLATFORM )
	end,
	OnThink = function( self, ply )
		if ( SERVER ) then
			ply.WaveEnemies = ply.WaveEnemies or {}
			if ( #ply.WaveEnemies < enemies ) then
				-- Spawn one enemy per frame when there aren't max already
				local classes = {
					"ggcj_npc_demon",
					"ggcj_npc_skull",
					"ggcj_npc_shrieker",
				}
				local rnd = classes[math.random( 1, #classes )]
				local npc = GAMEMODE.CreateEnt( rnd, nil, POS_PLATFORM + Vector( math.random( -size, size ), math.random( -size, size ), 0 ), Angle( 0, 0, 0 ) )
				table.insert( ply.WaveEnemies, npc )
			end

			if ( ply:Alive() ) then
				local pos = ply:GetPos()
				if ( pos.z <= POS_PLATFORM.z - 100 ) then
					ply:Kill()
				end
			end
		end
	end,
	OnFinish = function( self, ply )

	end,
})

if ( SERVER ) then
	hook.Add( "OnNPCKilled", HOOK_PREFIX .. "WaveDefense_OnNPCKilled", function( npc, attacker, inflictor )
		table.RemoveByValue( attacker.WaveEnemies, npc )
	end )
end

if ( CLIENT ) then
	hook.Add( "PreDrawOpaqueRenderables", HOOK_PREFIX .. "WaveDefense_PreDrawOpaqueRenderables", function()
		if ( LocalPlayer():GetStateName() == STATE_WAVE_DEFENSE ) then
			render.Clear( 0, 0, 0, 255 )
			render.ClearDepth()

			GAMEMODE.RenderCachedModel(
				"models/hunter/plates/plate1x1.mdl",
				POS_PLATFORM + Vector( 0, 0, -2000 ),
				Angle( 0, 0, 0 ),
				Vector( 1, 1, 1 ) * 1000,
				"models/debug/debugwhite",
				Color( 0, 0, 0, 255 )
			)
			GAMEMODE.RenderCachedModel(
				"models/props_phx/construct/metal_tube.mdl",
				POS_PLATFORM + Vector( 0, 0, -2000 ),
				Angle( 0, 0, 0 ),
				Vector( 1, 1, 1 ) * 1000,
				"models/debug/debugwhite",
				Color( 0, 0, 0, 255 )
			)

			local light = 20
			GAMEMODE.RenderCachedModel(
				"models/hunter/plates/plate1x1.mdl",
				POS_PLATFORM+ Vector( 0, 0, -60 ),
				Angle( 0, 0, 0 ),
				Vector( 1, 1, 1 ) * 40,
				"models/debug/debugwhite",
				Color( light, light, light, 255 )
			)
		end
	end )
	hook.Add( "CalcView", HOOK_PREFIX .. "WaveDefense_CalcView", function( ply, pos, ang, fov )
		if ( LocalPlayer():GetStateName() == STATE_WAVE_DEFENSE ) then
			local view = {}
				view.origin = pos
				view.angles = ang
				view.fov = fov
				--view.zfar = 1000

				LocalPlayer().CalcViewAngles = nil
			return view
		end
	end )
end
