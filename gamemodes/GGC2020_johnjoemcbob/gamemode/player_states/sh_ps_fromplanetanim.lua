--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Animate Planet-to-Space
--

STATE_FROM_PLANET_ANIM = "FROMPLANETANIM"

GM.AddPlayerState( STATE_FROM_PLANET_ANIM, {
	OnStart = function( self, ply )
		ply:HideFPSController()

		if ( CLIENT ) then
			PLANET_MODELS = LoadScene( "planet_base" )
			PlaySceneAnimation( PLANET_MODELS, "planet_base_from", function()
				ply:SwitchState( STATE_FPS )
			end )
		end
	end,
	OnThink = function( self, ply )
		
	end,
	OnFinish = function( self, ply )
		ply:ShowFPSController()
	end,
})

if ( CLIENT ) then
	local SHUTTLES = {
		{
			Model = "models/slyfo/shuttle.mdl",
			Start = Vector( -363, 262, 398 ),
			Target = Vector( -516, 546, 408 ),
			Angle = Angle( 0, 120, 0 ),
			Scale = 0.05,
			Speed = 1,
		},
		{
			Model = "models/slyfo/cratemover.mdl",
			Start = Vector( -405, 641, 450 ),
			Target = Vector( -477, 294, 394 ),
			Angle = Angle( 0, -115, 0 ),
			Scale = 0.05,
			Speed = 2,
		},
		{
			Model = "models/spacebuild/nova/blimp.mdl",
			Start = Vector( -542, 584, 500 ),
			Target = Vector( -543, 554, 501 ),
			Angle = Angle( 0, 5, 0 ),
			Scale = 0.05,
			Speed = 0.5,
		},
		{
			Model = "models/slyfo/rex1peice.mdl",
			Start = Vector( -216, 470, 358 ),
			Target = Vector( -432, 459, 358 ),
			Angle = Angle( 0, 185, 0 ),
			Scale = 0.05,
			Speed = 1,
		},
	}

	local scale = 0.02

	hook.Add( "PostDrawTranslucentRenderables", HOOK_PREFIX .. "FromPlanetAnim_PostDrawTranslucentRenderables", function()
		if ( LocalPlayer():GetStateName() != STATE_FROM_PLANET_ANIM ) then return end

		-- Clear
		render.Clear( 0, 0, 0, 255 )
		render.ClearDepth()

		-- Render planet
		RenderScene( PLANET_MODELS, Vector( -342, 407, 348 ) )

		-- Render other shuttles
		if ( LocalPlayer().CurrentAnimation ) then
			local progress = LocalPlayer().CurrentAnimation.CurrentProgress or 1
			for k, shuttle in pairs( SHUTTLES ) do
				GAMEMODE.RenderCachedModel(
					shuttle.Model,
					LerpVector( progress * shuttle.Speed, shuttle.Start, shuttle.Target ),
					shuttle.Angle,
					Vector( 1, 1, 1 ) * shuttle.Scale
				)
			end
		end

		-- Render ship
		if ( PLANET_MODELS[RESERVED_PLAYER] ) then
			local ShipPos = PLANET_MODELS[RESERVED_PLAYER][2]
			local ship = Ship.GetShip()
			if ( ship ) then
				ship:Render3D( ShipPos, 180, scale )
			end
		end
	end )

	hook.Add( "CalcView", HOOK_PREFIX .. "FromPlanetAnim_CalcView", function( ply, pos, angles, fov )
		if ( LocalPlayer():GetStateName() == STATE_FROM_PLANET_ANIM ) then
			return GetSceneCalcView( PLANET_MODELS, ply, pos, ang, fov )
		end
	end )
end