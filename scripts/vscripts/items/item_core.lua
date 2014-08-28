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
                "CategoryCunning"   "10"        //
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
-- 精通等级名称表，从全局变量获取字符串
local category_names = {
        DAMAGE_CATEGORY_FORCE,
        DAMAGE_CATEGORY_SENSITIVE,
        DAMAGE_CATEGORY_CUNNING,
        DAMAGE_CATEGORY_WISDOM
    }
    
-- 从物品中读取精通等级，并绑定给单位
function OnAddItemCategory(keys)
    -- 获取物品的拥有者
    local caster = keys.caster
    -- 读取设置值，默认增加值为0
    local value_add = {
        [DAMAGE_CATEGORY_FORCE] = tonumber(keys.CategoryForce or "0" ),
        [DAMAGE_CATEGORY_SENSITIVE] = tonumber(keys.CategorySensitive or "0" ),
        [DAMAGE_CATEGORY_CUNNING] = tonumber(keys.CategoryCunning or "0" ),
        [DAMAGE_CATEGORY_WISDOM] = tonumber(keys.CategoryWisdom or "0" )
    }
    -- 将各种精通等级写入英雄Context
    for _,name in pairs(category_names) do
        local value_old = tonumber( caster:GetContext(name) or "0" )
        local value_add = value_add[name]
        local value_new = value_old + value_add
        caster:SetContext(name,value_new,0)
    end
end

-- 当物品因任何原因，死亡/丢弃或者其他问题，从英雄身上移除，将会移除该物品所带来的精通等级
function OnRemoveItemCategory(keys)
    -- 获取物品拥有者
    local caster = keys.caster
    -- 获取物品所定义的精通等级，默认为0
    local value_remove = {
        [DAMAGE_CATEGORY_FORCE] = tonumber(keys.CategoryForce or "0" ),
        [DAMAGE_CATEGORY_SENSITIVE] = tonumber(keys.CategorySensitive or "0" ),
        [DAMAGE_CATEGORY_CUNNING] = tonumber(keys.CategoryCunning or "0" ),
        [DAMAGE_CATEGORY_WISDOM] = tonumber(keys.CategoryWisdom or "0" )
    }
    -- 为英雄的精通等级设置新值，可能为负数，但是没关系
    for _,name in pairs(category_names) do
        local value_old = tonumber( caster:GetContext(name) or "0" )
        local value_remove = value_remove[name]
        local value_new = value_old - value_remove
        caster:SetContext(name,value_new,0)
    end
end

-- 从物品中获取精通等级的方法，返回值为英雄所拥有的对应精通等级的数值/100 + 1
function ItemCore:GetAttribute(hero,category_name)
    return tonumber( hero:GetContext(category_name) or "0") / 100 + 1
end

-- 让一个英雄只能拥有一种类型物品的方法
function ItemCore:CheckItemType(hero, newitem)
    -- 循环英雄身上所有物品
    for i = 0, 11 do
        local ITEM= hero:GetItemInSlot(i)
        if ITEM then
            local item_type = ITEM:GetSpecialValueFor("item_type")
            local item_new_type = newitem:GetSpecialValueFor("item_type")
            -- 如果物品类型和身上某一个物品类型相同
            if item_type == item_new_type and (not item_new_type == "other")then
                -- 为玩家增加购买金钱
                PlayerResource:SetGold(hero:GetPlayerID(), PlayerResource:GetUnreliableGold(hero:GetPlayerID())+ newitem:GetCost(), false)
                -- 移除物品
                item:Remove()
                break
            end
        end
    end
end
