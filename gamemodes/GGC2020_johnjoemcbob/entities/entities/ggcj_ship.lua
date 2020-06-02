--
-- GGC2020_johnjoemcbob
-- 01/06/20
--
-- Shared Ship Entity
--

AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "GGC2020_johnjoemcbob Ship"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "2DPos" )
	self:NetworkVar( "Vector", 1, "2DVelocity" )
	self:NetworkVar( "Float", 0, "2DRotation" )
	-- self:NetworkVar( "Float", 1, "2DSpeed" )
	self:NetworkVar( "Int", 0, "Index" )

	-- self:SetIndex( -1 )
	local range = 20
	self:Set2DPos( Vector( math.random( -range, range ), math.random( -range, range ) ) )
	self:Set2DVelocity( Vector( 0, 0 ) )
	self:Set2DRotation( 0 )
	-- self:Set2DSpeed( 0 )
end

function ENT:Initialize()
	if ( SERVER ) then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:SetNoDraw( true )
	end

	self.Parts = {}
	self.CurrentCollisions = {}
	self.LateInitialized = false
	self.Speed = 0

	self.Multiplier = 4
	self.Acceleration = 100 * self.Multiplier
	self.Decceleration = 100 * self.Multiplier
	self.MaxSpeed = 10 * self.Multiplier
	self.MaxVelocity = 100 * self.Multiplier
end

function ENT:MoveInput( ply )
	if ( tablelength( self.CurrentCollisions ) > 0 ) then return end

	-- Rotation
	-- local dir = ( Vector( 100, 100 ) - Vector( x, y ) ):GetNormalized()
	-- self:Set2DRotation( -math.atan2( dir.x, dir.y ) * 180 / math.pi )
	local pos = self:GetMapPos( ply )
	local vec, ang = WorldToLocal( pos, Angle( 0, 0, 0 ), ply:EyePos(), ply:EyeAngles() )
	local dir = -( Vector( vec.y, vec.z ) - Vector( 200, 200 ) * 0.4 / 2 ):GetNormalized()
		local vel = self:Get2DVelocity()
		if ( vel:LengthSqr() > 0 ) then
			self.Direction = vel:GetNormalized()
		end
	local dir = self.Direction or dir
	self:Set2DRotation( -math.atan2( dir.x, dir.y ) * 180 / math.pi )

	-- Drag/Dampen?
	self:Set2DVelocity( ApproachVector( FrameTime() * self.Decceleration, self:Get2DVelocity(), Vector( 0, 0, 0 ) ) )

	-- Input
	local moving = false
		if ( ply:KeyDown( IN_FORWARD ) ) then
			self:AddMove( self:Forward() * ( self.Speed + FrameTime() * self.Decceleration ) )
			moving = true
		end
		if ( ply:KeyDown( IN_BACK ) ) then
			self:AddMove( -self:Forward() * ( self.Speed + FrameTime() * self.Decceleration ) )
			moving = true
		end
		if ( ply:KeyDown( IN_MOVERIGHT ) ) then
			self:AddMove( self:Right() * ( self.Speed + FrameTime() * self.Decceleration ) )
			-- self:Set2DRotation( self:Get2DRotation() + 1 )
			moving = true
		end
		if ( ply:KeyDown( IN_MOVELEFT ) ) then
			self:AddMove( -self:Right() * ( self.Speed + FrameTime() * self.Decceleration ) )
			-- self:Set2DRotation( self:Get2DRotation() - 1 )
			moving = true
		end

	local target = self.MaxSpeed
		if ( !moving ) then
			target = 0
		end
	self.Speed = Lerp( FrameTime() * self.Acceleration, self.Speed, target )
end

function ENT:AddMove( add )
	self:Set2DVelocity(
		-- self:Get2DVelocity() + add
		Clamp2DVectorLength(
			self:Get2DVelocity() + add,
			-self.MaxVelocity,
			self.MaxVelocity
		)
	)
end

function ENT:Think()
	-- self:Set2DPos( Vector( 0, 0 ) )
	if ( self:GetIndex() != -1 and !self.LateInitialized ) then
		Ship.Ship[self:GetIndex()] = self
		if( SERVER ) then
			Ship:SendToClient( self )
		end

		self.LateInitialized = true
	end

	-- Calculate the max bounds of the ship to get center
	if ( !self.Size and self.Constructor ) then
		local min = Vector( 100, 100 )
		local max = Vector( 0, 0 )
			for k, part in pairs( self.Constructor ) do
				if ( part.Grid.x < min.x ) then
					min.x = part.Grid.x
				end
				if ( part.Grid.x > max.x ) then
					max.x = part.Grid.x
				end
				if ( part.Grid.y < min.y ) then
					min.y = part.Grid.y
				end
				if ( part.Grid.y > max.y ) then
					max.y = part.Grid.y
				end
			end
		self.Min = min
		self.Max = max
		self.Size = Vector( max.x - min.x, max.y - min.y )
	end

	if ( SERVER ) then
		self:Set2DPos( self:Get2DPos() + self:Get2DVelocity() * FrameTime() )

		local collisions = Ship:CheckCollision( self )
		for collide, bool in pairs( collisions ) do
			if ( self.CurrentCollisions[collide] ) then
				self:OnCollisionStay( collide )
			else
				self:OnCollisionStart( collide )

				self.CurrentCollisions[collide] = self:Get2DPos() - Ship.Ship[collide]:Get2DPos()
			end
		end
		local remove = {}
		for old, bool in pairs( self.CurrentCollisions ) do
			if ( !collisions[old] ) then
				self:OnCollisionFinish( old )

				remove[old] = true
			end
		end
		for rmv, bool in pairs( remove ) do
			self.CurrentCollisions[rmv] = nil
		end
	end
