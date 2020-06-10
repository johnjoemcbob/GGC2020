--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Planetside
--

STATE_PLANET = "PLANET"

local MODEL_ROOM = "models/cerus/modbridge/core/sc-332.mdl"
local ROOM_PROPS = {}
local RoomPos = Vector( -320, 520, 355 )
local RoomAngles = Angle( 0, -90, 0 )
local CameraPos = RoomPos + Vector( 3 / 2, 3 / 2, 2 ) * SHIPPART_SIZE * 0.7
local CameraAngles = Angle( 40, -130, 0 )
local CameraFOV = 50
local PlayerSize = 80
local PlayerPos = RoomPos
local TargetPos = PlayerPos
local Speed = 50
local LastLeft = true

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

if ( CLIENT ) then
    hook.Add( "PostDrawTranslucentRenderables", HOOK_PREFIX .. "Planet_PostDrawTranslucentRenderables", function()
        if ( LocalPlayer():GetStateName() != STATE_PLANET ) then return end

        -- Clear
        --render.Clear( 0, 0, 0, 255 )
        --render.ClearDepth()

        -- Render Room
        GAMEMODE.RenderCachedModel(
            MODEL_ROOM,
            RoomPos,
            RoomAngles,
            Vector( 1, 1, 1 )
        )

        -- Render details
        for k, detail in pairs( ROOM_PROPS ) do
            local scale = detail[4] or Vector( 1, 1, 1 )
            GAMEMODE.RenderCachedModel(
                detail[1],
                RoomPos + detail[2],
                detail[3],
                scale
            )
        end

        -- Test interaction
        if ( input.IsMouseDown( MOUSE_LEFT ) or PlayerPos == RoomPos ) then
            local halfscreen = Vector( ScrW() / 2, ScrH() / 2 )
            local aspect = 1 + ( ScrH() / ScrW() ) / 2
            local mouseoff = ( Vector( gui.MouseX(), gui.MouseY() ) - halfscreen ) * aspect
                mouseoff = mouseoff + halfscreen
            local ray = {
                position = CameraPos,
                direction = util.AimVector( CameraAngles, CameraFOV, mouseoff.x, mouseoff.y, ScrW(), ScrH() ),
            }
            local plane = {
                position = RoomPos + Vector( 0, 0, 1 ) * -SHIPPART_SIZE * 0.4,
                normal = Vector( 0, 0, 1 ),
            }
            local pos = intersect_ray_plane( ray, plane )
            if ( pos ) then
                TargetPos = pos
            end
            if ( PlayerPos == RoomPos ) then
                PlayerPos = pos
            end
        end

        -- Movement
        PlayerPos = ApproachVector( FrameTime() * Speed, PlayerPos, TargetPos )

        -- Render self
        local mat = MAT_PLAYER
        local anim = "idle"
            if ( PlayerPos != TargetPos ) then
                anim = "run"

                if ( PlayerPos:ToScreen().x < TargetPos:ToScreen().x ) then
                    LastLeft = false
                else
                    LastLeft = true
                end
            end
        local data = GetAnimation( mat, anim )
        local frame = math.floor( CurTime() * ( data.Speed ) % #data + 1 )
        local left = LastLeft
        local u1, v1, u2, v2 = GetUVs( mat, anim, frame )
        GAMEMODE:DrawBillboardedUVs( PlayerPos + Vector( 0, 0, -PlayerSize ) * 0.92, Vector( 0.6, 1 ) * PlayerSize, mat, u1, v1, u2, v2, left )
    end )

    hook.Add( "CalcView", HOOK_PREFIX .. "Planet_CalcView", function( ply, pos, angles, fov )
        if ( LocalPlayer():GetStateName() == STATE_PLANET ) then
            local pos = CameraPos
            local ang = CameraAngles

            local view = {}
                view.origin = pos
                view.angles = ang
                view.fov = CameraFOV
                -- view.zfar = 1000

                LocalPlayer().CalcViewAngles = Angle( view.angles.p, view.angles.y + 90, view.angles.r )
            return view
        end
    end )
    
    hook.Add( "HUDPaint", HOOK_PREFIX .. "Planet_HUDPaint", function()
        if ( LocalPlayer():GetStateName() == STATE_PLANET ) then
            --draw.RoundedBox( 0, testpos.x, testpos.y, 1, 1, COLOUR_WHITE )
        end
	end )
end

ROOM_PROPS = {
	{
		"models/cerus/modbridge/misc/accessories/acc_radar1.mdl",
		Vector( -210, -5, 52 ),
		Angle( 46, 90, 90 ),
	},
	{
		"models/cerus/modbridge/misc/engines/eng_sq11b.mdl",
		Vector( 0, -210, 128 ),
		Angle( 90, -90, 180 ),
	},
	{
		"models/slyfo_2/acc_billboard_spcmx.mdl",
		Vector( -96, -85, 55 ),
        Angle( 5, 57, -1 ),
        Vector( 1, 1, 1 ) * 0.5,
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( -179, 37, -60 ),
		Angle( 0, 44, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( -161, 104, -60 ),
		Angle( 0, -60, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( 182, -92, -60 ),
		Angle( 0, 130, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( 184, -33, -60 ),
		Angle( 0, -128, 0 ),
	},
	{
		"models/slyfo/sword_overengine.mdl",
		Vector( 1, -108, -43 ),
		Angle( 0, -180, 0 ),
	},
	{
		"models/props_junk/glassbottle01a.mdl",
		Vector( 43, -110, -19 ),
		Angle( 0, 114, 0 ),
	},
	{
		"models/props_junk/garbage_glassbottle003a.mdl",
		Vector( 37, -101, -18 ),
		Angle( 0, 113, 0 ),
	},
	{
		"models/props_junk/glassjug01.mdl",
		Vector( 35, -108, -26 ),
		Angle( 0, 107, 0 ),
	},
	{
		"models/props_junk/garbage_carboard002a.mdl",
		Vector( -14, -107, -26 ),
		Angle( 0, 81, 0 ),
	},
	{
		"models/props_c17/furnituretable001a.mdl",
		Vector( 166, -68, -42 ),
		Angle( 0, 134, 0 ),
	},
	{
		"models/props_c17/furnituretable001a.mdl",
		Vector( -153, 66, -42 ),
		Angle( 0, 1, 0 ),
	},
	{
		"models/props_c17/furnituretable001a.mdl",
		Vector( 123, 82, -42 ),
		Angle( 0, 135, 0 ),
	},
	{
		"models/props_c17/furnituretable001a.mdl",
		Vector( -30, 96, -42 ),
		Angle( 0, 45, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( -54, 53, -60 ),
		Angle( 0, 59, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( 1, 115, -60 ),
		Angle( 0, -138, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( 102, 43, -60 ),
		Angle( 0, 67, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( 160, 107, -60 ),
		Angle( 0, -155, 0 ),
	},
	{
		"models/smallbridge/vehicles/sbvpchair.mdl",
		Vector( 93, 115, -60 ),
		Angle( 0, -60, 0 ),
	},
}
