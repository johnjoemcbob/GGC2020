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
COLOUR_LIT = Color( 255, 255, 255, 255 )
COLOUR_UNLIT = Color( 100, 100, 100, 255 )
COLOUR_GLASS = Color( 50, 100, 255, 255 )
SHIPPART_SIZE = 128 + 22
SHIPEDITOR_ORIGIN = function( index )
	return Vector( -489, 426, -21 + ( SHIPPART_SIZE + 4 ) * ( index - 1 ) )
end
NET_SHIPEDITOR_SPAWN = "Net_ShipEditor_Spawn"

local CORRWIDTH = 8
SHIPPARTS = {
	["x-111"] = {
		"models/cerus/modbridge/core/x-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 2, 1, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 3, w, h, self.Rotation )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
	},
	["c-111"] = {
		"models/cerus/modbridge/core/c-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 3, w, h, self.Rotation )
		end,
	},
	["s-111"] = {
		"models/cerus/modbridge/core/s-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
	},
	["t-111"] = {
		"models/cerus/modbridge/core/t-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
			AddRotatableSegment( x, y, 2, 3, w, h, self.Rotation )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
	},
	["sc-111"] = {
		"models/cerus/modbridge/core/sc-111.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
		end,
	},
	["sc-g-111"] = {
		"models/cerus/modbridge/core/sc-111g.mdl",
		Vector( 1, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation )
			surface.SetDrawColor( COLOUR_GLASS )
			AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation )
		end,
	},
	["s-311"] = {
		"models/cerus/modbridge/core/s-311.mdl",
		Vector( 3, 1, 1 ),
		Vector( 0, 0, 0 ),
		function( self, x, y, w, h )
			local segs = 3
			for segx = 1, segs do
				AddRotatableSegment( x, y, 1, 2, w, h, self.Rotation, segx )
				AddRotatableSegment( x, y, 2, 2, w, h, self.Rotation, segx )
				AddRotatableSegment( x, y, 3, 2, w, h, self.Rotation, segx )
			end
		end,
	},
	["x-221"] = {
		"models/cerus/modbridge/core/x-221.mdl",
		Vector( 2, 2, 1 ),
		Vector( -0.5, 0.5, 0 ),
		function( self, x, y, w, h )
			for segx = 1, 2 do
				for segy = 1, 2 do
					for cx = 1, 3 do
						for cy = 1, 3 do
							AddRotatableSegment( x, y, cx, cy, w / 2, h / 2, self.Rotation, segx, segy )
						end
					end
				end
			end
		end,
	},
}

-- Resources

-- Includes (after globals)
if ( SERVER ) then
	AddCSLuaFile( "sh_netvar.lua" )
	AddCSLuaFile( "sh_worldtext.lua" )
	AddCSLuaFile( "sh_ship.lua" )
end
include( "sh_netvar.lua" )
include( "sh_worldtext.lua" )
include( "sh_ship.lua" )

local meta = FindMetaTable( "Player" )

function meta:GetIndex()
	local index = 1
		for k, v in pairs( player.GetAll() ) do
			if ( v == self ) then
				break
			end
			index = index + 1
		end
	return index
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
	local dir = ( ( foot == 1 ) and 1 or -1 )
	ply:EmitSound( "physics/metal/metal_canister_impact_soft2.wav", 75, math.random( 80, 120 ), 0.2 )
	ply:ViewPunch( Angle( 1, 0, 2 * dir ) )
	if ( CLIENT ) then
		-- Punch viewmodel?
		-- ply.ViewModelPos = ply.ViewModelPos + ply:GetRight() * 1 * dir

		GAMEMODE.AddWorldText( pos + Vector( 0, 0, 5 ), Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), 0.1, "tum", 0.5, false )
	end
	return true
end

-- TODO move to util
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function UnNaNVector( vector, default )
	-- NaN isn't equal to itself
	if ( vector and vector.x == vector.x and vector.y == vector.y and vector.z == vector.z ) then
		return vector
	end
	if ( default ) then
		return default
	end
	return Vector( 0, 0, 0 )
end
function UnNaNAngle( angle, default )
	-- NaN isn't equal to itself
	if ( angle and angle.x == angle.x and angle.y == angle.y and angle.z == angle.z ) then
		return angle
	end
	if ( default ) then
		return default
	end
	return Angle( 0, 0, 0 )
end

-- function ClampVectorLength( vec, min, max )
	-- min = min:
	-- if ( vec:LengthSqr() < min
	-- local dir = vec:GetNormalized()
	-- local
-- end

function Clamp2DVectorLength( vec, min, max )
	-- Square these instead of rooting the length
	local minsqr = min * min
	local maxsqr = max * max

	local lensqr = vec:LengthSqr()
	if ( lensqr < minsqr or lensqr > maxsqr ) then
		-- At least don't have to sqrroot when inside range? idk
		local len = vec:Length()

		local dir = vec:GetNormalized()
		return ( dir * math.Clamp( len, min, max ) )
	else
		return vec
	end
end

function ApproachVector( change, current, target )
	return Vector(
		math.Approach( current.x, target.x, change ),
		math.Approach( current.y, target.y, change ),
		math.Approach( current.z, target.z, change )
	)
end

function GetPrettyVector( vector )
	return "Vector( " .. math.Round( vector.x ) .. ", " .. math.Round( vector.y ) .. " " .. math.Round( vector.z ) .. " )"
end

-- Make a shallow copy of a table (from http://lua-users.org/wiki/CopyTable)
-- Extended for recursive tables
function table.shallowcopy( orig )
    local orig_type = type( orig )
    local copy
    if ( orig_type == "table" ) then
        copy = {}
        for orig_key, orig_value in pairs( orig ) do
			if ( type( orig_value ) == "table" ) then
				copy[orig_key] = table.shallowcopy( orig_value )
			else
				copy[orig_key] = orig_value
			end
        end
	-- Number, string, boolean, etc
    else
        copy = orig
    end
    return copy
end

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
