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
-----------------------------------------------------------------------------------------------------------------
ItemCore = {}
-- 精通等级名称表，从全局变量获取字符串
local category_names = {
        DAMAGE_CATEGORY_FORCE,
        DAMAGE_CATEGORY_SENSITIVE,
        DAMAGE_CATEGORY_CUNNING,
        DAMAGE_CATEGORY_WISDOM
    }
-----------------------------------------------------------------------------------------------------------------
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
        print('玩家的精通等级改变，改变类型:',name,'前后数值',value_old,value_new)
        caster:SetContext(name,tostring( value_new ),0)
    end
end
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
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
        print('玩家的精通等级改变，改变类型:',name,'前后数值',value_old,value_new)
        caster:SetContext(name,tostring( value_new ),0)
    end
end
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- 从物品中获取精通等级的方法，返回值为英雄所拥有的对应精通等级的数值/100 + 1
function ItemCore:GetAttribute(hero,category_name)
    return tonumber( hero:GetContext(category_name) or "0") / 100 + 1
end
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- 注册物品事件
function ItemCore:RegistEvents()
    --ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(ItemCore, "OnItemPurchased"), self) 
    --ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(ItemCore, "OnItemPickedUp"), self) 
end
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- 玩家购买物品事件
function ItemCore:OnItemPurchased(keys)
    print('=====ON ITEM PURCHASED=========')
    tPrintTable(keys)
    --[[
    keys
    itemcost
    itemname
    PlayerID
    ]]
    local itemname = keys.itemname
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local hero = player:GetAssignedHero()
    if self:IsPlayerHasItemSameType(hero, itemname) then
        print("Already has item this type, returning to shop")
        CFGeneral:ShowError("#only_1_this_type", keys.PlayerID)
        hero:ModifyGold(keys.itemcost, true, 0) 
        for i = 0,11 do
            local ITEM = hero:GetItemInSlot(i)
            if ITEM then
                if ITEM:GetName() == itemname then
                    ITEM:RemoveSelf()
                    break
                end
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- 玩家拾取物品事件
function ItemCore:OnItemPickedUp(keys)
    print('=====ON ITEM PICKUP=========')
    tPrintTable(keys)
    --[[
    keys
    itemname
    PlayerID
    ItemEntityIndex
    HeroEntityIndex
    ]]
    local itemname = keys.itemname
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local hero = player:GetAssignedHero()

    if self:IsPlayerHasItemSameType(hero, itemname) then
        print("Already has item this type, returning to shop")
        CFGeneral:ShowError("#only_1_this_type", keys.PlayerID)
        local ITEM = EntIndexToHScript(keys.ItemEntityIndex)
        ITEM:RemoveSelf()
        CFGeneral:DropLoot(itemname, hero:GetOrigin())
    end
end
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- 让一个英雄只能拥有一种类型物品的方法
function ItemCore:IsPlayerHasItemSameType(hero, newitem)
    print("************************")
    local item_counter = 0
    local newitem_type = string.sub(newitem,1,7)
    print(newitem_type)
    -- 循环英雄身上所有物品
    for i = 0, 11 do
        local ITEM= hero:GetItemInSlot(i)
        if ITEM then
            local item_type = string.sub(ITEM:GetName(),1,7)
            print(item_type)
            if itemtype == newitem_type then item_counter = item_counter + 1 end
        end
    end
    if item_counter > 1 then
        return true
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------
function CheckItemType(keys)
    tPrintTable(keys)
    local hero = keys.caster
    local ModifierName = keys.ModifierName
    if hero:GetContext(ModifierName) == nil then
        hero:SetContext(ModifierName,"1",0)
    else
        print("PLAYER HAS ALREADY HAS THIS ITEM")
        CFGeneral:ShowError("#only_1_this_type", keys.PlayerID)
        CFGeneral:DropLoot(itemname, hero:GetOrigin())
    end

end
-----------------------------------------------------------------------------------------------------------------
-- 在玩家身上所有物品中循环，寻找itemname对应的物品并返回hScript
function ItemCore:FindItemByName(hero,itemname)
    for i = 0,11 do
        local ITEM = hero:GetItemInSlot(i)
        if ITEM then
            print(i)
            print(ITEM:GetName())
            --[[
            if ITEM:GetName() == itemname then
                return ITEM
            end]]
        end
    end
    print("ITEM NOT FOUND RETURNING NIL")
    return nil
end
-----------------------------------------------------------------------------------------------------------------