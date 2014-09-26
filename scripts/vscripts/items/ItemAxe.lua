
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

--救世战斧
function OnAxeJiuShi( keys )
    local caster = keys.caster
    local target = keys.target

    -- print("CASTER=="..caster:GetUnitName())
    -- print("TARGET=="..target:GetUnitName())

    --创建特效
    local P=ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_explosion.vpcf",PATTACH_WORLDORIGIN,target)
    ParticleManager:SetParticleControl(P,0,target:GetOrigin())
    ParticleManager:SetParticleControl(P,3,target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(P)

    --获取最大生命值百分比
    local heal_percent = keys.ability:GetSpecialValueFor("heal_percent") /100

    --获取伤害范围
    local radius = keys.ability:GetSpecialValueFor("damage_radius")

    --计算
    local heal = target:GetMaxHealth() * heal_percent

    --设置常量
    local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
    local flags = DOTA_UNIT_TARGET_FLAG_NONE

    --获取自愈血种周围的单位
    local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), nil, radius, teams, types, flags, FIND_UNITS_EVERYWHERE, true) 

    --造成伤害
    for i,unit in pairs(group) do
        local table = {caster=caster,
                        target=unit,
                        damage_max=heal,
                        damage_min=heal}
        OnAxeRandomDamageComposite(table)
    end
end

--毁灭战斧
function OnAxeHuiMieCreated( keys )
    local caster = keys.caster
    local target = keys.target

    --获取生命值
    local heal = - keys.ability:GetSpecialValueFor("heal")

    --如果低于减少的生命值就直接杀死单位，否者添加减少生命值的modifier
    if target:GetMaxHealth()<heal then
        target:Kill(target,caster)
    else
        keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_item_zs_axe_huimiezhanfu_debuff_heal", nil)
    end
end

--删除modifier
function OnAxeHuiMieDestroy( keys )
    local caster = keys.caster
    local target = keys.target

    target:RemoveModifierByName("modifier_item_zs_axe_huimiezhanfu_debuff_heal")
end

--天神战斧
function OnAxeTianShen( keys )
    local caster = keys.caster
    local caster_vec = caster:GetOrigin()
    local caster_face = caster:GetForwardVector()

    --获取召唤时间
    local time = keys.ability:GetSpecialValueFor("time")

    --获取持续时间
    local duration = keys.ability:GetSpecialValueFor("duration")

    --获取作用范围
    local radius = keys.ability:GetSpecialValueFor("radius")

    --用于记录计时器时间
    local overtime = 0
    local num = 0

    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnAxeTianShen"), 
        function( )
            if overtime<=duration then

                --设置随机角度
                local angle = QAngle(0,RandomInt(0, 360),0)

                --设置随机距离
                local len = RandomInt(0, radius)

                --设置特效创建点
                local vec = caster_vec + len * caster_face
                local rota = RotatePosition(caster_vec, angle, vec)

                --创建特效
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf",PATTACH_WORLDORIGIN,caster)
                ParticleManager:SetParticleControl(particle,0,rota)
                ParticleManager:SetParticleControl(particle,1,Vector(200,200,200))
                ParticleManager:ReleaseParticleIndex(particle)

                if (num%25) == 0 then
                    --播放音效
                    EmitSoundOn("Hero_Omniknight.Purification",caster)
                end

                if (num%20) == 0 then
                    --获取伤害系数和伤害力量加成
                    local increase = keys.ability:GetSpecialValueFor("increase")
                    local str_hurt = keys.ability:GetSpecialValueFor("str_hurt")
                    
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
                                        damage_type=DAMAGE_TYPE_COMPOSITE,
                                        damage_category="force",
                                        damage_str=str_hurt}
                    DamageTarget(damageTable)
                end

                num = num + 1
                overtime = overtime + 0.05
                return 0.05
            end
            return nil
        end, time)
    

end

--地狱战斧
function OnAxeDiYu( keys )
    local caster = keys.caster
    local caster_vec = caster:GetOrigin()
    local caster_face = caster:GetForwardVector()

    --获取地面碎裂时间
    local time = keys.ability:GetSpecialValueFor("time")

    --获取地狱火持续时间
    local duration = keys.ability:GetSpecialValueFor("duration")

    --获取作用范围
    local radius = keys.ability:GetSpecialValueFor("radius")

    --用于记录特效
    local particles={}

    --设置特效数量
    local num = 15

    --循环创建特效
    for i=1,num do
        --设置旋转角度
        local angle = QAngle(0,(360/num)*i,0)

        --设置终点
        local vec = caster_vec + caster_face * radius
        local rota = RotatePosition(caster_vec, angle, vec)

        --创建地面碎裂特效
        particles[i] = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter_b.vpcf",PATTACH_WORLDORIGIN,caster)
        ParticleManager:SetParticleControl(particles[i],0,caster_vec)
        ParticleManager:SetParticleControl(particles[i],1,rota)
        ParticleManager:SetParticleControl(particles[i],3,Vector(0,time,0))
    end

    --用于记录第一次创建地狱火特效
    local first = false
    --用于记录时间
    local overtime  = 0

    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnAxeDiYu"), 
        function( )
            if overtime<duration then
                if first==false then
                    --停止音效
                    StopSoundEvent("Hero_ElderTitan.EarthSplitter.Projectile",caster)
                    --播放音效
                    EmitSoundOn("Dire.ancient.Destruction",caster)

                    for i=1,num do
                        --删除裂痕特效
                        ParticleManager:DestroyParticle(particles[i],true)

                        --设置旋转角度
                        local angle = QAngle(0,(360/num)*i,0)

                        --设置终点
                        local vec = caster_vec + caster_face * radius
                        local rota = RotatePosition(caster_vec, angle, vec)

                        --创建地狱火特效
                        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf",PATTACH_WORLDORIGIN,caster)
                        ParticleManager:SetParticleControl(particle,0,caster_vec)
                        ParticleManager:SetParticleControl(particle,1,rota)
                        ParticleManager:SetParticleControl(particle,2,Vector(duration,0,0))
                        ParticleManager:ReleaseParticleIndex(particle)
                        first=true
                    end
                end

             --获取伤害系数和伤害力量加成
                local increase = keys.ability:GetSpecialValueFor("increase")
                local str_hurt = keys.ability:GetSpecialValueFor("str_hurt")
                
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
                                    damage_type=DAMAGE_TYPE_COMPOSITE,
                                    damage_category="force",
                                    damage_str=str_hurt}
                DamageTarget(damageTable)

                overtime = overtime + 0.2
                return 0.2
            else
                --停止音效
                StopSoundEvent("Dire.ancient.Destruction",caster)
                return nil
            end
        end, time)
end