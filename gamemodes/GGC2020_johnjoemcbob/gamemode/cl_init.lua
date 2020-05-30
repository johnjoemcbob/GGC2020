--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Clientside
--

include( "shared.lua" )

include( "cl_modelcache.lua" )
include( "cl_shipeditor.lua" )

local MAT_PLAYER = Material( "playersheet.png", "smooth" )
local MAT_PLAYER_WIDTH = 643
local MAT_PLAYER_HEIGHT = 831
local PLAYER_WIDTH = 40
local PLAYER_HEIGHT = 74
local PLAYER_UV_WIDTH = 41
local PLAYER_UV_HEIGHT = 74

local ANIMS = {}
ANIMS[MAT_PLAYER] = {}
local x = 28
local y = 94
local w = PLAYER_UV_HEIGHT - 2
ANIMS[MAT_PLAYER]["idle"] = {
	Speed = 5,
	Vector( x + w * 0, y ),
	Vector( x + w * 1, y ),
	Vector( x + w * 2, y ),
	Vector( x + w * 1, y ),
}
local x = 32
local y = y + PLAYER_UV_HEIGHT + 4
local w = PLAYER_UV_HEIGHT + 4
ANIMS[MAT_PLAYER]["run"] = {
	Speed = 5,
	Vector( x + w * 0, y ),
	Vector( x + w * 1, y ),
	Vector( x + w * 2, y ),
	Vector( x + w * 3, y ),
	-- Vector( 17 + PLAYER_UV_SIZE * 4, y ),
}
local w = 0--16
ANIMS[MAT_PLAYER]["jump"] = {
	Speed = 1,
	Vector( 22 - w, 497 ),
	Vector( 81 - w, 484 ),
	Vector( 142 - w, 475 ),
	Vector( 196 - w, 467 ),
	Vector( 245 - w, 468 ),
}

------------------------
  -- Gamemode Hooks --
------------------------
function GM:Initialize()
	
end

function GM:Think()
	
end

function GM:PreRender()
	render.SetLightingMode( 0 ) -- 1 )
end

function GM:PrePlayerDraw( ply )
	local pos = ply:GetPos()
	local ang = LocalPlayer():GetAngles()
		ang.p = 0
		ang.r = 0
		ang:RotateAroundAxis( ang:Right(), 90 )
		ang:RotateAroundAxis( ang:Up(), -90 )
	cam.Start3D2D( pos, ang, 1 )
		local frame = 1
		local anim = "idle"
			if ( !ply:IsOnGround() ) then
				anim = "jump"

				local frames = #ANIMS[MAT_PLAYER][anim]
				local tr = util.TraceLine( {
					start = ply:GetPos(),
					endpos = ply:GetPos() - Vector( 0, 0, 10000 ),
					filter = ply
				} )
				local dist = math.floor( math.Clamp( ply:GetPos():Distance( tr.HitPos ) / 10, 0, frames - 1 ) )
				frame = dist + 1

				-- Animate wobble a little at height of jump
				if ( frame == frames ) then
					frame = math.floor( CurTime() * ANIMS[MAT_PLAYER][anim].Speed % 2 ) + frames - 1
				end
			elseif ( ply:GetVelocity():LengthSqr() > 10 ) then
				anim = "run"
			end
			if ( anim != "jump" ) then
				frame = math.floor( CurTime() * ( ANIMS[MAT_PLAYER][anim].Speed ) % #ANIMS[MAT_PLAYER][anim] + 1 )
			end
			-- local anim = "jump"
		DrawWithUVs( -PLAYER_WIDTH / 2, -PLAYER_HEIGHT, PLAYER_WIDTH, PLAYER_HEIGHT, MAT_PLAYER, anim, frame )
	cam.End3D2D()

	return true
end

function GM:HUDPaint()
	render.SetLightingMode( 0 )
end
-------------------------
  -- /Gamemode Hooks --
-------------------------

-- UV anims
function DrawWithUVs( x, y, w, h, mat, anim, frame )
	-- 17 / 643, 94 / 831, ( 17 + 68 ) / 643, ( 94 + 68 ) / 831
	local uvs = ANIMS[mat][anim][frame]
	local u1 = uvs.x / MAT_PLAYER_WIDTH
	local v1 = uvs.y / MAT_PLAYER_HEIGHT
	local u2 = ( uvs.x + PLAYER_UV_WIDTH ) / MAT_PLAYER_WIDTH
	local v2 = ( uvs.y + PLAYER_UV_HEIGHT ) / MAT_PLAYER_HEIGHT

	surface.SetDrawColor( COLOUR_WHITE )
	surface.SetMaterial( mat )
	surface.DrawTexturedRectUV( x, y, w, h, u1, v1, u2, v2 )
end
