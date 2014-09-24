
--最高最低混合伤害
function OnAxeRandomDamageComposite( keys )
    local caster = keys.caster
    local target = keys.target

    --获取最低最高伤害
    local damage_min = keys.damage_min or 1
    local damage_max = keys.damage_max or 1

    local damageTable = {victim=target,
                        attacker=caster,
                        damage=RandomInt(damage_min, damage_max),
                        damage_type=DAMAGE_TYPE_COMPOSITE}
    ApplyDamage(damageTable)
end

--天使战斧
function OnAxeTianShi( keys )
    local caster = keys.caster
    local target = keys.target

    --获取恢复的生命值百分比
    local heal_percent = keys.ability:GetSpecialValueFor("heal_percent") /100

    --获取最高恢复的生命值
    local heal_max = keys.ability:GetSpecialValueFor("heal_max")

    --计算
    local heal = caster:GetHealth() * heal_percent

    --如果生命值高于heal_max
    if heal>=heal_max then
        heal=heal_max
    end

    caster:SetHealth(caster:GetHealth() + heal)
    
    --设置table用于调用OnAxeRandomDamageComposite
    local table = {caster=caster,
                    target=target,
                    damage_min=heal,
                    damage_max=heal,
                    }
    OnAxeRandomDamageComposite(table)
end

