--[[
 卡尔BOSS的AI
]]

require( "AIs/ai_core" )

local BossAbilities = {
    'invoker_sun_strike',
    'invoker_deafening_blast',
    'invoker_cold_snap',
    'invoker_forge_spirit',
    'invoker_ice_wall',
    'invoker_alacrity'
}

local BossInvokerStartPosition = nil

local ABI_SUN_STRIKE = nil
local ABI_DEAF_BLAST = nil
local ABI_COLD_SNAP  = nil
local ABI_FO_SPIRITE = nil
local ABI_ICE_WALL   = nil
local ABI_ALACRITY   = nil

local nAbilityCastRange = 800

local function CastAbilities()
    print('boss attempt to cast abilities')

    -- 如果没有在攻击，攻击最近的目标
    if not thisEntity:IsAttacking() then
        local target = AICore:RandomEnemyHeroInRange(thisEntity, 800)
        if target then
            thisEntity:SetForceAttackTarget(target)
        end
    end

    -- 对血量最高的目标释放天火
    if ABI_SUN_STRIKE then
        print('ability sunstrike found')
        if ABI_SUN_STRIKE:IsFullyCastable() then
            print('sunstrike is castable')
            local target = AICore:StrongestEnemyHeroInRange( thisEntity, 2000 )
            if target then
                print(target:GetUnitName())
                thisEntity:Stop()
                print('BOSS INVOKER: attempt to cast sun strike')

                AICore:ShowWarningMessage( '#Boss_Invoker_warning_sun_strike' , 1 )
                thisEntity:CastAbilityOnPosition(target:GetOrigin(), ABI_SUN_STRIKE, -1)
                
                return 5 -- 休息5秒
            end
        end
    end

    -- 对最近目标释放超震声波
    if ABI_DEAF_BLAST then
        if ABI_DEAF_BLAST:IsFullyCastable() then
            local target = AICore:NearestEnemyHeroInRange(thisEntity, 500 )
            if target then
                
                print('BOSS INVOKER: attempt to cast defeaning blast')
                
                thisEntity:CastAbilityOnPosition(target:GetOrigin(), ABI_DEAF_BLAST, -1) 
                
                return 5
            end
        end
    end

    -- 对最弱目标释放急速冷却并攻击
    if ABI_COLD_SNAP then
        if ABI_COLD_SNAP:IsFullyCastable() then
            local target = AICore:WeakestEnemyHeroInRange(thisEntity, 800 )
            if target then
                
                print('BOSS INVOKER: attempt to cast cold snap')
                
                thisEntity:CastAbilityOnTarget(target, ABI_COLD_SNAP, -1) 
                thisEntity:PerformAttack(target, false, false, false, false)
                
                return 5
            end
        end
    end

    -- 如果可以释放熔炉精灵，则释放
    if ABI_FO_SPIRITE then
        if ABI_FO_SPIRITE:IsFullyCastable() then
            print('BOSS INVOKER: attempt to cast forge spirit')
            
            thisEntity:CastAbilityNoTarget(ABI_FO_SPIRITE, -1)
            
            return 5
        end
    end

    -- 如果可以释放灵动迅捷，则释放
    if ABI_ALACRITY then
        if ABI_ALACRITY:IsFullyCastable() then
            
            print('BOSS INVOKER: attempt to cast alacrity')
            
            thisEntity:CastAbilityOnTarget(thisEntity, ABI_ALACRITY, -1)
            
            return 5
        end
    end

    -- 如果可以释放冰墙，则对最近的目标释放冰墙
    --[[TODO]]

    -- 如果啥技能都不能放，则一秒后再检测
    return 1

end

function BossInvokerThink()

    -- 如果BOSS已经死亡，注册重新刷新的计时器，同时注销这个单位的AI
    if thisEntity:IsNull() or not thisEntity:IsAlive() then
        print('boss invoker is killed, respawning')
        GameRules:GetGameModeEntity():SetContextThink('boss_invoker_respawner', 
            function() 
                print('respawning invoker')
                
                local respawned_boss = CreateUnitByName('npc_cf_boss_invoker', BossInvokerStartPosition, true, nil, nil, DOTA_TEAM_BADGUYS)

                FireGameEvent('show_center_message', {
                    message = "#Boss_invoker_has_respawn",
                    duration = 5
                }) 
            end,
        300)
        return nil
    end

    if AICore:RandomEnemyHeroInRange(thisEntity , 2000 ) == nil then
        thisEntity:SetHealth(thisEntity:GetMaxHealth())
    end

    -- 如果没人对BOSS造成伤害，不触发，直接返回
    if thisEntity:GetHealth() == thisEntity:GetMaxHealth() then
        return 1
    end

    print('BOSS INVOKER DISTANCE'..( thisEntity:GetOrigin() - BossInvokerStartPosition ):Length())
    
    -- 如果BOSS的位置超过初始距离2000，让BOSS返回原位置
    if ( thisEntity:GetOrigin() - BossInvokerStartPosition ):Length() >= 2000 then
        thisEntity:SetHealth( thisEntity:GetMaxHealth() )
        thisEntity:SetOrigin( BossInvokerStartPosition )
        
        thisEntity:Stop()

        return 1
    end

    -- 如果正在战斗，释放技能
    return CastAbilities()

end

function Spawn( entityKeyValues )
    
    print("BOSS INVOKER: SPAWN")
    for k,v in pairs(entityKeyValues) do
        print(k,v)
    end

    -- 启动AI
    thisEntity:SetContextThink( "AIThink", BossInvokerThink , 1 )

    -- 记录初始位置
    if BossInvokerStartPosition == nil then
        BossInvokerStartPosition = thisEntity:GetOrigin()
    end

    --[[在主程序注册这个BOSS
    local MainGameMode = _G[CForgedGameMode]
    MainGameMode:RegisterLivingBoss(thisEntity)]]

    -- 初始化BOSS的技能等级
    local abilities = {
        'invoker_quas',
        'invoker_wex',
        'invoker_exort'
    }
    for _,ability in pairs(abilities) do
        local ABILITY = thisEntity:FindAbilityByName(ability)
        if ABILITY then 
            print('set ability to level 7')
            ABILITY:SetLevel(7) 
        end
    end
    for _,ability in pairs(BossAbilities) do
        local ABILITY = thisEntity:FindAbilityByName(ability)
        if ABILITY then ABILITY:SetLevel(7) end
    end

    ABI_COLD_SNAP  = thisEntity:FindAbilityByName('invoker_cold_snap') 
    ABI_FO_SPIRITE = thisEntity:FindAbilityByName('invoker_forge_spirit') 
    ABI_ICE_WALL   = thisEntity:FindAbilityByName('invoker_ice_wall') 
    ABI_SUN_STRIKE = thisEntity:FindAbilityByName('invoker_sun_strike') 
    ABI_DEAF_BLAST = thisEntity:FindAbilityByName('invoker_deafening_blast') 
    ABI_ALACRITY   = thisEntity:FindAbilityByName('invoker_alacrity') 

    local eStartPos = Entities:FindByName(nil, 'invoker_path_2')
    BossInvokerStartPosition = eStartPos:GetOrigin()
end
