--
-- GGC2020_johnjoemcbob
-- 30/05/20
--
-- Clientside Ship Editor
--

ShipEditor = {}
	ShipEditor.Cells = 8

local DRAGDROP_SHIP = "DRAGDROP_SHIP"
local SHIPPART_SIZE = 128 + 22

local CORRWIDTH = 4
local SHIPPARTS = {
	["x-111"] = {
		"models/cerus/modbridge/core/x-111.mdl",
		function( self, w, h )
			surface.DrawRect( w / 2 - CORRWIDTH / 2, 0, CORRWIDTH, h )
			surface.DrawRect( 0, h / 2 - CORRWIDTH / 2, w, CORRWIDTH )
		end
	},
	["c-111"] = {
		"models/cerus/modbridge/core/c-111.mdl",
		function( self, w, h )
			local rotation = {
				{ 0.5, 0.5, 0, 0.5 },
				{ 0.5, 0.5, 0.5, 0.5 },
				{ 0.5, 0, 0.5, 0.5 },
				{ 0.5, 0, 0, 0.5 },
			}
			local r = rotation[self.Rotation + 1]
			surface.DrawRect( r[1] * w - CORRWIDTH / 2, r[2] * h, CORRWIDTH, h / 2 + CORRWIDTH / 2 )
			surface.DrawRect( r[3] * w, r[4] * h - CORRWIDTH / 2, w / 2, CORRWIDTH )
		end
	},
	["s-111"] = {
		"models/cerus/modbridge/core/s-111.mdl",
		function( self, w, h )
			local rotation = {
				false,
				true,
				false,
				true,
			}
			local r = rotation[self.Rotation + 1]
			if ( r ) then
				surface.DrawRect( w / 2 - CORRWIDTH / 2, 0, CORRWIDTH, h )
			else
				surface.DrawRect( 0, h / 2 - CORRWIDTH / 2, w, CORRWIDTH )
			end
		end
	},
	["t-111"] = {
		"models/cerus/modbridge/core/t-111.mdl",
		function( self, w, h )
			local cw = CORRWIDTH
			local rotation = {
				{ 0.5, 0.5, w, cw, 0.5, 0.5, cw, h }, -- 0
				{ 1, 0.5, w, cw, 0.5, 0, cw, h + cw }, -- 1
				{ 0.5, 0.5, w, cw, 0.5, -0.5, cw, h }, -- 2
				{ 0, 0.5, w, cw, 0.5, 0, cw, h + cw }, -- 3
			}
			local r = rotation[self.Rotation + 1]
			surface.DrawRect( r[1] * w - r[3] / 2, r[2] * h - cw / 2, r[3], r[4] )
			surface.DrawRect( r[5] * w - r[7] / 2, r[6] * h - cw / 2, r[7], r[8] )
		end
	},
	["sc-111"] = {
		"models/cerus/modbridge/core/sc-111.mdl",
		function( self, w, h )
			local cw = CORRWIDTH
			local rotation = {
				{ 1, 0.5, w, cw }, -- 0
				{ 0.5, -0.5, cw, w }, -- 1
				{ 0, 0.5, w, cw }, -- 2
				{ 0.5, 0.5, cw, w }, -- 3
			}
			local r = rotation[self.Rotation + 1]
			surface.DrawRect( r[1] * w - r[3] / 2, r[2] * h - cw / 2, r[3], r[4] )
		end
	},
	["s-311"] = {
		"models/cerus/modbridge/core/s-311.mdl",
		function( self, w, h )
			local rotation = {
				false,
				true,
				false,
				true,
			}
			local r = rotation[self.Rotation + 1]
			surface.SetDrawColor( Color( 255, 0, 0, 12 ) )
			if ( r ) then
				surface.DrawRect( w / 2 - CORRWIDTH / 2, 0, CORRWIDTH, h )
			else
				surface.DrawRect( 0, h / 2 - CORRWIDTH / 2, w, CORRWIDTH )
			end
		end
	},
}

-------------------------
  -- Gamemode Hooks --
