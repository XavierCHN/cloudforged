function OnGoldTeleport(keys)

    local eTelEntity = keys.activator
    
    if eTelEntity then 
        if eTelEntity:IsRealHero() then
            local eGoldSpawner = Entities:FindByName(nil,'CFSpawner_Gold_Enemy_Spawner')
            eTelEntity:SetOrigin(eGoldSpawner:GetOrigin())
            if eGoldSpawner:GetContext('spawing_gold') == 'false' or eGoldSpawner:GetContext('spawing_gold') == nil then
                eGoldSpawner:SetContext('spawning_gold', 'true', 0) 


                local nSingleSpawnCount = 1
                local nSingleSpawnMultipler = 1
                local unitSpawned = {}
                eGoldSpawner:SetContextThink(DoUniqueString('gold_spawner_spawn_gold'),
                    function()
                        local currentSpawned = 0
                        for k,v in pairs(unitSpawned) do
                            if not v:IsNull() then
                                if IsValidEntity(v) then
                                    if v:IsAlive() then currentSpawned = currentSpawned + 1 end
                                end
                            end
                        end
                        -- 同时存在的活着的怪物只能有30个
                        if currentSpawned < 30 then 
                            for i=1,nSingleSpawnCount do
                                local goldCreep = CreateUnitByName('creep_gold', eGoldSpawner:GetOrigin() + RandomVector(200) , true, nil, nil, DOTA_TEAM_BADGUYS)
                                goldCreep:CreatureLevelUp(eTelEntity:GetLevel() + 3)
                                goldCreep:SetInitialGoalEntity(eTelEntity)
                                table.insert(unitSpawned,goldCreep)
                            end
                            nSingleSpawnMultipler = nSingleSpawnMultipler + 1 
                            nSingleSpawnCount = math.modf(nSingleSpawnMultipler / 10 )
                        end

                        if eGoldSpawner:GetContext('spawing_gold') == 'false' then
                            return nil
                        end
                        return 0.6
                    end, 2)
            else
                GameRules:GetGameModeEntity():SendCustomMessage('#Gold_Island_Allow_Only_One_Hero', eTelEntity:GetTeam(), 0)
            end

        end
    end
end

function OnGoldTeleportBackToBase(keys)
    local eTelEntity = keys.activator

    if eTelEntity then
        if eTelEntity:IsRealHero() then
            local eTelBack = Entities:FindByName(nil,'CFTeleport_Back_Base')
            if eTelBack then
                eTelEntity:SetOrigin(eGoldSpawner:GetOrigin())
            end
        end
    end

    local eGoldSpawner = Entities:FindByName(nil,'CFSpawner_Gold_Enemy_Spawner')
    if eGoldSpawner then
        eGoldSpawner:SetContext('spawning_gold', 'false', 0)
    end 
end