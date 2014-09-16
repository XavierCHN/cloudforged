

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
	--获取施法者
	local caster = EntIndexToHScript(keys.caster_entindex)
	--获取技能
	local ability=keys.ability
	--获取作用范围
	local radius = ability:GetSpecialValueFor("radius") 

	local teams =  DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
	local flags = DOTA_UNIT_TARGET_FLAG_NONE

	--标记施法者开启技能
	caster:SetContextNum("rubick_sacrifice_on", 1, 0)

	--开启计时器
	GameRules:GetGameModeEntity():SetContextThink(
													DoUniqueString("sacrifice_on"),
													function()
														if caster:GetContext("rubick_sacrifice_on")==1 then

															--获取技能等级
															local i=ability:GetLevel()-1
															--获取时间间隔
															local time=ability:GetLevelSpecialValueFor("time",i) 
															--获取生命值百分比
															local p=ability:GetLevelSpecialValueFor("percentage",i) 

															--获取单位组
															local group = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, teams, types, flags, FIND_CLOSEST, true) 
															
															--计算生命值
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
	caster:SetContextNum("rubick_sacrifice_on", 0, 0)
	caster:RemoveModifierByName("create_rubick_sacrifice_effect")
end

--隐修议员 4技能 被动
function rubick_wise( keys )
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability=keys.ability
	
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("rubick_wise_loop"), 
		 											function()
		 												if caster:IsAlive() and IsValidEntity(caster) then
			 												local hp = caster:GetHealth()
			 												local i=ability:GetLevel()-1
			 												local x=ability:GetLevelSpecialValueFor("int", i)
			 												local a_hp = caster:GetIntellect()*x
			 												if hp<caster:GetMaxHealth() then
			 													caster:SetHealth(hp+a_hp)
			 												end
		 													return 1
		 												else
		 													caster:RemoveModifierByName("create_wise")
		 													return nil
		 												end
		 											end, 0)
end

--学习守护
function rubick_learn_defend( keys )
	local caster = keys.caster
	local ability_wise = caster:FindAbilityByName("rubick_wise")
	local ability_defend = caster:FindAbilityByName("rubick_defend")
	ability_defend:SetLevel(ability_wise:GetLevel())
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

	if target:IsOpposingTeam(caster:GetTeam()) then	--是否是敌人

		--设置技能名字和modifier的名称
		abilityName="rubick_Bless_enemy_hidden"
		modifierName="create_Bless_enemy"

		--添加技能
		target:AddAbility(abilityName)

		--获取持续时间
		overtime=keys.ability:GetLevelSpecialValueFor("time_enemy", i-1)

		--获取技能并设置等级
		ability = target:FindAbilityByName(abilityName)
		ability:SetLevel(i)

	else
		--设置技能名字和modifier的名称
		abilityName="rubick_Bless_friendly_hidden"
		modifierName="create_Bless_friendly"

		--添加技能
		target:AddAbility(abilityName)

		--获取持续时间
		overtime=keys.ability:GetLevelSpecialValueFor("time_friendly", i-1)

		--获取技能并设置等级
		ability = target:FindAbilityByName(abilityName)
		ability:SetLevel(i)
	end

	--开启计时器，计时器到期删除技能和modifier
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("rubick_Bless_time"), 
		 											function()
		 												target:RemoveAbility(abilityName)
		 												target:RemoveModifierByName(modifierName)
		 												return nil
		 											end, overtime)
end



--隐修议员 大招
function rubick_natural_shelter( keys )

	--获取施法者
	local caster = keys.caster
	--获取施法者所在位置
	local vec_caster = caster:GetOrigin()
	--获取施法者的向量
	local face = caster:GetForwardVector()

	--设置两个table来记录两组特效
	local particle_1={}
	local particle_2={}

	--设置两个table来记录特效的位置
	local vec_particle_1 = {}
	local vec_particle_2 = {}

	--设置旋转角度
	local angle = QAngle(0,-5,0)

	--标记施法者开始施法
	caster:SetContextNum("rubick_natural_shelter",1,0)

	--为施法者加入光环
	local abilityName_aura = "rubick_natural_shelter_aura"
	caster:AddAbility(abilityName_aura)
	local ability_aura=caster:FindAbilityByName(abilityName_aura)
	ability_aura:SetLevel(keys.ability:GetLevel())

	--开始创建特效并记录初始创建的位置
	for i=1,8,1 do
		particle_1[i]=ParticleManager:CreateParticle("particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf",PATTACH_WORLDORIGIN,caster)
		particle_2[i]=ParticleManager:CreateParticle("particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf",PATTACH_WORLDORIGIN,caster)
		vec_particle_1[i]=vec_caster + (i*100)*face
		vec_particle_2[i]=vec_caster - (i*100)*face
	end

	--开启计时器
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("rubick_natural_shelter_time"), 
		function( )
			if caster:GetContext("rubick_natural_shelter")==1 then
				
				for i=1,8,1 do

					--绕vec_caster旋转
					local rota_1 = RotatePosition(vec_caster,angle, vec_particle_1[i])
					local rota_2 = RotatePosition(vec_caster,angle, vec_particle_2[i])

					--设置特效所在位置
					ParticleManager:SetParticleControl(particle_1[i],0,rota_1)
					ParticleManager:SetParticleControl(particle_2[i],0,rota_2)

					--更新记录的位置为旋转后的位置
					vec_particle_1[i]=rota_1
					vec_particle_2[i]=rota_2

				end

				return 0.03
			else
				for i=1,8,1 do 		--删除特效
					ParticleManager:DestroyParticle(particle_1[i],false)
					ParticleManager:DestroyParticle(particle_2[i],false)
				end

				--删除光环
				caster:RemoveAbility(abilityName_aura)
				caster:RemoveModifierByName("create_rubick_natural_shelter_aura")
				
				return nil
			end
		end, 0)
