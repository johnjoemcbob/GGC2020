--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Just joined the server
--

STATE_JOINED = "Joined"

GM.AddPlayerState( STATE_JOINED, {
    OnStart = function( self, ply )
        print( "start!" )
    end,
    OnThink = function( self, ply )
        
    end,
    OnFinish = function( self, ply )
        print( "finish!" )
    end,
})
