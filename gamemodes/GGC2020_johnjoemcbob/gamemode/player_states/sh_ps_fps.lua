--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: First Person (own ship or boarding)
--

STATE_FPS = "FPS"

GM.AddPlayerState( STATE_FPS, {
	OnStart = function( self, ply )
		
	end,
	OnThink = function( self, ply )
		if ( SERVER ) then
			if ( ply:InVehicle() ) then
				ply:SwitchState( STATE_SHIP_PILOT )
			end
		end
	end,
	OnFinish = function( self, ply )

	end,
})

if ( CLIENT ) then
	hook.Add( "PreDrawOpaqueRenderables", HOOK_PREFIX .. "FPS_PreDrawOpaqueRenderables", function()
		if ( LocalPlayer():GetStateName() == STATE_FPS ) then
			render.Clear( 0, 0, 0, 255 )
			render.ClearDepth()
		end
	end )
	hook.Add( "CalcView", HOOK_PREFIX .. "FPS_CalcView", function( ply, pos, ang, fov )
		if ( LocalPlayer():GetStateName() == STATE_FPS ) then
			local view = {}
				view.origin = pos
				view.angles = ang
				view.fov = fov
				view.zfar = 1000

				LocalPlayer().CalcViewAngles = nil
			return view
		end
	end )
end
