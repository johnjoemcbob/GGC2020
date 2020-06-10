--
-- GGC2020_johnjoemcbob
-- 10/06/20
--
-- Shared Player States
--

GM.PlayerStates = GM.PlayerStates or {}

STATE_ERROR = "ERROR"

-- Load all states, add to download (called at bottom)
function includeanddownload()
	local dir = "player_states/"
	local files = {
		"sh_ps_joined",
		"sh_ps_fps",
		"sh_ps_shippilot",
		"sh_ps_toplanetanim",
		"sh_ps_planet",
		"sh_ps_fromplanetanim",
	}
	for k, file in pairs( files ) do
		local path = dir .. file .. ".lua"
		if ( SERVER ) then
			AddCSLuaFile( path )
		end
		include( path )
	end
end

-- Define add state function
function GM.AddPlayerState( name, data )
	GM.PlayerStates[name] = data
end

-- Net
local NETSTRING = HOOK_PREFIX .. "Net_PlayerState"
if ( SERVER ) then
	util.AddNetworkString( NETSTRING )

	function GM.BroadcastPlayerState( ply, oldstate, newstate )
		-- Communicate to client
		net.Start( NETSTRING )
			net.WriteEntity( ply )
			net.WriteString( oldstate )
			net.WriteString( newstate )
		net.Broadcast()
	end
end
if ( CLIENT ) then
	net.Receive( NETSTRING, function( lngth )
		local ply = net.ReadEntity()
		local oldstate = net.ReadString()
		local newstate = net.ReadString()

		-- Start/Finish clientside
		if ( oldstate != STATE_ERROR ) then
			GAMEMODE.PlayerStates[oldstate]:OnFinish( ply )
		end
		GAMEMODE.PlayerStates[newstate]:OnStart( ply )
	end )
end

-- Player meta functions
local meta = FindMetaTable( "Player" )
if ( SERVER ) then
	-- First, Initial state setup
	function meta:SetState( state )
		self:SetNWString( "PlayerState", state )
	end
	-- Start and finish properly
	function meta:SwitchState( state )
		if ( self:GetStateName() == state ) then return end

		local oldstate = self:GetStateName()
		if ( oldstate != STATE_ERROR ) then
			self:GetState():OnFinish( self )
		end
		self:SetState( state )
		self:GetState():OnStart( self )

		-- Send to clients too
		GAMEMODE.BroadcastPlayerState( self, oldstate, state )
	end
end
function meta:GetState()
	return GAMEMODE.PlayerStates[self:GetStateName()]
end
function meta:GetStateName()
	return self:GetNWString( "PlayerState", STATE_ERROR )
end
function meta:HideFPSController()
	if ( !self.LastFPSController ) then
		self.LastFPSController = {
			self:GetPos(),
			self:EyeAngles()
		}
		self:SetPos( Vector( 947, -630, -144 ) )
	end
end
function meta:ShowFPSController()
	if ( self.LastFPSController ) then
		self:SetPos( self.LastFPSController[1] )
		self:SetEyeAngles( self.LastFPSController[2] )
		self.LastFPSController = nil
	end
end

-- Gamemode hooks
hook.Add( "Think", HOOK_PREFIX .. "PlayerStates_Think", function()
	for k, ply in pairs( player.GetAll() ) do
		ply:GetState():OnThink( ply )
	end
end )

-- Show current state on HUD
if ( CLIENT ) then
	hook.Add( "HUDPaint", HOOK_PREFIX .. "PlayerStates_HUDPaint", function()
		draw.SimpleText( LocalPlayer():GetStateName(), "DermaDefault", 50, 50, COLOUR_WHITE )
	end )
end

-- Last, after necessary functions are defined
includeanddownload()