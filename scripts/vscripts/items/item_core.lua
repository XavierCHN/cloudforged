ItemCore = class({})

function ItemCore:GetAttribute(hero,attribute_type)
    for i = 0,5 do
        local ITEM = hero:GetItemInSlot(i) 
        local Attribute = 0
        if ITEM  then
            local Attribute = Attribute + tonumber(ITEM:GetSpecialValueFor(attribute_type))
        end
    end
end