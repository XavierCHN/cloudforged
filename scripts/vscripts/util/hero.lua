
	--全局Hero表
	Hero = {}

	local Hero = Hero

	setmetatable(Hero, Hero)

	--英雄的默认值
	Hero.hero_meta = {
		__index = {
			handle 	= nil,			--英雄实例

			values	= nil,			--存储自定义数据,需要在创建英雄表的时候新建table

			--设置自定义数据
				--通过	hero:Set(k, v)	调用
			Set	= function(hero, key, value)
				hero.values[key] = value
			end,

			--获取自定义数据
				--通过	hero:Get(k)		调用
			Get	= function(hero, key)
				return hero.values[key]
			end,
		},
	}

	--注册英雄,返回英雄表
	function Hero.Init(hUnit)
		--创建英雄表
		Hero[hUnit] = {
			handle 	= hUnit,	--实例
			values 	= {},		--存储自定义数据
		}

		--添加默认值
		setmetatable(Hero[hUnit], Hero.hero_meta)

		--返回英雄表
		return Hero[hUnit]
	end

	--从实例上获取英雄表
		--可以同时通过Hero[hUnit]与Hero(hUnit)来获得英雄表
	function Hero.__call(Hero, hUnit)
		return Hero[hUnit]
	end