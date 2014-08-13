	--[[

		计时器函数Timer
		调用方法：
		Timer.Wait '5秒后打印一次' (5,
			function()
				print '我已经打印了一次文本'
			end
		)

		Timer.Loop '每隔1秒打印一次,一共打印5次' (1, 5,
			function(i)
				print('这是第' .. i .. '次打印')
				if i == 5 then
					print('我改变主意了,我还要打印10次,但是间隔降低为0.5秒')
					return 0.5, i + 10
				end
				if i == 10 then
					print('我好像打印的太多了,算了不打印了')
					return true
				end
			end
		)
	]]

	--全局计时器表
	Timer = {}
	
	local Timer = Timer

	setmetatable(Timer, Timer)

	function Timer.Wait(name)
		if not dota_base_game_mode then
	        print('WARNING: Timer created too soon!')
	        return
	    end
	    
		return function(t, func)
			local ent	= dota_base_game_mode.thisEntity

			ent:SetThink(func, DoUniqueString(name), t)
		end
	end

	function Timer.Loop(name)
		if not dota_base_game_mode then
	        print('WARNING: Timer created too soon!')
	        return
	    end
	    
		return function(t, count, func)
			if not func then
				count, func = -1, count
			end
			
			local times = 0
			local function func2()
				times 				= times + 1
				local t2, count2	= func(times)
				t, count = t2 or t, count2 or count
				
				if t == true or times == count then
					return nil
				end

				return t
			end
			
			local ent 	= dota_base_game_mode.thisEntity
			
			ent:SetThink(func2, DoUniqueString(name), t)
		end
	end