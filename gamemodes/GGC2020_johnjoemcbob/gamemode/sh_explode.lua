
--
-- GGC2020_johnjoemcbob
-- 15/06/20
--
-- Shared Explosions
--

MAT_EXPLOSION = Material( "explosion.png", "nocull 1 smooth 0" )

EXPLOSION_DAMAGE = 100
EXPLOSION_DURATION = 1
EXPLOSION_FRAMES = 64
EXPLOSION_SIZE = 256
EXPLOSION_FORCE = 1000
EXPLOSION_VISUAL_OFFSET = EXPLOSION_SIZE * 1.2

local NETSTRING_EXPLODE = HOOK_PREFIX .. "Explode"
if ( SERVER ) then
	util.AddNetworkString( NETSTRING_EXPLODE )

	function GM:Explode( attacker, pos, radius )
		-- Hurt players/push objects
		for k, v in pairs( ents.FindInSphere( pos, radius ) ) do
			if ( v:IsPlayer() or v:IsNPC() ) then
				local dmg = EXPLOSION_DAMAGE
					if ( v == attacker ) then
						dmg = dmg / 10
					end
				v:TakeDamage( dmg, attacker )
			end
			local dir = ( v:GetPos() - pos ):GetNormalized()
			local phys = v:GetPhysicsObject()
			if ( v:IsPlayer() ) then
				v:SetVelocity( dir * 0.3 * EXPLOSION_FORCE )
			elseif ( phys and phys:IsValid() ) then
				phys:Wake()
				phys:ApplyForceCenter( phys:GetMass() * dir * EXPLOSION_FORCE )
			end
		end

		-- Play sound
		sound.Play( "ambient/explosions/explode_4.wav", pos, 95, 255, 1 )

		-- Net send to clients!
		net.Start( NETSTRING_EXPLODE )
			net.WriteVector( pos )
		net.Broadcast()
	end
end

if ( CLIENT ) then
	net.Receive( NETSTRING_EXPLODE, function( lngth )
		local pos = net.ReadVector()

		-- Store for render
		GAMEMODE:Explode( pos )
	end )

	function GM:Explode( pos )
		LocalPlayer().CurrentExplosions = LocalPlayer().CurrentExplosions or {}
		table.insert( LocalPlayer().CurrentExplosions, { pos, CurTime() } )
	end

	hook.Add( "PostDrawTranslucentRenderables", HOOK_PREFIX .. "Explode_PostDrawTranslucentRenderables", function()
		if ( !LocalPlayer().CurrentExplosions ) then return end

		local toremove = {}
		for k, exp in pairs( LocalPlayer().CurrentExplosions ) do
			local pos = exp[1]
			local time = exp[2]

			-- Change frame based on exist timer
			local progress = math.Clamp( ( CurTime() - time ) / EXPLOSION_DURATION, 0, 1 )
			local frame = math.Round( EXPLOSION_FRAMES * progress )

			-- Render billboard at pos
			local u1, v1, u2, v2 = GetExplosionUVs( frame )
			local ang = GAMEMODE:GetBillboardAngle( true )
			GAMEMODE:DrawBillboardedUVs(
				pos + ang:Up() * EXPLOSION_VISUAL_OFFSET, 0, Vector( 1, 1 ) * EXPLOSION_SIZE,
				MAT_EXPLOSION,
				u1, v1, u2, v2,
				false,
				true
			)

			-- Add to remove array if passed
			if ( progress >= 1 ) then
				table.insert( toremove, k )
			end
		end
		for k, remove in pairs( toremove ) do
			table.remove( LocalPlayer().CurrentExplosions, remove )
		end
	end )
end

function GetExplosionUVs( frame )
	local full = 2048
	local per = 8
	local size = full / per

	local x = math.floor( frame % per )
	local y = math.floor( frame / per )

	local u1 = x * size / full
	local v1 = y * size / full
	local u2 = u1 + size / full
	local v2 = v1 + size / full

	return u1, v1, u2, v2
end
