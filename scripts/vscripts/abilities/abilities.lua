

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


--隐修议员 1技能
rubick_sacrifice_is=false
--
function rubick_sacrifice_on( keys )
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability=keys.ability
	local radius = ability:GetSpecialValueFor("radius") 
	local teams =  DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
	local flags = DOTA_UNIT_TARGET_FLAG_NONE
	rubick_sacrifice_is=true
	GameRules:GetGameModeEntity():SetContextThink(
													DoUniqueString("sacrifice_on"),
													function()
														if rubick_sacrifice_is==true then
															local i=ability:GetLevel()-1
															local time=ability:GetLevelSpecialValueFor("time",i) 
															local p=ability:GetLevelSpecialValueFor("percentage",i) 
															local group = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, teams, types, flags, FIND_CLOSEST, true) 
															local c_hp=(caster:GetHealth())*(p/100)
															local hp=c_hp+caster:GetIntellect()
															caster:SetHealth(caster:GetHealth()-c_hp)
															for i,u in pairs(group) do
																if u~=caster and u:IsAlive() and u:GetHealth()<u:GetMaxHealth() then
																	u:SetHealth(u:GetHealth()+hp) 
																end
															end
															--print(tostring(i)..tostring(time).."---"..tostring(p).."---"..tostring(c_hp).."---"..tostring(hp))
															return time
														else 
															return nil
														end
													end,
													0
												)
end

function rubick_sacrifice_off( keys )
	local caster = keys.caster
	rubick_sacrifice_is=false
	caster:RemoveModifierByName("create_rubick_sacrifice_effect")
end

--隐修议员 3技能 被动
function rubick_wise( keys )
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability=keys.ability
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("rubick_wise_loop"), 
		 											function()
		 												local hp = caster:GetHealth()
		 												local i=ability:GetLevel()-1
		 												local x=ability:GetLevelSpecialValueFor("int", i)
		 												local a_hp = caster:GetIntellect()*x
		 												if hp<caster:GetMaxHealth() and caster:IsAlive() then
		 													caster:SetHealth(hp+a_hp)
		 												end
		 												return 1
		 											end, 0)
end


--隐修议员 2技能
function rubick_Bless( keys )
	local caster = keys.caster
	local target = keys.target
	local i=keys.ability:GetLevel()
	local overtime = 0
	local ability      =nil
	local abilityName  =nil
	local modifierName =nil

	if target:IsOpposingTeam(caster:GetTeam()) then
		abilityName="rubick_Bless_enemy_hidden"
		modifierName="create_Bless_enemy"
		target:AddAbility(abilityName)
		overtime=keys.ability:GetLevelSpecialValueFor("time_enemy", i-1)
		ability = target:FindAbilityByName(abilityName)
		ability:SetLevel(i)
	else
		abilityName="rubick_Bless_friendly_hidden"
		modifierName="create_Bless_friendly"
		target:AddAbility(abilityName)
		overtime=keys.ability:GetLevelSpecialValueFor("time_friendly", i-1)
		ability = target:FindAbilityByName(abilityName)
		ability:SetLevel(i)
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("rubick_Bless_time"), 
		 											function()
		 												target:RemoveAbility(abilityName)
		 												target:RemoveModifierByName(modifierName)
		 												return nil
		 											end, overtime)
end



--隐修议员 4技能
--全局变量
rubick_natural_shelter_channel=false
--
function rubick_natural_shelter( keys )
	local caster = keys.caster
	local vec_caster = caster:GetOrigin()
	local dummy_left = {}
	local dummy_right = {}
	local i = 1
	local angle = QAngle(0,-5,0)
	local unitName = "npc_dummy"
	local abilityName = "rubick_natural_shelter_dummy"
	rubick_natural_shelter_channel=true

	local abilityName_aura = "rubick_natural_shelter_aura"
	caster:AddAbility(abilityName_aura)
	local ability_aura=caster:FindAbilityByName(abilityName_aura)
	ability_aura:SetLevel(keys.ability:GetLevel())


	for Len=100,800,100 do
		local vec_left = vec_caster+Vector(0,Len,0)
		local vec_right = vec_caster+Vector(0,-Len,0)
		dummy_left[i]=CreateUnitByName(unitName, vec_left, false, caster, nil, caster:GetTeam())
		dummy_left[i]:AddAbility(abilityName)
		local ability1 = dummy_left[i]:FindAbilityByName(abilityName)
		ability1:SetLevel(1)
		dummy_right[i]=CreateUnitByName(unitName, vec_right, false, caster, nil, caster:GetTeam())
		dummy_right[i]:AddAbility(abilityName)
		local ability2 = dummy_right[i]:FindAbilityByName(abilityName)
		ability2:SetLevel(1)
		i=i+1
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("rubick_natural_shelter_time"), 
		function( )
			if rubick_natural_shelter_channel then
				for k=1,8,1 do
					local vec_left = dummy_left[k]:GetOrigin()
					local vec_right = dummy_right[k]:GetOrigin()
					local vec_left_rotate = RotatePosition(vec_caster, angle, vec_left)
					local vec_right_rotate = RotatePosition(vec_caster, angle, vec_right)
					dummy_left[k]:SetOrigin(vec_left_rotate)
					dummy_right[k]:SetOrigin(vec_right_rotate)
				end
				return 0.03
			else
				for k=1,8,1 do
					dummy_left[k]:Kill(dummy_left[k], dummy_left[k])
					dummy_right[k]:Kill(dummy_right[k], dummy_right[k])
				end
				caster:RemoveAbility(abilityName_aura)
				caster:RemoveModifierByName("create_rubick_natural_shelter_aura")
				return nil
			end
		end, 0)
end

function rubick_natural_shelter_channel_is( keys )
	rubick_natural_shelter_channel=false
end