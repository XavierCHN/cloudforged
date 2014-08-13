--[[
			==天炼:addon_game_mode.lua==
			*********2014.08.10*********
			***********AMHC*************
			============================
				Authors:
				XavierCHN
				...
			============================
]]

-- load everyhing
require('require_everything')

if CForgedGameMode == nil then
	CForgedGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	CForgedGameMode:InitGameMode()
end

function CForgedGameMode:InitGameMode()
	GameRules:SetPreGameTime( 10.0)
 	
 	-- 设定游戏准备时间
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	GameRules:SetPreGameTime(1)

	-- 初始化
	--CFRoundThinker:InitPara()

	ItemCore:Init()
end

-- Evaluate the state of the game
function CForgedGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

		--CFRoundThinker:Think()
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
