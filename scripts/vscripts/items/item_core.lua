--[[
"Modifiers"
{
    "modifier_damage_category"
    {
        "Passive"   "1"
        "IsHidden"  "1"
        "Attributes"    "MODIFIER_ATTRIBUTE_MULTIPLE"
        "OnCreated"
        {
            "RunScript"
            {
                "ScriptFile"        "scripts/vscripts/items/item_core.lua"
                "Function"          "OnAddItemCategory"
                "CategorySensitive"     "10"    //四个数值，代表增加的对应属性值，可选填，最好引用AbilitySpecial中的数值。
                "CategorySensitive" "10"        //增加10点，其对应技能实际伤害数值相当于增加 1 + 10/100 = 1.1倍
                "CategoryCunning"   "10"
                "CategoryWisdom"    "10"
            }
        }
        "OnDestroy"
        {
            "RunScript"
            {
                "ScriptFile"        "scripts/vscripts/items/item_core.lua"
                "Function"          "OnRemoveItemCategory"
                "CategoryForce"     "10"
                "CategorySensitive" "10"
                "CategoryCunning"   "10"
                "CategoryWisdom"    "10"
            }
        }
    }


]]

ItemCore = {}

local category_names = {
        DAMAGE_CATEGORY_FORCE,
        DAMAGE_CATEGORY_SENSITIVE,
        DAMAGE_CATEGORY_CUNNING,
        DAMAGE_CATEGORY_WISDOM
    }
    
    
function OnAddItemCategory(keys)
    local caster = keys.caster
    local value_add = {
        [DAMAGE_CATEGORY_FORCE] = tonumber(keys.CategoryForce or "0" )
        [DAMAGE_CATEGORY_SENSITIVE] = tonumber(keys.CategorySensitive or "0" )
        [DAMAGE_CATEGORY_CUNNING] = tonumber(keys.CategoryCunning or "0" )
        [DAMAGE_CATEGORY_WISDOM] = tonumber(keys.CategoryWisdom or "0" )
    }
    
    for _,name in pairs(category_names) do
        local value_old = tonumber( caster:GetContext(name) or "0" )
        local value_add = value_add[name]
        local value_new = value_old + value_add
        caster:SetContext(name,value_new,0)
    end
end


function OnRemoveItemCategory(keys)
    local caster = keys.caster
    local value_remove = {
        [DAMAGE_CATEGORY_FORCE] = tonumber(keys.CategoryForce or "0" )
        [DAMAGE_CATEGORY_SENSITIVE] = tonumber(keys.CategorySensitive or "0" )
        [DAMAGE_CATEGORY_CUNNING] = tonumber(keys.CategoryCunning or "0" )
        [DAMAGE_CATEGORY_WISDOM] = tonumber(keys.CategoryWisdom or "0" )
    }
    
    for _,name in pairs(category_names) do
        local value_old = tonumber( caster:GetContext(name) or "0" )
        local value_remove = value_remove[name]
        local value_new = value_old - value_remove
        caster:SetContext(name,value_new,0)
    end
end

function ItemCore:GetAttribute(hero,category_name)
    return tonumber( hero:GetContext(category_name) or "100") / 100
end

