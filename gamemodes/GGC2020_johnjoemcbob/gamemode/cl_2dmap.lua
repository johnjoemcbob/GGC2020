--
-- GGC2020_johnjoemcbob
-- 11/06/20
--
-- Clientside 2D Maps
--

Map2D = Map2D or {}

-- Net
net.Receive( NETSTRING_2DMAP_SYSTEM, function( lngth )
	local system = net.ReadTable()

	LocalPlayer().CurrentSystem = system
end )

hook.Add( "HUDPaint", HOOK_PREFIX .. "2dMap_HUDPaint", function()
	-- if ( LocalPlayer().CurrentSystem ) then
	-- 	local x = ScrW() / 4 * 3
	-- 	local y = ScrH() / 2
	-- 	local scale = 32

	-- 	Map2D:Render( x, y, scale )
	-- end
end )

function Map2D:Render( x, y, scale )
	debug.Trace()
	if ( !LocalPlayer().CurrentSystem ) then return end

	local bounds = LocalPlayer().CurrentSystem.Bounds

	-- Draw background
	local size = bounds.Radius * 2 * scale
	draw.NoTexture()
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( x - size / 2, y - size / 2, size, size )

	-- Draw sun
	local sun = LocalPlayer().CurrentSystem.Sun
	if ( sun ) then
		surface.SetDrawColor( 200, 100, 0, 255 )
		draw.Circle( x + sun.Pos.x, y + sun.Pos.y, sun.Radius * scale, 4, 0 )
	end

	-- Draw boundaries
	surface.SetDrawColor( 255, 200, 200, 50 )
	draw.CircleSegment( x + bounds.Pos.x, y + bounds.Pos.y, bounds.Radius * scale, 64, scale / 16, 0, 100 )

	-- Draw bodies
	for k, body in pairs( LocalPlayer().CurrentSystem.Bodies ) do
		if ( body.Orbit ) then
			-- Draw orbital path
			surface.SetDrawColor( 200, 255, 255, 20 )
			draw.CircleSegment( x, y, math.max( body.Pos.x, body.Pos.y ) * scale, 64, scale / 16, 0, 100 )
		end

		-- Draw body
		local segs = 16
		surface.SetDrawColor( 100, 100, 150, 255 )
			if ( body.Type == "JumpPoint" ) then
				surface.SetDrawColor( 100, 0, 255, 255 )
				segs = 3
			end
		draw.Circle( x + body.Pos.x * scale, y + body.Pos.y * scale, body.Radius * scale, segs, 0 )
	end
end
