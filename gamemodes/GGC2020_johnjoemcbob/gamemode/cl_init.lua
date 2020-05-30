--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Clientside
--

include( "shared.lua" )

include( "cl_modelcache.lua" )

local COLOUR_WHITE = Color( 255, 255, 255, 255 )
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

local DRAGDROP_SHIP = "DRAGDROP_SHIP"
local SHIPPART_SIZE = 128 + 22

------------------------
  -- Gamemode Hooks --
------------------------
function GM:Initialize()
	
end

function GM:Think()
	if ( LocalPlayer():KeyPressed( IN_ATTACK2 ) ) then
		CreateVGUI()
	end
end

function GM:PreRender()
	render.SetLightingMode( 0 ) -- 1 )
end

function GM:PostDrawOpaqueRenderables()
	local origin = Vector( -489, 426, -21 )
	if ( LocalPlayer().ShipParts ) then
		for k, v in pairs( LocalPlayer().ShipParts ) do
			GAMEMODE.RenderCachedModel( v.Model, origin + v.Grid * SHIPPART_SIZE, Angle( 0, 90 * v.Rotation, 0 ), Vector( 1, 1, 1 ), nil, COLOUR_WHITE )
		end
	end
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

function CreateVGUI()
	if ( LocalPlayer().ShipDesigner ) then
		LocalPlayer().ShipDesigner:Remove()
	end

	local width, height = ScrW() / 3, ScrH() / 1.5
	local border = 6
	local leftwidth = width / 3 * 2 - border

	local frm = vgui.Create( "DFrame" )
		frm:SetTitle( "Ship designer" )
		frm:SetSize( width, height )
		frm:Center()
		frm:SetPos( ScrW() / 16 * 10, ScrH() / 4 ) -- temp
		frm:MakePopup()
	LocalPlayer().ShipDesigner = frm
	LocalPlayer().ShipParts = {}

	-- Grid vars
	local cells = math.floor( math.sin( CurTime() * 1 ) * 2 + 4 )
	local cells = 8
	-- local cells = 12
	local cellsize = leftwidth / ( cells + 2 )
	local gridheight = cells * cellsize
	local cellline = 2
	local cellcolour = Color( 255, 255, 255, 128 )
	local ystart = 0

	LocalPlayer().ShipDesigner.Spawners = {}
	local function addpiecespawner( name, model, index )
		if ( !index ) then
			index = tablelength( LocalPlayer().ShipDesigner.Spawners )
		end
		if ( !LocalPlayer().ShipDesigner.Spawners[name] ) then
			local spawner = vgui.Create( "DModelPanel", LocalPlayer().ShipDesigner.Right )
				spawner:SetPos( 10 + cellsize * index, 10 )
				spawner:SetSize( cellsize, cellsize )
				-- spawner:SetBackgroundColor( Color(255, 64, 64, 255) )
				spawner:SetModel( model )
				spawner:Droppable( DRAGDROP_SHIP )
				spawner.Name = name
				spawner.Index = index
				spawner.Model = model
			LocalPlayer().ShipDesigner.Spawners[name] = spawner
		end
	end

	local function getgridpos( mx, my )
		-- mx = ( mx - ( x + 8 ) )
		-- my = ( my - ( y + 32 ) )
		local gx = math.Clamp( math.floor( ( mx / cellsize ) ), 1, cells )
		local gy = math.Clamp( math.floor( ( ( my - ystart ) / cellsize ) + 1 ), 1, cells )

		-- surface.SetDrawColor( Color( 0, 255, 0, 255 ) )
		-- surface.DrawRect( mx, my, 4, 4 )
		-- surface.SetDrawColor( Color( 0, 0, 255, 255 ) )
		-- surface.DrawRect( mx, ystart, 4, 4 )

		return gx, gy
	end
	local function ondrop( v, add )
		-- Remove this as a spawner and create new
		LocalPlayer().ShipDesigner.Spawners[v.Name] = nil
		addpiecespawner( v.Name, v.Model, v.Index )

		-- If add then add or update existing
		if ( add ) then
			if ( !v.Added ) then
				-- Add
				v.Added = CurTime()
			end
			LocalPlayer().ShipParts[v.Added] = {
				Rotation = 0,
				Grid = v.Grid,
				Model = v.Model,
			}
		elseif ( v.Added ) then
			-- Otherwise try to remove
			LocalPlayer().ShipParts[v.Added] = nil
		end
	end

	-- Left side is actual design grid
	local left = vgui.Create( "DPanel", frm )
		left:SetSize( leftwidth, height )
		left:Dock( LEFT )
		function left:Paint( w, h )
			local x, y = frm:GetPos()
			ystart = ( h - gridheight ) / 2

			-- Background
			draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0 ) )

			-- Grid
			for x = 1, cells + 1 do
				surface.SetDrawColor( cellcolour )
				surface.DrawRect( x * cellsize, ystart, cellline, gridheight )
			end
			for y = 0, cells do
				surface.SetDrawColor( cellcolour )
				surface.DrawRect( cellsize, ystart + y * cellsize, leftwidth - cellsize * 2, cellline )
			end

			-- Highlight player cursor
			local gx, gy = getgridpos( gui.MouseX() - ( x + 8 ), gui.MouseY() - ( y + 32 ) )

			surface.SetDrawColor( Color( 255, 0, 0, 12 ) )
			surface.DrawRect( gx * cellsize, ystart + gy * cellsize - cellsize, cellsize, cellsize )
			
			draw.SimpleText( gx .. " " .. gy, "DermaDefault", 50, 50, COLOUR_WHITE )
		end
		left:Receiver(
			DRAGDROP_SHIP,
			function( receiver, panels, isDropped, menuIndex, mouseX, mouseY )
				-- if ( isDropped ) then
					local x, y = frm:GetPos()
					for k, v in pairs( panels ) do
						v:SetParent( receiver )
						local gx, gy = getgridpos( mouseX, mouseY )
						v:SetPos( gx * cellsize, ystart + ( gy - 1 ) * cellsize )
						v.Grid = Vector( gx, gy )
						ondrop( v, true )
					end
				-- end
			end,
			{}
		)
	LocalPlayer().ShipDesigner.Left = left

	-- Right side is toolbox
	local right = vgui.Create( "DPanel", frm )
		right:SetSize( width / 3 - border, height )
		right:Dock( RIGHT )
		right:Receiver(
			DRAGDROP_SHIP,
			function( receiver, panels, isDropped, menuIndex, mouseX, mouseY )
				if ( isDropped ) then
					for k, v in pairs( panels ) do
						v:Remove()
						ondrop( v, false )
					end
				end
			end,
			{}
		)
	LocalPlayer().ShipDesigner.Right = right
	addpiecespawner( "1x1 x", "models/cerus/modbridge/core/x-111.mdl" )
	addpiecespawner( "1x1 c", "models/cerus/modbridge/core/c-111.mdl" )
end
CreateVGUI()
