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
        local sMsg = tostring(k)..' : '..tosting(v)
        tPrint(sMsg)
    end
    tPrint('--E.NDPRINT TABLE--')
end

function GetDistance(vPos1,vPos2)
    if not (vPos1.x and vPos1.y and vPos2.x and vPos2.y ) then
        tPrint( 'ERROR: attempt to call function GetDistance with non-vector pramater' , DEV_PRINT )
        return 0
    else
        local fDifx = vPos1.x - vPos2.x
        local fDify = vPos1.y - vPos2.y
        return math.sqrt( fDifx * fDifx + fDify * fDify )
    end
end

function GetDistance3D(vPos1,vPos2)
    if not (vPos1.x and vPos1.y and vPos1.z and vPos2.x and vPos2.y and vPos2.z ) then
        tPrint( 'ERROR: attempt to call function GetDistance3D with non-vector pramater' , DEV_PRINT )
        return 0
    else
        local fDifx = vPos1.x - vPos2.x
        local fDify = vPos1.y - vPos2.y
        local fDifz = vPos1.z - vPos2.z
        return math.sqrt( fDifx * fDifx + fDify * fDify + fDifz * fDifz )
    end
end