end

function ENT:OnCollisionStart( other )
	-- Temp measure to only board in one direction
	if ( self:GetIndex() < other ) then
		-- Board!!
		print( "BOARD " .. other )
		for k, ply in pairs( player.GetAll() ) do
			if ( ply:GetNWInt( "CurrentShip" ) == self:GetIndex() ) then
				if ( ply:InVehicle() ) then
					ply:ExitVehicle()
				end
				ply:SetPos( Ship.Ship[other].SpawnPoint )
				PrintMessage( HUD_PRINTCENTER, "BOARDING" )
			end
		end
	end

	-- Shake
	for k, v in pairs( player.GetAll() ) do
		if ( v:GetNWInt( "CurrentShip" ) == self:GetIndex() ) then
			util.ScreenShake( Vector( 0, 0, 0 ), 5, 5, 1, 5000 )
		end
	end

	-- Sound
	self:EmitSound( "physics/metal/metal_large_debris" .. math.random( 1, 2 ) .. ".wav" )
	
	self:Set2DVelocity( -self:Get2DVelocity() )
end

function ENT:OnCollisionStay( other )
	-- Push back from other ship
	local othership = Ship.Ship[other]
	self:AddMove( self.CurrentCollisions[other] * 50 )
end

function ENT:OnCollisionFinish( other )
	self:Set2DVelocity( Vector( 0, 0 ) )
end

if ( CLIENT ) then
	function ENT:HUDPaint( x, y, scale, col )
		col = table.shallowcopy( col ) -- TODO TEMP REMOVE
		col.a = 100 -- TODO TEMP REMOVE

		local cellsize = SHIPPART_SIZE_2D
		-- surface.SetDrawColor( COLOUR_WHITE )
		if ( self.Constructor ) then
			-- print( self.Size )
			-- local center = Vector( 

			local mat = Matrix()
				-- Translate back onto vgui
				mat:Rotate( Angle( 0, 0, 90 ) )
				-- print( self.Pos.x )
				-- mat:Translate( Vector( self.Pos.x / 3.5, self.Pos.z + 60, -self.Pos.y ) )
				mat:Translate( Vector( 40, self.Pos.z + 60, -self.Pos.y ) )
				-- Translate this ship
				mat:Translate( Vector( x, -y ) )
				mat:Rotate( Angle( 0, -self:Get2DRotation(), 0 ) )
				mat:Translate( Vector(
					-( self.Size.x * cellsize ),
					-( self.Size.y * cellsize )
				) )
			cam.PushModelMatrix( mat )
				local index = 0
				for k, part in pairs( self.Constructor ) do
					local w = cellsize * SHIPPARTS[part.Name][2].x
					local h = cellsize * SHIPPARTS[part.Name][2].y
					-- surface.SetDrawColor( Color( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ), 255 ) )
						if ( false ) then
							surface.SetDrawColor( col )
							-- for cx = 0, SHIPPARTS[part.Name][2].x - 1 do
								-- for cy = 0, SHIPPARTS[part.Name][2].y - 1 do
									local cx = SHIPPARTS[part.Name][2].x
									local cy = SHIPPARTS[part.Name][2].y
										if ( part.Rotation % 2 != 0 ) then
											local temp = cx
											cx = cy
											cy = temp
											-- if ( cx > 3 ) then
												-- cx = cx - 4
											-- end
										end
									surface.DrawRect(
										x + part.Grid.x * cellsize,
										y + part.Grid.y * cellsize,
										w * cx, h * cy
									)
									-- break
								-- end
							-- end
						else
							surface.SetDrawColor( col )
							SHIPPARTS[part.Name][4](
								part,
								( part.Grid.x ) * cellsize,
								( part.Grid.y ) * cellsize,
								w, h
							)
						end
				end
			cam.PopModelMatrix()
		end

		-- local x = gui.MouseX()
		-- local y = gui.MouseY()
		-- surface.DrawRect(
			-- x,
			-- y,
			-- 32, 32
		-- )
		-- local dir = ( Vector( 100, 100 ) - Vector( x, y ) ):GetNormalized()
		-- self:Set2DRotation( -math.atan2( dir.x, dir.y ) * 180 / math.pi )
		-- surface.DrawLine( x, y, x + dir.x * 32, y + dir.y * 32 )
		-- print( dir )
		-- draw.SimpleText( dir, "DermaDefault", x, y + 32 * self:GetIndex(), Color( 255, 255, 255, 10 ) )
		-- draw.SimpleText( self:Get2DVelocity(), "DermaDefault", x, y + 44, Color( 255, 255, 255, 10 ) )
	end
end

function ENT:GetMapPos()
	return Vector( 100, 48, SHIPEDITOR_ORIGIN( self:GetIndex() ).z + 40 )
end

function ENT:Forward()
	-- return Angle( 0, self:Get2DRotation(), 0 ):Right()
	return Vector( 0, -1, 0 )
end
function ENT:Right()
	-- return Angle( 0, self:Get2DRotation(), 0 ):Forward()
	return Vector( 1, 0, 0 )
end