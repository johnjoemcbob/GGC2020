--
-- GGC2020_johnjoemcbob
-- 30/05/20
--
-- Clientside Ship Editor
--

ShipEditor = ShipEditor or {}
	ShipEditor.Cells = 8

local DRAGDROP_SHIP = "DRAGDROP_SHIP"

-------------------------
  -- Gamemode Hooks --
-------------------------
hook.Add( "KeyPress", HOOK_PREFIX .. "_ShipEditor_KeyPress", function( ply, key )
	if ( ply == LocalPlayer() and key == IN_ZOOM ) then
		if ( !ShipEditor.VGUI or !ShipEditor.VGUI:IsValid() ) then
			ShipEditor:CreateVGUI()
		else
			ShipEditor.VGUI:SetVisible( true )
		end
	end
end )
-------------------------
  -- /Gamemode Hooks --
-------------------------

function ShipEditor.Save( self )
	local tab = self.ShipParts
	local json = util.TableToJSON( tab, true )
	file.CreateDir( HOOK_PREFIX ) 
	file.Write( HOOK_PREFIX .. "/" .. self:GetName() .. ".txt", json )
end

function ShipEditor.Load( self )
	local json = file.Read( HOOK_PREFIX .. "/" .. self:GetName() .. ".txt" )
	local tab = util.JSONToTable( json )

	local function load()
		-- TODO REDO THIS
		-- TODO REDO THIS
		-- TODO REDO THIS

		--self:Initialize()

		-- local index = 1
		-- for k, v in pairs( tab ) do
		-- 	local spawner = self:AddPartSpawner( v.Name, 0, true )
		-- 		spawner.Grid = v.Grid
		-- 		spawner.Rotation = v.Rotation
		-- 			for rot = 1, v.Rotation do
		-- 				ShipEditor.RotatePart( spawner )
		-- 			end
		-- 		spawner.AttachPoints = v.AttachPoints
		-- 		spawner.Added = -index
		-- 	self:OnDrop( spawner, true, true )

		-- 	index = index + 1
		-- end
	end
	if ( !ystart or ystart == 0 ) then
		timer.Simple( 0.1, function() load() end )
	else
		load()
	end
end

function ShipEditor.SendToServer()
	-- local tab = table.shallowcopy( ShipEditor.ShipParts )
	-- 	for k, v in pairs( tab ) do
	-- 		v.Collisions = nil
	-- 		v.Panel = nil
	-- 	end
	-- net.Start( NET_SHIPEDITOR_SPAWN )
	-- 	net.WriteTable( tab )
	-- net.SendToServer()
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
		end
		left:Receiver(
			DRAGDROP_SHIP,
			function( receiver, panels, isDropped, menuIndex, mouseX, mouseY )
				
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
			self:CreateVGUI()
		end
	button:Dock( TOP )

	local button = vgui.Create( "DButton", right )
		button:SetText( "Save" )
		button:SetSize( 250, 30 )
		button.DoClick = function()
			ShipEditor:Save()
		end
	button:Dock( BOTTOM )

	local spawnerpanel = vgui.Create( "DPanel", right )
		spawnerpanel:Receiver(
			DRAGDROP_SHIP,
			function( receiver, panels, isDropped, menuIndex, mouseX, mouseY )
				-- if ( isDropped ) then
				-- 	for k, v in pairs( panels ) do
				-- 		v:Remove()
				-- 		self:OnDrop( v, false )
				-- 	end
				-- end
			end,
			{}
		)
		spawnerpanel:Dock( FILL )
	right.SpawnerPanel = spawnerpanel

	self:Load()
end

function ShipEditor.Initialize( self )
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

function ShipEditor.GetFirstFreeSpawnerPos( self, size )
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

function ShipEditor.AddPartSpawner( self, name, index, force, pos )
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

function ShipEditor.CanDrop( self, v, gx, gy )
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

function ShipEditor.CollideIsSelf( self, v, gx, gy )
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

function ShipEditor.OnDrop( self, v, add, load )
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
	-- 	self:SaveShip()
	-- end
end

function ShipEditor.SetCollision( self, v, on )
	for x = 0, v.Collisions.x - 1 do
		for y = 0, v.Collisions.y - 1 do
			self.ShipCollisions[v.Grid.x + x][v.Grid.y + y] = on
		end
	end
end

function ShipEditor.GetName( self )
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

--ShipEditor:CreateVGUI()
