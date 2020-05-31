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
GM.ShipPartModels		= {
	["1x1"] = {
		Straight = "models/cerus/modbridge/core/s-111.mdl",
		StraightGlass = "models/cerus/modbridge/core/s-111g.mdl",
		End = "models/cerus/modbridge/core/sc-111.mdl",
		EndGlass = "models/cerus/modbridge/core/sc-111g.mdl",
		T = "models/cerus/modbridge/core/t-111.mdl",
		Cross = "models/cerus/modbridge/core/x-111.mdl",
		Corner = "models/cerus/modbridge/core/c-111.mdl",
	},
}
-- Convert from 1 to 3 = models/cerus/modbridge/core/spartan/cv-11-31.mdl
HOOK_PREFIX = "GGC2020_johnjoemcbob_"
COLOUR_BLACK = Color( 0, 0, 0, 255 )
COLOUR_WHITE = Color( 255, 255, 255, 255 )
SHIPEDITOR_ORIGIN = Vector( -489, 426, -21 )
SHIPPART_SIZE = 128 + 22
NET_SHIPEDITOR_SPAWN = "Net_ShipEditor_Spawn"

local CORRWIDTH = 4
SHIPPARTS = {
	["x-111"] = {
		"models/cerus/modbridge/core/x-111.mdl",
		function( self, w, h )
			surface.DrawRect( w / 2 - CORRWIDTH / 2, 0, CORRWIDTH, h )
			surface.DrawRect( 0, h / 2 - CORRWIDTH / 2, w, CORRWIDTH )
		end
	},
	["c-111"] = {
		"models/cerus/modbridge/core/c-111.mdl",
		function( self, w, h )
			local rotation = {
				{ 0.5, 0.5, 0, 0.5 },
				{ 0.5, 0.5, 0.5, 0.5 },
				{ 0.5, 0, 0.5, 0.5 },
				{ 0.5, 0, 0, 0.5 },
			}
			local r = rotation[self.Rotation + 1]
			surface.DrawRect( r[1] * w - CORRWIDTH / 2, r[2] * h, CORRWIDTH, h / 2 + CORRWIDTH / 2 )
			surface.DrawRect( r[3] * w, r[4] * h - CORRWIDTH / 2, w / 2, CORRWIDTH )
		end
	},
	["s-111"] = {
		"models/cerus/modbridge/core/s-111.mdl",
		function( self, w, h )
			local rotation = {
				false,
				true,
				false,
				true,
			}
			local r = rotation[self.Rotation + 1]
			if ( r ) then
				surface.DrawRect( w / 2 - CORRWIDTH / 2, 0, CORRWIDTH, h )
			else
				surface.DrawRect( 0, h / 2 - CORRWIDTH / 2, w, CORRWIDTH )
			end
		end
	},
	["t-111"] = {
		"models/cerus/modbridge/core/t-111.mdl",
		function( self, w, h )
			local cw = CORRWIDTH
			local rotation = {
				{ 0.5, 0.5, w, cw, 0.5, 0.5, cw, h }, -- 0
				{ 1, 0.5, w, cw, 0.5, 0, cw, h + cw }, -- 1
				{ 0.5, 0.5, w, cw, 0.5, -0.5, cw, h }, -- 2
				{ 0, 0.5, w, cw, 0.5, 0, cw, h + cw }, -- 3
			}
			local r = rotation[self.Rotation + 1]
			surface.DrawRect( r[1] * w - r[3] / 2, r[2] * h - cw / 2, r[3], r[4] )
			surface.DrawRect( r[5] * w - r[7] / 2, r[6] * h - cw / 2, r[7], r[8] )
		end
	},
	["sc-111"] = {
		"models/cerus/modbridge/core/sc-111.mdl",
		function( self, w, h )
			local cw = CORRWIDTH
			local rotation = {
				{ 1, 0.5, w, cw }, -- 0
				{ 0.5, -0.5, cw, w }, -- 1
				{ 0, 0.5, w, cw }, -- 2
				{ 0.5, 0.5, cw, w }, -- 3
			}
			local r = rotation[self.Rotation + 1]
			surface.DrawRect( r[1] * w - r[3] / 2, r[2] * h - cw / 2, r[3], r[4] )
		end
	},
	["s-311"] = {
		"models/cerus/modbridge/core/s-311.mdl",
		function( self, w, h )
			local rotation = {
				false,
				true,
				false,
				true,
			}
			local r = rotation[self.Rotation + 1]
			surface.SetDrawColor( Color( 255, 0, 0, 12 ) )
			if ( r ) then
				surface.DrawRect( w / 2 - CORRWIDTH / 2, 0, CORRWIDTH, h )
			else
				surface.DrawRect( 0, h / 2 - CORRWIDTH / 2, w, CORRWIDTH )
			end
		end
	},
}

-- Resources

-- TODO move to util
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Includes (after globals)

-- Create a physics prop which is frozen by default
-- Model (String), Position (Vector), Angle (Angle), Should Move? (bool)
function GM.CreateProp( mod, pos, ang, mov )
	local ent = ents.Create( "prop_physics" )
		ent:SetModel( mod )
		ent:SetPos( pos )
		ent:SetAngles( ang )
		ent:Spawn()
		if ( !mov ) then
			local phys = ent:GetPhysicsObject()
			if ( phys and phys:IsValid() ) then
				phys:EnableMotion( false )
			end
		end
	return ent
end

-- Create an ent which is frozen by default
-- Class (String), Model (String), Position (Vector), Angle (Angle), Should Move? (bool), Should auto spawn? (bool)
function GM.CreateEnt( class, mod, pos, ang, mov, nospawn )
	local ent = ents.Create( class )
		if ( mod ) then
			ent:SetModel( mod )
		end
		ent:SetPos( pos )
		ent:SetAngles( ang )
		if ( !nospawn ) then
			ent:Spawn()
		end
		if ( !mov ) then
			local phys = ent:GetPhysicsObject()
			if ( phys and phys:IsValid() ) then
				phys:EnableMotion( false )
			end
		end
	return ent
end
