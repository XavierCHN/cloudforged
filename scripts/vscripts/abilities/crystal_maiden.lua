if CCrystalMaiden == nil then
  print ( '[CloudForged] creating CCrystalMaiden' )
  CCrystalMaiden = {}
  CCrystalMaiden.szEntityClassName = "CCrystalMaiden"
  CCrystalMaiden.szNativeClassName = "dota_ability_crystal_maiden_class"
  CCrystalMaiden.__index = CCrystalMaiden
end

function CCrystalMaiden.new( orm )
  print ( '[CloudForged] CCrystalMaiden:new' )
  orm = orm or {}
  setmetatable( orm, CCrystalMaiden )
  return orm
end

function CCrystalMaiden:OnCrystalMaiden01Start(keys)
	local target = keys.target
	local caster = EntIndexToHScript(keys.caster_entindex)
	local nPlayerID = keys.unit:GetPlayerID()
	local magic = 1  --Todo
	local fire = 1  --Todo
	local increase = keys.ability:LoadKeyValuesFromString("base_Increase")
	local area = keys.ability:LoadKeyValuesFromString("base_area")
	local casterLevel = caster:GetLevel()
	local targetLevel = caster:GetLevel()
	local attribute = 0
	if( keys.ability:LoadKeyValuesFromString("increase_type") == "int" )then
		attribute = caster:GetIntellect()
	end
	local abilityLevel = keys.ability:GetLevel()
	local damage = (1 + fire/10 ) * magic * attribute * (2.0 + (abilityLevel-1)*0.5) * casterLevel/targetLevel
	local DamageTable = {
	victim = target, 
	attacker = caster, 
	damage = damage, 
	damage_type = DAMAGE_TYPE_PURE, 
	damage_flags = 1
	}
	self:UnitDamageArea(DamageTable,target:GetOrigin(),200+(abilityLevel-1)*80)
end

function CCrystalMaiden:UnitDamageTarget(DamageTable)
	ApplyDamage(damage)
end

function CCrystalMaiden:UnitDamageArea(DamageTable,vec,area)
	local DamageTargets = FindUnitsInRadius(
		   caster:GetTeam(),		--caster team
		   vec,		                --find position
		   nil,					    --find entity
		   area,		            --find radius
		   DOTA_UNIT_TARGET_TEAM_ENEMY,
		   DOTA_UNIT_TARGET_ALL,
		   0, FIND_CLOSEST,
		   false
	)
	for k,v in pairs(DamageTargets) do
        ApplyDamage(DamageTable)
	    print("[CloudForged]CrystalMaiden Damagetargets!")
	end
end

