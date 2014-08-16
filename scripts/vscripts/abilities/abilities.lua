
--红雾死神 3技能 添加隐藏被动
function axe_war_will_hidden_learn( keys )
	local caster=EntIndexToHScript(keys.caster_entindex) 
	local abilityName="axe_war_will_hidden"
	caster:AddAbility(abilityName) 
	local ability=caster:FindAbilityByName(abilityName) 
	ability:SetLevel(1) 
end

--红雾死神 3技能 隐藏被动
function axe_war_will_hidden( keys )
	local caster=EntIndexToHScript(keys.caster_entindex) 
	local target={}
	target=keys.target_entities
	for i,tar in pairs(target) do
		local order={	UnitIndex=tar:entindex() ,
						TargetIndex=caster:entindex() ,
						OrderType=DOTA_UNIT_ORDER_ATTACK_TARGET,
					}
		ExecuteOrderFromTable(order) 
	end
end