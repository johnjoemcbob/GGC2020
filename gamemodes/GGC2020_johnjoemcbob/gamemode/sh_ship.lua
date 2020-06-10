--
-- GGC2020_johnjoemcbob
-- 01/06/20
--
-- Shared Ship
--

Ship = Ship or {}
Ship.Ship = Ship.Ship or {}

local NETSTRING_SHIP = HOOK_PREFIX .. "Ship"

-- Net
if ( SERVER ) then
	util.AddNetworkString( NETSTRING_SHIP )
	util.AddNetworkString( NET_SHIPEDITOR_SPAWN )

	function Ship.SendToClient( self, ship )
		-- TODO need to send ship layouts to all clients
		net.Start( NETSTRING_SHIP )
			net.WriteInt( ship:GetIndex(), 9 )
			net.WriteTable( ship.Constructor )
		net.Broadcast()
	end

	net.Receive( NET_SHIPEDITOR_SPAWN, function( len, ply )
		-- Load ship data
		local tab = net.ReadTable()

		-- Clear old
		-- Ship:Clear( ply )

		-- Generate new
		Ship:Generate( ply, tab )
	end )
end
if ( CLIENT ) then
	net.Receive( NETSTRING_SHIP, function( lngth )
		local index = net.ReadInt( 9 )
		local tab = net.ReadTable()

		-- Store for render
		Ship.Ship[index].Constructor = tab
		-- print( "Receive ship! " .. index )
		-- PrintTable( Ship.Ship[index].Constructor )
	end )
end

if ( SERVER ) then
	Ship.Generate = function( self, ply, tab )
		local index = #self.Ship + 1

		self.Ship[index] = ents.Create( "ggcj_ship" )
			self.Ship[index]:SetPos( SHIPEDITOR_ORIGIN( index ) )
			self.Ship[index]:SetIndex( index )
		self.Ship[index]:Spawn()
		self.Ship[index].EnemySpawners = {}

		local first = nil
		self.Ship[index].Constructor = table.shallowcopy( tab )
		for k, v in pairs( tab ) do
			local part = SHIPPARTS[v.Name]
				v.Collisions = part[2]
				if ( v.Rotation % 2 != 0 ) then
					v.Collisions = Vector( v.Collisions.y, v.Collisions.x )
				end
			local ent = GAMEMODE.CreateProp(
				part[1],
				SHIPEDITOR_ORIGIN( index ) + Ship.GetPartOffset( v ),
				Angle( 0, 90 * v.Rotation, 0 ),
				false
			)
			ent:SetColor( COLOUR_UNLIT )
			table.insert( self.Ship[index].Parts, ent )

			-- Temp testing - Enemy spawners/player spawn point
			if ( math.random( 1, 2 ) == 1 ) then
				table.insert( self.Ship[index].EnemySpawners, ent:GetPos() )
			else
				self.Ship[index].SpawnPoint = ent:GetPos() - Vector( 0, 0, 32 )
				ply:SetPos( self.Ship[index].SpawnPoint )
				ply:SetHealth( ply:GetMaxHealth() )
				ply:SetNWEntity( "CurrentShip", index )
				ply:SwitchState( STATE_FPS )
				ply.OwnShip = index
			end

			-- Test doors
			if ( v.Collisions.x == 1 and v.Collisions.y == 1 ) then
				local doors = {
					{ Vector( 1, 0, 0 ),	Angle( 0, 0, 0 ) },
					{ Vector( -1, 0, 0 ),	Angle( 0, 0, 0 ) },
					{ Vector( 0, 1, 0 ),	Angle( 0, 90, 0 ) },
					{ Vector( 0, -1, 0 ),	Angle( 0, 90, 0 ) },
				}
				for k, doordata in pairs( doors ) do
					local pos = ent:GetPos() + doordata[1] * SHIPPART_SIZE / 2
					local tr = util.TraceLine( {
						start = ent:GetPos(),
						endpos = ent:GetPos() + doordata[1] * SHIPPART_SIZE / 2 * 1.5,
					} )
					if ( !tr.Hit ) then
						if ( math.random( 1, 5 ) == 1 ) then
							local door = ents.Create( "ggcj_door" )
								door:SetPos( pos + doordata[2]:Forward() * 0.1 )
								door:SetAngles( doordata[2] )
								door:SetColor( COLOUR_UNLIT )
								door:Spawn()
								table.insert( self.Ship[index].Parts, door.OuterFrame )
							table.insert( self.Ship[index].Parts, door )
						end
					end
				end
			end

			if ( first ) then
				-- ent:SetParent( first )
			else
				first = ent
			end
		end

		-- Spawn pilot chair
		local ent = GAMEMODE.CreateEnt(
			"prop_vehicle_prisoner_pod",
			"models/nova/chair_office02.mdl",
			SHIPEDITOR_ORIGIN( index ) + Vector( 630, -500, -64 ),
			Angle( 0, 0, 0 ),
			false
		)
		ent:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
	end

	Ship.Clear = function( self, ply )
		if ( ply.OwnShip and self.Ship[ply.OwnShip] and self.Ship[ply.OwnShip]:IsValid() ) then
			for k, part in pairs( self.Ship[ply.OwnShip].Parts ) do
				if ( part and part:IsValid() ) then
					part:Remove()
				end
			end
			self.Ship[ply.OwnShip]:Remove()
			self.Ship[ply.OwnShip] = nil
		end
	end

	-- Gamemode Hooks
	hook.Add( "PlayerInitialSpawn", HOOK_PREFIX .. "Ship_PlayerInitialSpawn", function( ply )
		print( "try to sync existing ships!" )
		for k, ship in pairs( Ship.Ship ) do
			print( "syncing ship... " .. tostring( k ) )
			Ship:SendToClient( ship )
		end
		print( "done syncing!" )
	end )

	hook.Add( "Think", HOOK_PREFIX .. "Ship_Think", function()
		for k, ply in pairs( player.GetAll() ) do
			local ship = ply:GetNWInt( "CurrentShip", -1 )
			if ( ship >= 0 and Ship.Ship[ship] and Ship.Ship[ship]:IsValid() and ply:GetStateName() == STATE_SHIP_PILOT ) then
				Ship.Ship[ship]:MoveInput( ply )
			end
		end
	end )

	-- Command to join other ships for now
	concommand.Add( "ggcj_setship", function( ply, cmd, args )
		ply:SetNWInt( "CurrentShip", tonumber( args[1] ) )
	end )

	concommand.Add( "ggcj_loadships", function( ply, cmd, args )
		local ships = {
			"shipbig.txt",
			"shipsmall.txt",
			"shiptiny.txt",
		}
		for k, ship in pairs( ships ) do
			local json = file.Read( HOOK_PREFIX .. "/" .. ship )
			local tab = util.JSONToTable( json )
			Ship:Generate( ply, tab )
		end
	end )
