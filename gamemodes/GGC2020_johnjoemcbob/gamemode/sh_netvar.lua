--
-- GGC2020_johnjoemcbob
-- 01/05/20
--
-- Shared Networked Variables (for non-ents)
--
-- TODO Maybe just use a custom ent class instead? to communicate any global vars
-- TODO optimise by not using a table for everything... jesus
-- TODO optimise for only send updates, store last sent to client
-- TODO support late player joins

GM.NetVars = GM.NetVars or {}

local NETSTRING = HOOK_PREFIX .. "NetVar"

-- Net
if ( SERVER ) then
	util.AddNetworkString( NETSTRING )

	function GM.AddNetVar( type, var, val )
		-- Store serverside
		GAMEMODE.SetNetVar( type, var, val )

		-- Communicate var to client
		net.Start( NETSTRING )
			net.WriteString( type )
			net.WriteString( var )
			net.WriteTable( { val } )
		net.Broadcast()
	end
end
if ( CLIENT ) then
	net.Receive( NETSTRING, function( lngth )
		local type = net.ReadString()
		local var = net.ReadString()
		local val = net.ReadTable()[1]

		-- Store clientside
		GAMEMODE.SetNetVar( type, var, val )
	end )
end

-- Shared
function GM.SetNetVar( type, var, val )
	GAMEMODE.NetVars[var] = val
end
