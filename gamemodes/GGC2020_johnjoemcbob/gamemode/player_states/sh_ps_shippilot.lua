--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Piloting Ship
--

STATE_SHIP_PILOT = "SHIPPILOT"

GM.AddPlayerState( STATE_SHIP_PILOT, {
	OnStart = function( self, ply )
		
	end,
	OnThink = function( self, ply )
		if ( SERVER ) then
			if ( !ply:InVehicle() ) then
				ply:SwitchState( STATE_FPS )
			end

			if ( ply:KeyDown( IN_WALK ) ) then
				ply:SwitchState( STATE_TO_PLANET_ANIM )
			end
		end
	end,
	OnFinish = function( self, ply )
		
	end,
})

if ( CLIENT ) then
	hook.Add( "CalcView", HOOK_PREFIX .. "ShipPilot_CalcView", function( ply, pos, ang, fov )
		if ( LocalPlayer():GetStateName() == STATE_SHIP_PILOT ) then
			local view = {}
				view.origin = pos
				view.angles = Angle( 0, 90, 0 )
				view.fov = fov
				-- view.zfar = 1000

				LocalPlayer().CalcViewAngles = Angle( view.angles.p, view.angles.y, view.angles.r )
			return view
		end
	end )
end