-------------------------
hook.Add( "Think", HOOK_PREFIX .. "_ShipEditor_Think", function()
	if ( LocalPlayer():KeyPressed( IN_ATTACK2 ) ) then
		ShipEditor:CreateVGUI()
	end
end )

hook.Add( "PostDrawOpaqueRenderables", HOOK_PREFIX .. "_ShipEditor_PostDrawOpaqueRenderables", function()
	local origin = Vector( -489, 426, -21 )
	if ( ShipEditor.ShipParts ) then
		for k, v in pairs( ShipEditor.ShipParts ) do
			GAMEMODE.RenderCachedModel( SHIPPARTS[v.Name][1], origin + Vector( v.Grid.x, -v.Grid.y ) * SHIPPART_SIZE, Angle( 0, 90 * v.Rotation, 0 ), Vector( 1, 1, 1 ), nil, Color( 255, 255, 255, 128 ) )
		end
	end
end )

local cooldown = 0
hook.Add( "CreateMove", HOOK_PREFIX .. "ShipEditor_CreateMove", function()
	if ( input.WasKeyPressed( KEY_R ) and cooldown <= CurTime() ) then
		local v = ShipEditor.GrabbedShipPart
		if ( v ) then
			v.Rotation = v.Rotation + 1
			if ( v.Rotation > 3 ) then
				v.Rotation = 0
			end
		else
			-- Try to find piece under mouse cursor
		end
		cooldown = CurTime() + 0.1
	end
end )
-------------------------
  -- /Gamemode Hooks --
-------------------------

function ShipEditor.SaveShip( self )
	local tab = self.ShipParts
	local json = util.TableToJSON( tab, true )
	file.CreateDir( HOOK_PREFIX ) 
	file.Write( HOOK_PREFIX .. "/ship.txt", json )
end

function ShipEditor.LoadShip( self )
	local json = file.Read( HOOK_PREFIX .. "/ship.txt" )
	local tab = util.JSONToTable( json )

	local function load()
		local index = 1
		for k, v in pairs( tab ) do
			local spawner = self:AddPartSpawner( v.Name, 0, true )
				spawner.Grid = v.Grid
				spawner.Rotation = v.Rotation
				spawner.Added = -index
			self:OnDrop( spawner, true )

			index = index + 1
		end
	end
	if ( !ystart or ystart == 0 ) then
		timer.Simple( 0.1, function() load() end )
	else
		load()
	end
end

local ystart = 0
function ShipEditor.CreateVGUI( self )
	if ( self.VGUI ) then
		self.VGUI:Remove()
	end

	local width, height = ScrW() / 3, ScrH() / 1.5
	local border = 6
	local leftwidth = width / 3 * 2 - border

	local frm = vgui.Create( "DFrame" )
		frm:SetTitle( "Ship Editor" )
		frm:SetSize( width, height )
		frm:Center()
		frm:SetPos( ScrW() / 16 * 10, ScrH() / 4 ) -- temp
		frm:MakePopup()
	self.VGUI = frm
	self.ShipParts = {}
	self.ShipCollisions = {}

	-- Grid vars
	self.CellSize = leftwidth / ( self.Cells + 2 )
	local gridheight = self.Cells * self.CellSize
	local cellline = 2
	local cellcolour = Color( 255, 255, 255, 128 )
	for x = 1, self.Cells do
		self.ShipCollisions[x] = {}
		for y = 1, self.Cells do
			self.ShipCollisions[x][y] = false
		end
	end

	self.Spawners = {}
	local function getgridpos( mx, my )
		local gx = math.Clamp( math.floor( ( mx / self.CellSize ) ), 1, self.Cells )
		local gy = math.Clamp( math.floor( ( ( my - ystart ) / self.CellSize ) + 1 ), 1, self.Cells )

		return gx, gy
	end
	local function candrop( v, gx, gy )
		return !( self.ShipCollisions[gx][gy] )
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
			for x = 1, ShipEditor.Cells + 1 do
				surface.SetDrawColor( cellcolour )
				surface.DrawRect( x * ShipEditor.CellSize, ystart, cellline, gridheight )
			end
			for y = 0, ShipEditor.Cells do
				surface.SetDrawColor( cellcolour )
				surface.DrawRect( ShipEditor.CellSize, ystart + y * ShipEditor.CellSize, leftwidth - ShipEditor.CellSize * 2, cellline )
			end

			-- Highlight player cursor
			local gx, gy = getgridpos( gui.MouseX() - ( x + 8 ), gui.MouseY() - ( y + 32 ) )

			surface.SetDrawColor( Color( 255, 0, 0, 12 ) )
			surface.DrawRect( gx * ShipEditor.CellSize, ystart + gy * ShipEditor.CellSize - ShipEditor.CellSize, ShipEditor.CellSize, ShipEditor.CellSize )
			
			draw.SimpleText( gx .. " " .. gy, "DermaDefault", 50, 50, COLOUR_WHITE )
		end
		left:Receiver(
			DRAGDROP_SHIP,
			function( receiver, panels, isDropped, menuIndex, mouseX, mouseY )
				-- if ( isDropped ) then
					local x, y = frm:GetPos()
					for k, v in pairs( panels ) do
						local gx, gy = getgridpos( mouseX, mouseY )
						if ( candrop( v, gx, gy ) or v.Grid == Vector( gx, gy ) ) then
							v.Grid = Vector( gx, gy )
							self:OnDrop( v, true )
						end

						v.Selected = !isDropped
						self.GrabbedShipPart = v
					end
				-- end
			end,
			{}
		)
	self.Left = left

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
						self:OnDrop( v, false )
					end
				end
			end,
			{}
		)
	self.Right = right
	
	for name, part in pairs( SHIPPARTS ) do
		self:AddPartSpawner( name )
	end

	self:LoadShip()
