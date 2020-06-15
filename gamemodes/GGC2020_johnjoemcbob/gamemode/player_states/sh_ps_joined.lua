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

if ( CLIENT ) then
	SCENE_TEST = LoadScene( "jumppoint_base" )
	PlaySceneAnimation( SCENE_TEST, "jumppoint_in" )
 
	RT_Scene_Camera = GetRenderTarget( "RT_Scene_Camera", ScrW(), ScrH() )
	Material_RT_Scene = CreateMaterial( "RT_Scene_Camera_Mat", "UnlitGeneric", {
		["$basetexture"] = RT_Scene_Camera:GetName(),
		["$vertexcolor"] = 1
	} )

	local scenepos = Vector( -105, -35, -11834 )
	hook.Add( "PreDrawOpaqueRenderables", HOOK_PREFIX .. "Joined_PreDrawOpaqueRenderables", function()
		if ( LocalPlayer():GetStateName() == STATE_JOINED ) then
			if ( !SCENE_TEST ) then
				SCENE_TEST = LoadScene( "jumppoint_base" )
			end
			if ( !LocalPlayer().CurrentAnimation ) then
				PlaySceneAnimation( SCENE_TEST, "jumppoint_in" )
			end
			RenderScene( SCENE_TEST, scenepos )

			-- Render camera
			if ( SCENE_TEST[RESERVED_CAMERA] ) then
				local ent = GAMEMODE.RenderCachedModel(
					"models/editor/camera.mdl",
					scenepos + SCENE_TEST[RESERVED_CAMERA][2] - SCENE_TEST[RESERVED_CAMERA][3]:Forward() * 15,
					SCENE_TEST[RESERVED_CAMERA][3],
					Vector( 1, 1, 1 )
				)
			end

			-- Render ship
			local scale = 0.02
			if ( SCENE_TEST[RESERVED_PLAYER] ) then
				local ShipPos = scenepos + SCENE_TEST[RESERVED_PLAYER][2]
				local ship = Ship.GetShip()
				if ( ship ) then
					ship:Render3D( ShipPos, 180, scale )
				end
			end
		end
	end )

	hook.Add( "HUDPaint", HOOK_PREFIX .. "Joined_HUDPaint", function()
		if ( LocalPlayer():GetStateName() == STATE_JOINED ) then
			if ( SCENE_TEST[RESERVED_CAMERA] ) then
				render.PushRenderTarget( RT_Scene_Camera )
					local w, h = ScrW() / 8, ScrW() / 8
					-- Draw background
					cam.Start2D()
						surface.SetDrawColor( 0, 0, 0, 255 )
						surface.DrawRect( 0, 0, ScrW(), ScrH() )
					cam.End2D()

					-- Draw this player's view
					render.RenderView( {
						origin = scenepos + SCENE_TEST[RESERVED_CAMERA][2],
						angles = SCENE_TEST[RESERVED_CAMERA][3],
						x = 0, y = 0,
						w = ScrW(), h = ScrH(),
						fov = SCENE_TEST[RESERVED_CAMERA].FOV or 75,
						drawviewmodel = false,
					} )
				render.PopRenderTarget()

				local w = ScrW() / 4
				local h = w
				local x = ScrW() - w
				local y = 0
				surface.SetDrawColor( COLOUR_WHITE )
				surface.SetMaterial( Material_RT_Scene )
				surface.DrawTexturedRect( x, y, w, h )

				if ( LocalPlayer().CurrentAnimation ) then
					draw.SimpleText( LocalPlayer().CurrentAnimation.CurrentProgress, "DermaLarge", x, y + h, COLOUR_WHITE )
				end
			end
		end
	end )
end
