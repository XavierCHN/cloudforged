
	--接口
	--[[

		"RunScript"
		{
			"ScriptFile"		"scripts/vscripts/util/damage.lua"
			"Function"			"Damage"
			"damage_base"		"0"									//固定的基础伤害(默认0)
			"damage_increase"	"1"									//伤害系数(默认1)
			"damage_type"		"DAMAGE_TYPE_PURE"					//伤害类型(默认纯粹)
			"damage_category"	"DAMAGE_CATEGORY_FORCE"				//精通类型(默认蛮力)
			"damage_str"		"1"									//力量加成(默认0)
			"damage_agi"		"1"									//敏捷加成(默认0)
			"damage_int"		"1"									//智力加成(默认0)
			"damage_min"		"0"									//该技能最少能造成的伤害(默认0)
		}
		
	]]

	--常量
		--damage_category	精通类型(默认为蛮力)
		DAMAGE_CATEGORY_FORCE		= 'force'		--蛮力
		DAMAGE_CATEGORY_SENSITIVE	= 'sensitive'	--灵敏
		DAMAGE_CATEGORY_CUNNING		= 'cunning'		--狡诈
		DAMAGE_CATEGORY_WISDOM		= 'wisdom'		--智慧



	--全局Damage表
	Damage = {}

	local Damage = Damage

	setmetatable(Damage, Damage)

	--伤害表的默认值
	Damage.damage_meta = {
		__index = {
			attacker 			= nil, 						--伤害来源
			victim 				= nil, 						--伤害目标
			damage				= 0,						--伤害
			damage_base			= 0,						--基础伤害,不写的话是0
			damage_add			= 0,						--额外伤害(在除以对方等级之前)
			damage_type			= DAMAGE_TYPE_PURE,			--伤害类型,不写的话是纯粹伤害
			damage_flags 		= 1, 						--伤害标记
			damage_increase		= 1, 						--伤害系数,只有技能伤害需要用到,写了以后会按照默认的技能公式进行运算.非技能伤害不要填写
			damage_category		= DAMAGE_CATEGORY_FORCE,	--精通类型,只有技能伤害需要用到,人物对应的武器熟练度影响伤害
			damage_str			= 0,						--力量加成系数
			damage_agi			= 0,						--敏捷加成系数
			damage_int			= 0,						--智力加成系数
			damage_min			= 0,						--最小伤害
			
			attacker_level		= 1,						--攻击者等级
			victim_level		= 1,						--目标等级
			ability_level		= 1,						--技能等级
			attacker_attribute	= 0,						--单位属性数值
			category_level		= 0,						--精通数值
		},
	}

	--造成伤害主函数(技能)
	function Damage.__call(Damage, damage)
		--获取技能
		local targets	= keys.target_entities	--技能施放目标(数组)

		if not targets then
			print(debug.traceback '无伤害目标')
		end

		--添加默认值
		setmetatable(damage, Damage.damage_meta)
		
		--获取技能传参,构建伤害table
		damage.attacker				= EntIndexToHScript(keys.caster_entindex)						--伤害来源(施法者)
		damage.attacker_level		= attacker:GetLevel()											--技能施放者的等级
		damage.ability_level		= ability:GetLevel()											--技能等级
		damage.category_level		= ItemCore:GetAttribute(damage.attacker,keys.damage_category)	--伤害分类精通

		--根据公式计算出伤害(在除以对方的等级之前)
			--精通等级 * 伤害系数 * (力量 * 力量系数 + 敏捷 * 敏捷系数 + 智力 * 智力系数) * 技能等级 ^ 2 * 英雄等级 / 目标等级
		damage.damage_add			=	damage.category_level
									*	damage.damage_increase
									*	(
											damage.attacker:GetStrength()	* damage.damage_str
										+	damage.attacker:GetAgility()	* damage.damage_agi
										+	damage.attacker:GetIntellect()	* damage.damage_int
									)
									*	damage.ability_level * damage.ability_level
									*	damage.attacker_level

		--遍历数组进行伤害
		for i, victim in ipairs(targets) do
	        damage.victim 		= victim
			damage.victim_level	= victim:GetLevel()
			damage.damage 		= math.max(damage.damage_min, damage.damage_base + damage.damage_add / damage.victim_level)
			
			ApplyDamage(damage)
		end
	end