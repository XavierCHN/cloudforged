
function OnStaffLongTou( keys )
	local caster = keys.caster
	local x = keys.ability:GetLevelSpecialValueFor("heal_mana", keys.ability:GetLevel() - 1)
	caster:SetHealth(caster:GetHealth() + x)
	caster:SetMana(caster:GetMana() + x)
end