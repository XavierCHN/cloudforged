--[[
            ==   天炼:constants.lua   ==
            *********2014.08.10*********
            ***********AMHC*************
            ============================
                Authors:
                XavierCHN
                ...
            ============================
]]

ADDON_PREFIX = '[C.F]'

if DEBUG_MODE == nil then
    if Convars:GetFloat( 'developer' ) == 1 then
        DEBUG_MODE = true
    else
        DEBUG_MODE = false
    end
end

--tPrint
ALWAYS_PRINT = 0
DEV_PRINT = 1
LOG_PRINT = 2