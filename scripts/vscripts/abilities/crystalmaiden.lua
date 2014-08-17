
if CCrystalMaiden == nil then
	CCrystalMaiden = class({})
end


function OnCrystalMaiden01Start(keys)
	
	tPrint('vscripts/abilities/crystalmaiden.lua:OnCrystalMaiden01Start(keys)')

	--[[ 技能 伤害类型为  蛮力/灵敏/狡诈/智慧等级 * 技能伤害系数 
	* (力量值*力量系数 + 敏捷值*敏捷系数 + 智力值* 智力系数) * 技能等级的平方 * 英雄等级/目标等级]]

	-- 获取施法者
	local hCaster = EntIndexToHScript(keys.caster_entindex)
	
	-- 获取玩家ID
	local nPlayerId = hCaster:GetPlayerID()
	
	-- 获取技能目标列表
	local thTarget = keys.target_entities

	if not thTarget then print('damage no target') return end

	-- 获取从技能决定依赖天赋 - 从物品获取依赖天赋的等级
	local nWisdomLevel = ItemCore:GetAttribute(hCaster,keys.AbilityDepenis) or 1

	-- 获取技能伤害系数
	local ability_multi = tonumber(keys.AbilityMulti) 

	-- 获取主属性值
	local primary_value = hCaster:GetPrimaryStatValue() 

	-- 获取技能等级
	local ability_level = keys.ability:GetLevel() 

	-- 获取英雄等级
	local hero_level = hCaster:GetLevel()

	-- 获取敌方等级
	local target_level = thTarget[1]:GetLevel()

	-- 计算伤害值
	local damage_to_deal = nWisdomLevel * ability_multi * primary_value * ability_level * ability_level * hero_level / target_level

	-- 传入技能至少造成伤害值
	if keys.MiniunDamage and damage_to_deal < keys.MiniunDamage then damage_to_deal = keys.MiniunDamage end
	
	-- 循坏各个目标单位
	for _,v in pairs(thTarget) do
		local damage_table = {
			victim = v,
			attacker = hCaster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PURE, 
	    	damage_flags = 0
		}
		ApplyDamage(damage_table)
	end
	
	local hIceEffect = CreateUnitByName(
	        "npc_CFroged_unit_CrystalMaiden_iceEffect"
		    ,thTarget[1]:GetOrigin()
		    ,false
		    ,hCaster
		    ,hCaster
	     	,hCaster:GetTeam()
    	)
    	local nIceIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall_shards.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect)
    		
    	ParticleManager:SetParticleControl(nIceIndex, 0, thTarget[1]:GetOrigin())
		ParticleManager:SetParticleControl(nIceIndex, 1, thTarget[1]:GetOrigin())
		
      	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('Release_Effect'),
    	function ()
	        hIceEffect:Destroy()
			print('[CrystalMaiden01]Release Effect!')
	    	return nil
    	end,3)
end

