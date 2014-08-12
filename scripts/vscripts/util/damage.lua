
	--接口如下

	--[[

	"RunScript"
	{
		"ScriptFile"	"scripts/vscripts/util/damage.lua"
		"Function"		"Damage"
		"damage"		"100"
		"damage_type"	"DAMAGE_TYPE_PURE"
	}
	
	--]]

	--全局Damage表
	Damage = {}

	local Damage = Damage

	setmetatable(Damage, Damage)

	Damage.damage_meta = {
		__index = {
			attacker = nil, --伤害来源
			victim = nil, --伤害目标
			damage = 0, --默认伤害为0
			damage_type = DAMAGE_TYPE_PURE, --默认伤害类型为纯粹
			damage_flags = 1, --默认标记为1
			para = 1, --伤害系数
		},
	}

	--造成伤害主函数
	function Damage.__call(Damage, damage)
		--添加默认值
		setmetatable(damage, Damage.damage_meta)

		--按照公式计算伤害--（1+宁雨/10)*剑术*智力*1.2*等级/敌人等级 
		local attacker = damage.attacker
		damage = damage + (1 + attacker:getPara(1) / 10) * attacker:getPara(2) * attacker:getPara(3) * damage.para * attacker:getLevel() / damage.victim:getlevel()
		
		--计算完毕
		ApplyDamage(damage)
	end