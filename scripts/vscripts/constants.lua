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

--伤害系统 精通类型
DAMAGE_CATEGORY_FORCE		= 'force'		--蛮力
DAMAGE_CATEGORY_SENSITIVE	= 'sensitive'	--灵敏
DAMAGE_CATEGORY_CUNNING		= 'cunning'		--狡诈
DAMAGE_CATEGORY_WISDOM		= 'wisdom'		--智慧