--[[
 卡尔BOSS的AI
]]
require( "ai_core" )

local BossAbilities = {
    'invoker_sun_strike',
    'invoker_deafening_blast',
    'invoker_cold_snap',
    'invoker_forge_spirit',
    'invoker_ice_wall',
    'invoker_alacrity'
}

function Spawn( entityKeyValues )
    
    print("BOSS INVOKER: SPAWN")
    PrintTable(entityKeyValues)

    -- 启动AI
    thisEntity:SetContextThink( "AIThink", AIThink, 1 )

    -- 记录初始位置
    if thisEntity._startOrigin == nil then
        thisEntity._startOrigin = thisEntity:GetOrigin()
    end

    -- 在主程序注册这个BOSS
    CForgedGameMode:RegisterLivingBoss(thisEntity)

    -- 初始化技能等级
    local abilities = {
        'invoker_quas',
        'invoker_wex',
        'invoker_exort'
    }
    for _,ability in pairs(abilities) do
        local ABILITY = thisEntity:FindAbilityByName(ability)
        if ABILITY then ABILITY:SetLevel(7) end
    end
    for _,ability in pairs(BossAbilities) do
        local ABILITY = thisEntity:FindAbilityByName(ability)
        if ABILITY then ABILITY:SetLevel(1) end
    end

end

function AIThink()

    -- 如果BOSS已经死亡，注销AI
    if thisEntity:IsNull() or not thisEntity:IsAlive() then
        return nil
    end

    -- 如果没人对BOSS造成伤害，不触发
    if thisEntity:GetHealth() == thisEntity:GetMaxHealth() then
        return 1
    end

    -- 如果BOSS的位置超过初始距离2000，让BOSS返回原位置
    if ( thisEntity:GetOrigin() - thisEntity._startOrigin ):Length2D() >= 2000 then
        thisEntity:SetHealth( thisEntity:GetMaxHealth() )
        thisEntity:SetOrigin( thisEntity._startOrigin )
        return 1
    end

    -- 如果正在战斗，释放技能
    return CastAbilities()
end

local ABI_SUN_STRIKE = thisEntity:FindAbilityByName('invoker_sun_strike') 
local ABI_DEAF_BLAST = thisEntity:FindAbilityByName('invoker_deafening_blast') 
local ABI_COLD_SNAP  = thisEntity:FindAbilityByName('invoker_cold_snap') 
local ABI_FO_SPIRITE = thisEntity:FindAbilityByName('invoker_forge_spirit') 
local ABI_ICE_WALL   = thisEntity:FindAbilityByName('invoker_ice_wall') 
local ABI_ALACRITY   = thisEntity:FindAbilityByName('invoker_alacrity') 

local nAbilityCastRange = 800

function CastAbilities()
    -- 对血量最高的目标释放天火
    if ABI_SUN_STRIKE then
        if ABI_SUN_STRIKE:IsFullyCastable() then
            local target = AICore:StrongestEnemyHeroInRange( thisEntity, 2000 )
            if target then
                thisEntity:CastAbilityOnPosition( target:GetOrigin() , ABI_SUN_STRIKE , -1) 
                return 2 -- 休息4秒
            end
        end
    end
    -- 对最近目标释放超震声波
    if ABI_DEAF_BLAST then
        if ABI_DEAF_BLAST:IsFullyCastable() then
            local target = AICore:NearestEnemyHeroInRange(thisEntity, 500 )
            if target then
                thisEntity:CastAbilityOnPosition(target:GetOrigin(), ABI_DEAF_BLAST, -1) 
                return 2
            end
        end
    end
    -- 对最弱目标释放急速冷却并攻击
    if ABI_COLD_SNAP then
        if ABI_COLD_SNAP:IsFullyCastable() then
            local target = AICore:WeakestEnemyHeroInRange(thisEntity, 800 )
            if target then
                thisEntity:CastAbilityOnPosition(target:GetOrigin(), ABI_COLD_SNAP, -1) 
                thisEntity:PerformAttack(target, false, false, false, false)
                return 2
            end
        end
    end
    -- 如果可以释放熔炉精灵，则释放
    if ABI_FO_SPIRITE then
        if ABI_FO_SPIRITE:IsFullyCastable() then
            thisEntity:CastAbilityNoTarget(ABI_FO_SPIRITE, -1)
            return 1
        end
    end
    -- 如果可以释放灵动迅捷，则释放
    if ABI_ALACRITY then
        if ABI_ALACRITY:IsFullyCastable() then
            thisEntity:CastAbilityOnTarget(thisEntity, ABI_ALACRITY, -1)
            return 1
        end
    end
    -- 如果可以释放冰墙，则对最近的目标释放冰墙
    --[[]]

    -- 如果啥技能都不能放，则一秒后再检测
    return 1
end