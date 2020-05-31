--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Shared
--

GM.Name = "GGC2020_johnjoemcbob"
GM.Author = "johnjoemcbob"
GM.Email = ""
GM.Website = ""

-- Base Game
GM.DERIVE_SANDBOX = true
if GM.DERIVE_SANDBOX then
	DeriveGamemode( "Sandbox" ) -- For testing purposes, nice to have spawn menu etc
else
	DeriveGamemode( "base" )
end

-- Globals
GM.Epsilon				= 0.001
GM.GamemodePath			= "gamemodes/GGC2020_johnjoemcbob/"
GM.ShipPartModels		= {
	["1x1"] = {
		Straight = "models/cerus/modbridge/core/s-111.mdl",
		StraightGlass = "models/cerus/modbridge/core/s-111g.mdl",
		End = "models/cerus/modbridge/core/sc-111.mdl",
		EndGlass = "models/cerus/modbridge/core/sc-111g.mdl",
		T = "models/cerus/modbridge/core/t-111.mdl",
		Cross = "models/cerus/modbridge/core/x-111.mdl",
		Corner = "models/cerus/modbridge/core/c-111.mdl",
	},
}
-- Convert from 1 to 3 = models/cerus/modbridge/core/spartan/cv-11-31.mdl
HOOK_PREFIX = "GGC2020_johnjoemcbob_"
COLOUR_BLACK = Color( 0, 0, 0, 255 )
COLOUR_WHITE = Color( 255, 255, 255, 255 )
SHIPEDITOR_ORIGIN = Vector( -489, 426, -21 )
SHIPPART_SIZE = 128 + 22
NET_SHIPEDITOR_SPAWN = "Net_ShipEditor_Spawn"

local CORRWIDTH = 4
SHIPPARTS = {
	["x-111"] = {
		"models/cerus/modbridge/core/x-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, w, h )
			-- surface.DrawRect( w / 2 - CORRWIDTH / 2, 0, CORRWIDTH, h )
			-- surface.DrawRect( 0, h / 2 - CORRWIDTH / 2, w, CORRWIDTH )
			AddRotatableSegment( 2, 1, w, h, self.Rotation )
			AddRotatableSegment( 2, 2, w, h, self.Rotation )
			AddRotatableSegment( 2, 3, w, h, self.Rotation )
			AddRotatableSegment( 1, 2, w, h, self.Rotation )
			AddRotatableSegment( 3, 2, w, h, self.Rotation )
		end,
	},
	["c-111"] = {
		"models/cerus/modbridge/core/c-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, w, h )
			AddRotatableSegment( 1, 2, w, h, self.Rotation )
			AddRotatableSegment( 2, 2, w, h, self.Rotation )
			AddRotatableSegment( 2, 3, w, h, self.Rotation )
		end,
	},
	["s-111"] = {
		"models/cerus/modbridge/core/s-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, w, h )
			AddRotatableSegment( 1, 2, w, h, self.Rotation )
			AddRotatableSegment( 2, 2, w, h, self.Rotation )
			AddRotatableSegment( 3, 2, w, h, self.Rotation )
		end,
	},
	["t-111"] = {
		"models/cerus/modbridge/core/t-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, w, h )
			AddRotatableSegment( 1, 2, w, h, self.Rotation )
			AddRotatableSegment( 2, 2, w, h, self.Rotation )
			AddRotatableSegment( 2, 3, w, h, self.Rotation )
			AddRotatableSegment( 3, 2, w, h, self.Rotation )
		end,
	},
	["sc-111"] = {
		"models/cerus/modbridge/core/sc-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, w, h )
			AddRotatableSegment( 3, 2, w, h, self.Rotation )
		end,
	},
	["sc-g-111"] = {
		"models/cerus/modbridge/core/sc-111g.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, w, h )
			AddRotatableSegment( 3, 2, w, h, self.Rotation )
		end,
	},
	["s-311"] = {
		"models/cerus/modbridge/core/s-311.mdl",
		Vector( 3, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, w, h )
			for x = 1, 3 do
				AddRotatableSegment( 1, 2, w, h, self.Rotation, x )
				AddRotatableSegment( 2, 2, w, h, self.Rotation, x )
				AddRotatableSegment( 3, 2, w, h, self.Rotation, x )
			end
		end,
	},
	["x-221"] = {
		"models/cerus/modbridge/core/x-221.mdl",
		Vector( 2, 2, 1 ),
		Vector( -0.5, 0.5, 0 ),
		function( self, w, h )
			-- Just a big ol' square
			surface.DrawRect( 0, 0, w, h )
		end,
	},
}

-- Resources

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf ) 
	ply:EmitSound( "physics/metal/metal_canister_impact_soft2.wav", 75, math.random( 80, 120 ), 0.2 )
	ply:ViewPunch( Angle( 1, 0, 2 * ( ( foot == 1 ) and 1 or -1 ) ) )
	return true
end

-- TODO move to util
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function UnNaN( vector )
	-- NaN isn't equal to itself
	if ( vector.x == vector.x and vector.y == vector.y and vector.z == vector.z ) then
		return vector
	end
	return Vector( 0, 0, 0 )
end

-- Includes (after globals)

-- Create a physics prop which is frozen by default
-- Model (String), Position (Vector), Angle (Angle), Should Move? (bool)
function GM.CreateProp( mod, pos, ang, mov )
	local ent = ents.Create( "prop_physics" )
		ent:SetModel( mod )
		ent:SetPos( pos )
		ent:SetAngles( ang )
		ent:Spawn()
		if ( !mov ) then
			local phys = ent:GetPhysicsObject()
			if ( phys and phys:IsValid() ) then
				phys:EnableMotion( false )
			end
		end
	return ent
end

-- Create an ent which is frozen by default
-- Class (String), Model (String), Position (Vector), Angle (Angle), Should Move? (bool), Should auto spawn? (bool)
function GM.CreateEnt( class, mod, pos, ang, mov, nospawn )
	local ent = ents.Create( class )
		if ( mod ) then
			ent:SetModel( mod )
		end
		ent:SetPos( pos )
		ent:SetAngles( ang )
		if ( !nospawn ) then
			ent:Spawn()
		end
		if ( !mov ) then
			local phys = ent:GetPhysicsObject()
			if ( phys and phys:IsValid() ) then
				phys:EnableMotion( false )
			end
		end
	return ent
end
