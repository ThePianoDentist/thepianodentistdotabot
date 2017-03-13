local next = next -- makes things quicker apparently :|
require( GetScriptDirectory().."/locations2" )
require( GetScriptDirectory().."/hero_funcs/generic" )
require( GetScriptDirectory().."/utility_funcs" )

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
params["p_hero_attackrange"] = -98.5357324448 --dynamic
params["p_hero_attackspeed"] = -0.170246347935 --dynamic
params["p_hero_attackdamage"] = -7.49743232042 --dynamic
params["p_hero_movespeed"] = -43.3832889123 --dynamic

params["p_damage_spread_neutral"] = -0.143773182753 --dynamic
params["p_neutral_total_eff_hp"] = 0.0033 --dynamic
params["p_targeted_neutral_eff_hp"] = 0.0033 --dynamic
params["p_fraction_neutral_left"] = 0.0033 --dynamic

params["p_damage_spread_lane"] = 0.0033 --dynamic
params["p_fraction_lane_left"] = -0.0555292731014 --dynamic
params["p_targeted_lane_eff_hp"] = 0.0033 --dynamic
params["p_lane_total_eff_hp"] = -104.930474431 --dynamic


function CDOTA_Bot_Script:send_results()
    _G.final_values.success = self:check_chain_pull_success()
    --print("Success: " .. tostring(_G.final_values.success))
    local data = _G.final_values
    local truncated_data = {}
--    for k, v in pairs(data) do -- 256 char limit on data. must truncate
--        local split_key = split(k, "_")
--        local trunc_key = ""
--        for _, v in ipairs(split_key) do
--            trunc_key = trunc_key .. v:gsub("^(.).-$", "%1")
--        end
--        truncated_data[trunc_key] = v
--    end
    print("JSN:" .. tostring(JSON:encode(data)))
    local request_str = "doublepull/run?data=" .. tostring(JSON:encode(data))
    --print(request_str)
    local req = CreateHTTPRequest(request_str)
    --print("req: " .. tostring(req))
    --req:Send()
    GetTeamMember(1):ActionImmediate_PurchaseItem("item_tpscroll") --this is an indicator to reload game/map
    --DebugPause()
    _G.results_sent = true
end

function CDOTA_Bot_Script:pull_camp(camp, timing, should_chain, pull_num, double_timing)
    if DotaTime() > 74 and _G.final_values.success == nil then
        --_G.state.success = self:check_chain_pull_success()
        --print("Success: " .. tostring(_G.state.success))
        if _G.results_sent == nil then
            self:send_results()
        end
    end
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
        if (DotaTime() > timing - self:estimate_travel_time(camp.location) or pull_num == 1) then
            self:aggro_camp(camp)
        else
            self:Action_MoveToLocation(camp.pull_to) -- now is too early. stand in waiting spot
        end
    else -- we've 'initiated' the pull
        -- do the double pull
        -- replace with time to pull and creep health to always work
        local total_neutral_count = 4 -- TODO set this
        local values = self:get_chain_pull_vals(total_neutral_count)
        local data = {type="parameter_values", values=values}
        --            local data = {type="parameters", hero_data=hero_data, lane_creeps=lane_creeps, neutral_creeps=neutral_creeps,
        --                damage_spread_lane=damage_spread_lane, damage_spread_neutral=damage_spread_neutral}
        --print("JSN:" .. tostring(JSON:encode(data)))
        --            local req = CreateHTTPRequest(":9200/doublepull/run?" ..tostring(JSON:encode(data)))
        --            req:Send()
        if should_chain then  -- dont want overwritten when this pulling code gets called for farming the double pull
            _G.final_values = values
            _G.final_values.success = nil
        end

        if should_chain and self:time_to_chain_pull_ML(params, values) and camp.is_alive then
    --        print("JSN:" .. tostring(JSON:encode(data)))
            --if should_chain and self:time_to_chain_pull_basic(59) and camp.is_alive then
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
            if pull_num == 1 and self:GetNearbyLaneCreeps(1000, false) then -- we double pulled soooo early that we never even finished single pull
                _G.final_values.success = self:check_chain_pull_success()
                if _G.results_sent == nil then
                    self:send_results()
                end
            end
            self:farm_camp(camp, pull_num)

        end
    end
end

function CDOTA_Bot_Script:time_to_chain_pull_ML(params, values)
    local result = 0
    --TODO assuming ordered correctly seems an unncessary hassle
    for k, v in pairs(params) do
        --print(k .. ": " .. tostring(values[k:gsub("^p_(.-)$", "%1")]) .. "\n")
        result = result + (v  * values[k:gsub("^p_(.-)$", "%1")])
    end
    --print("RESULT: " .. tostring(result))
    if result > 10 then return true else return false end
end

