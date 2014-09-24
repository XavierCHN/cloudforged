
--龙头法杖
function OnStaffLongTou( keys )
	local caster = keys.caster
	local x = keys.ability:GetLevelSpecialValueFor("heal_mana", keys.ability:GetLevel() - 1)
	caster:SetHealth(caster:GetHealth() + x)
	caster:SetMana(caster:GetMana() + x)
end

--风雪法杖
function OnStaffFengXue( keys )
	local caster = keys.caster

	--获取施法者所在点
	local caster_vec = caster:GetOrigin()

	--获取施法者的面向角度
	local caster_face = caster:GetForwardVector()

	--设置特效移动距离
	local Len = 800

	--用于存储特效
	local particle = {}

	--用于存储特效的位置
	local particle_vec = {}

	--用于存储特效移动的终点
	local particle_over = {}

	--定义移动函数
	function FengXue( particle , particle_vec , particle_over ,ice)
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("FengXue"), 
		function( )
			if (particle_over - particle_vec):Length()>50 then
				
				local face = (particle_over - particle_vec):Normalized()
				local vec = face * 30
				particle_vec = particle_vec + vec
				ParticleManager:SetParticleControl(particle,0,particle_vec)

				particle_over=RotatePosition(caster_vec, QAngle(0,2,0), particle_over)

				return 0.01
			else
				ParticleManager:DestroyParticle(particle,false)
				ParticleManager:DestroyParticle(ice,false)
				return nil
			end
		end, 0) 
	end

	--循环创建特效
	for i=1,12,1 do
		particle[i] = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf",PATTACH_WORLDORIGIN,caster)
		
		--初始化特效位置
		particle_vec[i] = caster_vec
		particle_over[i] = caster_vec + caster_face * Len
		ParticleManager:SetParticleControl(particle[i],0,caster_vec)

		--旋转终点
		particle_over[i]=RotatePosition(caster_vec, QAngle(0,(360/12)*i,0), particle_over[i])

		--创建冰女的一个特效
		local ice = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf",PATTACH_WORLDORIGIN,caster)
		ParticleManager:SetParticleControl(ice,0,caster_vec + (particle_over[i] - caster_vec):Normalized() * (Len/2))

		--调用移动函数
		FengXue(particle[i],particle_vec[i],particle_over[i],ice)
	end
end

--宁静之力 减少周围敌人的生命值
function OnStaffNingJing( keys )
	local caster = keys.caster
	local group = keys.target_entities

	--获取生命值百分比
	local heal_percent = keys.ability:GetSpecialValueFor("heal_percent") /100

	for i,unit in pairs(group) do
		local heal = unit:GetHealth() * heal_percent
		unit:SetHealth(unit:GetHealth() - heal)
		caster:SetHealth(caster:GetHealth() + heal)
	end
end

--宁静之力 最大最小纯粹伤害
function OnStaffNingJingAttack( keys )
	local caster = keys.caster
	local target = keys.target

	--获取最大最小纯粹伤害
	local min = keys.ability:GetSpecialValueFor("pure_min")
	local max = keys.ability:GetSpecialValueFor("pure_max")

	--随机伤害
	local rdamage = RandomInt(min, max)

	local damageTable = {victim=target,
						attacker=caster,
						damage=rdamage,
						damage_type=DAMAGE_TYPE_PURE}

	ApplyDamage(damageTable)
end

--冻结之力 最大最小魔法伤害
function OnStaffDongJieDamage( keys )
	local caster = keys.caster
	local target = keys.target

	--获取技能等级
	local i = keys.ability:GetLevel() - 1

	--获取最大最小魔法伤害
	local magmin = keys.ability:GetSpecialValueFor("mag_min")
	local magmax = keys.ability:GetSpecialValueFor("mag_max")

	--设置伤害table
	local damageTable = {victim=target,
						attacker=caster,
						damage=RandomInt(magmin, magmax),
						damage_type=DAMAGE_TYPE_MAGICAL}
	ApplyDamage(damageTable)
end