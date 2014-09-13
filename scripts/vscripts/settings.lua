-- 自定义最大等级
CUSTOM_MAX_LEVEL = 75

-- 经验图表
CUSTOM_XP_TABLE = {}
local xp = 0
for i=1,CUSTOM_MAX_LEVEL - 1 do
  CUSTOM_XP_TABLE[i] = i * i * 100 + xp
  xp = xp + i * i * 100
end

-- 英雄选择时间
TIME_HERO_SELECTION = 60

-- 游戏准备阶段时间
TIME_PRE_GAME = 120
