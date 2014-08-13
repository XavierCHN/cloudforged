function OnCrystalMaiden01Start(keys)

	tPrint('vscripts/abilities/crystalmaiden.lua:OnCrystalMaiden01Start(keys)')

	-- 技能 伤害类型为  蛮力等级 * 技能伤害系数 * 主属性值 * 技能等级的平方 * 英雄等级/目标等级

	-- 获取施法者
	local hCaster = EntIndexToHScript(keys.caster_entindex)
	
	-- 获取技能目标列表
	local thTarget = keys.target_entities

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
end
