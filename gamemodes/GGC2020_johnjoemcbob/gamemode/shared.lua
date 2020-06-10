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

-- Convert from 1 to 3 = models/cerus/modbridge/core/spartan/cv-11-31.mdl
HOOK_PREFIX = "GGC2020_johnjoemcbob_"
COLOUR_BLACK		= Color( 0, 0, 0, 255 )
COLOUR_WHITE		= Color( 255, 255, 255, 255 )
COLOUR_LIT			= Color( 255, 255, 255, 255 )
COLOUR_UNLIT		= Color( 100, 100, 100, 255 )
COLOUR_GLASS		= Color( 50, 100, 255, 255 )

-- Ship part size
SHIPPART_SIZE		= 128 + 22
SHIPPART_SIZE_2D	= 8

SHIPEDITOR_ORIGIN	= function( index )
	return Vector( -489, 426, -21 + ( SHIPPART_SIZE + 4 ) * 2 * ( index - 1 ) )
end
NET_SHIPEDITOR_SPAWN = "Net_ShipEditor_Spawn"

local CORRWIDTH = 8
SHIPENDCAP = "models/cerus/modbridge/plate/flat/s11.mdl"
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
		AttachPoints = {
			{ Vector( 1, 0 ), 90 },
			{ Vector( -1, 0 ), 90 },
			{ Vector( 0, 1 ), 0 },
			{ Vector( 0, -1 ), 0 },
		},
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
		AttachPoints = {
			{ Vector( -1, 0 ), 90 },
			{ Vector( 0, 1 ), 0 },
		},
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
	AddCSLuaFile( "sh_util.lua" )
	AddCSLuaFile( "sh_worldtext.lua" )
	AddCSLuaFile( "sh_playerstates.lua" )
	AddCSLuaFile( "sh_ship.lua" )
end
include( "sh_util.lua" )
include( "sh_worldtext.lua" )
include( "sh_playerstates.lua" )
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
