function QuestTest(keys)
    print(keys.caller:GetName())-- 就是实体名字
    print(keys.activator:GetUnitName()) -- 就是英雄名字，npc_hero_crystal_maiden什么的
end