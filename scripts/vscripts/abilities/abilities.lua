

--红雾死神 3技能 隐藏被动
function axe_war_will_hidden( keys )
	local caster=EntIndexToHScript(keys.caster_entindex) 
	local target={}
	target=keys.target_entities
	for i,tar in pairs(target) do
		local order={	UnitIndex=tar:entindex() ,
						TargetIndex=caster:entindex() ,
						OrderType=DOTA_UNIT_ORDER_ATTACK_TARGET,
					}
		ExecuteOrderFromTable(order) 
	end
end

--红雾死神大招
function axe_titan_force_effect( keys )
	local caster = EntIndexToHScript(keys.caster_entindex) 
	local vec=keys.target_points
	local effect = ParticleManager:CreateParticle("particles/hw_fx/hw_roshan_death_e.vpcf",PATTACH_WORLDORIGIN,caster)
	ParticleManager:SetParticleControl(effect,0,vec[1])
	ParticleManager:ReleaseParticleIndex(effect) 
end