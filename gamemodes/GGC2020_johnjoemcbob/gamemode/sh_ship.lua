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
		print( "Receive ship! " .. index )
		PrintTable( Ship.Ship[index].Constructor )
	end )
end

if ( SERVER ) then
	Ship.Generate = function( self, ply, tab )
		local index = #self.Ship + 1

		self.Ship[index] = ents.Create( "ggcj_ship" )
			self.Ship[index]:SetPos( SHIPEDITOR_ORIGIN( index ) )
			self.Ship[index]:SetIndex( index )
		self.Ship[index]:Spawn()

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
				SHIPEDITOR_ORIGIN( index ) +
					Vector(
						v.Grid.x + math.floor( v.Collisions.x / 2 ) + part[3].x,
						-v.Grid.y - math.floor( v.Collisions.y / 2 ) + part[3].y
					) * SHIPPART_SIZE,
				Angle( 0, 90 * v.Rotation, 0 ),
				false
			)
			ent:SetColor( COLOUR_UNLIT )
			table.insert( self.Ship[index].Parts, ent )

			-- Temp testing
			if ( math.random( 1, 2 ) == 1 ) then
				local npc = GAMEMODE.CreateEnt( "npc_combine_s", nil, ent:GetPos(), Angle( 0, 0, 0 ) )
					npc:Give( "weapon_ar2" )
					npc:SetHealth( 20 )
					-- npc:SetNoDraw( true )
				table.insert( self.Ship[index].Parts, npc )
			else
				self.Ship[index].SpawnPoint = ent:GetPos() - Vector( 0, 0, 32 )
				ply:SetPos( self.Ship[index].SpawnPoint )
				ply:SetHealth( ply:GetMaxHealth() )
				ply:SetNWEntity( "CurrentShip", index )
				ply.OwnShip = index
			end

			if ( first ) then
				-- ent:SetParent( first )
			else
				first = ent
			end
		end
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
			if ( ship >= 0 and Ship.Ship[ship] and Ship.Ship[ship]:IsValid() and ply:InVehicle() ) then
				Ship.Ship[ship]:MoveInput( ply )
				-- print( ship )
			end
		end
	end )

	-- Command to join other ships for now
	concommand.Add( "ggcj_setship", function( ply, cmd, args )
		ply:SetNWInt( "CurrentShip", tonumber( args[1] ) )
		-- print( args[1] )
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
		local x = 0 -- ScrW() - w
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
						surface.SetDrawColor( COLOUR_WHITE )
						surface.DrawLine( sx, sy, sx + ship:Get2DVelocity().x, sy + ship:Get2DVelocity().y )

						surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
						surface.DrawLine( sx, sy, sx + ship:Forward().x * 100, sy + ship:Forward().y * 100 )

					-- Player ship
					local col = COLOUR_GLASS
						local collide = tablelength( Ship:CheckCollision( ship ) ) > 0
						-- print( collide )
						if ( collide ) then
							col = Color( 255, 0, 100, 255 )
						end
					ship.Pos = self.Pos
					ship:HUDPaint( sx, sy, sw, col )

					-- Draw all other ships based on this position
					local ox, oy = sx, sy
					for k, other in pairs( Ship.Ship ) do
						if ( other != ship ) then
							local sx = sx + ( other:Get2DPos().x - ship:Get2DPos().x )
							local sy = sy + ( other:Get2DPos().y - ship:Get2DPos().y )
							other.Pos = self.Pos
							other:HUDPaint( sx, sy, sw, COLOUR_WHITE )
						
							surface.SetDrawColor( Color( 255, 255, 0, 255 ) )
							surface.DrawLine( ox, oy, sx, sy )
						end
					end
				end
			end
		end
		draw.StencilBasic( mask, inner )
	end

	hook.Add( "PostDrawTranslucentRenderables", "DrawDemoFrame", function()
		local ship = LocalPlayer():GetNWInt( "CurrentShip" )
		-- print( ship )
		if ( ship and ship >= 0 ) then
			local ship = Ship.Ship[ship]
			if ( ship and ship:IsValid() ) then
				local pos = ship:GetMapPos()
				-- local pos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 1
				-- print( pos )
				sampleFrame.Pos = pos
				vgui.Start3D2D( pos, Angle( 0, 0, 90 ), 0.4 )
					sampleFrame:Paint3D2D()
				vgui.End3D2D()
			end
		end
	end )
end

function Ship.CheckCollision( self, ship )
	local collisions = {}
		if ( ship.Size ) then
			local sx = 0
			local sy = 0
			local sw = ( ship.Size.x - 0 ) * SHIPPART_SIZE_2D
			local sh = ( ship.Size.y - 0 ) * SHIPPART_SIZE_2D
			local a = { sx, sy, sw, sh, -ship:Get2DRotation() }

			for k, other in pairs( Ship.Ship ) do
				if ( other != ship and other.Size ) then
					local b = {
						sx + ( other:Get2DPos().x - ship:Get2DPos().x ),
						sy + ( other:Get2DPos().y - ship:Get2DPos().y ),
						( other.Size.x - 1 ) * SHIPPART_SIZE_2D, ( other.Size.y - 1 ) * SHIPPART_SIZE_2D,
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