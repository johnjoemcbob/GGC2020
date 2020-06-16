--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- Clientside Player
--

MAT_PLAYER = Material( "playersheet.png", "nocull 1 smooth 0" )
	-- MAT_PLAYER:SetInt( "$flags", bit.bor( MAT_PLAYER:GetInt( "$flags" ), 2 ^ 8 ) )

	local MAT_PLAYER_WIDTH = 643
	local MAT_PLAYER_HEIGHT = 831
	-- MAT_PLAYER:SetInt( "$flags", 2 ^ 3 )
	-- MAT_PLAYER:SetInt( "$flags", bit.bor( MAT_PLAYER:GetInt( "$flags" ), 2 ^ 8 ) )

PLAYER_WIDTH = 40
PLAYER_HEIGHT = 74
PLAYER_UV_WIDTH = 41
PLAYER_UV_HEIGHT = 74

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

VIEWMODEL_LERP_VECTOR	= 45
VIEWMODEL_LERP_ANGLE	= 5
VIEWMODEl_BREATHE		= 1
VIEWMODEl_BREATHE_SPEED	= 1

function GM:PrePlayerDraw( ply )
	local pos = ply:GetPos()
	local ang = LocalPlayer():GetAngles()
		ang.p = 0
		ang.r = 0
		ang:RotateAroundAxis( ang:Right(), 90 )
		ang:RotateAroundAxis( ang:Up(), -90 )

	-- Draw player
	local frame = 1
	local anim = "idle"
		if ( !ply:IsOnGround() ) then
			anim = "jump"

			local frames = #ANIMS[MAT_PLAYER][anim]
			local tr = util.TraceLine( {
				start = pos,
				endpos = pos - Vector( 0, 0, 10000 ),
				filter = ply
			} )
			local dist = math.floor( math.Clamp( pos:Distance( tr.HitPos ) / 10, 0, frames - 1 ) )
			frame = dist + 1

			-- Animate wobble a little at height of jump
			if ( frame == frames ) then
				frame = math.floor( CurTime() * ANIMS[MAT_PLAYER][anim].Speed % 2 ) + frames - 1
			end

			-- Detect for npcs
			if ( dist == 0 ) then
				anim = "idle"
			end
		end
		if ( anim != "jump" ) then
			if ( ply:GetVelocity():LengthSqr() > 10 ) then
				anim = "run"
			end

			frame = math.floor( CurTime() * ( ANIMS[MAT_PLAYER][anim].Speed ) % #ANIMS[MAT_PLAYER][anim] + 1 )
		end
	local left = ply.BillboardLeft
		local dir = ply:GetVelocity():GetNormalized()
		local angBetween = dir:Dot( LocalPlayer():GetAngles():Right() )
		if ( angBetween != 0 ) then
			left = angBetween < 0
		end
		ply.BillboardLeft = left
	DrawPlayerWithUVs( ply, MAT_PLAYER, anim, frame, left )

	-- Draw weapon
	-- TODO DOESN'T WORK, WEAPONS NEED TO REFACTOR TO DRAW THEMSELVES
	-- TODO DOESN'T WORK, WEAPONS NEED TO REFACTOR TO DRAW THEMSELVES
	-- TODO DOESN'T WORK, WEAPONS NEED TO REFACTOR TO DRAW THEMSELVES
	local reloading = false
		local weapon = ply:GetActiveWeapon()
		if ( weapon and weapon:IsValid() and weapon.ReloadDuration ) then
			local reloading = false
			local reloadtime = weapon:GetNWFloat( "ReloadTime", 0 )
			local reloadduration = weapon.ReloadDuration
			if ( reloadtime ) then
				reloading = reloadtime > CurTime()
			end
			if ( reloading ) then
				local progress = ( reloadtime - CurTime() ) / reloadduration
				ply.ReloadingProgress = -progress * 360

				if ( ply.ReloadingProgress < 360 ) then
					ang:RotateAroundAxis( ang:Up(), ply.ReloadingProgress )
				end
			else
				ply.ReloadingProgress = 0
			end
		end
	-- cam.Start3D2D( pos, ang, 1 )
		local x = -PLAYER_WIDTH / 2
		local y = -PLAYER_HEIGHT / 5 * 3 + 1 * frame
		DrawWeapon( ply, x, y, 1, left )
	-- cam.End3D2D()

	return true
end

function GM:PreDrawViewModel( viewmodel, ply, weapon )
	if ( !ply ) then return end

	local ft = FrameTime()
	ft = 0.016

	-- Transform
	local scale = 2
	local ang = LocalPlayer():EyeAngles()
	local pos = LocalPlayer():EyePos() +
		ang:Right() * ( 14 + math.sin( CurTime() * VIEWMODEl_BREATHE_SPEED ) * VIEWMODEl_BREATHE ) +
		ang:Up() * ( -3 + math.cos( CurTime() * VIEWMODEl_BREATHE_SPEED ) * VIEWMODEl_BREATHE )
		-- Angle after pos
		ang:RotateAroundAxis( ang:Right(), 3 )
		ang:RotateAroundAxis( ang:Up(), 180 + 5 )
		ang:RotateAroundAxis( ang:Forward(), 90 )
	-- Reloading
		if ( weapon and weapon:IsValid() and weapon.ReloadDuration ) then
			local reloading = false
			local reloadtime = weapon:GetNWFloat( "ReloadTime", 0 )
			local reloadduration = weapon.ReloadDuration
			if ( reloadtime ) then
				reloading = reloadtime > CurTime()
			end
			if ( reloading ) then
				local progress = ( reloadtime - CurTime() ) / reloadduration
				ply.ReloadingProgress = -progress * 360

				if ( ply.ReloadingProgress < 360 ) then
					pos = pos + ang:Forward() * -30
					ang:RotateAroundAxis( ang:Up(), ply.ReloadingProgress )
				end
			else
				ply.ReloadingProgress = 0
			end
		end
	ply.ViewModelPos = LerpVector( ft * VIEWMODEL_LERP_VECTOR, UnNaNVector( ply.ViewModelPos, pos ), pos )
	ply.ViewModelAngles = LerpAngle( ft * VIEWMODEL_LERP_ANGLE, UnNaNAngle( ply.ViewModelAngles ), ang )

	-- Draw
	if ( weapon.DrawViewModelCustom ) then
		weapon:DrawViewModelCustom( viewmodel, ply )
	end
	local scale = 1
		if ( weapon.Sprite ) then
			scale = weapon.Sprite.Scale
		end
	if ( weapon and weapon:IsValid() and weapon.Crosshair ) then
		local ang = ply:EyeAngles()
			ang:RotateAroundAxis( ang:Right(), 90 )
			ang:RotateAroundAxis( ang:Up(), -90 )
		local pos = ply:EyePos() + ply:EyeAngles():Forward() * 10
		cam.Start3D2D( pos, ang, 0.01 )
			draw.NoTexture()
			weapon:RenderCrosshair( 0, 0 )
		cam.End3D2D()
	end
	cam.Start3D2D( ply.ViewModelPos, ply.ViewModelAngles, 1 )
		DrawWeapon( ply, -60, 0, scale, true, true )
	cam.End3D2D()

	if ( ply.SwitchWeaponTime and ply.SwitchWeaponTime + 0.1 > CurTime() ) then
		local target = ply:EyeAngles() + Angle( 120, -90, 0 )
		ply.LastViewModelAngles = ply.LastViewModelAngles or ang
		ply.LastViewModelAngles = LerpAngle( ft * VIEWMODEL_LERP_ANGLE / 2, UnNaNAngle( ply.LastViewModelAngles ), target )

		cam.Start3D2D( ply.ViewModelPos, ply.LastViewModelAngles, 1 )
			DrawWeapon( ply.SwitchWeaponLast, -60, 0, ply.SwitchWeaponLast.Sprite and ply.SwitchWeaponLast.Sprite.Scale or 1, true, true )
		cam.End3D2D()
	end

	return true
end

hook.Add( "HUDPaint", HOOK_PREFIX .. "Player_Crosshair_HUDPaint", function()
	-- local weapon = LocalPlayer():GetActiveWeapon()
	-- if ( weapon and weapon:IsValid() and weapon.Crosshair ) then
	-- 	weapon:Crosshair( ScrW() / 2, ScrH() / 2 )
	-- end
end )
-------------------------
  -- /Gamemode Hooks --
-------------------------

-- UV anims
function DrawWeapon( ply, x, y, scale, left, viewmodel )
	local weapon = ply
		if ( ply:IsPlayer() ) then
			weapon = ply:GetActiveWeapon()
		end
	if ( !weapon or !weapon:IsValid() ) then return end

	local offset_view = Vector( 0, 0 )
	local offset_world = Vector( 0, 0 )
	local mat = MAT_GUNS_FUTURE
	local gun = Get2DGun()
		if ( weapon.GetSprite ) then
			local data = weapon:GetSprite()
			mat = data[1]
			gun = data[2]
			offset_view = data[3]
			offset_world = data[4]
		end
	local mat_muzzle = MAT_MUZZLEFLASH
	local muzzle_scale = 1
	local muzzle_off = Vector( 0, 0 )
	local muzzle_solid = false
		if ( weapon.Muzzle ) then
			mat_muzzle = weapon.Muzzle[1] or mat_muzzle
			muzzle_scale = weapon.Muzzle[2] or muzzle_scale
			muzzle_off = weapon.Muzzle.Off or muzzle_off
			muzzle_solid = weapon.Muzzle.Solid
		end
	local start = gun[1]
	local w = gun[2].x
	local h = gun[2].y
	local border = 2

	-- Center origin better
	local dir = 1
	if ( left ) then
		x = x - w * scale * GUNSCALE * 0.2
		dir = -1
	end

	local last = 0
		if ( weapon.LastShootTime ) then
			last = weapon:LastShootTime()
		end
	local firing = last + 0.1 >= CurTime()

	-- 
	if ( firing ) then
		x = x - 5 * dir
	end

	-- Draw gun
	surface.SetDrawColor( COLOUR_WHITE )
	surface.SetMaterial( mat )
	if ( viewmodel ) then
		-- VIEW
		DrawWithUVs( x + offset_view.x, y + offset_view.y, w * scale * GUNSCALE, h * GUNSCALE, start.x / MAT_GUNS_FUTURE_WIDTH, start.y / MAT_GUNS_FUTURE_HEIGHT, ( start.x + w ) / MAT_GUNS_FUTURE_WIDTH, ( start.y + h ) / MAT_GUNS_FUTURE_HEIGHT, left )
	else
		-- WORLD
		local ang = GAMEMODE:GetBillboardAngle()
		GAMEMODE:DrawBillboardedUVs(
			ply:GetPos() + ang:Forward() * dir * offset_world.x + ang:Up() * offset_world.y,
			ply.ReloadingProgress,
			Vector( w * scale * GUNSCALE, h * GUNSCALE ),
			mat,
			start.x / MAT_GUNS_FUTURE_WIDTH, start.y / MAT_GUNS_FUTURE_HEIGHT,
			( start.x + w ) / MAT_GUNS_FUTURE_WIDTH, ( start.y + h ) / MAT_GUNS_FUTURE_HEIGHT,
			left
		)
	end

	-- Draw muzzle flash
	if ( firing ) then
		surface.SetMaterial( mat_muzzle )
		--local size = math.random( 0.9, 1.1 )
		local size = 1 * muzzle_scale
		local colour = math.sin( CurTime() * 50 ) / 2 + 0.5
			if ( muzzle_solid ) then
				colour = 1
			end
		local muzzle = 1 * dir
			muzzle = muzzle * size
		surface.SetDrawColor( Color( 255, 255, 255, 255 * colour ) )
		DrawWithUVs(
			x + muzzle_off.x + w * scale * GUNSCALE * muzzle - border * muzzle,
			y + muzzle_off.y - border * 2 + 14 * -size + 14,
			w * scale * size * GUNSCALE,
			h * size * GUNSCALE,
			0, 0, 1, 1,
			left
		)

		-- ply.ViewModelPos = ply.ViewModelPos - ply:GetForward() * 5
	end
end
function DrawPlayerWithUVs( ply, mat, anim, frame, left )
	local u1, v1, u2, v2 = GetUVs( mat, anim, frame )

	if ( !left ) then
		local temp = u1
		u1 = u2
		u2 = temp
	end
	GAMEMODE:DrawBillboardedEntUVs( ply, ply:EyeAngles().r, mat, u1, v1, u2, v2 )
end
function DrawWithUVs( x, y, w, h, u1, v1, u2, v2, left )
	if ( left ) then
		local temp = u1
		u1 = u2
		u2 = temp
	end
	surface.DrawTexturedRectUV( x, y, w, h, u1, v1, u2, v2 )
end

function GetAnimation( mat, anim )
	return ANIMS[mat][anim]
end

function GetUVs( mat, anim, frame )
	-- 17 / 643, 94 / 831, ( 17 + 68 ) / 643, ( 94 + 68 ) / 831
	local uvs = ANIMS[mat][anim][frame]
	local u1 = uvs.x / MAT_PLAYER_WIDTH
	local v1 = uvs.y / MAT_PLAYER_HEIGHT
	local u2 = ( uvs.x + PLAYER_UV_WIDTH ) / MAT_PLAYER_WIDTH
	local v2 = ( uvs.y + PLAYER_UV_HEIGHT ) / MAT_PLAYER_HEIGHT

	return u1, v1, u2, v2
end

function Get2DGun()
	return { Vector( 103, 92 ), Vector( 176, 76 ) }
end