end

function rubick_natural_shelter_channel_is( keys )
	keys.caster:SetContextNum("rubick_natural_shelter",0,0)
end


--征战暴君 1技能
function centaur_speed_support( keys )
	local caster = keys.caster
	local point = keys.target_points

	--设置施法者面向角度
	caster:SetForwardVector((point[1] - caster:GetOrigin()):Normalized())

	--开启计时器
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("centaur_speed_support_time"), 
		function( )

			--获取施法者所在的位置
			local vec_caster = caster:GetAbsOrigin()

			--如果施法者与施法点的距离小于50就退出循环
			if	(vec_caster - point[1]):Length()>=50 then
				local face=(point[1] - vec_caster):Normalized()
				local vec=face * 50.0
				caster:SetOrigin(vec_caster + vec)
				return 0.01
			else
				caster:RemoveModifierByName("modifier_phased")
				caster:RemoveModifierByName("create_speed_support_animation")
				return nil
			end

		end, 0)
end


--征战暴君 2技能
function centaur_hoof_stomp( keys )
	local caster = keys.caster

	--获取传递进来的单位组
	local group = keys.target_entities

	--用于记录时间
	local time = 0
	--结束时间
	local overtime = 0.15

	--如果单位不是死亡的就添加相位移动的BUFF
	for i,unit in pairs(group) do
		if unit:IsAlive() and IsValidEntity(unit) then
			unit:AddNewModifier(caster, keys.ability, "modifier_phased", {duration=1})
		end
	end

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("centaur_hoof_stomp_1"), 
		function( )
			if time<overtime then

				--获取施法者的位置
				local casterAbs = caster:GetAbsOrigin()

				for i,unit in pairs(group) do

					--获取单位的位置
					local unitAbs = unit:GetAbsOrigin()

					--如果单位距离施法者200以上就移动单位
					if (casterAbs - unitAbs):Length()>200 then
						local face = (casterAbs - unitAbs):Normalized()
						local vec = face * 50.0
						unit:SetAbsOrigin(unitAbs + vec)
					end
				end
				time = time + 0.01
				return 0.01
			else
				return nil
			end
		end, 0)
end

--征战暴君 4技能
function centaur_trample_road_run(caster,hero,ability)
	local overVec = caster:GetOrigin() + 1700 * caster:GetForwardVector()
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("trample_road_run"), 
		function( )
			local casterVec = caster:GetOrigin()
			if (overVec - casterVec):Length()>50 then
				local casterAbs = caster:GetAbsOrigin()
				local face = overVec - casterVec
				local vec = face:Normalized() * 35.0
				caster:SetAbsOrigin(casterAbs + vec)
				return 0.01
			else
				caster:RemoveSelf()
				return nil
			end
		end, 0) 
	local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
	local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_MECHANICAL
	local flags = DOTA_UNIT_TARGET_FLAG_NONE
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("trample_road_run"), 
		function( )
			if	IsValidEntity(caster) then 
				local i=ability:GetLevel() - 1
				local increase = ability:GetLevelSpecialValueFor("increase", i)
				local str = ability:GetLevelSpecialValueFor("str", i)
				local group = FindUnitsInRadius(hero:GetTeam(), caster:GetOrigin(), nil, 150, teams, types, flags, FIND_CLOSEST, true)
				
				for i,unit in pairs(group) do
					local damageTable = {attacker= hero,
										victim=unit,
										ability=ability,
										damage_increase=increase,
										damage_type=DAMAGE_TYPE_PURE,
										damage_category="force",
										damage_str=str}
					DamageTarget(damageTable)
				end
				return 0.2
			else
				return nil
			end

		end, 0)
end

