--
-- GGC2020_johnjoemcbob
-- 11/06/20
--
-- Serverside 2D Maps
--

Map2D = Map2D or {}
Map2D.Systems = Map2D.Systems or {}

ZONE_TYPE_SYSTEM = 0
ZONE_TYPE_HYPERLANE = 1

-- Dynamic file loading
local PATH = HOOK_PREFIX .. "/systems/"

-- Load all systems
function Map2D:LoadSystem( name )
	return LoadTableFromJSON( PATH, name )
end
local function load() -- Called last
	ForAllDataFilesInDir( PATH, function( name )
		Map2D.Systems[name] = Map2D:LoadSystem( name )
		Map2D:SendToPlayer( Entity(1), name )
	end )
end

-- Net
util.AddNetworkString( NETSTRING_2DMAP_SYSTEM )

function Map2D:SendToPlayer( ply, zone )
	ply:SetNWString( "2dMapZone", zone )

	-- Communicate to client
	net.Start( NETSTRING_2DMAP_SYSTEM )
		net.WriteTable( Map2D.Systems[zone] )
	net.Send( ply )
end

-- Updates
local temp = false
hook.Add( "Think", HOOK_PREFIX .. "2DMap_Think", function()
	for id, system in pairs( Map2D.Systems ) do
		-- Update 2d bodies
		-- e.g. planets orbit sun, etc
		-- send update to players in this system
		local ship = Ship.GetShip( Entity(1) )
		local body = system.Bodies["PlanetTest"]
		if ( ship and body ) then
			local dist = ship:Get2DPos():Distance( body.Pos * MAP2D_TO_SHIP_SCALE )
			--print( dist )
			if ( dist < 20 ) then
				if ( !temp ) then
					local ply = Entity(1)
					if ( ply:GetStateName() == STATE_FPS ) then
						ply:SwitchState( STATE_TO_PLANET_ANIM )
						temp = true
					end
				end
			else
				temp = false
			end
		end
	end
end )

-- Setters
function Map2D:SetEntityZone( ent, zone, systemid )
	if ( zone == ZONE_TYPE_SYSTEM ) then
		zone = systemid
	end

	ent:SetCurrentZone( zone )

	-- For all players inside this ship, send local system map data
	if ( ent:GetClass() == "ggcj_ship" ) then
		for k, ply in pairs( player.GetAll() ) do
			if ( ply:GetNWInt( "CurrentShip" ) == ent:GetIndex() ) then
				Map2D:SendToPlayer( ply, zone, systemid )
			end
		end
	end
end

-- Load all, last - after function definitions
hook.Add( "InitPostEntity", HOOK_PREFIX .. "2DMap_InitPostEntity", function() 
	load()
end )
load()

-- Load system layouts from data files
	-- Expect a sun in the middle, maybe let it scale
	-- Place planets with their orbit params
	-- Place jump points at stationary positions
	-- System bounds

-- Create test planet file format
-- local tab = {
-- 	Sun = {
-- 		Pos = Vector( 0, 0 ),
-- 		Radius = 1,
-- 	},
-- 	Bounds = {
-- 		Pos = Vector( 0, 0 ),
-- 		Radius = 3
-- 	},
-- 	Bodies = {
-- 		PlanetTest = {
-- 			Type = "Planet",
-- 			Pos = Vector( 2, 0 ),
-- 			Radius = 0.5,
-- 			Orbit = "Sun",
-- 		},
-- 	},
-- }
-- local json = util.TableToJSON( tab, true )
-- file.Write( HOOK_PREFIX .. "system.json", json )
-- print( json )