function CDOTA_Bot_Script:get_chain_pull_vals(total_neutral_count)
    --dota_start_game
    --dota_neutral_spawn_interval
    --dota_neutral_initial_spawn_delay

    --dota_spawn_neutrals
    --dota_spawn_creeps
    local values = {}

    values["hero_attackrange"] = self:GetAttackRange()
    values["hero_attackspeed"] = self:GetAttackSpeed()
    values["hero_attackdamage"] = self:GetAttackDamage()
    values["hero_movespeed"] = self:GetCurrentMovementSpeed()

    values["damage_spread_neutral"] = 0
    values["neutral_total_eff_hp"] = 0
    values["targeted_neutral_eff_hp"] = 0
    values["fraction_neutral_left"] = 0

    values["damage_spread_lane"] = 0
    values["fraction_lane_left"] = 0
    values["targeted_lane_eff_hp"] = 0
    values["lane_total_eff_hp"] = 0

    local targeted_lane_creeps = {}
    local max_targets_lane = 0
    for i,v in ipairs(self:GetNearbyNeutralCreeps(1200)) do
        --print("Ith neutral: " .. tostring(i))
--        if v:TimeSinceDamagedByCreep() < 1.5 then
--            print("HAHAHA..: " .. tostring(v:TimeSinceDamagedByCreep()))
--            values["damage_spread_neutral"] = values["damage_spread_neutral"] + 1
--        end
        values["neutral_total_eff_hp"] = values["neutral_total_eff_hp"] + effective_hp(v:GetHealth(), v:GetArmor())
        values["fraction_neutral_left"] =  values["fraction_neutral_left"] + (1 / total_neutral_count)
        local target = v:GetTarget()
        if target ~= nil then
            --print("v:GetAttackTarget() neutral")
            --print(target:GetUnitName())
            local userdata
            for k,v in pairs(target) do
--                print(k)
--                print(v)
                userdata = v
            end
            local new_target = true
            for i,v in ipairs(targeted_lane_creeps) do
                if v.userdata == userdata then
                    new_target = false
                    local num_targets = v.count + 1
                    if num_targets > max_targets_lane then
                        max_targets_lane = num_targets
                        values["targeted_lane_eff_hp"] = effective_hp(target:GetHealth(), target:GetArmor())
                    end
                    v.count = num_targets
                end
            end

            if new_target then
                targeted_lane_creeps[#targeted_lane_creeps+1] = {userdata=v, count=1 }
                values["damage_spread_lane"] = values["damage_spread_lane"] + 1
            end
        end

    end

    local targeted_neutral_creeps = {}
    local max_targets_neutral = 0
    --TODO do I need to check isAlive stuff?
    for i,v in ipairs(self:GetNearbyLaneCreeps(1200, false)) do
        --print("Ith lane creep: " .. tostring(i))
--        if v:TimeSinceDamagedByCreep() < 1.5 then
--            print("HAHAHA..: " .. tostring(v:TimeSinceDamagedByCreep()))
--            values["damage_spread_lane"] = values["damage_spread_lane"] + 1
--        end
        values["lane_total_eff_hp"] = values["lane_total_eff_hp"] + effective_hp(v:GetHealth(), v:GetArmor())
        values["fraction_lane_left"] =  values["fraction_lane_left"] + 0.2
        local target = v:GetAttackTarget()
        if target ~= nil then
            --print("v:GetAttackTarget() v is lane. target is neutral")
           -- print(target:GetUnitName())
            local userdata
            for k,v in pairs(target) do
--                print(k)
--                print(v)
                userdata = v
            end
            local new_target = true
            for i,v in ipairs(targeted_neutral_creeps) do
                --print("v.tar: " .. tostring(v.tar))
                --print("target: " .. tostring(target) .. "\n")
                if v.tar == target then
                    --print("new target false")
                    new_target = false
                    local num_targets = v.count + 1
                    --print("num targets " .. tostring(v.count + 1))
                    if num_targets > max_targets_neutral then
                        max_targets_neutral = num_targets
                        values["targeted_neutral_eff_hp"] = effective_hp(target:GetHealth(), target:GetArmor())
                    end
                    v.count = num_targets
                end
            end

            if new_target then
                --print("Adding new target")
                values["damage_spread_neutral"] = values["damage_spread_neutral"] + 1
                targeted_neutral_creeps[#targeted_neutral_creeps+1] = {tar=target, count=1}
            end
        end

    end

    return values
end

function CDOTA_Bot_Script:check_chain_pull_success()
    local creeps_left = 0
    local creeps_pulled = 0
    local success = false  -- if there are no nearby creeps then the pull will have failed
    for i,v in ipairs(self:GetNearbyLaneCreeps(1000, false)) do
        if i == 1 then success = true end  -- check if we have 1 nearby creep. if yes temporarily set success true
        --print("ith ..: " .. tostring(i))
        if v:GetLocation().y < -5150 then success = false else -- if creeps this far down then the chain pull missed them
            creeps_pulled = creeps_pulled + 1
        end
        --print("Creeps pulled: " .. tostring(creeps_pulled))
    end
    for _, v in ipairs(self:GetNearbyNeutralCreeps(1000)) do -- if they are still farming small camp we have failed
        if v:GetLocation().x < self:GetLocation().x then success = false; break end
    end
    return success
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

function CDOTA_Bot_Script:farm_camp(camp, pull_num)
--    local values = self:get_chain_pull_vals(4)
--    for k, v in pairs(params) do
--        print(k .. ": " .. tostring(values[k:gsub("^p_(.-)$", "%1")]) .. "\n")
--    end

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