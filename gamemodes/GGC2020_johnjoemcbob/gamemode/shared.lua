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

-- Resources

-- TODO move to util
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Includes (after globals)
