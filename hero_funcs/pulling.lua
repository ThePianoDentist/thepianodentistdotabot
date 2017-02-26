local next = next -- makes things quicker apparently :|
require( GetScriptDirectory().."/locations2" )
require( GetScriptDirectory().."/hero_funcs/generic" )

function reset_pull_vars()
    _G.state.current_target = nil
    _G.state.temp_memory.creeps_aggroed = nil
    _G.state.temp_memory.have_pulled = false
    return
end

function CDOTA_Bot_Script:pull_camp(camp, timing, should_chain, pull_num)
--    if pull_num == 0 and chain_pull ~= nil then
--        return self:pull_camp(RAD_SAFE_HARD, 59, false, 1);
--    end

    -- someone damaging the camp without pulling might break this?

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
        if should_chain and self:time_to_chain_pull(camp) == true and camp.is_alive then
            print ("Doing chain pull")
            reset_pull_vars()
            camp.is_alive = false -- TODO this isnt being updated properly
            _G.state.current_mode = "chain_pull_hard"
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
                print ("Got new target")
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

    if _G.state.current_target ~= nil and _G.state.current_target:IsAlive() == true
    then
        print("Attack target")
        if self:NumQueuedActions() == 0 then
            self:ActionPush_AttackUnit(_G.state.current_target, true)
            self:ActionQueue_MoveToLocation(camp.pull_to)
        end

        --_G.state.temp_memory.creeps_aggroed = true
        if self:haveWeAggroedPull() then
            _G.state.temp_memory.creeps_aggroed = true
            print ("Have Aggored the creeps")
        end
    else
        self:Action_MoveToLocation(camp.location)
    end
    return
end

function CDOTA_Bot_Script:farm_camp(camp)

    if _G.state.current_target == nil or (not self:GetNearbyLaneCreeps(1000, false) and _G.state.current_target:GetHealth() < 220) then --either pull failed or all our creeps are dead
        print ("Cannot complete pull")
        print ("Either all friendly creeps died. Or current_target got set to nil")
        _G.state.temp_memory.creeps_aggroed = nil
        _G.state.temp_memory.have_pulled = false
        _G.state.current_mode = "none"
        return
    end
    print ("_G.state.current_target:IsAlive: " .. tostring(_G.state.current_target:IsAlive()))
    if _G.state.current_target:GetHealth() == 0 or _G.state.current_target:IsAlive() == false then -- check IsAlive
        print ("_G.state.current_target = self:get_target(camp)")
        _G.state.current_target = self:get_target(camp)
    end

    if _G.state.current_target ~= nil then
        self:Action_AttackUnit(_G.state.current_target, true)
    else -- camp is dead. go do some other stuff
        print ("camp dead")
        camp.is_alive = false
        _G.state.temp_memory.creeps_aggroed = nil
        _G.state.temp_memory.have_pulled = false
        _G.state.current_mode = "none"
        self:Action_MoveToLocation(RAD_SAFE_EASY.pull_to)
    end
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