function centaur_trample_road( keys )
	local caster = keys.caster
	local point = keys.target_points
	local casterVec = caster:GetOrigin()
	local face = (point[1] - casterVec):Normalized()
	local angle = caster:GetAngles()
	caster:SetForwardVector(face)
	local abilityName = "centaur_trample_road_dummy"

	faceLast=(casterVec - point[1]):Normalized()
	local casterLast = casterVec + 700 * faceLast

	local unit_a = {}
	local Len = 175
	for i=1,8,2 do
		local unitLast = casterVec + Len*faceLast
		local vec_a = RotatePosition(casterLast, QAngle(0,90,0), unitLast)
		local vec_b = RotatePosition(casterLast, QAngle(0,-90,0), unitLast)
		unit_a[i] = CreateUnitByName("npc_dota_hero_centaur", vec_a, false, caster, nil, caster:GetTeam())
		unit_a[i+1] = CreateUnitByName("npc_dota_hero_centaur", vec_b, false, caster, nil, caster:GetTeam())
		unit_a[i]:SetForwardVector(face)
		unit_a[i+1]:SetForwardVector(face)
		unit_a[i]:SetModelScale(1.0)
		unit_a[i+1]:SetModelScale(1.0)
		unit_a[i]:AddAbility(abilityName)
		unit_a[i+1]:AddAbility(abilityName)
		local ability_a = unit_a[i]:FindAbilityByName(abilityName)
		local ability_b = unit_a[i+1]:FindAbilityByName(abilityName)
		ability_a:SetLevel(1) 
		ability_b:SetLevel(1) 
		unit_a[i]:SetBaseStrength(caster:GetStrength())
		unit_a[i+1]:SetBaseStrength(caster:GetStrength())
		Len=Len+150
	end

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("trample_road_time_1"), 
		function( )
			for i=1,8,1 do
				centaur_trample_road_run(unit_a[i],caster,keys.ability)
			end
			EmitSoundOn("Hero_Centaur.Stampede.Cast", caster) 
			return nil
		end, 1)

end

--拉比克 3技能 召唤
hRubickUnit=nil
function rubick_defend( keys )
	
	--如果守护的单位不为空就删除单位
	if hRubickUnit~=nil then
		hRubickUnit:RemoveSelf() 
	end

	local caster = keys.caster
	local vec = caster:GetOrigin() + 200*caster:GetForwardVector()
	hRubickUnit = keys.target
	hRubickUnit:SetAbsOrigin(caster:GetAbsOrigin() + 200*caster:GetForwardVector())
	hRubickUnit:SetForwardVector((hRubickUnit:GetOrigin() - caster:GetOrigin()):Normalized())
	local ability = keys.ability
	local i = ability:GetLevel()-1

	local ability_1 = hRubickUnit:FindAbilityByName("rubick_defend_ability_1")
	ability_1:SetLevel(i+1)

	--传递单位和施法者到函数
	rubick_defend_ability_1(hRubickUnit,caster)

	--获取并设置技能
	local ability_2 = hRubickUnit:FindAbilityByName("rubick_defend_ability_2")
	ability_2:SetLevel(i+1)

	--获取最小攻击=施法者最小攻击+施法者的智力*智力加成系数
	local BaseDamageMin=caster:GetBaseDamageMin() + caster:GetIntellect() * ability:GetLevelSpecialValueFor("int", i)
	--获取最大攻击=最小攻击+5
	local BaseDamageMax=BaseDamageMin + 5

	hRubickUnit:SetBaseDamageMin(BaseDamageMin)
	hRubickUnit:SetBaseDamageMax(BaseDamageMax)	

	--获取护甲=施法者护甲+施法者敏捷*敏捷加成系数
	local armor = caster:GetPhysicalArmorValue() + caster:GetAgility() * ability:GetLevelSpecialValueFor("agi", i)+5
	hRubickUnit:SetPhysicalArmorBaseValue(armor)

	--获取生命值=1000 + 施法者的力量*力量加成系数
	local health = 1000 + caster:GetStrength() * ability:GetLevelSpecialValueFor("str", i)
	hRubickUnit:SetMaxHealth(health)
	hRubickUnit:SetHealth(health)


end


--大兵正气
function rubick_defend_ability_1(caster,hero)
	local ability = caster:FindAbilityByName("rubick_defend_ability_1")
	local i = ability:GetLevelSpecialValueFor("int", ability:GetLevel()-1)

	local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
	local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
	local flags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("rubick_defend_ability_1_time"), 
		function( )
			if IsValidEntity(caster) then
				if caster:IsAlive() then
					local num = hero:GetIntellect()*i+caster:GetAttackDamage()
					print(num)
					local group = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 250, teams, types, flags, FIND_CLOSEST, true)

					for i,unit in pairs(group) do
						local damageTable = {victim=unit,
											attacker=caster,
											damage_type=DAMAGE_TYPE_MAGICAL,
											damage=num}
						ApplyDamage(damageTable)
					end
					return 1
				else
					return nil
				end
			else
				return nil
			end
		end, 0)
end

--大兵正义之剑
function rubick_defend_ability_2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local i = ability:GetLevelSpecialValueFor("heal", ability:GetLevel()-1) * 0.01

	local num = caster:GetHealth() * i
	local damageTable = {victim=target,
						attacker=caster,
						damage_type=DAMAGE_TYPE_PHYSICAL,
						damage=num}
	ApplyDamage(damageTable)

	print(num)
end

