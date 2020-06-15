--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Client Projectile Entity
--

include( "shared.lua" )

local speed = 10
local count = 7
MAT_PROJECTILE = {}
for i = 1, count do
	MAT_PROJECTILE[i] = Material( "projectile/1/Arcane_Effect_" .. i .. ".png", "nocull 1 smooth 0" )
end

function ENT:Initialize()
	
end

function ENT:Draw()
	--self:DrawModel() -- temp

	local size = 120 * self:GetModelScale()
	local frame = math.floor( CurTime() * speed % count + 1 )
	GAMEMODE:DrawBillboardedEntSize( self, MAT_PROJECTILE[frame], size, size )
end
