--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- State: Planetside
--

-- TODO binoculars and sharpen for cctv look

STATE_PLANET = "PLANET"

MAT_BARTENDER = Material( "bartender.png", "nocull 1 smooth 0" )
local MODEL_ROOM = "models/cerus/modbridge/core/sc-332.mdl"
local ROOM_PROPS = {}
local RoomPos = Vector( -320, 520, 355 )
local RoomAngles = Angle( 0, -90, 0 )
local CameraFOV = 50
local PlayerSize = 80
local PlayerPos = Vector( 0, 0, 0 )
local TargetPos = Vector( 0, 0, 0 )
local Speed = 100
local LastLeft = true
local IntroSpeed = 0.2

local BoundsMultiplier = 1.2

-- TEMP
-- if ( CLIENT ) then
-- 	ROOM_PROPS = LoadScene( "spacebar_base" )
-- 	PlaySceneAnimation( ROOM_PROPS, "spacebar_base" )
-- end

GM.AddPlayerState( STATE_PLANET, {
	OnStart = function( self, ply )
		ply:HideFPSController()
		if ( CLIENT ) then
			gui.EnableScreenClicker( true )

			PlayerPos = Vector( 0, 0, 0 )
			TargetPos = Vector( 0, 0, 0 )

			ROOM_PROPS = LoadScene( "spacebar_base" )
			PlaySceneAnimation( ROOM_PROPS, "spacebar_base" )
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
	local Collisions = nil
	function DoesCollide( pos )
		for k, collide in pairs( Collisions ) do
			if ( intersect_point_rotated_rect( pos, collide, collide.angle ) ) then
				return true
			end
		end
		return false
	end

	function TestPathTo( pos )
		--PlayerPos = 

		-- From current pos
		-- To target pos
		-- Direction
		-- Break into path segments
		-- Check for collision at each stage, store last valid otherwise
		local dir = ( pos - PlayerPos ):GetNormalized()
		local segdist = 10
		local segs = math.ceil( ( pos - PlayerPos ):Length() / segdist )
		local lastvalid = PlayerPos
			for seg = 1, segs do
				local trypos = PlayerPos + dir * seg * segdist
					if ( seg == segs ) then
						trypos = pos
					end
					--debugoverlay.Cross( trypos, 10, 1, Color( 255, 255, 0, 255 ), false )
				if ( DoesCollide( trypos ) ) then
					break
				end
				lastvalid = trypos
			end
		return lastvalid
	end

	hook.Add( "PreDrawEffects", HOOK_PREFIX .. "Planet_PreDrawEffects", function()
		if ( LocalPlayer():GetStateName() != STATE_PLANET ) then return end

		-- Clear
		render.Clear( 0, 0, 0, 255 )
		render.ClearDepth()

		-- Render Room
		GAMEMODE.RenderCachedModel(
			MODEL_ROOM,
			RoomPos,
			RoomAngles,
			Vector( 1, 1, 1 )
		)

		-- Render details
		local storecollisions = false
		if ( !Collisions ) then
			-- Initial collisions
			Collisions = {}
				-- One for each room edge
				local mult = 0.9
				local dirs = {
					Vector( 1, 0 ),
					Vector( -1, 0 ),
					--Vector( 0, 1 ),
					Vector( 0, -1 ),
				}
				for k, dir in pairs( dirs ) do
					local z = -0.15
					local min = Vector( dir.x * mult - 0.5, dir.y * mult - 0.5, z )
					local max = Vector( dir.x * mult - 0.5 + 1, dir.y * mult - 0.5 + 1, z )
					table.insert( Collisions, {
						min = RoomPos + min * 3 * SHIPPART_SIZE,
						max = RoomPos + max * 3 * SHIPPART_SIZE,
						angle = 0
					} )
				end
			storecollisions = true
		end

		-- Render and generate collisions if needed
		local ret = RenderScene( ROOM_PROPS, RoomPos, storecollisions, Collisions, BoundsMultiplier )
		if ( ret ) then
			Collisions = ret
		end

		-- Debug render collisions
		-- for k, collide in pairs( Collisions ) do
		--	 collide.max.z = collide.min.z + 1
		--	 cam.IgnoreZ( true )
		--		 render.DrawBox( Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), collide.min, collide.max, Color( 255, 255, 0, 255 ) )
		--	 cam.IgnoreZ( false )
		-- end

		-- Test interaction
		if ( !LocalPlayer().CurrentAnimation ) then
			if ( input.IsMouseDown( MOUSE_LEFT ) ) then
				local halfscreen = Vector( ScrW() / 2, ScrH() / 2 )
				local aspect = 1 + ( ScrH() / ScrW() ) / 2
				local mouseoff = ( Vector( gui.MouseX(), gui.MouseY() ) - halfscreen ) * aspect
					mouseoff = mouseoff + halfscreen
				local ray = {
					position = ROOM_PROPS[RESERVED_CAMERA][2],
					direction = util.AimVector( ROOM_PROPS[RESERVED_CAMERA][3], CameraFOV, mouseoff.x, mouseoff.y, ScrW(), ScrH() ),
				}
				local plane = {
					position = RoomPos + Vector( 0, 0, 1 ) * -SHIPPART_SIZE * 0.4,
					normal = Vector( 0, 0, 1 ),
				}
				local pos = intersect_ray_plane( ray, plane )
				if ( pos ) then
					--if ( !DoesCollide( pos ) ) then
					TargetPos = TestPathTo( pos )
					--end
				end
			end

			-- Exit zone
			if ( PlayerPos == TargetPos ) then
				local dist = TargetPos:Distance( Vector( -424, 653, 295 ) )
				--print( GetPrettyVector( PlayerPos ) )
				if ( dist < 15 ) then
					LocalPlayer():SwitchState( STATE_FROM_PLANET_ANIM )
				end
			end
		elseif ( ROOM_PROPS[RESERVED_PLAYER] ) then
			TargetPos = ROOM_PROPS[RESERVED_PLAYER][2]
			--PlayerPos = TargetPos
			if ( PlayerPos == Vector( 0, 0, 0 ) ) then
				PlayerPos = TargetPos
			end
		end

		-- Movement
		PlayerPos = ApproachVector( FrameTime() * Speed, PlayerPos, TargetPos )

		-- Render Bartender
		local pos = Vector( -324, 379, 225 )
		GAMEMODE:DrawBillboardedUVs( 
			pos,
			0,
			Vector( 0.6, 1 ) * PlayerSize,
			MAT_BARTENDER,
			0, 0, 1, 1,
			false
		)
	
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
		GAMEMODE:DrawBillboardedUVs(
			PlayerPos + Vector( 0, 0, -PlayerSize ) * 0.92,
			0,
			Vector( 0.6, 1 ) * PlayerSize,
			mat,
			u1, v1, u2, v2,
			!left
		)
	end )

	hook.Add( "CalcView", HOOK_PREFIX .. "Planet_CalcView", function( ply, pos, ang, fov )
		if ( LocalPlayer():GetStateName() == STATE_PLANET ) then
			return GetSceneCalcView( ROOM_PROPS, ply, pos, ang, CameraFOV )
		end
	end )

	hook.Add( "HUDPaint", HOOK_PREFIX .. "Planet_HUDPaint", function()
		if ( LocalPlayer():GetStateName() == STATE_PLANET ) then
			--draw.RoundedBox( 0, testpos.x, testpos.y, 1, 1, COLOUR_WHITE )
		end
	end )
 
	local border = 320
	local mat = Material( "dev/dev_prisontvoverlay001" )
	hook.Add( "RenderScreenspaceEffects", HOOK_PREFIX .. "Planet_RenderScreenspaceEffects", function()
		if ( LocalPlayer():GetStateName() == STATE_PLANET ) then
			DrawMaterialOverlay( "effects/combine_binocoverlay", -0.02 )
			--DrawMaterialOverlay( "dev/dev_prisontvoverlay001", -0.02 )
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( mat )
				surface.DrawTexturedRect( -border, -border, ScrW() + border * 2, ScrH() + border * 2 )
			DrawSharpen( 20, -0.09 )
		end
	end )
end