function OnCrystalMaiden02Start(keys)
	tPrint('vscripts/abilities/crystalmaiden.lua:OnCrystalMaiden02Start(keys)')
	
	PrintTable(keys)

	--[[ 技能 伤害类型为  蛮力/灵敏/狡诈/智慧等级 * 技能伤害系数 
	* (力量值*力量系数 + 敏捷值*敏捷系数 + 智力值* 智力系数) * 技能等级的平方 * 英雄等级/目标等级]]

	-- 获取施法者
	local hCaster = EntIndexToHScript(keys.caster_entindex)
	
	-- 获取玩家ID
	local nPlayerId = hCaster:GetPlayerID()
	
	-- 获取技能目标列表
	local thTarget = FindUnitsInRadius(
		   hCaster:GetTeam(),		                        --caster team
		   hCaster:GetOrigin(),		                        --find position
		   nil,					                        --find entity
		   keys.Radius,		                                --find radius
		   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		   DOTA_UNIT_TARGET_ALL,
		   0, FIND_CLOSEST,
		   false
	    )
		
	if not thTarget then print('damage no target') return end

	-- 获取从技能决定依赖天赋 - 从物品获取依赖天赋的等级
	local nWisdomLevel = ItemCore:GetAttribute(hCaster,keys.AbilityDepenis) or 1

	-- 获取技能伤害系数
	local ability_multi = tonumber(keys.AbilityMulti) 

	-- 获取主属性值
	local primary_value = hCaster:GetPrimaryStatValue() 

	-- 获取技能等级
	local ability_level = keys.ability:GetLevel() 

	-- 获取英雄等级
	local hero_level = hCaster:GetLevel()
	
	local healing_to_deal = nWisdomLevel * ability_multi * primary_value * ability_level
	
	local armor_gain = nWisdomLevel * ability_multi * primary_value * ability_level / 5
	
	local nIceIndex
	
	local vec = hCaster:GetOrigin()
	
	local vecEffect
	
	-- 循坏各个目标单位
	for k,v in pairs(thTarget) do
		v:SetHealth(v:GetHealth() + healing_to_deal)
		nIceIndex = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_e_cowlofice.vpcf", PATTACH_CUSTOMORIGIN, v)
		ParticleManager:ReleaseParticleIndex(nIceIndex)
		v:SetPhysicalArmorBaseValue(v:GetPhysicalArmorBaseValue() + armor_gain)
		print("[CrystalMaiden02]Healingtarget!")
	end
	
	local hIceEffect = CreateUnitByName(
	        "npc_CFroged_unit_CrystalMaiden_iceEffect"
		    ,hCaster:GetOrigin()
		    ,false
		    ,hCaster
		    ,hCaster
	     	,hCaster:GetTeam()
    	)
		
	for i = 0,19 do
    	nIceIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_ice_path_shards.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect)
    	vecEffect = Vector(vec.x + math.cos(i*0.314)*700,vec.y+ math.sin(i*0.314)*700,vec.z)
    	ParticleManager:SetParticleControl(nIceIndex, 0, vecEffect)
		ParticleManager:SetParticleControl(nIceIndex, 1, vecEffect)
	end
	
	local vec2 = Vector(vec.x + math.cos(0)*350,vec.y+ math.sin(0)*350,vec.z)
	
	for i = 0,9 do
    	nIceIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_ice_path_shards.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect)
    	vecEffect = Vector(vec2.x + math.cos(i*0.314)*350,vec2.y+ math.sin(i*0.314)*350,vec2.z)
    	ParticleManager:SetParticleControl(nIceIndex, 0, vecEffect)
		ParticleManager:SetParticleControl(nIceIndex, 1, vecEffect)
	end
	
	local vec2 = Vector(vec.x + math.cos(3.14)*350,vec.y + math.sin(3.14)*350,vec.z)
	
	for i = 10,19 do
    	nIceIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_ice_path_shards.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect)
    	vecEffect = Vector(vec2.x + math.cos(i*0.314)*350,vec2.y + math.sin(i*0.314)*350,vec2.z)
    	ParticleManager:SetParticleControl(nIceIndex, 0, vecEffect)
		ParticleManager:SetParticleControl(nIceIndex, 1, vecEffect)
	end
	
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('Release_Effect'),
    	function ()
	        hIceEffect:Destroy()
			print('[CrystalMaiden02]Release Effect!')
			-- 循坏各个目标单位
	        for k,v in pairs(thTarget) do
	        	v:SetPhysicalArmorBaseValue(v:GetPhysicalArmorBaseValue() - armor_gain)
	        end
	    	return nil
    	end,7)
end

function OnCrystalMaiden03Start(keys)
	
	tPrint('vscripts/abilities/crystalmaiden.lua:OnCrystalMaiden03Start(keys)')

	--[[ 技能 伤害类型为  蛮力/灵敏/狡诈/智慧等级 * 技能伤害系数 
	* (力量值*力量系数 + 敏捷值*敏捷系数 + 智力值* 智力系数) * 技能等级的平方 * 英雄等级/目标等级]]

	-- 获取施法者
	local hCaster = EntIndexToHScript(keys.caster_entindex)
	
	-- 获取玩家ID
	local nPlayerId = hCaster:GetPlayerID()
	
	-- 获取技能目标列表
	local thTarget = keys.target_entities

	if not thTarget then print('damage no target') return end

	-- 获取从技能决定依赖天赋 - 从物品获取依赖天赋的等级
	local nWisdomLevel = ItemCore:GetAttribute(hCaster,keys.AbilityDepenis) or 1

	-- 获取技能伤害系数
	local ability_multi = tonumber(keys.AbilityMulti) 

	-- 获取主属性值
	local primary_value = hCaster:GetPrimaryStatValue() 

	-- 获取技能等级
	local ability_level = keys.ability:GetLevel() 

	-- 获取英雄等级
	local hero_level = hCaster:GetLevel()

	-- 获取敌方等级
	local target_level = thTarget[1]:GetLevel()

	-- 计算伤害值
	local damage_to_deal = nWisdomLevel * ability_multi * primary_value * ability_level * ability_level * hero_level / target_level

	-- 传入技能至少造成伤害值
	if keys.MiniunDamage and damage_to_deal < keys.MiniunDamage then damage_to_deal = keys.MiniunDamage end
	
	local hIceEffect = CreateUnitByName(
	        "npc_CFroged_unit_CrystalMaiden_iceEffect"
		    ,hCaster:GetOrigin()
		    ,false
		    ,hCaster
		    ,hCaster
	     	,hCaster:GetTeam()
    )
	
	-- 循坏各个目标单位
	for _,v in pairs(thTarget) do
		local damage_table = {
			victim = v,
			attacker = hCaster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PURE, 
	    	damage_flags = 0
		}

    	local nIceIndex = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_e_cowlofice.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect)
    		
    	ParticleManager:SetParticleControl(nIceIndex, 0, v:GetOrigin())
		ParticleManager:SetParticleControl(nIceIndex, 1, v:GetOrigin())
		
		ApplyDamage(damage_table)
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('Release_Effect'),
    	function ()
	        hIceEffect:Destroy()
			print('[CrystalMaiden03]Release Effect!')
	    	return nil
    	end,3)
	
