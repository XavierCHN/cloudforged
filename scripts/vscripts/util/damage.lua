
	--接口
	--[[

		"RunScript"
		{
			"ScriptFile"	"scripts/vscripts/util/damage.lua"
			"Function"		"Damage"
		}
		
	]]

	--伤害字段
		
		--damage_base		基础伤害(貌似苍云传里都是0,那就不用填)

		--damage_increase	伤害系数(默认为1)
	
		--damage_type		伤害类型(dota预设,默认为纯粹伤害)

		--damage_weapon		武器类型(默认为魔法)
		DAMAGE_WEAPON_MAGIC		= 1		--魔法
		DAMAGE_WEAPON_SWORD		= 2		--剑

		--damage_element	元素类型(默认为火)
		DAMAGE_ELEMENT_FIRE		= 101		--火
		DAMAGE_ELEMENT_WATER	= 102		--水

		--damage_attribute	属性类型(默认为智力)
		DAMAGE_ATTRIBUTE_STR	= 201		--力量
		DAMAGE_ATTRIBUTE_AGI	= 202		--敏捷
		DAMAGE_ATTRIBUTE_INT	= 203		--智力

		--damage_area		伤害范围(仅范围伤害需要)

		--damage_team_type	队伍筛选(dota预设,仅范围伤害需要)
		
		--damage_target_type目标筛选(dota预设,仅范围伤害需要)
		
		--damage_sort_type	排序方式(dota预设,仅范围伤害需要)

	--全局Damage表
	Damage = {}

	local Damage = Damage

	setmetatable(Damage, Damage)

	--一些定义
	Damage.Define = {
	
		--武器类型
		DAMAGE_WEAPON_MAGIC		= 'hero_state_magic',
		DAMAGE_WEAPON_SWORD		= 'hero_state_sword',
		
		--元素类型
		DAMAGE_ELEMENT_FIRE		= 'hero_state_fire',
		DAMAGE_ELEMENT_WATER	= 'hero_state_water',

		--属性类型
		DAMAGE_ATTRIBUTE_STR	= 'GetStrength',
		DAMAGE_ATTRIBUTE_AGI	= 'GetAgility',
		DAMAGE_ATTRIBUTE_INT	= 'GetGetIntellect',
	}

	--伤害表的默认值
	Damage.damage_meta = {
		__index = {
			attacker 			= nil, 							--伤害来源
			victim 				= nil, 							--伤害目标
			damage				= 0,							--伤害
			damage_base			= 0,							--基础伤害,不写的话是0
			damage_add			= 0,							--额外伤害(在除以对方等级之前)
			damage_type			= DAMAGE_TYPE_PURE,				--伤害类型,不写的话是纯粹伤害
			damage_flags 		= 1, 							--伤害标记
			damage_increase		= 1, 							--伤害系数,只有技能伤害需要用到,写了以后会按照默认的技能公式进行运算.非技能伤害不要填写
			damage_weapon		= DAMAGE_WEAPON_MAGIC,			--武器类型,只有技能伤害需要用到,人物对应的武器熟练度影响伤害
			damage_element		= DAMAGE_ELEMENT_FIRE,			--元素类型,只有技能伤害需要用到,人物对应的元素精通影响伤害
			damage_attribute	= DAMAGE_ATTRIBUTE_INT,			--属性类型,只有技能伤害需要用到,人物对应的属性数值影响伤害
			
			attacker_level		= 1,							--攻击者等级
			victim_level		= 1,							--目标等级
			ability_level		= 1,							--技能等级
			
			damage_area			= nil,							--伤害范围,不填就是单体伤害,填了是群体
			damage_team_type	= DOTA_UNIT_TARGET_TEAM_ENEMY,	--队伍筛选
			damage_target_type	= DOTA_UNIT_TARGET_ALL,			--目标筛选
			damage_sort_type	= FIND_CLOSEST,					--排序方式
			
			Apply = function(damage, victim)					--对指定目标造成伤害
				damage.victim 		= victim
				damage.victim_level	= victim:GetLevel()
				damage.damage 		= damage.damage_base + damage.damage_add / damage.victim_level
				
				ApplyDamage(damage)
			end,
		},
	}

	--造成伤害主函数(技能)
	function Damage.__call(Damage, keys)
		--获取技能
		local ability	= keys.ability
		local target	= keys.target	--技能施放目标(单位或点)
		
		--获取技能传参,构建伤害table
		local damage = {
			attacker		= EntIndexToHScript(keys.caster_entindex), 		--技能施放者								
			damage_base		= ability:GetSpecialValueFor 'damage_base',		--基础伤害
			damage_type		= ability:GetSpecialValueFor 'damage_type',		--技能伤害类型
			damage_flags	= ability:GetSpecialValueFor 'damage_flags',	--技能标记
			attacker_level	= attacker:GetLevel(),							--技能施放者的等级
			ability_level	= ability:GetLevel(),							--技能等级
		}

		--添加默认值
		setmetatable(damage, Damage.damage_meta)

		--按公式计算出基础伤害
		local damage_increase	= ability:GetSpecialValueFor 'damage_increase'	--伤害系数
		local damage_weapon		= ability:GetSpecialValueFor 'damage_weapon'	--武器类型
		local damage_element	= ability:GetSpecialValueFor 'damage_element'	--元素类型
		local damage_attribute	= ability:GetSpecialValueFor 'damage_attribute'	--属性类型
		
		local damage_weapon		= attacker:GetSpecialValueFor(Damage.Define[damage_weapon])		or 0	--单位该武器的数值
		local damage_element	= attacker:GetSpecialValueFor(Damage.Define[damage_element])	or 0	--单位该元素的数值
		local damage_attribute	= attacker[Damage.Define[damage_attribute]](attacker)			or 0	--单位该属性的数值
		damage.damage_add		= (1 + damage_element / 10) * damage_weapon * damage_attribute * (1.5 + damage.ability_level * 0.5) * damage.attacker_level

		--如果是单体伤害,则直接造成伤害
		if not damage.damage_area then
			damage:Apply(target)
			return
		end

		--读取群体参数
		damage.damage_area			= ability:GetSpecialValueFor 'damage_area'			--伤害范围
		damage.damage_team_type		= ability:GetSpecialValueFor 'damage_team_type'		--队伍筛选
		damage.damage_target_type	= ability:GetSpecialValueFor 'damage_target_type'	--目标筛选
		damage.damage_sort_type		= ability:GetSpecialValueFor 'damage_sort_type'		--排序方式

		--群体伤害,则进行搜寻
		local targets = FindUnitsInRadius(
			   damage.attacker:GetTeam(),	--施法者的队伍
			   target:GetOrigin(),			--技能释放点
			   nil,					    	--实体
			   damage.damage_area,			--搜寻范围
			   damage.damage_team_type,		--队伍筛选
			   damage.damage_target_type,	--目标筛选
			   0,							--
			   damage_sort_type,			--排序类型
			   false						--
		)
		for i, victim in ipairs(targets) do
	        damage:Apply(victim)
		end
	end