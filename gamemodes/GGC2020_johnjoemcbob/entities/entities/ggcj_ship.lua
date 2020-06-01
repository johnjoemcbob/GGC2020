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
	self:NetworkVar( "Float", 0, "2DAngle" )
	-- self:NetworkVar( "Float", 1, "2DSpeed" )
	self:NetworkVar( "Int", 0, "Index" )

	-- self:SetIndex( -1 )
	self:Set2DPos( Vector( 0, 0, 0 ) )
	self:Set2DVelocity( Vector( 0, 0, 0 ) )
	self:Set2DAngle( 0 )
	-- self:Set2DSpeed( 0 )
end

function ENT:Initialize()
	if ( SERVER ) then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:SetNoDraw( true )
	end

	self.Parts = {}
	self.LateInitialized = false
	self.Acceleration = 1
	self.Speed = 0
	self.MaxSpeed = 1
	self.MaxVelocity = 100
end

function ENT:MoveInput( ply )
	-- Drag/Dampen?
	self:Set2DVelocity( ApproachVector( FrameTime() * self.MaxVelocity / 10, self:Get2DVelocity(), Vector( 0, 0, 0 ) ) )

	-- Input
	local moving = false
		if ( ply:KeyDown( IN_FORWARD ) ) then
			self:AddMove( self:Forward() * self.Speed )
			moving = true
		end
		if ( ply:KeyDown( IN_BACK ) ) then
			self:AddMove( -self:Forward() * self.Speed )
			moving = true
		end
		if ( ply:KeyDown( IN_MOVERIGHT ) ) then
			self:AddMove( self:Right() * self.Speed )
			moving = true
		end
		if ( ply:KeyDown( IN_MOVELEFT ) ) then
			self:AddMove( -self:Right() * self.Speed )
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
		self:Get2DVelocity() + add
		-- Clamp2DVectorLength(
			-- self:Get2DVelocity() + add,
			-- -self.MaxVelocity,
			-- self.MaxVelocity
		-- )
	)
end

function ENT:Think()
	if ( self:GetIndex() != -1 and !self.LateInitialized ) then
		Ship.Ship[self:GetIndex()] = self
		if( SERVER ) then
			Ship:SendToClient( self )
		end

		self.LateInitialized = true
	end

	if ( SERVER ) then
		self:Set2DPos( self:Get2DPos() + self:Get2DVelocity() * FrameTime() )
	end
end

if ( CLIENT ) then
	function ENT:HUDPaint( x, y, scale )
		local cellsize = 12
		surface.SetDrawColor( COLOUR_WHITE )
		if ( self.Constructor ) then
			-- Calculate the max bounds of the ship to get center
			if ( !self.Size ) then
				local min = Vector( 0, 0 )
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
				self.Size = Vector( max.x - min.x, max.y - min.y )
			end
			-- print( self.Size )
			-- local center = Vector( 

			local index = 0
			for k, part in pairs( self.Constructor ) do
				local w = cellsize * SHIPPARTS[part.Name][2].x
				local h = cellsize * SHIPPARTS[part.Name][2].y
				-- surface.SetDrawColor( Color( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ), 255 ) )

				local mat = Matrix()
					-- mat:Rotate( Angle( 0, math.sin( CurTime() ) * 5, 0 ) )
					-- mat:Translate( Vector( x, y ) )
				cam.PushModelMatrix( mat )
					if ( false ) then
						surface.SetDrawColor( COLOUR_WHITE )
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
						surface.SetDrawColor( COLOUR_GLASS )
						SHIPPARTS[part.Name][4](
							part,
							x + ( part.Grid.x - ( self.Size.x / 2 ) ) * cellsize,
							y + ( part.Grid.y - ( self.Size.y / 2 ) ) * cellsize,
							w, h
						)
					end
				cam.PopModelMatrix()
			end
		-- else
			-- surface.DrawRect( x, y, scale, scale )
		end

		draw.SimpleText( self:Get2DPos(), "DermaDefault", x, y, COLOUR_GLASS )
		draw.SimpleText( self:Get2DVelocity(), "DermaDefault", x, y + 16, COLOUR_GLASS )
	end
end

-- TODO implement
function ENT:Forward()
	return Vector( 0, 1 )
end
function ENT:Right()
	return Vector( 1, 0 )
end