--[[
变量的命名规则
1.在标识意思明确的情况下，尽量缩小长度，比如说CurrentValue，允许缩写成CurrValue等
2.尽量避免使用数字区分。
3.变量的前缀标识变量类型
    h = handle
    s = string
    n = number
    b = boolean
    f = float
    e = entity
    t = table
    v = vector

函数名使用动词+名词的方式，比如GetPlayerName(),GetDistance等，与官方的API规则尽量一致

常量使用全部大写字母，如DOTA_PLAYER_TEAM

lua文件架构：
主目录文件夹只存放addon_game_mode.lua，存放游戏流程控制，事件监听等核心代码

addon_game_mode.lua里面载入
require('require_everything')
其他lua都通过require_everything


还没写完，其他的大家讨论决定
]]