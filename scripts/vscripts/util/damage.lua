
	--接口如下

	--[[

	"RunScript"
	{
		"ScriptFile"	"scripts/vscripts/util/damage.lua"
		"Function"		"Damage"
		"damage"		"0"
		"damage_type"	"DAMAGE_TYPE_PURE"
		"damage_para"	"1.5"
	}

		damage		基础伤害,不写的话是0
		damage_type	伤害类型,不写的话是纯粹伤害
		damage_para	伤害系数,只有技能伤害需要用到,写了以后会按照默认的技能公式进行运算.非技能伤害不要填写
	
	--]]

	--全局Damage表
	Damage = {}

	local Damage = Damage

	setmetatable(Damage, Damage)

	Damage.damage_meta = {
		__index = {
			attacker 		= nil, 				--伤害来源
			victim 			= nil, 				--伤害目标
			damage 			= 0,				--默认伤害为0
			damage_type		= DAMAGE_TYPE_PURE, --默认伤害类型为纯粹
			damage_flags 	= 1, 				--默认标记为1
			damage_para 	= nil, 				--伤害系数
		},
	}

	--造成伤害主函数
	function Damage.__call(Damage, damage)
		--添加默认值
		setmetatable(damage, Damage.damage_meta)

		--如果有伤害系数,则按照公式进行伤害计算;否则直接造成伤害
		if damage.damage_para then
			--按照公式计算伤害--（1+宁雨/10)*剑术*智力*1.2*等级/敌人等级 getPara函数是口胡的,用于获取宁雨/剑术/智力等参数
			local attacker	= damage.attacker
			local victim	= damage.victim
			damage = damage + (1 + attacker:getPara(1) / 10) * attacker:getPara(2) * attacker:getPara(3) * damage.damage_para * attacker:GetLevel() / victim:GetLevel()
		end
		
		--计算完毕
		ApplyDamage(damage)
	end