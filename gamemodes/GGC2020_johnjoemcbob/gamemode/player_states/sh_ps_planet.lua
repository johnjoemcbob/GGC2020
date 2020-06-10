--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Planetside
--

STATE_PLANET = "PLANET"

local ROOM = "models/cerus/modbridge/core/sc-332.mdl"

GM.AddPlayerState( STATE_PLANET, {
    OnStart = function( self, ply )
        ply:HideFPSController()
        if ( CLIENT ) then
            gui.EnableScreenClicker( true )
        end
    end,
    OnThink = function( self, ply )
        
    end,
    OnFinish = function( self, ply )
        ply:ShowFPSController()
        if ( CLIENT ) then
            gui.EnableScreenClicker( false )
        end
    end,
})
