--
-- GGC2020_johnjoemcbob
-- 06/06/20
--
-- Clientside Outside Ship Renderings
--

local ASTEROIDS = {
	Vector( 0, 0, 0 ),
}

hook.Add( "PreDrawTranslucentRenderables", HOOK_PREFIX .. "Outside_PreDrawTranslucentRenderables", function()
	local selfship = Ship.GetShip( LocalPlayer() )
	if ( selfship ) then
		local basepos = selfship:GetPosFrom2D()

		-- Render other ships
		-- for k, ship in pairs( Ship.Ship ) do
			-- if ( ship != selfship and ship.Constructor ) then
				-- for _, data in pairs( ship.Constructor ) do
					-- local part = SHIPPARTS[data.Name]
					-- local rot = selfship:Get2DRotation()
					-- local rad = math.rad( rot )
					-- local pos = ( basepos - ship:Get2DPos() )
						-- local mult = SHIPPART_SIZE_2D * 3
						-- pos.x = pos.x * mult
						-- pos.y = pos.y * mult
						-- pos = pos + Ship.GetPartOffset( data )
					-- local localpos = Vector( 0, 0 )
						-- localpos.x = ( pos.x * math.cos( rad ) ) - ( pos.y * math.sin( rad ) )
						-- localpos.y = ( pos.y * math.cos( rad ) ) + ( pos.x * math.sin( rad ) )
						-- localpos.z = pos.z
					-- GAMEMODE.RenderCachedModel(
						-- part[1],
						-- localpos,
						-- Angle( 0, rot + ship:Get2DRotation() + 90 * data.Rotation, 0 ),
						-- Vector( 1, 1, 1 ) * 1
					-- )
				-- end
			-- end
		-- end

		-- Render asteroids
		-- for k, pos in pairs( ASTEROIDS ) do
			-- GAMEMODE.RenderCachedModel(
				-- "models/props_junk/rock001a.mdl",
				-- basepos + pos,
				-- Angle( 0, 0, 0 ),
				-- Vector( 1, 1, 1 ) * 50,
				-- "models/props_pipes/GutterMetal01a"
			-- )
		-- end

		-- Render dust
		-- local dist = 1000
		-- local poses = {
		-- 	Vector( 0, 1, 0 ),
		-- 	Vector( 1, 0, 0 ),
		-- 	Vector( 0, -1, 0 ),
		-- 	Vector( -1, 0, 0 ),
		-- }
		-- for k, pos in pairs( poses ) do
		-- 	GAMEMODE.RenderCachedModel(
		-- 		"models/effects/splodeglass.mdl",
		-- 		pos * dist,
		-- 		Angle( 0, 0, 0 ),
		-- 		Vector( 1, 1, 1 ) * 1
		-- 	)
		-- end
	end
end )