end

if ( CLIENT ) then
	local sampleFrame = vgui.Create( "DFrame" )
	sampleFrame:SetTitle( "" )
	sampleFrame:ShowCloseButton( false )
	sampleFrame:SetPos( 0, 0 )
	sampleFrame:SetSize( 200, 200 )
	sampleFrame:ParentToHUD()
	sampleFrame.Paint = function( self, w, h )
		-- local w = ScrW() / 4
		-- local h = w
		local x = 0
		local x = ScrW() - w
		local y = 0

		-- Background
		local function mask()
			surface.SetDrawColor( COLOUR_BLACK )
			surface.DrawRect( x, y, w, h )
		end
		local function inner()
			-- Draw world centered on own ship
			local ship = LocalPlayer():GetNWInt( "CurrentShip" )
			-- print( ship )
			if ( ship and ship >= 0 ) then
				local ship = Ship.Ship[ship]
				if ( ship and ship:IsValid() ) then
					local sw = SHIPPART_SIZE_2D
					local sh = sw
					local sx = x + w / 2 -- sw
					local sy = y + h / 2 -- sh

					-- Draw grid for telling movement is happening
					surface.SetDrawColor( Color( 255, 255, 255, 5 ) )
					local cells = w / sw
					for cx = 1, cells do
						local cx = x + cx * sw - ship:Get2DPos().x % sw
						local cy = y
						surface.DrawLine( cx, cy, cx, cy + h )
					end
					for cy = 1, cells do
						local cx = x
						local cy = y + cy * sh - ship:Get2DPos().y % sw
						surface.DrawLine( cx, cy, cx + w, cy )
					end

					-- Debug lines
						local mult = 0.1
						surface.SetDrawColor( COLOUR_WHITE )
						surface.DrawLine( sx, sy, sx + ship:Get2DVelocity().x * mult, sy + ship:Get2DVelocity().y * mult )

						-- surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
						-- surface.DrawLine( sx, sy, sx + ship:Forward().x * 100, sy + ship:Forward().y * 100 )

					-- Player ship
					local col = COLOUR_GLASS
						DEBUG_SHIP_COLLISION_POS = Vector( x + w / 2, y + h / 2 )
						-- local collide = ( tablelength( Ship:CheckCollision( ship ) ) > 0 )
						-- if ( collide ) then
							-- col = Color( 255, 0, 100, 255 )
						-- end
					ship.Pos = self.Pos
					ship:HUDPaint( sx, sy, sw, col )

					-- Draw system objects
					-- TODO
					--for k, ent in pairs( things ) do
						-- yeah
					--end

					-- Draw all other ships based on this position
					local ox, oy = sx, sy
					for k, other in pairs( Ship.Ship ) do
						if ( other != ship ) then
							local sx = sx + ( other:Get2DPos().x - ship:Get2DPos().x )
							local sy = sy + ( other:Get2DPos().y - ship:Get2DPos().y )
							other.Pos = self.Pos
							other:HUDPaint( sx, sy, sw, COLOUR_WHITE )
						
							surface.SetDrawColor( Color( 255, 255, 0, 10 ) )
							surface.DrawLine( ox, oy, sx, sy )
						end
					end
				end
			end
		end
		draw.StencilBasic( mask, inner )
		-- inner()
	end

	hook.Add( "PostDrawTranslucentRenderables", HOOK_PREFIX .. "ShipMap_PostDrawTranslucentRenderables", function()
		local ship = LocalPlayer():GetNWInt( "CurrentShip" )

		if ( ship and ship >= 0 ) then
			local ship = Ship.Ship[ship]
			if ( ship and ship:IsValid() ) then
				local pos = ship:GetMapPos()

				sampleFrame.Pos = pos
				
				cam.Start3D2D( pos, Angle( 0, 0, 90 ), 0.4 )
					sampleFrame:Paint( 200, 200 )
				cam.End3D2D()
				--vgui.Start3D2D( pos, Angle( 0, 0, 90 ), 0.4 )
				--	sampleFrame:Paint3D2D()
				--vgui.End3D2D()
			end
		end
	end )

	hook.Add( "HUDPaint", HOOK_PREFIX .. "ShipMap_HUDPaint", function()
		sampleFrame.Pos = Vector( 0, 0, 0 )
		sampleFrame:Paint( ScrW() / 6, ScrW() / 6 )
	end )
