--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Animate Planet-to-Space
--

STATE_FROM_PLANET_ANIM = "FROMPLANETANIM"

DURATION = 3

GM.AddPlayerState( STATE_FROM_PLANET_ANIM, {
    OnStart = function( self, ply )
        ply:HideFPSController()
        ply.CurrentStateEnd = CurTime() + DURATION
    end,
    OnThink = function( self, ply )
        if ( SERVER ) then
            if ( ply.CurrentStateEnd <= CurTime() ) then
                ply:SwitchState( STATE_PLANET )
                return
            end
        end
    end,
    OnFinish = function( self, ply )
        ply:ShowFPSController()
    end,
})
