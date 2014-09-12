--[[
            ==   天炼:global_function.lua   ==
            ************2014.08.10************
            **************AMHC****************
            ==================================
                Authors:
                XavierCHN
                ...
            ==================================
]]

function tPrint(msg)
    if not msg then return end
    local sMsg = tostring(msg)
    if DEBUG_MODE then
        print(sMsg)
    end
end

function tPrintTable(msg)
    tPrint('--P.RINTING TABLE--')
    for k,v in pairs(msg) do
        local sMsg = tostring(k)..' : '..tostring(v)
        tPrint(sMsg)
    end
    tPrint('--E.NDPRINT TABLE--')
end


---------------------------------------------------------------------------------------------------
if CFGeneral == nil then
    CFGeneral = class({})
end

function CFGeneral:DropLoot( lootItemType, position )
    local newItem = CreateItem( lootItemType, nil, nil )
    newItem:SetPurchaseTime( 0 )
    local drop = CreateItemOnPositionSync( position , newItem)
    if drop then
        drop:SetContainedItem( newItem )
        newItem:LaunchLoot( false, 100, 0.35, position + RandomVector( RandomFloat( 10, 100 ) ) )
    end
end

function CFGeneral:ShowError(msg, playerid)
    FireGameEvent('custom_error_show', {player_ID = playerid, _error = msg})
end
---------------------------------------------------------------------------------------------------