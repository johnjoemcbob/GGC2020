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

DEBUG_NOSTRIP = false
DEBUG_BOARDING = true
DEBUG_DOORS = true

HOOK_PREFIX			= "GGC2020_johnjoemcbob_"
COLOUR_BLACK		= Color( 0, 0, 0, 255 )
COLOUR_WHITE		= Color( 255, 255, 255, 255 )
COLOUR_LIT			= Color( 255, 255, 255, 255 )
COLOUR_UNLIT		= Color( 100, 100, 100, 255 )
COLOUR_GLASS		= Color( 50, 100, 255, 255 )

-- Net Strings
NETSTRING_2DMAP_SYSTEM = HOOK_PREFIX .. "Net_2DMap_System"

-- Ship part size
SHIPPART_SIZE		= 128 + 22
SHIPPART_SIZE_2D	= 8
MAP2D_TO_SHIP_SCALE = SHIPPART_SIZE_2D * 12

SHIPEDITOR_ORIGIN	= function( index )
	return Vector( -489, 426, -21 + ( SHIPPART_SIZE + 4 ) * 2 * ( index - 1 ) )
end
NET_SHIPEDITOR_SPAWN = "Net_ShipEditor_Spawn"

-- Resources

-- Includes (after globals)
if ( SERVER ) then
	AddCSLuaFile( "sh_util.lua" )
	AddCSLuaFile( "sh_worldtext.lua" )
	AddCSLuaFile( "sh_playerstates.lua" )
	AddCSLuaFile( "sh_explode.lua" )
	AddCSLuaFile( "sh_shipparts.lua" )
	AddCSLuaFile( "sh_ship.lua" )
end
include( "sh_util.lua" )
include( "sh_worldtext.lua" )
include( "sh_playerstates.lua" )
include( "sh_explode.lua" )
include( "sh_shipparts.lua" )
include( "sh_ship.lua" )

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
	local dir = ( ( foot == 1 ) and 1 or -1 )
	ply:EmitSound( "physics/metal/metal_canister_impact_soft2.wav", 75, math.random( 80, 120 ), 0.2 )
	ply:ViewPunch( Angle( 1, 0, 2 * dir ) )
	if ( CLIENT ) then
		-- Punch viewmodel?
		-- ply.ViewModelPos = ply.ViewModelPos + ply:GetRight() * 1 * dir

		GAMEMODE.AddWorldText( pos + Vector( 0, 0, 5 ), Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), 0.1, "tum", COLOUR_WHITE, 0.5, false )
	end
	return true
end

function GM:IsNPC( ent )
	return ( ent:IsNPC() or ent:IsNextBot() )
end
