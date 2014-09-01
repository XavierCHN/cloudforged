 -- CFRoundThinker:IncreaseRestTime(duration)

function OnItemRestPurchased(keys)
    for k,v in pairs(keys) do
        print(k,v)
    end

    local caster = keys.caster

    local ITEM = keys.ability
    print(ITEM:GetName())
    for i=0,11 do
        local ITEM = caster:GetItemInSlot(i)
        if ITEM then
            print(ITEM:GetName())
        end
    end

    local playerid = caster:GetPlayerID()
    -- 如果不是正在休息阶段，显示错误信息，并退回金钱
    if CFRoundThinker:StateGet() ~= 2 then
        CFGeneral:ShowError("#Increase_rest_time_can_only_be_purchased_during_resting", playerid)
        caster:AddItem(CreateItem("item_cf_increase_rest",caster,caster))
    else
        CFRoundThinker:IncreaseRestTime(30)
    end
end