--
-- GGC2020_johnjoemcbob
-- 12/06/20
--
-- Clientside Module Editor
--

ModuleEditor = ModuleEditor or {}
	ModuleEditor.Cells = 8

local DRAGDROP_SHIP = "DRAGDROP_SHIP"

-------------------------
  -- Gamemode Hooks --
-------------------------
hook.Add( "KeyPress", HOOK_PREFIX .. "_ModuleEditor_KeyPress", function( ply, key )
	if ( ply == LocalPlayer() and key == IN_ZOOM ) then
		if ( !ModuleEditor.VGUI or !ModuleEditor.VGUI:IsValid() ) then
			ModuleEditor:CreateVGUI()
		else
			ModuleEditor.VGUI:SetVisible( true )
		end
	end
end )

hook.Add( "PostDrawOpaqueRenderables", HOOK_PREFIX .. "_ModuleEditor_PostDrawOpaqueRenderables", function()
	-- if ( ModuleEditor.VGUI and ModuleEditor.VGUI:IsVisible() and ModuleEditor.ShipParts ) then
	if ( ModuleEditor.ShipParts ) then
		-- TEMP FIND ATTACH POINT
		local attachpoint
			for k, v in pairs( ModuleEditor.ShipParts ) do
				if ( v.AttachPoints ) then
					for _, attach in pairs( v.AttachPoints ) do
						if ( !attach.Disabled and attach.Valid ) then
							attachpoint = SHIPEDITOR_ORIGIN( #Ship.Ship + 1 ) +
								Vector(
									attach[1].x + v.Grid.x + math.floor( v.Collisions.x / 2 ) + SHIPPARTS[v.Name][3].x,
									attach[1].y + -v.Grid.y - math.floor( v.Collisions.y / 2 ) + SHIPPARTS[v.Name][3].y
								) * SHIPPART_SIZE
							break
						end
					end
				end
			end
		if ( !attachpoint ) then return end

		-- Render attach point
		local around = attachpoint
			GAMEMODE.RenderCachedModel(
				"models/props_borealis/bluebarrel001.mdl",
				around,
				Angle( 0, 0, 0 ),
				Vector( 1, 1, 1 ) * 5
			)
			-- Render ship
		for rot = 0, 270, 90 do
			for k, v in pairs( ModuleEditor.ShipParts ) do
				local pos = SHIPEDITOR_ORIGIN( #Ship.Ship + 1 ) +
								Vector(
									v.Grid.x + math.floor( v.Collisions.x / 2 ) + SHIPPARTS[v.Name][3].x,
									-v.Grid.y - math.floor( v.Collisions.y / 2 ) + SHIPPARTS[v.Name][3].y
								) * SHIPPART_SIZE
				pos = rotate_point( pos.x, pos.y, around.x, around.y, rot )
				pos = Vector( pos[1], pos[2], SHIPEDITOR_ORIGIN( #Ship.Ship + 1 ).z )

				GAMEMODE.RenderCachedModel(
					SHIPPARTS[v.Name][1],
					pos,
					Angle( 0, rot + 90 * v.Rotation, 0 ),
					Vector( 1, 1, 1 ),
					nil,
					Color( 255, 255, 255, 128 )
				)

				-- if ( v.AttachPoints ) then
				-- 	for _, attach in pairs( v.AttachPoints ) do
				-- 		if ( attach.Disabled and attach.Valid ) then
				-- 			GAMEMODE.RenderCachedModel(
				-- 				SHIPENDCAP,
				-- 				pos + Vector( attach[1].x, -attach[1].y ) * SHIPPART_SIZE / 2,
				-- 				Angle( 90, rot + 90 + attach[2], 0 ),
				-- 				Vector( 1, 1, 1 ) * 0.9,
				-- 				nil,
				-- 				Color( 255, 255, 255, 128 )
				-- 			)
				-- 		end
				-- 	end
				-- end
			end
		end
	end
end )

local cooldown = 0
hook.Add( "CreateMove", HOOK_PREFIX .. "ModuleEditor_CreateMove", function()
	if ( ModuleEditor.VGUI and input.WasKeyPressed( KEY_R ) and cooldown <= CurTime() ) then
		local v = ModuleEditor.GrabbedShipPart
		if ( v and v.Rotation ) then
			v.Rotation = v.Rotation + 1
			if ( v.Rotation > 3 ) then
				v.Rotation = 0
			end
			ModuleEditor.RotatePart( v )
		else
			-- TODO Try to find piece under mouse cursor
		end
		cooldown = CurTime() + 0.1
	end
end )
-------------------------
  -- /Gamemode Hooks --
-------------------------
function ModuleEditor.RotatePart( v )
	local w, h = v:GetSize()
	v:SetSize( h, w )
	v.Collisions = Vector( v.Collisions.y, v.Collisions.x )

	-- Attach points
	for k, attach in pairs( v.AttachPoints ) do
		attach[1] = Vector( attach[1].y, -attach[1].x )
		attach[2] = attach[2] + 90
		if ( attach[3] ) then
			local center = v.Collisions / 2
			local rotate = rotate_point( attach[3].x, attach[3].y, center.x, center.y, 90 ) 
			attach[3] = Vector( rotate[1], rotate[2] )
		end
	end
end

function ModuleEditor.Save( self )
	local tab = self.ShipParts
	local json = util.TableToJSON( tab, true )
	file.CreateDir( HOOK_PREFIX ) 
	file.Write( HOOK_PREFIX .. "/" .. self:GetName() .. ".txt", json )
end

function ModuleEditor.Load( self )
	local json = file.Read( HOOK_PREFIX .. "/" .. self:GetName() .. ".txt" )
	local tab = util.JSONToTable( json )

	local function load()
		self:Initialize()

		local index = 1
		for k, v in pairs( tab ) do
			local spawner = self:AddPartSpawner( v.Name, 0, true )
				spawner.Grid = v.Grid
				spawner.Rotation = v.Rotation
					for rot = 1, v.Rotation do
						ModuleEditor.RotatePart( spawner )
					end
				spawner.AttachPoints = v.AttachPoints
				spawner.Added = -index
			self:OnDrop( spawner, true, true )

			index = index + 1
		end
	end
	if ( !ystart or ystart == 0 ) then
		timer.Simple( 0.1, function() load() end )
	else
		load()
	end
end

function ModuleEditor.SendToServer()
	local tab = table.shallowcopy( ModuleEditor.ShipParts )
		for k, v in pairs( tab ) do
			v.Collisions = nil
			v.Panel = nil
		end
	net.Start( NET_SHIPEDITOR_SPAWN )
		net.WriteTable( tab )
	net.SendToServer()
end

local ystart = 0
function ModuleEditor.CreateVGUI( self )
	if ( self.VGUI ) then
		self.VGUI:Remove()
	end

	local width, height = ScrW() / 3, ScrH() / 1.5
	local border = 6
	local leftwidth = width / 3 * 2 - border

	local frm = vgui.Create( "DFrame" )
		frm:SetTitle( "Room Editor" )
		frm:SetSize( width, height )
		frm:Center()
		frm:SetPos( ScrW() / 16 * 2, ScrH() / 4 ) -- temp
		frm:MakePopup()
	self.VGUI = frm

	-- Grid vars
	self.CellSize = leftwidth / ( self.Cells + 2 )
	local gridheight = self.Cells * self.CellSize
	local cellline = 2
	local cellcolour = Color( 255, 255, 255, 128 )

	--self:Initialize()

	local function getgridpos( mx, my )
		local gx = math.Clamp( math.floor( ( mx / self.CellSize ) ), 1, self.Cells )
		local gy = math.Clamp( math.floor( ( ( my - ystart ) / self.CellSize ) + 1 ), 1, self.Cells )

		return gx, gy
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
			for x = 1, ModuleEditor.Cells + 1 do
				surface.SetDrawColor( cellcolour )
				surface.DrawRect( x * ModuleEditor.CellSize, ystart, cellline, gridheight )
			end
			for y = 0, ModuleEditor.Cells do
				surface.SetDrawColor( cellcolour )
				surface.DrawRect( ModuleEditor.CellSize, ystart + y * ModuleEditor.CellSize, leftwidth - ModuleEditor.CellSize * 2, cellline )
			end

			-- Highlight player cursor
			local gx, gy = getgridpos( gui.MouseX() - ( x + 8 ), gui.MouseY() - ( y + 32 ) )

			surface.SetDrawColor( Color( 255, 0, 0, 12 ) )
			surface.DrawRect( gx * ModuleEditor.CellSize, ystart + gy * ModuleEditor.CellSize - ModuleEditor.CellSize, ModuleEditor.CellSize, ModuleEditor.CellSize )
			
			-- draw.SimpleText( gx .. " " .. gy, "DermaDefault", 50, 50, COLOUR_WHITE )
			
			-- Collision debug
			if ( ModuleEditor.ShipCollisions ) then
				for x = 1, ModuleEditor.Cells do
					for y = 1, ModuleEditor.Cells do
						if ( ModuleEditor.ShipCollisions[x][y] ) then
							surface.SetDrawColor( Color( 0, 255, 0, 12 ) )
							surface.DrawRect( x * ModuleEditor.CellSize, ystart + y * ModuleEditor.CellSize - ModuleEditor.CellSize, ModuleEditor.CellSize, ModuleEditor.CellSize )
						end
					end
				end
			end
		end
		left:Receiver(
			DRAGDROP_SHIP,
			function( receiver, panels, isDropped, menuIndex, mouseX, mouseY )
				-- if ( isDropped ) then
					local x, y = frm:GetPos()
					for k, v in pairs( panels ) do
						-- If just picked up then create a new spawner
						if ( !v.Added ) then
							self.Spawners[v.Name] = nil
							ModuleEditor:AddPartSpawner( v.Name, v.Index, false, v.DefaultPos )
						end

						-- Drag/drop
						local gx, gy = getgridpos( mouseX, mouseY )
						if ( ModuleEditor:CanDrop( v, gx, gy ) ) then
							v.Grid = Vector( gx, gy )
							self:OnDrop( v, true )
						end

						-- Track
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
	self.Right = right

	local textentry = vgui.Create( "DTextEntry", right )
		textentry:SetSize( 75, 20 )
		textentry:SetPlaceholderText( "Ship name" )
		textentry:SetValue( LocalPlayer().CurrentShipName or "" )
		textentry:SetUpdateOnType( true )
		function textentry:OnValueChange( value )
			LocalPlayer().CurrentShipName = value
		end
		textentry:Dock( TOP )
	self.VGUI.TextEntry = textentry

	local button = vgui.Create( "DButton", right )
		button:SetText( "Load" )
		button:SetSize( 250, 20 )
		button.DoClick = function()
			--ModuleEditor:Load()
			self:CreateVGUI()
		end
	button:Dock( TOP )

	local button = vgui.Create( "DButton", right )
		button:SetText( "Save" )
		button:SetSize( 250, 30 )
		button.DoClick = function()
			ModuleEditor:Save()

			-- -- Communicate to server
			-- ModuleEditor:Save()
			-- ModuleEditor:SendToServer()

			-- -- Hide editor and client models
			-- ModuleEditor.ShipParts = {}
			-- ModuleEditor.VGUI:Remove()
			-- ModuleEditor.VGUI = nil
		end
	button:Dock( BOTTOM )

	local spawnerpanel = vgui.Create( "DPanel", right )
		spawnerpanel:Receiver(
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
		spawnerpanel:Dock( FILL )
	right.SpawnerPanel = spawnerpanel

	self:Load()
end

function ModuleEditor.Initialize( self )
	-- Cleanup
	if ( self.Spawners ) then
		for k, v in pairs( self.Spawners ) do
			v:Remove()
		end
	end

	-- Initialize
	self.SpawnerListCollision = {}
		for x = 1, 4 do
			self.SpawnerListCollision[x] = {}
			for y = 1, 40 do
				self.SpawnerListCollision[x][y] = false
			end
		end
	self.Spawners = {}
		for name, part in pairs( SHIPPARTS ) do
			self:AddPartSpawner( name, nil, true )
		end

	self.ShipParts = {}
	self.ShipCollisions = {}
	for x = 1, self.Cells do
		self.ShipCollisions[x] = {}
		for y = 1, self.Cells do
			self.ShipCollisions[x][y] = false
		end
	end
end

function ModuleEditor.GetFirstFreeSpawnerPos( self, size )
	local cols = #self.SpawnerListCollision
	local rows = #self.SpawnerListCollision[1]
	for y = 1, rows do
		for x = 1, cols do
			-- Check if all slots starting here to the size of the piece are free and empty
			local free = true
				for cx = 0, size.x - 1 do
					for cy = 0, size.y - 1 do
						local sx = x + cx
						local sy = y + cy
						-- Outside of grid or did collide
						if ( ( sx > cols ) or ( sy > rows ) or self.SpawnerListCollision[sx][sy] ) then
							free = false
							break
						end
					end
					if ( !free ) then break end
				end
			if ( free ) then
				-- Occupy slots here too
				for cx = 0, size.x - 1 do
					for cy = 0, size.y - 1 do
						local sx = x + cx
						local sy = y + cy
						self.SpawnerListCollision[sx][sy] = true
					end
				end

				return Vector( x - 1, y - 1 )
			end
		end
	end
end

function ModuleEditor.AddPartSpawner( self, name, index, force, pos )
	-- if ( !self.CellSize ) then return end

	local spawner
		if ( self.Spawners[name] and !force ) then
			return self.Spawners[name]
		end
		if ( !pos ) then
			pos = self:GetFirstFreeSpawnerPos( SHIPPARTS[name][2] )
			pos.x = pos.x * ( self.CellSize + 4 )
			pos.y = pos.y * ( self.CellSize + 4 )
		end
		if ( !index ) then
			index = tablelength( self.Spawners )
		end

		-- if ( !self.Spawners[name] or force ) then
			spawner = vgui.Create( "DPanel", self.Right.SpawnerPanel )
				spawner:SetPos( pos.x, pos.y )
				spawner:SetSize( self.CellSize * SHIPPARTS[name][2].x, self.CellSize * SHIPPARTS[name][2].y )
				spawner:Droppable( DRAGDROP_SHIP )
				function spawner:Paint( w, h )
					if ( w ) then
						surface.SetDrawColor( COLOUR_BLACK )
						surface.DrawRect( 0, 0, w, h )

						surface.SetDrawColor( COLOUR_WHITE )
						if ( spawner.Selected ) then
							surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
						end
						SHIPPARTS[name][4]( self, 0, 0, w, h )
					end
				end
				spawner.Name = name
				spawner.Index = index
				spawner.Rotation = 0
				spawner.Collisions = SHIPPARTS[name][2]
				spawner.AttachPoints = table.shallowcopy( SHIPPARTS[name].AttachPoints )
				spawner.DefaultPos = Vector( pos.x, pos.y )
			self.Spawners[name] = spawner
		-- end
	return spawner
end

function ModuleEditor.CanDrop( self, v, gx, gy )
	for x = 0, v.Collisions.x - 1 do
		for y = 0, v.Collisions.y - 1 do
			if ( gx + x < 1 or gy + y < 1 or gx + x > self.Cells or gy + y > self.Cells ) then
				return false
			end
			if ( self.ShipCollisions[gx + x][gy + y] and !self:CollideIsSelf( v, gx + x, gy + y ) ) then
				return false
			end
		end
	end

	return true
end

function ModuleEditor.CollideIsSelf( self, v, gx, gy )
	if ( !v.Grid ) then return false end

	local sx = v.Grid.x
	local sy = v.Grid.y
	for x = 0, v.Collisions.x - 1 do
		for y = 0, v.Collisions.y - 1 do
			if ( ( gx == ( sx + x ) ) and ( gy == ( sy + y ) ) ) then
				return true
			end
		end
	end

	return false
end

function ModuleEditor.OnDrop( self, v, add, load )
	-- Remove this as a spawner and create new
	-- Unless loading from file!

	-- If add then add or update existing
	if ( add ) then
		if ( !v.Added ) then
			-- Add
			v.Added = CurTime()
		elseif ( self.ShipParts[v.Added] ) then
			-- Update, remove old collision spot
			local old = self.ShipParts[v.Added]
			self:SetCollision( old, false )
		end
		self.ShipParts[v.Added] = {
			Name = v.Name,
			Rotation = v.Rotation,
			Grid = v.Grid,
			Collisions = v.Collisions,
			AttachPoints = v.AttachPoints,
			Panel = v,
		}
		self:SetCollision( self.ShipParts[v.Added], true )

		self:UpdateAttachPoints( v )

		v:SetParent( self.Left )
		v:SetPos( v.Grid.x * self.CellSize + 1, ystart + ( v.Grid.y - 1 ) * self.CellSize + 1 )
	elseif ( v.Added ) then
		-- Otherwise remove
		local old = self.ShipParts[v.Added]
		self:SetCollision( old, false )
		self.ShipParts[v.Added] = nil

		self:RemoveAttachPoints( v )
	end

	-- Temp, should only save if something changed, at least
	-- if ( !load ) then
	-- 	self:Save()
	-- end
end

function ModuleEditor.UpdateAttachPoints( self, v, recursed )
	if ( !v.AttachPoints ) then return end

	-- Create buttons if none
	if ( !v.AttachButtons ) then
		v.AttachButtons = {}
		for k, attach in pairs( v.AttachPoints ) do
			local button = vgui.Create( "DButton", self.Left )
				button:SetText( "" )
				button.Paint = function( self, w, h )
					local col = Color( 0, 255, 100, 255 )
						if ( self.Disabled ) then
							col = Color( 255, 0, 100, 100 )
						end
					surface.SetDrawColor( col )
					surface.DrawRect( 0, 0, w, h )
				end
				button.DoClick = function( self )
					self.Disabled = !self.Disabled
					attach.Disabled = self.Disabled

					-- ModuleEditor:Save()
				end
				-- Load state
				button.Disabled = attach.Disabled
			table.insert( v.AttachButtons, button )
		end
	end

	-- Update buttons to new attach point positions
	for k, attach in pairs( v.AttachPoints ) do
		local button = v.AttachButtons[k]

		local size = self.CellSize
		local pos = attach[1]
			if ( attach[3] ) then
				pos = attach[3]
			end
		local ang = attach[2]
			-- ang = ang + v.Rotation * 90
		local w = size
		local h = 16
			if ( ang % 180 != 0 ) then
				w = h
				h = size
			end
		local x, y = v.Grid.x * size + 1, ystart + ( v.Grid.y - 1 ) * size + 1
		button:SetPos( x + ( pos.x + 1 ) * size / 2 - w / 2, y + ( pos.y + 1 ) * size / 2 - h / 2 )
		button:SetSize( w, h )
	end

	-- Check attach points for collision, in which case they are invalid
	for k, attach in pairs( v.AttachPoints ) do
		local button = v.AttachButtons[k]

		local pos = v.Grid + attach[1]
		attach.Valid = self:CanDrop( v, pos.x, pos.y )
		if ( !attach.Valid ) then
			-- Hide off screen..
			button:SetPos( -100, -100 )
		end
	end

	-- Get all neighbours and check those again, but don't recurse further than that
	if ( !recursed ) then
		-- TODO currently just updates all...
		for k, part in pairs( self.ShipParts ) do
			self:UpdateAttachPoints( part.Panel, true )
		end
	end
end

function ModuleEditor.RemoveAttachPoints( self, v )
	for k, button in pairs( v.AttachButtons ) do
		button:Remove()
	end
end

function ModuleEditor.SetCollision( self, v, on )
	for x = 0, v.Collisions.x - 1 do
		for y = 0, v.Collisions.y - 1 do
			self.ShipCollisions[v.Grid.x + x][v.Grid.y + y] = on
		end
	end
end

function ModuleEditor.GetName( self )
	local name = ""
	if ( self.VGUI and self.VGUI:IsValid() ) then
		name = LocalPlayer().CurrentShipName
	end
	return ( name != "" ) and name or "ship"
end

-- For individual part rendering, broken down into 3x3 patterns for each cell
function AddRotatableSegment( x, y, gx, gy, w, h, rot, segx, segy )
	if ( !segx ) then segx = 1 end
	if ( !segy ) then segy = 1 end
	if ( rot > 0 ) then
		for i = 1, rot do
			local temp = gx
			gx = gy
			gy = -temp
			if ( gy < 0 ) then
				gy = gy + 4
			end

			local temp = segx
			segx = segy
			segy = temp
		end
	end

	local cell = math.min( w, h )
	local inner = cell / 3
	surface.DrawRect(
		x + ( gx - 1 ) * inner + ( segx - 1 ) * cell,
		y + ( gy - 1 ) * inner + ( segy - 1 ) * cell,
		inner + 1,
		inner + 1
	)
end

--ModuleEditor:CreateVGUI()


-- Testing room rotation in 2d hud

--
-- local size = 32
-- local attach = Vector( 2, -1 )
-- local parts = {
-- 	Vector( 2, 0 ),
-- 	Vector( 1, 1 ),
-- 	Vector( 1, 2 ),
-- 	Vector( 2, 1 ),
-- 	Vector( 2, 2 ),
-- 	Vector( 3, 2 ),
-- 	Vector( 2, 3 ),
-- 	Vector( 2, 4 ),
-- 	Vector( 2, 5 ),
-- 	Vector( 3, 4 ),
-- 	Vector( 1, 4 ),

-- 	Vector( -2, 4 ),
-- 	Vector( -1, 4 ),
-- 	Vector( 0, 4 ),
-- 	Vector( 4, 4 ),
-- 	Vector( 5, 4 ),
-- 	Vector( 6, 4 ),
-- 	Vector( 7, 4 ),
-- }
-- hook.Add( "HUDPaint", HOOK_PREFIX .. "ModuleEditor_HUDPaint", function()
-- 	local x = ScrW() / 4 * 3
-- 	local y = ScrH() / 2

-- 	draw.NoTexture()

-- 	-- Draw single attach point
-- 	surface.SetDrawColor( 255, 255, 100, 100 )
-- 	surface.DrawRect( x + attach.x * size, y + attach.y * size, size, size )

-- 	-- For each rotated
-- 	for rot = 0, 270, 90 do
-- 		-- Draw parts
-- 		surface.SetDrawColor( 0, 255, 100, 255 )
-- 			if ( rot != 0 ) then
-- 				surface.SetDrawColor( 0, 255, 100, 100 )
-- 			end
-- 		for k, v in pairs( parts ) do
-- 			local pos = rotate_point( v.x, v.y, attach.x, attach.y, rot )
-- 			surface.DrawRect( x + pos[1] * size, y + pos[2] * size, size, size )
-- 		end
-- 	end
-- end )
