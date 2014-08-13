ItemCore = class({})

function OnItemAdded(keys)
    print('item core on item added called')
    for k,v in pairs(keys) do
        print(k,v)
    end
end

function OnItemTakenAway(keys)
    print('item core on item taken away')
    for k,v in pairs(keys) do
        print(k,v)
    end
end

function ItemCore:Init()
end
function ItemCore:GetAttribute(hero,attribute_type)
end

