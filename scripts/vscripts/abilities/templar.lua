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
      dummy_unit:EmitSound('Hero_TemplarAssassin.Trap')

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

      -- 获取技能变量
      local damage_agi_ratio = tonumber(keys.ability:GetLevelSpecialValueFor('damage_agi',keys.ability:GetLevel() -1))
      local ability_damage_min = tonumber(keys.ability:GetLevelSpecialValueFor('damage_min',keys.ability:GetLevel() -1))
      local ability_radius = tonumber(keys.ability:GetLevelSpecialValueFor('ability_radius',keys.ability:GetLevel() -1))

      -- 跳出循环的条件
      if direction.y >= 360 then

        local particle_blink_start = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_break.vpcf', PATTACH_CUSTOMORIGIN, caster) 
        ParticleManager:SetParticleControl(particle_blink_start, 1, caster:GetOrigin())
        ParticleManager:ReleaseParticleIndex(particle_blink_start)
        -- 在跳出放陷阱循环后，将英雄放到樱花环的中心
        caster:SetOrigin(point)
        
        -- 为英雄创造闪现的粒子特效
        local particle_blink = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit) 
        ParticleManager:SetParticleControl(particle_blink,0,point)
        ParticleManager:ReleaseParticleIndex(particle_blink)
        
        -- 让英雄无法移动
        caster:AddNewModifier(caster, nil, 'modifier_rooted', {})
        caster:AddNewModifier(caster, nil, 'modifier_silence', {})

        caster:SetContextThink(DoUniqueString("release_circle"), 
          function()
            caster:RemoveModifierByName('modifier_rooted') 
            caster:RemoveModifierByName('modifier_silence') 
            -- 获取自身周围500范围内的目标并施加伤害
            -- 调用Damage施加伤害
            local damage_keys = {
              caster_entindex = keys.caster_entindex,
              ability = keys.ability,
              damage_category = DAMAGE_CATEGORY_SENSITIVE,
              damage_type = DAMAGE_TYPE_PURE,
              damage_agi = damage_agi_ratio,
              damage_min = ability_damage_min,
              target_entities = FindUnitsInRadius(
                caster:GetTeam(),
                caster:GetOrigin(),
                nil,
                ability_radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                0, FIND_CLOSEST,
                false)
            }
            DamageTarget(damage_keys)
            -- 移除英雄移动限制
            caster:RemoveModifierByName('modifier_rooted') 
          end, 
        0.03)
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

  local damage_agi_ratio = tonumber(keys.ability:GetLevelSpecialValueFor('damage_agi',keys.ability:GetLevel() -1))

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
  local cOrigin = move_start_pos
  -- 让玩家无法移动
  caster:AddNewModifier(caster, nil, 'modifier_rooted', {}) 
  -- 开始玩家运动计时器
  caster:SetContextThink(DoUniqueString('phantom_sakura_main'),
    function()
      -- 设置英雄的运动位置
      caster:SetOrigin(move_target_pos)
      local p = ParticleManager:CreateParticle('particles/hero_templar/antimage_blink_end_b.vpcf',PATTACH_CUSTOMORIGIN,caster)
      -- 创建闪烁粒子特效
      ParticleManager:SetParticleControl(p, 0, caster:GetOrigin())
      ParticleManager:ReleaseParticleIndex(p)
      move_start_pos = move_target_pos
      move_target_pos = RotatePosition(caster_origin, move_rotate_angle, move_start_pos)
      -- 创建下一个粒子特效并存储
      local dummy_unit = CreateUnitByName('npc_cf_ta_trap', move_target_pos, false, caster, caster, caster:GetTeam())
      dummy_unit:EmitSound('Hero_TemplarAssassin.Trap')
      local trap_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
      ParticleManager:SetParticleControl(trap_particle, 0, move_target_pos)
      table.insert(TATraps,trap_particle,{
        position = move_target_pos,
        owning_unit = dummy_unit
      })

        -- 计算已经转向的次数
        corner_count = corner_count + 1

        -- 如果转向次数达到五次，完成了五角星
        if corner_count >= 5 then
          -- 让英雄回到初始位置
          caster:SetOrigin(caster_origin)

          local p = ParticleManager:CreateParticle('particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf', PATTACH_CUSTOMORIGIN,caster)
          ParticleManager:SetParticleControl(p, 0, caster_origin)
          ParticleManager:ReleaseParticleIndex(p)
          caster:EmitSound('Hero_TemplarAssassin.Trap')
          -- 英雄开始跳跃
          local jump_up_offset = Vector(0,0,80)
          local drop_down_offset = Vector(0,0,0)
          local rOrigin = caster:GetOrigin() + jump_up_offset
          local jumping_up = true

          caster:SetContextThink(DoUniqueString('jumping'),
            function()
              caster:SetOrigin(rOrigin)
              --==================================
              if jumping_up then -- 伪跳跃加速度
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
                  -- 引爆周围700单位的所有陷阱
                  if GetTrapDistance(v.position,caster_origin) < 700 then
                    -- 调用Damage施加伤害
                    local targets = FindUnitsInRadius(
                        caster:GetTeam(),
                        v.position,
                        nil,
                        300,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        0, FIND_CLOSEST,
                        false)
                    if #targets > 0 then
                      local damage_keys = {
                        caster_entindex = keys.caster_entindex,
                        ability = keys.ability,
                        damage_category = DAMAGE_CATEGORY_SENSITIVE,
                        damage_type = DAMAGE_TYPE_PURE,
                        damage_agi = damage_agi_ratio, --  伤害敏捷系数加成0.04
                        damage_min = 300,
                        target_entities = targets
                      }
                      DamageTarget(damage_keys)
                    end
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
                  caster:EmitSound('Hero_TemplarAssassin.Trap.Explode')
                end
                return nil
              end
              return 0.03
            end,
          0.03)
          -- 让英雄恢复移动 
          caster:RemoveModifierByName('modifier_rooted') 
          -- 移除连锁
          caster:RemoveModifierByName('modifier_phantom_sakura_interlock') 
          return nil
        end -- 结束 跳跃
        return 0.1
    end,
  0.03)
