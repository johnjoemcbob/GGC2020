--
-- GGC2020_johnjoemcbob
-- 03/06/20
--
-- Clientside Billboard
--

local mat = Material( "detail/detailsprites" )
MESH_BILLBOARD = Mesh()

-- Setup verts
local size = 80
local verts = {
	{ pos = Vector( 0, 0 ), u = 0, v = 0 },
	{ pos = Vector( 1, 0 ), u = 1, v = 0 },
	{ pos = Vector( 1, 1 ), u = 1, v = 1 },
	{ pos = Vector( 1, 1 ), u = 1, v = 1 },
	{ pos = Vector( 0, 1 ), u = 0, v = 1 },
	{ pos = Vector( 0, 0 ), u = 0, v = 0 },
}

-- Create mesh
mesh.Begin( MESH_BILLBOARD, MATERIAL_TRIANGLES, #verts / 3 )
	for i = 1, #verts do
		mesh.Position( Vector( verts[i].pos.x * size, 0, verts[i].pos.y * size ) )
		mesh.TexCoord( 0, verts[i].u, verts[i].v )
		mesh.AdvanceVertex()
	end
mesh.End()

-- Functions
function GM:DrawBillboardedEnt( ent, material )
	self:DrawBillboardedEntBase( ent, material, function()
		MESH_BILLBOARD:Draw()
	end )
end

function GM:DrawBillboardedEntUVs( ent, material, u1, v1, u2, v2 )
	self:DrawBillboardedEntBase( ent, material, function()
		GAMEMODE:DrawMeshPlane( size, size, u1, v1, u2, v2 )
	end )
end

function GM:DrawBillboardedEntBase( ent, material, draw )
	mat:SetTexture( "$basetexture", material:GetTexture( "$basetexture" ) )

	local width = 0.5
	render.SetLightingMode( 2 )
		render.SetMaterial( mat )
		local matrix = Matrix()
			matrix:Translate( ent:GetPos() )
			local ang = LocalPlayer():EyeAngles()
				ang.p = 0
				ang.r = 0
				ang:RotateAroundAxis( ang:Right(), 180 )
				ang:RotateAroundAxis( ang:Up(), 90 )
			matrix:Rotate( ang )
			matrix:Translate( Vector( 0, 0, 1 ) * ( -size * 0.9 ) )
			matrix:Translate( Vector( 1, 0, 0 ) * -size / 2 * width )
			matrix:Scale( Vector( width, 1, 1 ) )
		cam.PushModelMatrix( matrix )
			draw()
		cam.PopModelMatrix()
	render.SetLightingMode( 0 )
end

function GM:DrawBillboardedUVs( pos, size, material, u1, v1, u2, v2, left )
	if ( left ) then
		local temp = u1
		u1 = u2
		u2 = temp
	end

	mat:SetTexture( "$basetexture", material:GetTexture( "$basetexture" ) )

	render.SetLightingMode( 2 )
		render.SetMaterial( mat )
		local matrix = Matrix()
			matrix:Translate( pos )
			local ang = LocalPlayer():EyeAngles()
				ang.p = 0
				ang.r = 0
				ang:RotateAroundAxis( ang:Up(), 90 )
				-- ang:RotateAroundAxis( ang:Forward(), 180 )
				ang:RotateAroundAxis( ang:Right(), 180 )
			matrix:Rotate( ang )
			matrix:Translate( Vector( 0, 1, 0 ) )
			matrix:Translate( Vector( 1, 0, 0 ) * -size.x / 2 )
			matrix:Translate( Vector( 0, 0, 1 ) * size.y * -1.8 )
			-- matrix:Scale( size )
		cam.PushModelMatrix( matrix )
			GAMEMODE:DrawMeshPlane( size.x, size.y, u1, v1, u2, v2 )
		cam.PopModelMatrix()
	render.SetLightingMode( 0 )
end

function GM:DrawMeshPlane( w, h, u1, v1, u2, v2 )
	local us = {}
		us[0] = u1
		us[1] = u2
	local vs = {}
		vs[0] = v1
		vs[1] = v2
	mesh.Begin( MATERIAL_TRIANGLES, #verts / 3 )
		for i = 1, #verts do
			mesh.Position( Vector( verts[i].pos.x * w, 0, verts[i].pos.y * h ) )
			mesh.TexCoord( 0, us[verts[i].u], vs[verts[i].v] )
			mesh.AdvanceVertex()
		end
	mesh.End()
end