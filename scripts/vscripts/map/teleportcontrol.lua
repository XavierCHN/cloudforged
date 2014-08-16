function OnGoldTeleport(keys)
    print('ON GOLD TELEPORT CALLED')
    for k,v in pairs(keys) do
        print(k,v)
    end
    local eTelEntity = keys.activator
    
    if eTelEntity then 
        if eTelEntity:IsRealHero() then
            eTelEntity:SetOrigin(Entities:FindByName(nil,'CFTeleport_1'):GetOrigin())
        end
    end
end