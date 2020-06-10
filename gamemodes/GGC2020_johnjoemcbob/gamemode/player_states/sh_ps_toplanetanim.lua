--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Animate Space-to-Planet
--

STATE_TO_PLANET_ANIM = "TOPLANETANIM"

DURATION = 3

GM.AddPlayerState( STATE_TO_PLANET_ANIM, {
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

if ( CLIENT ) then
    local tab = {
        {
            "models/props_combine/combine_mortar01b.mdl",
            Vector( 0, 0, 0 ),
            Angle( 0, 135, 0 ),
        },
        {
            "models/props_canal/refinery_02_skybox.mdl",
            Vector( 232, -94, 2 ),
            Angle( 0, 179, 0 ),
        },
        {
            "models/props_canal/refinery_02_skybox.mdl",
            Vector( -22, -406, 9 ),
            Angle( 0, 90, 0 ),
        },
        {
            "models/props_buildings/project_building03_skybox.mdl",
            Vector( 134, -125, -1 ),
            Angle( 0, -116, 0 ),
        },
        {
            "models/props_buildings/project_building03_skybox.mdl",
            Vector( 136, -119, 82 ),
            Angle( 0, -136, 0 ),
        },
        {
            "models/props_canal/refinery_03_skybox.mdl",
            Vector( 51, -55, 2 ),
            Angle( 0, 135, 0 ),
        },
        {
            "models/props_canal/refinery_02_skybox.mdl",
            Vector( 153, -278, 12 ),
            Angle( 0, 135, 0 ),
        },
        {
            "models/props_combine/combine_emitter01.mdl",
            Vector( 102, -40, 30 ),
            Angle( 90, -45, 180 ),
        },
        {
            "models/combine_apc_destroyed_gib05.mdl",
            Vector( 183, -132, -15 ),
            Angle( 86, -136, 129 ),
        },
        {
            "models/props_combine/combinecamera001.mdl",
            Vector( -27, -35, 20 ),
            Angle( 0, -2, 0 ),
        },
        {
            "models/props_combine/combine_dispenser.mdl",
            Vector( -2, -111, 38 ),
            Angle( 0, 66, 0 ),
        },
        {
            "models/props_combine/combine_smallmonitor001.mdl",
            Vector( -108, -38, 21 ),
            Angle( 0, 135, 0 ),
        },
        {
            "models/props_buildings/project_building01_skybox.mdl",
            Vector( 31, -242, -1 ),
            Angle( 0, 180, 0 ),
        },
        {
            "models/props_buildings/project_building03_skybox.mdl",
            Vector( 290, -87, -1 ),
            Angle( 0, -179, 0 ),
        },
        {
            "models/props_canal/refinery_02_skybox.mdl",
            Vector( -182, -68, 13 ),
            Angle( 0, 0, 0 ),
        },
        {
            "models/props_combine/breenlight.mdl",
            Vector( -23, -55, 95 ),
            Angle( 0, 92, 0 ),
        },
        {
            "models/combine_helicopter/bomb_debris_3.mdl",
            Vector( -86, -49, 17 ),
            Angle( 78, -4, -82 ),
        },
        {
            "models/combine_helicopter/bomb_debris_2.mdl",
            Vector( 126, -18, 13 ),
            Angle( 0, -171, -90 ),
        },
        {
            "models/props_combine/combine_mortar01a.mdl",
            Vector( -69, -133, -4 ),
            Angle( 0, 45, 0 ),
        },
        {
            "models/props_buildings/project_building03_skybox.mdl",
            Vector( -124, -235, -1 ),
            Angle( 0, 92, 0 ),
        },
        {
            "models/combine_apc_destroyed_gib04.mdl",
            Vector( -49, -193, 88 ),
            Angle( 16, -128, -175 ),
        },
        {
            "models/props_combine/combine_generator01.mdl",
            Vector( 87, -170, 89 ),
            Angle( 0, 90, 0 ),
        },
        {
            "models/props_combine/combinecamera001.mdl",
            Vector( -30, -42, 2 ),
            Angle( 0, 173, 90 ),
        },
        {
            "models/props_buildings/project_destroyedbuildings04_skybox.mdl",
            Vector( -42, -210, 2 ),
            Angle( 0, 124, 0 ),
        },
        {
            "models/props_buildings/project_destroyedbuildings03_skybox.mdl",
            Vector( 293, -88, 83 ),
            Angle( 1, -177, 1 ),
        },
        {
            "models/props_canal/refinery_05_skybox.mdl",
            Vector( -72, -95, 2 ),
            Angle( 0, 60, 0 ),
        },
        {
            "models/effects/splodeglass.mdl",
            Vector( 100, -400, 200 ),
            Angle( 0, 0, 0 ),
        },
        {
            "models/effects/splodeglass.mdl",
            Vector( -400, 0, 300 ),
            Angle( 0, 0, 0 ),
        },
        {
            "models/perftest/rocksground01b.mdl",
            Vector( 0, 50, 0 ),
            Angle( 0, 90, 0 ),
            Material = "models/props_pipes/GutterMetal01a",
        },
        {
            "models/perftest/rocksground01b.mdl",
            Vector( -130, 70, 0 ),
            Angle( 0, 70, 0 ),
            Scale = Vector( 1, 1, 1 ) * 5,
            Material = "models/props_pipes/GutterMetal01a",
        },
        {
            "models/perftest/rocksground01b.mdl",
            Vector( -130, 100, 0 ),
            Angle( 0, 0, 0 ),
            Scale = Vector( 1, 1, 1 ) * 15,
            Material = "models/props_pipes/GutterMetal01a",
        },
        {
            "models/perftest/rocksground01b.mdl",
            Vector( -130, 100, 0 ),
            Angle( 0, 0, 0 ),
            Scale = Vector( 1, 1, 1 ) * 3,
            Material = "models/props_pipes/GutterMetal01a",
        },
        {
            "models/props_phx/construct/metal_dome360.mdl",
            Vector( 0, -200, -475 ),
            Angle( 0, 0, 0 ),
            Scale = Vector( 30, 30, 10 ),
            Material = "models/props_pipes/GutterMetal01a",
            Colour = Color( 80, 40, 40, 255 ),
        },
    }
    COLOUR_BASE = Color( 100, 100, 100, 255 )

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

    local start = Vector( -442, 507, 448 )
    local target = Vector( -355, 400, 355 )
    local startfov = 75
    local targetfov = 30

    local speed = 1 / DURATION / 3
    local scale = 0.02

    local time = 0
    local ShipPos = Vector( 0, 0, 0 )
    local ShipFOV = 75

    hook.Add( "PostDrawTranslucentRenderables", HOOK_PREFIX .. "ToPlanetAnim_PostDrawTranslucentRenderables", function()
        if ( LocalPlayer():GetStateName() != STATE_TO_PLANET_ANIM ) then return end

        -- Clear
        render.Clear( 0, 0, 0, 255 )
        render.ClearDepth()

        -- Render planet
        local basepos = Vector( -342, 407, 348 )
            basepos = basepos + tab[1][2]
        local baseang = tab[1][3]
        for k, ent in pairs( tab ) do
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
        ft = 0.016
        
        time = time + ft * speed
            if ( time > 1 ) then
                time = 0
            end
            -- time = 0.6
        local progress = math.min( 1, time + 0.1 )
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

    hook.Add( "CalcView", HOOK_PREFIX .. "ToPlanetAnim_CalcView", function( ply, pos, angles, fov )
        if ( LocalPlayer():GetStateName() == STATE_TO_PLANET_ANIM ) then
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
