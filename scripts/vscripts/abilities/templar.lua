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
            --[[
            -- 在陷阱列表中循环
            for k,v in pairs(TATraps) do
              
              -- 引爆周围300单位的所有陷阱
              if GetTrapDistance(v.position,point) < 300 then
               
                -- 调用Damage施加伤害
                local damage_keys = {
                  caster_entindex = keys.caster_entindex,
                  ability = keys.ability,
                  damage_category = DAMAGE_CATEGORY_SENSITIVE,
                  damage_type = DAMAGE_TYPE_PURE,
                  damage_agi = 0.4,
                  damage_min = 200,
                  target_entities = FindUnitsInRadius(
                    caster:GetTeam(),
                    v.position,
                    nil,
                    50,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    0, FIND_CLOSEST,
                    false)
                }
                DamageTarget(damage_keys)
                
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
            end ]]
            
            -- 移除英雄移动限制
            caster:RemoveModifierByName('modifier_rooted') 
            
            

          end, 0.8)
        return nil
      end

      return 0.07
    end,0.07)
end

function OnSakuraBladeImpact(keys)
  local caster = keys.caster
  for k,v in pairs(keys) do
    print(k,v)
  end
  for k,v in pairs(keys.target_entities) do
    local trap_pos = v:GetOrigin()
    v:SetContextThink(DoUniqueString('sakura_blade_death'),
      function()
        if not v:IsAlive() then
          
          local dummy_unit = CreateUnitByName('npc_cf_ta_trap', trap_pos, false, caster, caster, caster:GetTeam())
          local trap_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
          ParticleManager:SetParticleControl(trap_particle, 0, trap_pos)

          table.insert(TATraps,trap_particle,{
            position = trap_pos,
            owning_unit = dummy_unit
          })
        end
      end,0.2)
  end
end

function OnPathtonSakura(keys)
  -- 获取施法者
  local caster = keys.caster
  -- 避免重复释放
  if caster:HasModifier('modifier_phantom_sakura_interlock') then
    return
  end 
  -- 获取施法者位置
  local caster_origin = caster:GetOrigin()
  -- 设定旋转角度
  local move_rotate_angle = QAngle(0,144,0)
  -- 设置启示位置
  local move_start_pos = caster_origin + Vector( 500 , 0 , 0 )
  -- 设置运动目标位置
  local move_target_pos = RotatePosition(caster_origin, move_rotate_angle, move_start_pos)
  -- 计数器
  local corner_count = 0
  -- 创建第一个陷阱粒子特效并保存
  local dummy_unit = CreateUnitByName('npc_cf_ta_trap', move_target_pos, false, caster, caster, caster:GetTeam())
  local trap_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
  ParticleManager:SetParticleControl(trap_particle, 0, move_target_pos)
  table.insert(TATraps,trap_particle,{
    position = move_target_pos,
    owning_unit = dummy_unit
  })
  -- 初始化玩家移动位置
  caster:SetOrigin(move_start_pos)
  -- 让玩家无法移动
  caster:AddNewModifier(caster, nil, 'modifier_rooted', {}) 
  -- 开始玩家运动计时器
  caster:SetContextThink(DoUniqueString('phantom_sakura_main'),
    function()
      -- 获取玩家位置
      local cOrigin = caster:GetOrigin()
      -- 计算下一个运动位置
      local rOrigin = cOrigin + (move_target_pos - move_start_pos):Normalized() * 60
      -- 设置玩家面向角度
      caster:SetForwardVector((move_target_pos - move_start_pos):Normalized())
      -- 设置英雄的运动位置
      caster:SetOrigin(rOrigin)

      -- 如果距离目标位置距离大于30，继续循环
      if GetTrapDistance(cOrigin,move_target_pos) > 40 then
        return 0.03
      else
        corner_count = corner_count + 1
        if corner_count >= 5 then
          caster:SetOrigin(caster_origin)
          local jump_up_offset = Vector(0,0,80)
          local drop_down_offset = Vector(0,0,0)
          local rOrigin = caster:GetOrigin() + jump_up_offset
          local jumping_up = true
          caster:SetContextThink(DoUniqueString('jumping'),
            function()
              caster:SetOrigin(rOrigin)
              --==================================
              if jumping_up then
                jump_up_offset.z = jump_up_offset.z - 8
                rOrigin = rOrigin + jump_up_offset
              else
                drop_down_offset.z = drop_down_offset.z - 20
                rOrigin = rOrigin + drop_down_offset
              end
              if rOrigin.z > 1200 then
                jumping_up = false

                return 0.8
              end
              --==================================
              if rOrigin.z < caster_origin.z - 20 then
                -- 让英雄回到初始位置
                caster:SetOrigin(caster_origin)
                -- 在陷阱列表中循环
                for k,v in pairs(TATraps) do
                  -- 引爆周围300单位的所有陷阱
                  if GetTrapDistance(v.position,caster_origin) < 700 then
                    -- 调用Damage施加伤害
                    local damage_keys = {
                      caster_entindex = keys.caster_entindex,
                      ability = keys.ability,
                      damage_category = DAMAGE_CATEGORY_SENSITIVE,
                      damage_type = DAMAGE_TYPE_PURE,
                      damage_agi = 0.4,
                      damage_min = 200,
                      target_entities = FindUnitsInRadius(
                        caster:GetTeam(),
                        v.position,
                        nil,
                        100,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        0, FIND_CLOSEST,
                        false)
                    }
                    DamageTarget(damage_keys)
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
                return nil
              end
              return 0.03
            end,
          0.03)
          caster:RemoveModifierByName('modifier_rooted') 
          caster:RemoveModifierByName('modifier_phantom_sakura_interlock') 
          return nil
        else
          -- 终点变起点，继续循环。
          move_start_pos = move_target_pos
          caster:SetOrigin(move_start_pos)
          move_target_pos = RotatePosition(caster_origin, move_rotate_angle, move_start_pos)
          -- 创建下一个粒子特效并存储
          local dummy_unit = CreateUnitByName('npc_cf_ta_trap', move_target_pos, false, caster, caster, caster:GetTeam())
          local trap_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
          ParticleManager:SetParticleControl(trap_particle, 0, move_target_pos)
          table.insert(TATraps,trap_particle,{
            position = move_target_pos,
            owning_unit = dummy_unit
          })

          return 0.03
        end
      end
    end,
  0.03)
end