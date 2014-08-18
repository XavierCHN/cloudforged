if traps == nil then
  traps = {}
end

-- 0.07秒释放一个陷阱，总共释放6个，完成时间0.42秒
function PlantACircleTrap(keys)
  for k,v in pairs(keys) do
    print(k,v)
  end
  -- 获取施法者
  local caster = keys.caster
  -- 获取目标施法点
  local points = keys.target_points
  
  -- 初始化四周转向
  local direction = Vector(0,0,0)
  
  -- 移动英雄到目标地点并使其无法移动
  caster:SetOrigin(points[1])
  caster:AddNewModifier(caster,"modifier_rooted",{})
  
  -- 开始释放陷阱循环
  caster:SetContextThink(DoUniqueString("plant_trap"),
    function()
      -- 计算四周施法点，以英雄/施法地点为中心，周围150范围
      local trap_pos = RotatePosition(point,direction,point + Vector(150,0,0))
      -- 创建马甲单位
      local trap_unit = CreateUnitByName("npc_cf_ta_trap",trap_pos,false,nil,nil,caster:GetTeam())
      
      -- 存储马甲单位
      table.insert(traps,trap_unit)
      
      -- 为下一个马甲单位旋转施法点
      direction = direction + Vector(0,60,0)
      if direction.y >= 360 then
        -- 当一圈释放完毕，停止释放循环，移除英雄移动限制
        caster:RemoveModifierByName("modifier_rooted")
        return nil
      end
      return 0.07
    end,0.07)
end
