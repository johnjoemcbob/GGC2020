--
-- GGC2020_johnjoemcbob
-- 29/05/20
--
-- Main Clientside
--

include( "includes/modules/3d2dvgui.lua" )

include( "shared.lua" )

include( "cl_billboard.lua" )
include( "cl_modelcache.lua" )
include( "cl_player.lua" )
include( "cl_moduleeditor.lua" )
include( "cl_shipeditor.lua" )
include( "cl_outsiderender.lua" )
include( "cl_scene.lua" )
include( "cl_2dmap.lua" )

------------------------
  -- Gamemode Hooks --
------------------------
function GM:Initialize()
	LocalPlayer().ViewModelPos = Vector( 0, 0, 0 )
	LocalPlayer().ViewModelAngles = Angle( 0, 0, 0 )
end

function GM:Think()
	
end

function GM:PreRender()
	render.SetLightingMode( 0 )

	-- local dlight = DynamicLight( LocalPlayer():EntIndex() )
	-- if ( dlight ) then
		-- dlight.pos = LocalPlayer():GetPos() + Vector( 0, 0, 32 )
		-- dlight.r = 255
		-- dlight.g = 10
		-- dlight.b = 110
		-- dlight.brightness = 2
		-- dlight.Decay = 1000
		-- dlight.Size = 256 * 3
		-- dlight.DieTime = CurTime() + 1
	-- end
end

function GM:PostDrawOpaqueRenderables()
	for k, npc in pairs( ents.FindByClass( "npc_combine_s" ) ) do
		npc.RenderOverride = function( self )
			local wep = self:GetActiveWeapon()
			if ( wep and wep:IsValid() ) then
				wep:SetNoDraw( true )
			end

			GAMEMODE:PrePlayerDraw( self )
		end
	end
end

function GM:HUDPaint()
	render.SetLightingMode( 0 )

	-- Testing collision + rotation code!
	-- local x = ScrW() / 4 * 3
	-- local y = ScrH() / 2
	-- local w = 64
	-- local h = 32
	-- local a = { x, y, w, h, 0 }
	-- local b = {
		-- x + math.sin( CurTime() ) * w * 2,
		-- y + math.cos( CurTime() + 1 ) * h * 2,
		-- w, h,
		-- math.sin( CurTime() + 2 ) * 360
	-- }
	-- local b = {
		-- gui.MouseX(),
		-- gui.MouseY(),
		-- w, h,
		-- math.sin( CurTime() + 2 ) * 360
	-- }
	-- surface.SetDrawColor( COLOUR_WHITE )
	-- if ( intersect_squares( a, b ) ) then
		-- surface.SetDrawColor( COLOUR_GLASS )
	-- end
	-- surface.DrawTexturedRectRotated( a[1], a[2], a[3], a[4], a[5] )
	-- surface.DrawTexturedRectRotated( b[1], b[2], b[3], b[4], b[5] )
end

local hide = {
	["CHudCrosshair"] = true,
	--["CHudHealth"] = true,
	["CHudBattery"] = true,
	--["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudDamageIndicator"] = true,
}
function GM:HUDShouldDraw( name )
	if ( hide[ name ] ) then return false end

	return true
end
-------------------------
  -- /Gamemode Hooks --
-------------------------

-- More in sh_util.lua
function draw.Circle( x, y, radius, seg, rotate )
	local cir = GAMEMODE.GetCirclePoints( x, y, radius, seg, rotate )
	surface.DrawPoly( cir )
end