end

function ShipEditor.AddPartSpawner( self, name, index, force )
	local spawner
	if ( !index ) then
		index = tablelength( self.Spawners )
	end 
	if ( !self.Spawners[name] or force ) then
		spawner = vgui.Create( "DPanel", self.Right )
			spawner:SetPos( 10 + self.CellSize * ( index % 4 ), 10 + self.CellSize * math.floor( index / 4 ) )
			spawner:SetSize( self.CellSize, self.CellSize )
			spawner:Droppable( DRAGDROP_SHIP )
			function spawner:Paint( w, h )
				if ( w ) then
					surface.SetDrawColor( COLOUR_BLACK )
					surface.DrawRect( 0, 0, w, h )

					surface.SetDrawColor( COLOUR_WHITE )
					if ( spawner.Selected ) then
						surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
					end
					SHIPPARTS[name][2]( self, w, h )
				end
			end
			spawner.Name = name
			spawner.Index = index
			spawner.Rotation = 0
		self.Spawners[name] = spawner
	end
	return spawner
end

function ShipEditor.OnDrop( self, v, add )
	-- Remove this as a spawner and create new
	-- Unless loading from file!
	if ( !v.Added or v.Added >= 0 ) then
		self.Spawners[v.Name] = nil
		self:AddPartSpawner( v.Name, v.Index )
	end

	-- If add then add or update existing
	if ( add ) then
		if ( !v.Added ) then
			-- Add
			v.Added = CurTime()
		elseif ( self.ShipParts[v.Added] ) then
			-- Update, remove old collision spot
			local old = self.ShipParts[v.Added]
			self.ShipCollisions[old.Grid.x][old.Grid.y] = false
		end
		self.ShipParts[v.Added] = {
			Name = v.Name,
			Rotation = v.Rotation,
			Grid = v.Grid,
		}
		self.ShipCollisions[v.Grid.x][v.Grid.y] = true
		
		v:SetParent( self.Left )
		v:SetPos( v.Grid.x * self.CellSize + 1, ystart + ( v.Grid.y - 1 ) * self.CellSize + 1 )
	elseif ( v.Added ) then
		-- Otherwise remove
		local old = self.ShipParts[v.Added]
		self.ShipCollisions[old.Grid.x][old.Grid.y] = false
		self.ShipParts[v.Added] = nil
	end

	-- Temp, should only save if something changed, at least
	self:SaveShip()
end

ShipEditor:CreateVGUI()
