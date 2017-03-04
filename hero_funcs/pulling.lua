local next = next -- makes things quicker apparently :|
require( GetScriptDirectory().."/locations2" )
require( GetScriptDirectory().."/hero_funcs/generic" )

function Set (list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function reset_pull_vars()
    _G.state.current_target = nil
    _G.state.temp_memory.creeps_aggroed = nil
    _G.state.temp_memory.have_pulled = false
    return
end

---------------------
--ML parameters
-------------------
local params = {}
params["damage_spread_neutral"] = -0.161610971193 --dynamic
params["damage_spread_lane"] = 0.370439000794 --dynamic
params["p_hero_attack_range"] = 0 --dynamic
params["hero_attackspeed"] = 0.440648986884 --dynamic
params["hero_attackdamage"] = -0.395334854736 --dynamic
params["hero_movespeed"] = -0.165955990595 --dynamic
params["p_targeted_neutral_eff_hp"] = 0 --dynamic
params["p_targeted_lane_eff_hp"] = 0 --dynamic
params["p_neutral_total_eff_hp"] = 0 --dynamic
params["p_lane_total_eff_hp"] = 0 --dynamic

--local p_damage_spread_lane = 0 --dynamic
--local p_hero_attack_range = 0 --dynamic
--local p_hero_attackspeed = 0 --dynamic
--local p_hero_attackdamage = 0 --dynamic
--local p_hero_movespeed = 0 --dynamic
--local p_targeted_neutral_eff_hp = 0 --dynamic
--local p_targeted_lane_eff_hp = 0 --dynamic
--local p_neutral_total_eff_hp = 0 --dynamic
--local p_lane_total_eff_hp = 0 --dynamic

function CDOTA_Bot_Script:time_to_chain_pull_ML(params, values)
    local result = 0
    --TODO assuming ordered correctly seems an unncessary hassle
    for i=1,#params do
        result = result + (params[i] * values[i])
    end

end


--function CDOTA_Bot_Script:time_to_chain_pull_ML(damage_spread_neutral, damage_spread_lane, hero_attack_range,
--    hero_attackspeed, hero_attackdamage, hero_movespeed, targeted_neutral_eff_hp, targeted_lane_eff_hp,
--    neutral_total_eff_hp, lane_total_eff_hp
--)
--    local value = p_damage_spread_neutral* damage_spread_neutral * p_damage_spread_neutral + p_damage_spread_lane
--end




function CDOTA_Bot_Script:pull_camp(camp, timing, should_chain, pull_num, double_timing)
--    if pull_num == 0 and chain_pull ~= nil then
--        return self:pull_camp(RAD_SAFE_HARD, 59, false, 1);
--    end

    -- someone damaging the camp without pulling might break this?
    if not camp.is_alive then
        reset_pull_vars()
        _G.state.current_mode = "none"
        return
    end


    -- even after aggroing, if theyre fogged it reports velocity as 0 and max health as -1. Nice! :D
    if not _G.state.temp_memory.creeps_aggroed then
        -- The only time our 'action' goes over the minute, is in a chain pull. if we've told it to chain pull, then dont need to check time
        if (_G.seconds > timing - self:estimate_travel_time(camp.location) or pull_num == 1) then
            self:aggro_camp(camp)
        else
            self:Action_MoveToLocation(camp.pull_to) -- now is too early. stand in waiting spot
        end
    else -- we've 'initiated' the pull
        -- do the double pull
        -- replace with time to pull and creep health to always work
        if should_chain and self:time_to_chain_pull_basic(double_timing) == true and camp.is_alive then

            local values = {}
            values["damage_spread_neutral"] = 0
            values["damage_spread_lane"] = 0
--            values["hero_attack_range"] = 0
--            values["hero_attackspeed"] = 0
--            values["hero_attackdamage"] = 0
--            values["hero_movespeed"] = 0
--            values["targeted_neutral_eff_hp"] = 0
--            values["targeted_lane_eff_hp"] = 0
--            values["neutral_total_eff_hp"] = 0
--            values["lane_total_eff_hp"] = 0


            local hero_data = {
                name=self:GetUnitName(),
                range = self:GetAttackRange(),
                attackspeed = self:GetAttackSpeed(),
                attackdamage = self:GetAttackDamage(),
                movespeed = self:GetCurrentMovementSpeed()
            }

            local neutral_creeps = {}
            for i,v in ipairs(self:GetNearbyNeutralCreeps(1000, false)) do
                --                for k,v in pairs(targets) do
                --                    if k ~= v:GetAttackTarget() do
                if v:WasRecentlyDamagedByCreep() then
                    values["damage_spread_neutral"] = values["damage_spread_neutral"] + 1
                end

                local neutral = {
                    health=v:GetHealth(),
                    armour=v:GetArmor(),
                }
                neutral_creeps[#neutral_creeps+1] = neutral
            end

            local lane_creeps = {}
            local targets = {}
            for i,v in ipairs(self:GetNearbyLaneCreeps(1000, false)) do
--                for k,v in pairs(targets) do
--                    if k ~= v:GetAttackTarget() do
                if v:WasRecentlyDamagedByCreep() then --does this work for neutrals?
                    values["damage_spread_lane"] = values["damage_spread_lane"] + 1
                end
                local lane_creep = {
                    health=v:GetHealth(),
                    armour=v:GetArmor(),
                }
                lane_creeps[#lane_creeps+1] = lane_creep
            end

            local data = {type="parameter_values", values=values}
--            local data = {type="parameters", hero_data=hero_data, lane_creeps=lane_creeps, neutral_creeps=neutral_creeps,
--                damage_spread_lane=damage_spread_lane, damage_spread_neutral=damage_spread_neutral}
            print("JSN:" .. tostring(JSON:encode(data)))
            reset_pull_vars()
            _G.state.neutrals.rad_safe_ez.is_alive = false -- TODO this isnt being updated properly
            if _G.state.neutrals.rad_safe_hard.is_alive then
                _G.state.current_mode = "chain_pull_hard"
            else
                _G.state.current_mode = "none"
            end
            return
        end

        --if pull_num == 1 then friendly_creep_rad_check = 400 -- because we want to pull creeps all way over to other camp. dont stop halfway
        if _G.state.temp_memory.have_pulled ~= true and GetUnitToLocationDistance(self, camp.pull_to) > 200 then -- we have pulled and are dragging creeps into lane
            self:Action_MoveToLocation(camp.pull_to)
        else
            _G.state.temp_memory.have_pulled = true
            self:farm_camp(camp)
        end
    end
end

function CDOTA_Bot_Script:get_target(camp)
    if _G.state.current_target == nil or _G.state.current_target:IsAlive() == false then
        local neuts = self:GetNearbyNeutralCreeps(1000)
        for k, v in pairs(neuts) do
            if (v:GetHealth() > 0) and GetUnitToLocationDistance(v, camp.location) < 300 and string.match(v:GetUnitName(), "neutral") then
                return v
            end
        end
        return nil
    else
        return _G.state.current_target
    end
end

function CDOTA_Bot_Script:aggro_camp(camp)
    if _G.state.current_target == nil then
        _G.state.current_target = self:get_target(camp)
    end

    if _G.state.current_target  ~= nil and _G.state.current_target:IsAlive() == true
    then
        self:Action_AttackUnit(_G.state.current_target, true)
        if self:haveWeAggroedPull() then
            _G.state.temp_memory.creeps_aggroed = true
        end
    else
        self:Action_MoveToLocation(camp.location)
    end
    return
end

function CDOTA_Bot_Script:farm_camp(camp)

    -- erm what is 220 for. why did I do that?
    if _G.state.current_target == nil or (not next(self:GetNearbyLaneCreeps(1000, false)) and _G.state.current_target:GetHealth() < 220) then --either pull failed or all our creeps are dead
        _G.state.temp_memory.creeps_aggroed = nil
        _G.state.temp_memory.have_pulled = false
        _G.state.current_mode = "none"
        return
    end
    if _G.state.current_target:GetHealth() == 0 or _G.state.current_target:IsAlive() == false then -- check IsAlive
        _G.state.current_target = self:get_target(camp)
    end

    if _G.state.current_target ~= nil then
        self:Action_AttackUnit(_G.state.current_target, true)
    else -- camp is dead. go do some other stuff
        camp.is_alive = false
        _G.state.temp_memory.creeps_aggroed = nil
        _G.state.temp_memory.have_pulled = false
        _G.state.current_mode = "none"
        self:Action_MoveToLocation(RAD_SAFE_EASY.pull_to)
    end
end

function CDOTA_Bot_Script:time_to_chain_pull_basic(timing)
    return DotaTime() >= timing
end


-- rushed. maybe refactor
function CDOTA_Bot_Script:time_to_chain_pull(camp)
    local camp_health = 0
    local camp_max_health = 0 -- fogged creeps have 0.. or -1
    local neuts = self:GetNearbyNeutralCreeps(1000)
    for _, v in pairs(neuts) do
        if GetUnitToLocationDistance(v, camp.location) < 300 and string.match(v:GetUnitName(), "neutral") then
            camp_health = camp_health + v:GetHealth()
            camp_max_health = camp_max_health + v:GetMaxHealth()
        end
    end
    if camp_health <= 600 and camp_max_health > 600 then
        return true
    else
        return false
    end
end

function CDOTA_Bot_Script:haveWeAggroedPull()
    return not (_G.state.current_target:GetVelocity().x == 0 and _G.state.current_target:GetVelocity().y == 0 and not _G.state.temp_memory.creeps_aggroed
            and _G.state.current_target:GetHealth() == _G.state.current_target:GetMaxHealth() and next(self:GetNearbyLaneCreeps(300, false)) == nil)
end