end

function Ship.CheckCollision( self, ship )
	local border = 16
	local collisions = {}
		if ( ship.Size ) then
			local sx = 0
			local sy = 0
			local sw = ( ship.Size.x ) * SHIPPART_SIZE_2D + border
			local sh = ( ship.Size.y ) * SHIPPART_SIZE_2D + border
			local a = { sx, sy, sw, sh, -ship:Get2DRotation() }

			for k, other in pairs( Ship.Ship ) do
				if ( other != ship and other.Size ) then
					local b = {
						sx + ( other:Get2DPos().x - ship:Get2DPos().x ),
						sy + ( other:Get2DPos().y - ship:Get2DPos().y ),
						( other.Size.x ) * SHIPPART_SIZE_2D + border,
						( other.Size.y ) * SHIPPART_SIZE_2D + border,
						-other:Get2DRotation()
					}
					if ( intersect_squares( a, b ) ) then
						collisions[k] = true
					end
				end
			end
		end
	return collisions
end

Ship.GetShip = function( ply )
	if ( CLIENT and !ply ) then ply = LocalPlayer() end
	local index = ply:GetNWInt( "CurrentShip", -1 )
		if ( index == -1 ) then
			return nil
		end
	return Ship.Ship[index]
end

Ship.GetPartOffset = function( data )
	local part = SHIPPARTS[data.Name]
	-- return Vector(
		-- data.Grid.x + math.floor( data.Collisions.x / 2 ) + part[3].x,
		-- -data.Grid.y - math.floor( data.Collisions.y / 2 ) + part[3].y
	-- ) * SHIPPART_SIZE
	return Vector(
		data.Grid.x + math.floor( part[2].x / 2 ) + part[3].x,
		-data.Grid.y - math.floor( part[2].y / 2 ) + part[3].y
	) * SHIPPART_SIZE
end
