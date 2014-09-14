function OnBingyuanSuifuCast(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local mana = caster:GetMana()
    caster:AddAbility('tusk_ice_shards') 
    local ABILITY = caster:FindAbilityByName('tusk_ice_shards')
    ABILITY:SetLevel(4) 
    ABILITY:SetOverrideCastPoint(0)
    ABILITY:EndCooldown() 
    caster:CastAbilityOnPosition(point, ABILITY, caster:GetPlayerID()) 
    caster:SetContextThink(DoUniqueString('remove_ability') ,
        function()
            caster:RemoveAbility('tusk_ice_shards')
            caster:SetMana(mana)
        end,
    0.2)
end

function OnGaoliTiefuCast(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local mana = caster:GetMana()
    caster:AddAbility('earthshaker_fissure') 
    local ABILITY = caster:FindAbilityByName('earthshaker_fissure')
    ABILITY:SetLevel(4) 
    ABILITY:SetOverrideCastPoint(0)
    ABILITY:EndCooldown() 
    caster:CastAbilityOnPosition(point, ABILITY, caster:GetPlayerID()) 
    caster:SetContextThink(DoUniqueString('earthshaker_fissure') ,
        function()
            caster:RemoveAbility('earthshaker_fissure')
            caster:SetMana(mana)
        end,
    0.2)
end

function OnTouluLiefuCast(keys)
    local caster = keys.caster
    local target = keys.target_entities[1]
    local mana = caster:GetMana()
    caster:AddAbility('axe_culling_blade') 
    local ABILITY = caster:FindAbilityByName('axe_culling_blade')
    ABILITY:SetLevel(3) 
    ABILITY:SetOverrideCastPoint(0)
    ABILITY:EndCooldown() 
    caster:CastAbilityOnTarget(target, ABILITY, caster:GetPlayerID())
    caster:SetContextThink(DoUniqueString('axe_culling_blade') ,
        function()
            caster:RemoveAbility('axe_culling_blade')
            caster:SetMana(mana)
        end,
    0.2)
end
function OnShijunZhifuCast(keys)
    local caster = keys.caster
    local mana = caster:GetMana()
    caster:AddAbility('sven_warcry') 
    local ABILITY = caster:FindAbilityByName('sven_warcry')
    ABILITY:SetLevel(4) 
    ABILITY:SetOverrideCastPoint(0)
    ABILITY:EndCooldown() 
    caster:CastAbilityNoTarget(ABILITY, caster:GetPlayerID()) 
    caster:SetContextThink(DoUniqueString('sven_warcry') ,
        function()
            caster:RemoveAbility('sven_warcry')
            caster:SetMana(mana)
        end,
    0.2)
end

function OnShuangyiZhanfuCast(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local mana = caster:GetMana()
    caster:AddAbility('beastmaster_wild_axes') 
    local ABILITY = caster:FindAbilityByName('beastmaster_wild_axes')
    ABILITY:SetLevel(4) 
    ABILITY:SetOverrideCastPoint(0)
    ABILITY:EndCooldown() 
    caster:CastAbilityOnPosition(point, ABILITY, caster:GetPlayerID()) 
    caster:SetContextThink(DoUniqueString('beastmaster_wild_axes') ,
        function()
            caster:RemoveAbility('beastmaster_wild_axes')
            caster:SetMana(mana)
        end,
    0.2)
end


function OnKaishanZhifuCast(keys)
    local caster = keys.caster
    local mana = caster:GetMana()
    caster:AddAbility('tusk_walrus_punch') 
    local ABILITY = caster:FindAbilityByName('tusk_walrus_punch')
    ABILITY:SetLevel(3) 
    ABILITY:SetOverrideCastPoint(0)
    ABILITY:EndCooldown() 
    caster:CastAbilityNoTarget(ABILITY, caster:GetPlayerID()) 
    caster:SetContextThink(DoUniqueString('tusk_walrus_punch') ,
        function()
            caster:RemoveAbility('tusk_walrus_punch')
            caster:SetMana(mana)
        end,
    0.2)
end