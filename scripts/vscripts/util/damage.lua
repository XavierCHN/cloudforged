
	--接口
	--[[

		"RunScript"
		{
			"ScriptFile"		"scripts/vscripts/util/damage.lua"
			"Function"			"DamageTarget"
			"damage_base"		"0"									//固定的基础伤害(默认0)
			"damage_increase"	"1"									//伤害系数(默认1)
			"damage_type"		"DAMAGE_TYPE_PURE"					//伤害类型(默认纯粹)
			"damage_category"	"force"								//精通类型(默认蛮力)
				//可选项
				/*
					'force'		--蛮力
					'sensitive'	--灵敏
					'cunning'	--狡诈
					'wisdom'	--智慧
				*/
			"damage_str"		"1"									//力量加成(默认0)
			"damage_agi"		"1"									//敏捷加成(默认0)
			"damage_int"		"1"									//智力加成(默认0)
			"damage_min"		"0"									//该技能最少能造成的伤害(默认0)
		}
		
	]]

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
			category_level		= 1,						--精通数值
		},
	}

	--造成伤害主函数(技能)
	function DamageTarget(damage)
		
		--获取技能
		local targets	= damage.target_entities or {damage.victim}	--技能施放目标(数组)
		
		--print('damage called for '..#targets)
		
		if #targets == 0 then
			print(debug.traceback '无伤害目标')
		end

		--添加默认值
		setmetatable(damage, Damage.damage_meta)
		
		--获取技能传参,构建伤害table
		damage.attacker			= damage.caster_entindex and EntIndexToHScript(damage.caster_entindex) or damage.attacker	--伤害来源(施法者)
		damage.attacker_level	= damage.attacker:GetLevel()																--技能施放者的等级
		damage.ability_level	= damage.ability:GetLevel()																	--技能等级
		damage.category_level	= ItemCore:GetAttribute(damage.attacker,damage.damage_category)								--伤害分类精通
		damage.damage_type		= type(damage.damage_type) == 'string' and _G[damage.damage_type] or damage.damage_type		--转换伤害类型常量
		

		-- 伤害计算公式：
		-- 至少造成基础伤害
		-- 最终伤害 = 基础伤害 + 加成伤害
		-- 精通等级 = （1+物品增加的精通等级/100） == 已经在GetAttribute计算
		-- 加成伤害 = (精通等级 * 伤害系数 * (1+((力量*力量系数 + 敏捷*敏捷系数 + 智力*智力系数) /100 )
		-- * 技能等级 * 英雄等级)/目标等级
		
		
		damage.damage_result=	damage.damage_base +
								damage.category_level
								*	damage.damage_increase
								*	
									(1 +
										((
											damage.attacker:GetStrength()	* damage.damage_str
										+	damage.attacker:GetAgility()	* damage.damage_agi
										+	damage.attacker:GetIntellect()	* damage.damage_int
										) / 100 )
									)
								*	damage.ability_level * damage.ability_level
								*	damage.attacker_level

		--遍历数组进行伤害		
		for i, victim in ipairs(targets) do
				if IsValidEntity(victim) and victim:IsAlive() then
		        	damage.victim 		= victim
		        	damage.victim_level	= victim:GetLevel()
					damage.damage 		= math.max(damage.damage_min, damage.damage_result / damage.victim_level)

					local damage_dealt = ApplyDamage(damage)
					print('damage dealt[]:'..damage_dealt)
				end
		end

	end