end

function OnSakuraFall(keys)
  -- 获取释放英雄
  local caster = keys.caster
  
  -- 获取英雄朝向
  local forward_vec = caster:GetForwardVector()

  -- 获取技能数值
  local damage_base = tonumber(keys.ability:GetLevelSpecialValueFor('damage_base',keys.ability:GetLevel() -1))
  local damage_length = tonumber( keys.ability:GetLevelSpecialValueFor('length',keys.ability:GetLevel() -1))
  print(damage_length)
  local caster_origin = caster:GetOrigin()
  print(forward_vec)
  local currentLength = 30
  caster:SetContextThink(DoUniqueString('sakura_fall'),
    function()
      for angleStart = -40,40,10 do
        local angle = QAngle(0,angleStart,0)
        local pPos = RotatePosition(caster_origin, angle, caster_origin + forward_vec * currentLength)
        local p = ParticleManager:CreateParticle('particles/hero_templar/antimage_manavoid_explode_b.vpcf', PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl(p, 0, pPos)
        ParticleManager:ReleaseParticleIndex(p)

        local targets = FindUnitsInRadius(
                caster:GetTeam(),
                pPos,
                nil,
                80, -- 数学渣
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                0, FIND_CLOSEST,
                false)
        if #targets > 0 then

          local damage_keys = {
            caster_entindex = keys.caster_entindex,
            ability = keys.ability,
            damage_category = DAMAGE_CATEGORY_CUNNING,
            damage_type = DAMAGE_TYPE_PURE,
            damage_min = damage_base,
            target_entities = targets
          }
          DamageTarget(damage_keys)
        end
      end
      currentLength = currentLength + 150
      if currentLength > damage_length then
        return nil
      end
      return 0.07
    end,
  0.03)
end

function OnSakuraPath(keys)
  local caster = keys.caster
  local caster_origin = caster:GetOrigin()
  local caster_fv = caster:GetForwardVector()
  local ABILITY = keys.ability

  caster:AddNewModifier(caster, nil, "modifier_rooted", {})

  -- 提升被动等级
  local level = tonumber(caster:GetContext('sakura_path_passive_level') or 0)
  level = math.min( level + 1 , 7 )
  local ABILITY_EFFECT = caster:FindAbilityByName('templar_sakura_path_passive')
  if ABILITY_EFFECT then ABILITY_EFFECT:SetLevel(level) end
  caster:SetContext("sakura_path_passive_level", tostring(level) , 0 )
  local sakura_disappear_time = GameRules:GetGameTime() + 4.9
  caster:SetContext("sakura_path_disappear_time",tostring(sakura_disappear_time),4.9)
  caster:SetContextThink(DoUniqueString('passive_check'),
    function()
      local time = GameRules:GetGameTime()
      if not caster:GetContext("sakura_path_disappear_time") then return nil end
      if time >= tonumber(caster:GetContext("sakura_path_disappear_time")) then
        caster:SetContext("sakura_path_passive_level", "0" , 0 )
        ABILITY_EFFECT:SetLevel(0)
        caster:SetContext("sakura_path_disappear_time","0", 0)
        if caster:HasModifier('modifier_sakura_path_passive_effect') then
          caster:RemoveModifierByName('modifier_sakura_path_passive_effect')
        end
      end
      return nil
    end,
  5)

  -- 有30%的概率刷新1技能
  local intChance = RandomInt(1, 100)
  if intChance > 70 then
    local ABILITY_DANCE = caster:FindAbilityByName('templar_sakura_fall') 
    if ABILITY_DANCE then ABILITY_DANCE:EndCooldown() end
  end

  local currentLength = 0
  caster:SetContextThink(DoUniqueString('sakura_path'),
      function()
        local rOrigin = caster_origin + caster_fv * currentLength
        caster:SetOrigin(rOrigin)
        currentLength = currentLength + 70
        if currentLength >= 700 then 
          caster:RemoveModifierByName('modifier_rooted')
          
          caster:RemoveModifierByName('modifier_templar_sakura_path')
          return nil
        end
        return 0.03
      end,
    0.03)
end