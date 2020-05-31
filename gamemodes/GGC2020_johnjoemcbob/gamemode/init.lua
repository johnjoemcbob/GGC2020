--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Serverside
--

-- LUA Downloads
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_modelcache.lua" )
AddCSLuaFile( "cl_shipeditor.lua" )

-- LUA Includes
include( "shared.lua" )

-- Resources
resource.AddFile( "materials/pixel.vtf" )

-- Net
util.AddNetworkString( NET_SHIPEDITOR_SPAWN )
net.Receive( NET_SHIPEDITOR_SPAWN, function( len, ply )
	-- Load ship data
	local json = file.Read( HOOK_PREFIX .. "/ship.txt" )
	local tab = util.JSONToTable( json )

	local first = nil
	for k, v in pairs ( tab ) do
		local part = SHIPPARTS[v.Name]
		local ent = GAMEMODE.CreateProp( part[1], SHIPEDITOR_ORIGIN + Vector( v.Grid.x, -v.Grid.y ) * SHIPPART_SIZE, Angle( 0, 90 * v.Rotation, 0 ), false )

		if ( first ) then
			ent:SetParent( first )
		else
			first = ent
		end
	end
end )

------------------------
  -- Gamemode Hooks --
------------------------
function GM:Initialize()
	
end

function GM:InitPostEntity()
	
end

function GM:Think()
	
end

function GM:PlayerDisconnected( ply )
	
end
-------------------------
  -- /Gamemode Hooks --
-------------------------
