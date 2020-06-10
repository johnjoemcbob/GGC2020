--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Animate Planet-to-Space
--

STATE_FROM_PLANET_ANIM = "FROMPLANETANIM"

DURATION = 1

GM.AddPlayerState( STATE_FROM_PLANET_ANIM, {
    OnStart = function( self, ply )
        ply:HideFPSController()
        ply.CurrentTime = 0
    end,
    OnThink = function( self, ply )
        if ( CLIENT ) then
            if ( ply.CurrentTime >= DURATION ) then
                ply:SwitchState( STATE_FPS )
                return
            end
        end
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

    local start = Vector( -355, 400, 355 )
    local target = Vector( -442, 507, 448 )
    local startfov = 30
    local targetfov = 75

    local scale = 0.02

    local time = 0
    local ShipPos = Vector( 0, 0, 0 )
    local ShipFOV = startfov

    hook.Add( "PostDrawTranslucentRenderables", HOOK_PREFIX .. "FromPlanetAnim_PostDrawTranslucentRenderables", function()
        if ( LocalPlayer():GetStateName() != STATE_FROM_PLANET_ANIM ) then return end

        -- Clear
        render.Clear( 0, 0, 0, 255 )
        render.ClearDepth()

        -- Render planet
        local basepos = Vector( -342, 407, 348 )
            basepos = basepos + PLANET_MODELS[1][2]
        local baseang = PLANET_MODELS[1][3]
        for k, ent in pairs( PLANET_MODELS ) do
            local col = ent.Colour
                if ( col == nil ) then
                    col = COLOUR_BASE
                end
            local scale = Vector( 1, 1, 1 )
                if ( ent.Scale != nil ) then
                    scale = ent.Scale
                end
            GAMEMODE.RenderCachedModel(
                ent[1],
                basepos + ent[2],
                ent[3],
                scale,
                ent.Material,
                col
            )
        end

        -- Move ship
        local ft = FrameTime()
            ft = 0.016 / DURATION / 2
        LocalPlayer().CurrentTime = LocalPlayer().CurrentTime + ft

        local progress = math.max( 0, LocalPlayer().CurrentTime - 0.1 )
        ShipPos = LerpVector( progress, start, target )
        ShipFOV = Lerp( progress, startfov, targetfov )

        -- Render other shuttles
        for k, shuttle in pairs( SHUTTLES ) do
            GAMEMODE.RenderCachedModel(
                shuttle.Model,
                LerpVector( progress * shuttle.Speed, shuttle.Start, shuttle.Target ),
                shuttle.Angle,
                Vector( 1, 1, 1 ) * shuttle.Scale
            )
        end

        -- Render ship
        -- TODO separate into rendership function
        local ship = Ship.GetShip()
        if ( ship and ship.Constructor ) then
            for _, data in pairs( ship.Constructor ) do
                local part = SHIPPARTS[data.Name]
                local localpos = ShipPos + data.Grid * SHIPPART_SIZE * scale
                GAMEMODE.RenderCachedModel(
                    part[1],
                    localpos,
                    Angle( 0, ship:Get2DRotation() + 90 * data.Rotation, 0 ),
                    Vector( 1, 1, 1 ) * scale
                )
            end
        end
    end )

    hook.Add( "CalcView", HOOK_PREFIX .. "FromPlanetAnim_CalcView", function( ply, pos, angles, fov )
        if ( LocalPlayer():GetStateName() == STATE_FROM_PLANET_ANIM ) then
            local pos = Vector( -320, 520, 355 )
            local ang = ( ShipPos - pos ):GetNormalized():Angle()

            local view = {}
                view.origin = pos
                view.angles = ang
                view.fov = ShipFOV
                -- view.zfar = 1000

                LocalPlayer().CalcViewAngles = Angle( ang.p, ang.y, ang.r )
            return view
        end
    end )
end