end

function OnCrystalMaidenSpell04Start(keys)
	CCrystalMaiden:OnCrystalMaiden04Start(keys)
end

function CCrystalMaiden:OnCrystalMaiden04Start(keys)
	tPrint('vscripts/abilities/crystalmaiden.lua:OnCrystalMaiden04Start(keys)')
	
	--[[ 技能 伤害类型为  蛮力/灵敏/狡诈/智慧等级 * 技能伤害系数 
	* (力量值*力量系数 + 敏捷值*敏捷系数 + 智力值* 智力系数) * 技能等级的平方 * 英雄等级/目标等级]]

	-- 获取施法者
	local hCaster = EntIndexToHScript(keys.caster_entindex)
	
	-- 获取玩家ID
	local nPlayerId = hCaster:GetPlayerID()

	local nIceIndex
	
	local vec = hCaster:GetOrigin()
	
	local vecEffect
	
	local hIceEffect
	
	if(self.nIceEffectIndex == nil)then
		self:initIceEffectData()
		hIceEffect = CreateUnitByName(
	        "npc_CFroged_unit_CrystalMaiden_iceEffect"
		    ,hCaster:GetOrigin()
		    ,false
		    ,hCaster
		    ,hCaster
	     	,hCaster:GetTeam()
    	)
        nIceIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall_shards.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect)
	    local range = RandomInt(0,700)
        vecEffect = Vector(vec.x + math.cos(self.nIceEffectIndex*0.314)*range,vec.y+ math.sin(self.nIceEffectIndex*0.314)*range,vec.z+(range/10))
        ParticleManager:SetParticleControl(nIceIndex, 0, vecEffect)
        ParticleManager:SetParticleControl(nIceIndex, 1, vecEffect)
		
		self.vIceEffect[self.nIceEffectIndex].hUnit = hIceEffect
		self.vIceEffect[self.nIceEffectIndex].nIceEffect = nIceIndex
		self.vIceEffect[self.nIceEffectIndex].vec = vecEffect
		self.nIceEffectIndex = self.nIceEffectIndex + 1
	else
	    hIceEffect = CreateUnitByName(
	        "npc_CFroged_unit_CrystalMaiden_iceEffect"
		    ,hCaster:GetOrigin()
		    ,false
		    ,hCaster
		    ,hCaster
	     	,hCaster:GetTeam()
    	)
        nIceIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall_shards.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect)
	    local range = RandomInt(0,700)
        vecEffect = Vector(vec.x + math.cos(self.nIceEffectIndex*0.314)*range,vec.y+ math.sin(self.nIceEffectIndex*0.314)*range,vec.z+(range/2))
        ParticleManager:SetParticleControl(nIceIndex, 0, vecEffect)
        ParticleManager:SetParticleControl(nIceIndex, 1, vecEffect)
		
		self.vIceEffect[self.nIceEffectIndex].hUnit = hIceEffect
		self.vIceEffect[self.nIceEffectIndex].nIceEffect = nIceIndex
		self.vIceEffect[self.nIceEffectIndex].vec = vecEffect
		self.nIceEffectIndex = self.nIceEffectIndex + 1
	end
end

function OnCrystalMaidenSpell04Release(keys)
	CCrystalMaiden:OnCrystalMaiden04Release(keys)
