--[[
			==天炼:CFRoundThinker.lua==
			*********2014.08.10*********
			***********AMHC*************
			============================
				Authors:
				XavierCHN
				...
			============================
]]

-------------------------------------------------------------------------------------------
if CFRoundThinker == nil then
	CFRoundThinker = class({})
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
local ROUND_STATE_PREPARE  = 0
local ROUND_STATE_FIGHTING = 1
local ROUND_STATE_REST     = 2

local ROUND_REST_TIME_BASE = 30
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:InitPara(kv)

	self._nCurrRound = 0
	self._currentState = ROUND_STATE_PREPARE
	self._nRoundRestTime = GameRules:GetGameTime() + ROUND_REST_TIME_BASE
	self._tAllEnemies = {}
	-- 读取所有的怪信息，赋给self._tAllEnemies
	self:ReadAllEnemiesFromKv()
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:Think()
	local cs = self._currentState
	--现在处于什么游戏阶段？ 游戏还没开始？ 正在一轮中？ 还是结束了？ 调用不同的函数
	if cs == ROUND_STATE_PREPARE then
		self:ThinkPrepare()
	elseif cs == ROUND_STATE_FIGHTING then
		self:ThinkFighting()
	elseif cs == ROUND_STATE_REST then
		self:ThinkRest()
	end
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:ThinkPrepare()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- 游戏时间变为0，就开始第一轮
		self._currentState = ROUND_STATE_FIGHTING
		self:StartNextRound()
	else
		--TODO
	end
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:ThinkFighting()
	-- 允许core/CFSpawner.lua 开始刷怪/检测循环
	CFSpawner:Think()

	-- 判断这一轮的怪物是否都被干掉了
	if CFSpawner:IsWaveClear() then

		-- 如果每一轮的怪物都被干掉了
		if self._nCurrRound > #self._tAllEnemies then

			-- 让主程序addon_game_mode.lua结束游戏
			CForgedGameMode:FinishedGame()
		else
			-- 如果还有下一轮，那么久
			self._currentState = ROUND_STATE_FIGHTING
			self._nRoundRestTime = GameRules:GetGameTime() + ROUND_REST_TIME_BASE
		end

	end
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:ThinkRest()
	-- 休息时间结束，就开始下一轮
	if GameRules:GetGameTime() >= self._nRoundRestTime then
		self._currentState = ROUND_STATE_FIGHTING
		self:StartNextRound()
	else

	end
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:ReadAllEnemiesFromKv()
	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )
	if not kv then print('Runtime error, maybe you havent put a mapName KV file in maps/ directory') end
	for k,v in pairs(kv["wave_data"]) do

		-- 读取单位名称，刷怪间隔，数量，等级信息
		local tSingleWaveData = {}
		tSingleWaveData.wavedata = {}
		tSingleWaveData.wavedata.name = v.name
		tSingleWaveData.wavedata.interval = v.spawn_interval
		tSingleWaveData.wavedata.count = v.count
		tSingleWaveData.wavedata.level = v.level
		tSingleWaveData.wavedata.roundtitle = v.RoundTitle
		tSingleWaveData.wavedata.roundquesttitle = v.RoundQuestTitle

		-- 读取刷怪点信息
		if not v["spawner"] then
			print('ERROR: spawner not defined for unit %s in maps/cloudforged.txt')
		else
			-- 读取刷怪点名字和第一个路径点
			tSingleWaveData.spawner = {}
			print('INITINT SPAWNER')
			for sk,sv in pairs(v["spawner"]) do
				local index = tonumber(sk)
				tSingleWaveData.spawner[index] = {}
				tSingleWaveData.spawner[index].name = sv.SpawnerEntityName
				tSingleWaveData.spawner[index].waypoint = sv.FirstPathCorner
			end
		end
		-- 存入self.tAllEnemies
		local i = tonumber(k)
		self._tAllEnemies[i] = tSingleWaveData
	end

end
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
function CFRoundThinker:ReadRoundData(round)
	return self._tAllEnemies[round]
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:StartNextRound()
	-- 轮数 + 1
	self._nCurrRound = self._nCurrRound + 1
	
	-- 读出这一轮怪的信息
	local tRoundData = self:ReadRoundData(self._nCurrRound)
	-- 调用core/CFSpawner.lua开始这一轮刷怪
	CFSpawner:SpawnWave(self._nCurrRound,tRoundData.wavedata,tRoundData.spawner)
end
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function CFRoundThinker:IncreaseRestTime(duration)
	self._nRoundRestTime = self._nRoundRestTime or 0
	self._nRoundRestTime = self._nRoundRestTime + duration
end
-------------------------------------------------------------------------------------------
