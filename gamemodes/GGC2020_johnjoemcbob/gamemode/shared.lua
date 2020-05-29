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

-- Resources


-- Includes (after globals)
