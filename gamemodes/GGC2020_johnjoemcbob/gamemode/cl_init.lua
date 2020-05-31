--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Clientside
--

include( "shared.lua" )

include( "cl_modelcache.lua" )
include( "cl_shipeditor.lua" )

local MAT_PLAYER = Material( "playersheet.png", "nocull 1 smooth 0" )
	MAT_PLAYER:SetInt( "$flags", bit.bor( MAT_PLAYER:GetInt( "$flags" ), 2 ^ 8 ) )

	local MAT_PLAYER_WIDTH = 643
	local MAT_PLAYER_HEIGHT = 831
	-- MAT_PLAYER:SetInt( "$flags", 2 ^ 3 )
	-- MAT_PLAYER:SetInt( "$flags", bit.bor( MAT_PLAYER:GetInt( "$flags" ), 2 ^ 8 ) )

local MAT_GUNS_FUTURE = Material( "guns_future.png", "nocull 1 smooth 0" )
	MAT_GUNS_FUTURE:SetInt( "$flags", bit.bor( MAT_GUNS_FUTURE:GetInt( "$flags" ), 2 ^ 8 ) )

	local MAT_GUNS_FUTURE_WIDTH = 1024
	local MAT_GUNS_FUTURE_HEIGHT = 1024
	local GUNSCALE = 0.3

local MAT_MUZZLEFLASH = Material( "muzzleflash.png", "nocull 1 smooth 0" )

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
		local left = ply.BillboardLeft
			local dir = ply:GetVelocity():GetNormalized()
			local angBetween = dir:Dot( LocalPlayer():GetAngles():Right() )
			if ( angBetween != 0 ) then
				left = angBetween < 0
			end
			ply.BillboardLeft = left
		DrawPlayerWithUVs( -PLAYER_WIDTH / 2, -PLAYER_HEIGHT, PLAYER_WIDTH, PLAYER_HEIGHT, MAT_PLAYER, anim, frame, left )

		-- Draw weapon
		local x = -PLAYER_WIDTH / 2
		local y = -PLAYER_HEIGHT / 5 * 3 + 1 * frame
		DrawWeapon( ply, x, y, 1, left )
	cam.End3D2D()

	return true
end

function GM:HUDPaint()
	render.SetLightingMode( 0 )
end

function GM:PreDrawViewModel( viewmodel, ply, weapon )
	if ( !ply ) then return end

	local scale = 2
	local ang = LocalPlayer():EyeAngles()
	local pos = LocalPlayer():EyePos() +
		ang:Forward() * 90 +
		ang:Right() * 8 +
		-- ang:Right() * 24 +
		ang:Up() * 3
		-- ang.p = 0
		-- ang.r = 0
		-- ang:RotateAroundAxis( ang:Right(), 180 )
		-- ang:RotateAroundAxis( ang:Up(), 180 )
		-- ang:RotateAroundAxis( ang:Forward(), 180 )
		-- ang:RotateAroundAxis( ang:Right(), 90 )
		ang:RotateAroundAxis( ang:Up(), 180 + 5 )
		ang:RotateAroundAxis( ang:Forward(), 90 )
	cam.Start3D2D( pos, ang, 1 )
		DrawWeapon( ply, 0, 0, scale, true )
	cam.End3D2D()

	return true
end
-------------------------
  -- /Gamemode Hooks --
-------------------------

-- UV anims
function DrawWeapon( ply, x, y, scale, left )
	local gun = ply:Get2DGun()
	local start = gun[1]
	local w = gun[2].x
	local h = gun[2].y
	local border = 2

	surface.SetDrawColor( COLOUR_WHITE )
	surface.SetMaterial( MAT_GUNS_FUTURE )
	DrawWithUVs( x, y, w * scale * GUNSCALE, h * GUNSCALE, start.x / MAT_GUNS_FUTURE_WIDTH, start.y / MAT_GUNS_FUTURE_HEIGHT, ( start.x + w ) / MAT_GUNS_FUTURE_WIDTH, ( start.y + h ) / MAT_GUNS_FUTURE_HEIGHT, left )

	local last = ply:GetActiveWeapon():LastShootTime()
	if ( last + 0.1 >= CurTime() ) then
		surface.SetMaterial( MAT_MUZZLEFLASH )
		local size = math.random( 0.9, 1.1 )
		local size = 1
		local colour = math.sin( CurTime() * 50 ) / 2 + 0.5
		local muzzle = 1.1
			if ( left ) then
				muzzle = -1
			end
			muzzle = muzzle * size
		surface.SetDrawColor( Color( 255, 255, 255, 255 * colour ) )
		DrawWithUVs(
			x + w * scale * GUNSCALE * muzzle - border * muzzle,
			y - border * 2 + 14 * -size + 14,
			w * scale * size * GUNSCALE,
			h * size * GUNSCALE,
			0, 0, 1, 1,
			left
		)
	end
end
function DrawPlayerWithUVs( x, y, w, h, mat, anim, frame, left )
	-- 17 / 643, 94 / 831, ( 17 + 68 ) / 643, ( 94 + 68 ) / 831
	local uvs = ANIMS[mat][anim][frame]
	local u1 = uvs.x / MAT_PLAYER_WIDTH
	local v1 = uvs.y / MAT_PLAYER_HEIGHT
	local u2 = ( uvs.x + PLAYER_UV_WIDTH ) / MAT_PLAYER_WIDTH
	local v2 = ( uvs.y + PLAYER_UV_HEIGHT ) / MAT_PLAYER_HEIGHT

	surface.SetDrawColor( COLOUR_WHITE )
	surface.SetMaterial( mat )
	DrawWithUVs( x, y, w, h, u1, v1, u2, v2, left )
end
function DrawWithUVs( x, y, w, h, u1, v1, u2, v2, left )
	if ( left ) then
		local temp = u1
		u1 = u2
		u2 = temp
	end
	surface.DrawTexturedRectUV( x, y, w, h, u1, v1, u2, v2 )
end

local meta = FindMetaTable("Player")

function meta:Get2DGun()
	return { Vector( 103, 92 ), Vector( 176, 76 ) }
end
