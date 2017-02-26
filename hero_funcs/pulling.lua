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
    print("self:NumQueuedActions()" .. tostring(self:NumQueuedActions()))
    print(_G.state.pull_status)
    if self:NumQueuedActions() ~= 0 then
        return
    end

    if _G.state.pull_status == "init" then
        self:ActionQueue_MoveToLocation(camp.pull_to) -- inefficient if going from zoning -> pull
        _G.state.pull_status = "waiting"
        return
    end

    -- someone damaging the camp without pulling might break this?
    if _G.state.pull_status == "waiting" and pull_num == 0 then
        self:wait_for_pull_timing(timing, camp)
        _G.state.pull_status = "delay"
        return
    end
    if _G.state.pull_status == "delay" then
        self:aggro_camp(camp)
        _G.state.pull_status = "aggro"
        return
    end
    if should_chain and self:time_to_chain_pull(camp) == true and camp.is_alive then
        print ("Doing chain pull")
        reset_pull_vars()
        camp.is_alive = false -- TODO this isnt being updated properly
        _G.state.current_mode = "chain_pull_hard"
        return
    end
    if _G.state.pull_status == "aggro" then
        self:attack_targets(camp, false)
        _G.state.pull_status = "farming"
        return
    end

end

function CDOTA_Bot_Script:get_target(camp)
    if _G.state.current_target == nil or _G.state.current_target:IsAlive() == false then
        local neuts = self:GetNearbyNeutralCreeps(1000)
        for k, v in pairs(neuts) do
            if (v:GetHealth() > 0) and GetUnitToLocationDistance(v, camp.location) < 300 then
                print ("Got new target")
                return v
            end
        end
        return nil
    else
        return _G.state.current_target
    end
end

function CDOTA_Bot_Script:attack_targets(camp, once)
    local neuts = self:GetNearbyNeutralCreeps(1000)
    for k, v in pairs(neuts) do
        if (v:GetHealth() > 0) and GetUnitToLocationDistance(v, camp.location) < 300 then
            self:ActionQueue_AttackUnit(v, once)
            if once then return end  -- only attack one creep
        end
    end
    return nil
end


function CDOTA_Bot_Script:aggro_camp(camp)
    self:attack_targets(camp, true)
    self:ActionQueue_MoveToLocation(camp.pull_to)
    _G.state.temp_memory.creeps_aggroed = true
    return
end

function CDOTA_Bot_Script:wait_for_pull_timing(timing, camp)
    local delay = timing - self:estimate_travel_time(camp.location) - _G.seconds
    self:ActionQueue_Delay(delay)
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