function draw.CircleSegment( x, y, radius, seg, thickness, offset, percent, drawlater )
	if ( thickness == 0 ) then
		return draw.Circle( x, y, radius, seg )
	end

	local shapes = {}

	local minseg = seg * offset / 100
	local maxseg = seg * ( percent + offset ) / 100
	local numsegrow = maxseg - minseg + 1 -- Extra one each row

	local cirtotal, cirtotalx, cirtotaly = 0, 0, 0

	for currentseg = minseg, maxseg - 1 do
		local cir = {}
			-- 1
			local a = math.rad( ( ( currentseg / seg ) * -360 ) )
			table.insert( cir, {
				x = x + math.sin( a ) * ( radius - thickness ),
				y = y + math.cos( a ) * ( radius - thickness ),
				u = math.sin( a ) / 2 + 0.5,
				v = math.cos( a ) / 2 + 0.5
			} )
				cirtotalx = cirtotalx + cir[#cir].x
				cirtotaly = cirtotaly + cir[#cir].y
				cirtotal = cirtotal + 1
			-- 3
			local a = math.rad( ( ( currentseg / seg ) * -360 ) )
			table.insert( cir, {
				x = x + math.sin( a ) * ( radius ),
				y = y + math.cos( a ) * ( radius ),
				u = math.sin( a ) / 2 + 0.5,
				v = math.cos( a ) / 2 + 0.5
			} )
				cirtotalx = cirtotalx + cir[#cir].x
				cirtotaly = cirtotaly + cir[#cir].y
				cirtotal = cirtotal + 1
			-- 4
			local a = math.rad( ( ( ( currentseg + 1 ) / seg ) * -360 ) )
			table.insert( cir, {
				x = x + math.sin( a ) * ( radius ),
				y = y + math.cos( a ) * ( radius ),
				u = math.sin( a ) / 2 + 0.5,
				v = math.cos( a ) / 2 + 0.5
			} )
				cirtotalx = cirtotalx + cir[#cir].x
				cirtotaly = cirtotaly + cir[#cir].y
				cirtotal = cirtotal + 1

			-- 1
			local a = math.rad( ( ( currentseg / seg ) * -360 ) )
			table.insert( cir, {
				x = x + math.sin( a ) * ( radius - thickness ),
				y = y + math.cos( a ) * ( radius - thickness ),
				u = math.sin( a ) / 2 + 0.5,
				v = math.cos( a ) / 2 + 0.5
			} )
			-- 4
			local a = math.rad( ( ( ( currentseg + 1 ) / seg ) * -360 ) )
			table.insert( cir, {
				x = x + math.sin( a ) * ( radius ),
				y = y + math.cos( a ) * ( radius ),
				u = math.sin( a ) / 2 + 0.5,
				v = math.cos( a ) / 2 + 0.5
			} )
			-- 2
			local a = math.rad( ( ( ( currentseg + 1 ) / seg ) * -360 ) )
			table.insert( cir, {
				x = x + math.sin( a ) * ( radius - thickness ),
				y = y + math.cos( a ) * ( radius - thickness ),
				u = math.sin( a ) / 2 + 0.5,
				v = math.cos( a ) / 2 + 0.5
			} )
				cirtotalx = cirtotalx + cir[#cir].x
				cirtotaly = cirtotaly + cir[#cir].y
				cirtotal = cirtotal + 1
		if ( not drawlater ) then
			surface.DrawPoly( cir )
		else
			table.insert( shapes, cir )
		end
	end

	local centerx, centery
		centerx = cirtotalx / cirtotal
		centery = cirtotaly / cirtotal
	return centerx, centery, shapes
	-- local a = math.rad( ( ( minseg / seg ) * -360 ) )
	-- return ( x + math.sin( a ) * ( radius - thickness ) ), ( y + math.cos( a ) * ( radius - thickness ) )
end

function draw.StencilBasic( mask, inner )
	render.ClearStencil()
	render.SetStencilEnable( true )
		render.SetStencilWriteMask( 255 )
		render.SetStencilTestMask( 255 )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetBlend( 0 ) --makes shit invisible
		render.SetStencilReferenceValue( 10 )
			mask()
		render.SetBlend( 1 )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
			inner()
	render.SetStencilEnable( false )
end

concommand.Add( "ggcj_getpos", function( ply, cmd, args )
	print( GetPrettyVector( ply:GetPos() ) )
end )

concommand.Add( "ggcj_getent", function( ply, cmd, args )
	-- TODO get trace ent and displays
end )

concommand.Add( "ggcj_getprops", function( ply, cmd, args )
	-- Get trace entity
	local tr = util.TraceLine( {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
		filter = ply,
	} )

	local function add( ent, pos, ang )
		return "	{\n" ..
			"		\"" .. ent:GetModel() .. "\",\n" ..
			"		" .. GetPrettyVector( pos ) .. ",\n" ..
			"		" .. GetPrettyAngle( ang ) .. ",\n" ..
		"	},\n"
	end

	local formatted = "{\n"
	if ( tr.Entity ) then
		-- Add first at zero
		local pos_base = tr.Entity:GetPos()
		local ang_base = tr.Entity:GetAngles()
		local pos = Vector( 0, 0, 0 )
		local ang = Angle( 0, 0, 0 )
		formatted = formatted .. add( tr.Entity, pos, ang )

		-- Find all other props
		for k, ent in pairs( ents.FindByClass( "prop_physics" ) ) do
			if ( ent != tr.Entity ) then
				-- Their position relative to this base ent
				pos = ent:GetPos() - pos_base
				ang = ent:GetAngles() - ang_base
				formatted = formatted .. add( ent, pos, ang )
			end
		end
	end
	formatted = formatted .. "}"

	print( formatted )
end )
