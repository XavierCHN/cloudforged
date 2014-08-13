--[[

  计时器函数Timers
  调用方法：
  Timers:CreateTimer(
    function()
      函数体
      return 下一次调用时间，如果只是使用一次的timer，就不return
    end,DoUniqueString('timer提示'), 延迟时间
  )
  例如
  Timers:CreateTimer(
    function()
      print('hello')
    end,DoUniqueString('print'), 1)
  将会在一秒之后打印一次hello
  
  local count = 0
  Timers:CreateTimer(
    function()
      count = count + 1
      print('hello')
      if count < 5 then return 1 end
    end,DoUniqueString('print'), 1)
    将会每隔一秒打印一次hello，打印五次
    
]]

local timers = {}
function timers:CreateTimer(...)
    if not dota_base_game_mode then
        print('WARNING: Timer created too soon!')
        return
    end

    local ent = dota_base_game_mode.thisEntity

    -- Run the timer
    ent:SetThink(...)
end
Timers = timers
