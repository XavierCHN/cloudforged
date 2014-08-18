if TATraps == nil then
  TATraps = {}
end

-- 获取两个点距离的局部函数
local function GetTrapDistance(vecA,vecB)
  local x1 = vecA.x
  local y1 = vecA.y
  local x2 = vecB.x
  local y2 = vecB.y
  return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

-- 0.07秒释放一个陷阱，总共释放6个，完成时间0.42秒 -- 释放完成后，本体经过0.8秒之后闪现进圆圈，引爆樱之环并造成伤害
function PlantACircleTrap(keys)

  -- 获取施法者
  local caster = keys.caster
  -- 获取目标施法点
  local point = keys.target_points[1]
  
  -- 初始化四周转向
  local direction = QAngle(0,0,0)
  local trap_pos = point + Vector(200,0,0)

  -- 开始释放陷阱循环
  caster:SetContextThink(DoUniqueString("plant_trap"),
    function()

      -- 创建粒子特效绑定马甲
      local dummy_unit = CreateUnitByName('npc_cf_ta_trap', point, false, caster, caster, caster:GetTeam())

      -- 计算本粒子特效位置
      local trap_pos = RotatePosition( point , direction , trap_pos)

      -- 创建粒子特效并设置位置
      local trap_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
      ParticleManager:SetParticleControl(trap_particle, 0, trap_pos)

      -- 存储粒子特效的ID，位置和马甲单位
      table.insert(TATraps,trap_particle,{
        position = trap_pos,
        owning_unit = dummy_unit
        })

      -- 为下一次循环修改位置
      direction = direction + QAngle(0,60,0)

      -- 跳出循环的条件
      if direction.y >= 360 then

        local particle_blink_start = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_break.vpcf', PATTACH_CUSTOMORIGIN, caster) 
        ParticleManager:SetParticleControl(particle_blink_start, 0, caster:GetOrigin())
        ParticleManager:ReleaseParticleIndex(particle_blink_start) --[[Returns:void
        Frees the specified particle index
        ]]
        -- 在跳出放陷阱循环后，将英雄放到樱花环的中心
        caster:SetOrigin(point)
        
        -- 为英雄创造闪现的粒子特效
        local particle_blink = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit) 
        ParticleManager:SetParticleControl(particle_blink,0,point)
        ParticleManager:ReleaseParticleIndex(particle_blink)
        
        -- 让英雄无法移动
        caster:AddNewModifier(caster, nil, 'modifier_rooted', {})

        -- 0.8秒之后，释放樱花环
        caster:SetContextThink(DoUniqueString("release_circle"), 
          function()
            
            -- 为了避免陷阱循环出错的临时表
            local temp = {}
            
            -- 在陷阱列表中循环
            for k,v in pairs(TATraps) do
              
              -- 引爆周围300单位的所有陷阱
              if GetTrapDistance(v.position,point) < 300 then
               
                -- 移除陷阱特效的粒子特效
                UTIL_RemoveImmediate(v.owning_unit)
                ParticleManager:ReleaseParticleIndex(k)
                
                -- 将粒子特效移除出列表
                TATraps[k] = nil

                -- 为引爆的粒子特效增加引爆粒子特效
                local particle_blink = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit) 
                ParticleManager:SetParticleControl( particle_blink , 0 , v.position )
                ParticleManager:ReleaseParticleIndex( particle_blink )

              end
            end
            
            -- 移除英雄移动限制
            caster:RemoveModifierByName('modifier_rooted') 
          end, 0.8)
        return nil
      end

      return 0.07
    end,0.07)
end