end

function CCrystalMaiden:OnCrystalMaiden04Release(keys)
	tPrint('vscripts/abilities/crystalmaiden.lua:OnCrystalMaiden04Release(keys)')

	--[[ 技能 伤害类型为  蛮力/灵敏/狡诈/智慧等级 * 技能伤害系数 
	* (力量值*力量系数 + 敏捷值*敏捷系数 + 智力值* 智力系数) * 技能等级的平方 * 英雄等级/目标等级]]

	-- 获取施法者
	local hCaster = EntIndexToHScript(keys.caster_entindex)
	
	-- 获取玩家ID
	local nPlayerId = hCaster:GetPlayerID()
	
	-- 获取技能目标列表
	local thTarget = keys.target

	if not thTarget then print('damage no target') return end

	-- 获取从技能决定依赖天赋 - 从物品获取依赖天赋的等级
	local nWisdomLevel = ItemCore:GetAttribute(hCaster,keys.AbilityDepenis) or 1

	-- 获取技能伤害系数
	local ability_multi = tonumber(keys.AbilityMulti) 

	-- 获取主属性值
	local primary_value = hCaster:GetPrimaryStatValue() 

	-- 获取技能等级
	local ability_level = keys.ability:GetLevel() 

	-- 获取英雄等级
	local hero_level = hCaster:GetLevel()

	-- 获取敌方等级
	local target_level = thTarget:GetLevel()

	-- 计算伤害值
	local damage_to_deal = nWisdomLevel * ability_multi * primary_value * ability_level * ability_level * hero_level / target_level

	-- 传入技能至少造成伤害值
	if keys.MiniunDamage and damage_to_deal < keys.MiniunDamage then damage_to_deal = keys.MiniunDamage end
	
	local vTargetVec = thTarget:GetOrigin()
	
	local nIceRadForWard
	
	local nSpeed = 60
	
	local damage_table = {
			victim = thTarget,
			attacker = hCaster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PURE, 
	    	damage_flags = 0
	}
	
	for i = 0,9 do
		if (self.vIceEffect[i].hUnit ~= nil) then
		    nIceRadForWard = GetRadBetweenTwoVec2D(self.vIceEffect[i].vec,vTargetVec)
			print("nIceRadForWard="..tostring(nIceRadForWard))
			
			self.vIceEffect[i].vec.x = math.cos(nIceRadForWard) * nSpeed + self.vIceEffect[i].vec.x
		    self.vIceEffect[i].vec.y = math.sin(nIceRadForWard) * nSpeed + self.vIceEffect[i].vec.y
			
			self.vIceEffect[i].vec = Vector(self.vIceEffect[i].vec.x,self.vIceEffect[i].vec.y,self.vIceEffect[i].vec.z)
			
			print("v.vec.x="..tostring(self.vIceEffect[i].vec.x))
			print("v.vec.y="..tostring(self.vIceEffect[i].vec.y))
			print("v.vec.z="..tostring(self.vIceEffect[i].vec.z))
			
		    ParticleManager:SetParticleControl(self.vIceEffect[i].nIceEffect, 0, self.vIceEffect[i].vec)
	        ParticleManager:SetParticleControl(self.vIceEffect[i].nIceEffect, 1, self.vIceEffect[i].vec)
		    if(GetDistanceBetweenTwoVec2D(vTargetVec,self.vIceEffect[i].vec) < 50) then
		        ApplyDamage(damage_table)
			    self.vIceEffect[i].hUnit:RemoveSelf()
				self.vIceEffect[i].hUnit = nil
		    end
		end
	end
	self.nTime = self.nTime + 0.1
	if(self.nTime>1)then
		for i = 0,9 do
			if (self.vIceEffect[i].hUnit ~= nil) then
				self.vIceEffect[i].hUnit:RemoveSelf()
				self.vIceEffect[i].hUnit = nil
			end
			self.vIceEffect[i] = nil
		end
		self.nIceEffectIndex = 0
		self.nTime = 0
	end
end

function GetRadBetweenTwoVec2D(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
end

function GetDistanceBetweenTwoVec2D(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function CCrystalMaiden:initIceEffectData()
	print("init IceEffect data in")
	self.vIceEffect = self.vIceEffect or {}
	for i = 0,10 do
		self.vIceEffect[i] = { 
		    hUnit = nil,                 
			nIceEffect = 0,
			vec = nil,
		}
	end
	self.nIceEffectIndex = 0
	self.nTime = 0
end
