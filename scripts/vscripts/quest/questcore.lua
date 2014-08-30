

local MAX_QUEST_LIMIT = 5

if QuestCore == nil then
	QuestCore = class({})
end

function QuestCore:Init()
	self._allQuests = {}
	self._questRefund = {}
	self:ReadAllQuestsFromKV()
end

function QuestCore:ReadAllQuestsFromKV()
	local kv = LoadKeyValues("scripts/quests/AllQuests.txt")
	if not kv then return end
	for k,v in pairs(kv) do
		self._allQuests[k].name = v.name
		self._allQuests[k].requirement = v.requerement
		self._questRefund.type = v.refund.type
		self._questRefund.value = v.refund.value
	end
end

-- 返回玩家是否已经完成某个任务
function QuestCore:GetQustFlag(playerid, questid)
	return self._questfinished[questid][playerid]
end

-- 返回玩家任务数量是否已经达到上限
function QuestCore:IsQuestSpaceLeft(playerid)
	if self._acceptedQuests[player] >= MAX_QUEST_LIMIT then
		return false
	end
	return true
end

-- 获取任务名称 #Quest_Name_my_quest
function QuestCore:GetQuestName(questid)
	return "#Quest_Name_"..self._allQuests[questid].name
end

-- 获取任务描述 #Quest_Description_my_quest
function QuestCore:GetQuestDescription(questid)
	return "#Quest_Description_"..self._allQuests[questid].name
end

-- 检测玩家身上是否持有所有任务物品
function QuestCore:CheckHaveAllQuestItems(playerid, targetitemtable)
	local target_items = targetitemtable
	local player = PlayerResource:GetPlayer(playerid)
	local hero = player:GetAssignedHero()
	for i = 0, 11 do
		local ITEM = hero:GetItemInSlot(i)
		if ITEM then
			table.foreach(target_items, 
				function(k,v)
					if v == ITEM:GetName() then
						v = nil
					end
				end
			)
		end
	end
	if #target_items == 0 then
		return true
	else
		print("QUEST CORE: QUEST ITEM NOT FOUND")
		for k,v in pairs(target_items) do
			print(k,v)
		end
	end
end

-- 给予任务奖励物品
function QuestCore:GiveQuestRefund(playerid, questid)
	for _,refund in pairs(self._questRefund[questid]) do
		if refund.type == "exp" then
			--TODO 经验奖励
		elseif refund.type == "item" then
			-- TODO 给予物品
		end
	end
end

function QuestTest(keys)
    print(keys.caller:GetName())-- 就是实体名字
    print(keys.activator:GetUnitName()) -- 就是英雄名字，npc_hero_crystal_maiden什么的

    local trigger_quest_name = keys.caller:GetName()
    local trigger_hero = keys.activator
    local playerid = trigger_hero:GetPlayerID()

    local quest_name = "#QuestName_"..trigger_quest_name
    local quest_desc = "#QuestDesc_"..trigger_quest_name
    print("======QUEST TRIGGERED========")
    print (quest_name)
    print (quest_desc)
    print("======QUEST TRIGGERED========")

    FireGameEvent("quest_show", {
    PlayerID = playerid,
    QuestName = quest_name,
    QuestDescription = quest_desc})

    print("======GAME EVENT FIRED========")
    --[[
    ListenToGameEvent("player_accept_quest",
    	function(keys)
    		for k,v in pairs(keys) do
    			print(k,v)
    		end
    	end, 
    nil)]]
    Convars:RegisterCommand('player_accept_quest',
    	function(keys)

    		print("accept quest clicked")
    		print(keys)
    		--[[
    		for k,v in pairs(keys) do
    			print(k,v)
    		end]]
    		end, "		", 0)
end