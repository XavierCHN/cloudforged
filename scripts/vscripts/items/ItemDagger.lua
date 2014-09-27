
function OnDaggerZhiMing( keys )
	local caster = keys.caster
	local target = keys.target

	--获取攻击加成
	local attack_damage = keys.ability:GetSpecialValueFor("attack") or 0
	local attack = attack_damage / 100

	--获取最大最小物理伤害
	local attack_min = keys.ability:GetSpecialValueFor("attack_min")
	local attack_max = keys.ability:GetSpecialValueFor("attack_max") 

	local damageTable = {victim=target,
						attacker=caster,
						damage= caster:GetAttackDamage() * attack + RandomInt(attack_min, attack_max),
						damage_type=DAMAGE_TYPE_PHYSICAL}
	ApplyDamage(damageTable)
end

function OnDaggerInvisible( keys )
	local caster = keys.caster

	--获取持续时间
	local duration = keys.ability:GetSpecialValueFor("duration")

	--添加隐身
	caster:AddNewModifier(caster, keys.ability, "modifier_persistent_invisibility", {duration=duration})
end


function OnDaggerInvisibleRemove( keys )
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_persistent_invisibility") 

	--删除modifier
	if caster:HasModifier("modifier_item_zs_dagger_liming_invisible_remove") then
		caster:RemoveModifierByName("modifier_item_zs_dagger_liming_invisible_remove")

	elseif caster:HasModifier("modifier_item_zs_dagger_anying_invisible_remove") then
		caster:RemoveModifierByName("modifier_item_zs_dagger_anying_invisible_remove")

	elseif caster:HasModifier("modifier_item_zs_dagger_linghun_invisible_remove") then
		caster:RemoveModifierByName("modifier_item_zs_dagger_linghun_invisible_remove")

	elseif caster:HasModifier("modifier_item_zs_dagger_yinhe_invisible_remove") then
		caster:RemoveModifierByName("modifier_item_zs_dagger_yinhe_invisible_remove")
	end
end

function OnDaggerYinHe( keys )
	local caster = keys.caster
	local caster_vec = caster:GetOrigin()
	local caster_face = caster:GetForwardVector()

	local num = 0
	for i=1,3 do
		--设置距离
		local len = i*200

		--设置每一圈特效数量
		num = num + 5
		for k=1,num do

			--设置特效创建点
			local vec = caster_vec + len * caster_face
			local rota = RotatePosition(caster_vec, QAngle(0,(360/num)*k), vec)

			--创建特效
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_dispel_magic.vpcf",PATTACH_WORLDORIGIN,caster)
			ParticleManager:SetParticleControl(particle,0,rota)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end

	--获取作用范围
	local radius = keys.ability:GetSpecialValueFor("radius")

	--获取伤害系数和伤害力量加成
    local increase = keys.ability:GetSpecialValueFor("increase")
    local agi_hurt = keys.ability:GetSpecialValueFor("agi_hurt")
    
    --设置常量
    local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
    local flags = DOTA_UNIT_TARGET_FLAG_NONE

    --获取自愈血种周围的单位
    local group = FindUnitsInRadius(caster:GetTeamNumber(), caster_vec, nil, radius, teams, types, flags, FIND_UNITS_EVERYWHERE, true) 

    --造成伤害
    local damageTable = {attacker= caster,
                        target_entities=group,
                        ability=keys.ability,
                        damage_increase=increase,
                        damage_type=DAMAGE_TYPE_MAGICAL,
                        damage_category="cunning",
                        damage_str=agi_hurt}
    DamageTarget(damageTable)
end