
function OnDaggerZhiMing( keys )
	local caster = keys.caster
	local target = keys.target

	--获取攻击加成
	local attack = keys.ability:GetSpecialValueFor("attack") /100

	--获取最大最小物理伤害
	local attack_min = keys.ability:GetSpecialValueFor("attack_min")
	local attack_max = keys.ability:GetSpecialValueFor("attack_max") 

	local damageTable = {victim=target,
						attacker=caster,
						damage= caster:GetAttackDamage() * attack + RandomInt(attack_min, attack_max),
						damage_type=DAMAGE_TYPE_PHYSICAL}
	ApplyDamage(damageTable)
end
