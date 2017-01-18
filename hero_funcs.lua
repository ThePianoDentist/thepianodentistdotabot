local next = next -- makes things quicker apparently :|
require( GetScriptDirectory().."/locations2" )

function reset_pull_vars()
    _G.current_target = nil
    _G.creeps_aggroed = nil
    _G.have_pulled = false
    return
end

function CDOTA_Bot_Script:pull_camp(camp, timing, should_chain, pull_num)
--    if pull_num == 0 and chain_pull ~= nil then
--        return self:pull_camp(RAD_SAFE_HARD, 59, false, 1);
--    end

    -- someone damaging the camp without pulling might break this?

    -- even after aggroing, if theyre fogged it reports velocity as 0 and max health as -1. Nice! :D
    if not _G.creeps_aggroed then
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
            _G.state = "chain_pull_hard"
            return
        end

        --if pull_num == 1 then friendly_creep_rad_check = 400 -- because we want to pull creeps all way over to other camp. dont stop halfway
        if _G.have_pulled ~= true and GetUnitToLocationDistance(self, camp.pull_to) > 200 then -- we have pulled and are dragging creeps into lane
                self:Action_MoveToLocation(camp.pull_to)
        else
            _G.have_pulled = true
            self:farm_camp(camp)
        end
    end
end

function CDOTA_Bot_Script:get_target(camp)
    if _G.current_target == nil or _G.current_target:IsAlive() == false then
        local neuts = self:GetNearbyCreeps(1000, true)
        for k, v in pairs(neuts) do
            print (k, v:GetHealth())
            if (v:GetHealth() > 0) and GetUnitToLocationDistance(v, camp.location) < 300 and string.match(v:GetUnitName(), "neutral") then
                print ("Got new target")
                return v
            end
        end
        return nil
    else
        return _G.current_target
    end
end

function CDOTA_Bot_Script:aggro_camp(camp)
    if _G.current_target == nil then
         _G.current_target = self:get_target(camp)
    end

    if _G.current_target  ~= nil and _G.current_target:IsAlive() == true
    then
        self:Action_AttackUnit(_G.current_target, true)
        if self:haveWeAggroedPull() then
            _G.creeps_aggroed = true
            print ("Have Aggored the creeps")
        end
    else
        self:Action_MoveToLocation(camp.location)
    end
    return
end

function CDOTA_Bot_Script:farm_camp(camp)
    if not self:GetNearbyCreeps(1000, false) and _G.current_target:GetHealth() < 220 then --either pull failed or all our creeps are dead
        print ("No friendlies to tank. retreating")
        _G.creeps_aggroed = nil
        _G.have_pulled = false
        _G.state = "none"
    end
    print ("_G.current_target:IsAlive: " .. tostring(_G.current_target:IsAlive()))
    if _G.current_target:GetHealth() == 0 or _G.current_target:IsAlive() == false then -- check IsAlive
        print ("_G.current_target = self:get_target(camp)")
        _G.current_target = self:get_target(camp)
    end

    if _G.current_target ~= nil then
        self:Action_AttackUnit(_G.current_target, true)
    else -- camp is dead. go do some other stuff
        print ("camp dead")
        camp.is_alive = false
        _G.creeps_aggroed = nil
        _G.have_pulled = false
        _G.state = "none"
        self:Action_MoveToLocation(RAD_SAFE_EASY.pull_to)
    end
end

-- rushed. maybe refactor
function CDOTA_Bot_Script:time_to_chain_pull(camp)
    local camp_health = 0
    local camp_max_health = 0 -- fogged creeps have 0.. or -1
    local neuts = self:GetNearbyCreeps(1000, true)
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


--maybe camps should be a struct and define these functions on camps?
--function camp
function CDOTA_Bot_Script:find_nearest_camp()
    -- theres probably going to be a minimum distance where you know if you're under that. no other camps can be closer
    -- oh my god. why is this game so complicated. if we use isAlive to filter out killed camps, how do we include ones that will respawn by time get there....
    local min_distance = 9000
    for k,v in pairs(camps) do
        local distance = GetUnitToLocationDistance(self, v.location) -- is this the optimal algo?
        local time_to_spawn = 60 - _G.seconds
        if _G.minutes % 2 ~= 0 then time_to_spawn = time_to_spawn + 60
        end
        if v.IsAlive() or self:estimate_travel_time(v.location) < time_to_spawn then  -- creeps only spawn every other minute... :/
        if distance < min_distance then
            local nearest_camp = v
        end
        end
    end

    return nearest_camp
end

function CDOTA_Bot_Script:stack_camp(camp)
    if _G.seconds < camp.stack_t then
        if self:GetLocation() ~= camp.pull_from then
            self:Action_MoveToLocation(camp.location)
        end
    else
        if (_G.current_target == nil or (_G.current_target ~= nil and (_G.current_target:GetVelocity().x == 0 and _G.current_target:GetVelocity().y == 0
                and _G.current_target:GetHealth() == _G.current_target:GetMaxHealth() and next(self:GetNearbyCreeps(400, false)) == nil))
        ) then
            self:aggro_camp(camp)
        else
            self:Action_MoveToLocation(camp.pull_to)
        end
    end
    return
end

function CDOTA_Bot_Script:estimate_travel_time(location)
    -- do I need to factor in turn rate as well?
    local distance = GetUnitToLocationDistance(self, location) -- why does self: not work. but passing self in does?
    --local move_speed = 300
    print( distance / self:GetCurrentMovementSpeed())
    return distance / self:GetCurrentMovementSpeed()
end

function CDOTA_Bot_Script:haveWeAggroedPull()
    return not (_G.current_target:GetVelocity().x == 0 and _G.current_target:GetVelocity().y == 0 and not _G.creeps_aggroed
            and _G.current_target:GetHealth() == _G.current_target:GetMaxHealth() and next(self:GetNearbyCreeps(300, false)) == nil)
end
