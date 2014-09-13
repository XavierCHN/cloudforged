-- 初始化AI核心
AICore = AICore or {}

-- 获取随机目标
function AICore:RandomEnemyHeroInRange( entity, range )
    local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    if #enemies > 0 then
        local index = RandomInt( 1, #enemies )
        return enemies[index]
    else
        return nil
    end
end

-- 获取最弱目标
function AICore:WeakestEnemyHeroInRange( entity, range )
    local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

    local minHP = nil
    local target = nil

    for _,enemy in pairs(enemies) do
        local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
        local HP = enemy:GetHealth()
        if enemy:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
            minHP = HP
            target = enemy
        end
    end

    return target
end

-- 获取最强目标
function AICore:StrongestEnemyHeroInRange( entity, range )
    local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

    local maxHP = nil
    local target = nil

    for _,enemy in pairs(enemies) do
        local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
        local HP = enemy:GetHealth()
        if enemy:IsAlive() and (maxHP == nil or HP > maxHP) and distanceToEnemy < range then
            maxHP = HP
            target = enemy
        end
    end

    return target
end

-- 获取最近目标
function AICore:NearestEnemyHeroInRange( entity, range )
    local enemies = FindUnitsInRadius( entity:GetTeam(), entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

    local minRange = 100000
    local target = nil

    for _,enemy in pairs(enemies) do
        local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()

        if distanceToEnemy < minRange then
            minRange = distanceToEnemy
            target = enemy
        end
    end
    return target
end