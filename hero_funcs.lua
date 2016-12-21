
require( GetScriptDirectory().."/locations" )
--function CDOTA_Bot_Script:pull_easy_radiant(should_double_pull)
--    -- if it switches decison midway through pull this can cause crashes I think. due to not unassigning _G.current_target and/or camp_is_there
--    local lane_spot = Vector(3747, -6344 , 0);
--    -- someone damaging the camp without pulling might break this?
--    if (_G.current_target == nil or (_G.current_target ~= nil and (_G.current_target:GetVelocity().x == 0 and _G.current_target:GetVelocity().y == 0
--        and _G.current_target:GetHealth() == _G.current_target:GetMaxHealth() and next(self:GetNearbyCreeps(500, false)) == nil))
--    ) then
--        if (_G.seconds > 43 - self:estimate_travel_time(RAD_SAFE_EASY)) then  -- obviously this doesnt work for the other pull timing
--            if _G.current_target ~= nil then
--                if _G.current_target:GetHealth() == -1 then -- we just got fogged....motherfucker
--                    print ("Got fogged: self:Action_AttackMove(RAD_SAFE_EASY)")
--                    self:Action_AttackMove(RAD_SAFE_EASY)
--                else
--                    print ("self:Action_AttackUnit(_G.current_target, true);")
--                    self:Action_AttackUnit(_G.current_target, true)
--                end
--            else
--                local neuts = self:GetNearbyCreeps(1000, true)
--                if next(neuts) == nil then
--                    print ("doing attack move")
--                    self:Action_AttackMove(RAD_SAFE_EASY) -- now is a good time to try and pull
--                else
--                    _G.current_target = neuts[1]
--                    print ("self:Action_AttackUnit(_G.current_target, true)")
--                    self:Action_AttackUnit(_G.current_target, true)
--                end
--
--            end
--        else
--            print ("self:Action_MoveToLocation(lane_spot)")
--            self:Action_MoveToLocation(lane_spot) -- now is too early. stand in waiting spot
--        end
--    else -- we've 'initiated' the pull
--    -- gonna be a bug where creep gone back
--        if _G.seconds > 50 and should_double_pull then
--            return self:chain_pull_hard_radiant()
--        end
--
--        if (_G.current_target:GetVelocity().y <= 0 and next(self:GetNearbyCreeps(500, false)) == nil) then -- we have pulled and are dragging creeps into lane
--            self:Action_MoveToLocation(lane_spot)
--        else
--            --if _G.current_target:GetHealth() <= 0 or not _G.current_target:IsAlive() then  -- was IsAlive working. can i drop back to 1 check?
--            if _G.current_target:GetHealth() == 0 then
--                print ("_G.current_target dead. Choosing new")
--                _G.current_target = nil
--                local neuts = self:GetNearbyCreeps(1000, true)
--                for k, v in pairs(neuts) do
--                    if v:GetHealth() > 0 or v:GetHealth() == -1 then
--                        _G.current_target = v
--                    end
--                end
--            end
--
--            if _G.current_target ~= nil then
--                print ("self:Action_AttackUnit(_G.current_target, true)")
--                self:Action_AttackUnit(_G.current_target, true)
--            else -- camp is dead. go do some other stuff
--                _G.radiant_easy_camp_is_there = false
--            end
--        end
--    end
--end


function CDOTA_Bot_Script:pull_camp(camp, pull_to, pull_from, timing, should_double_pull)
    if _G.current_target ~= nil then
        print(_G.current_target:GetHealth())
    end
    print ("chain_pull ~= nil: " .. tostring(chain_pull ~= nil))
    if chain_pull ~= nil and should_double_pull == true then
        return self:pull_camp(RAD_SAFE_HARD, RAD_SAFE_EASY, RAD_SAFE_HARD, 59, false);
    end

    -- if it switches decison midway through pull this can cause crashes I think. due to not unassigning _G.current_target and/or camp_is_there
    -- someone damaging the camp without pulling might break this?

    -- even after aggoring, if theyre fogged it reports velocity as 0 and max health as -1. Nice! :D
    if (_G.current_target == nil or (_G.current_target ~= nil and (_G.current_target:GetVelocity().x == 0 and _G.current_target:GetVelocity().y == 0
            and _G.current_target:GetHealth() == _G.current_target:GetMaxHealth() and next(self:GetNearbyCreeps(300, false)) == nil))
    ) then
        -- The only time our 'action' goes over the minute, is in a chain pull. if we've told it to chain pull, then dont need to check time
        if (_G.seconds > timing - self:estimate_travel_time(camp) or chain_pull ~= nil) then
            if _G.current_target ~= nil then
                if _G.current_target:GetHealth() == -1 and _G.creeps_aggroed == nil then -- we just got fogged....motherfucker
                print ("Got fogged: self:Action_MoveToLocation(camp)")
                print ("_G.current_target:GetMaxHealth()" .. tostring(_G.current_target:GetMaxHealth()))
                print ("_G.current_target:GetVelocity().y" .. tostring(_G.current_target:GetVelocity().y))
                self:Action_MoveToLocation(camp) --self:Action_AttackMove(camp)
                else
                    print ("huh")
                    print ("self:Action_AttackUnit(_G.current_target, true);")
                    self:Action_AttackUnit(_G.current_target, true)
                end
            else
                local neuts = self:GetNearbyCreeps(1000, true)
                for k,v in pairs(neuts) do  -- if double pulling need to check creeps are not from 1st camp
                    if GetUnitToLocationDistance(v, camp) < 200 then
                        _G.current_target = v
                    end
                end
                if _G.current_target == nil then
                    print ("self:Action_MoveToLocation(pull_from)")
                    self:Action_MoveToLocation(camp) --self:Action_AttackMove(camp) -- now is a good time to try and pull
                else
                    print ("guh")
                    print ("self:Action_AttackUnit(_G.current_target, true)")
                    print (_G.current_target)
                    self:Action_AttackUnit(_G.current_target, true)
                end

            end
        else
            print ("self:Action_MoveToLocation(lane_spot)")
            self:Action_MoveToLocation(pull_to) -- now is too early. stand in waiting spot
        end
    else -- we've 'initiated' the pull
        _G.creeps_aggroed = true
        -- gonna be a bug where creep gone back

        -- do the double pull
        if _G.seconds == 58  and should_double_pull  and _G.radiant_easy_camp_is_there then
            print ("Doing chain pull")
            chain_pull = true
            _G.current_target = nil -- maybe I should just call the OnEnd function?
            _G.creeps_aggroed = nil
            return
        end
        --if (_G.current_target:GetVelocity().y <= 0 and next(self:GetNearbyCreeps(200, false)) == nil) then
        local friendly_creep_rad_check = 500
        if chain_pull then friendly_creep_rad_check = 300 -- because we want to pull creeps all way over to other camp. dont stop halfway
        end
        print ("next(self:GetNearbyCreeps(friendly_creep_rad_check, false)): " .. tostring(next(self:GetNearbyCreeps(friendly_creep_rad_check, false))))
        if (next(self:GetNearbyCreeps(friendly_creep_rad_check, false)) == nil) then -- we have pulled and are dragging creeps into lane
            print ("self:Action_MoveToLocation(pull_to)")
            self:Action_MoveToLocation(pull_to)
        else
            --if _G.current_target:GetHealth() <= 0 or not _G.current_target:IsAlive() then  -- was IsAlive working. can i drop back to 1 check?
            if _G.current_target:GetHealth() == 0 then
                print ("_G.current_target dead. Choosing new")
                _G.current_target = nil
                local neuts = self:GetNearbyCreeps(1000, true)
                for k, v in pairs(neuts) do
                    if v:GetHealth() > 0 or v:GetHealth() == -1 then
                        _G.current_target = v
                    end
                end
            end

            if _G.current_target ~= nil then
                print ("fluh")
                print ("self:Action_AttackUnit(_G.current_target, true)")
                self:Action_AttackUnit(_G.current_target, true)
            else -- camp is dead. go do some other stuff
                _G.radiant_easy_camp_is_there = false
                chain_pull = nil
                _G.creeps_aggroed = nil
            end
        end
    end
end

function CDOTA_Bot_Script:chain_pull_hard_radiant()
    return true
end

function CDOTA_Bot_Script:calibrate_move_speed()
    -- Im fairly sure axe can randomly bodyblock slightly at start, causing slightly lower than what should be
    local dtime = DotaTime()
    if dtime > - 87 then
        self:Action_MoveToLocation(Vector(5000, -3000, 0)) -- make her go towards radiant jungle as otherwise misses first pull
    end

    if dtime > - 86 then
        if t_start == nil then
            t_start = dtime
            l_start = self:GetLocation()
            return nil  -- first time through we just log start time and position
        else
            t_end = dtime -- second time we can now compare and calculate a speed
            local speed = GetUnitToLocationDistance(self, l_start) / (t_end - t_start)
            print ("Speed calibrated")
            print (speed)
            return speed
        end
    else
        return nil -- only want to do the calibration once
    end
end

function CDOTA_Bot_Script:estimate_travel_time(location)
    -- do I need to factor in turn rate as well?
    local distance = GetUnitToLocationDistance(self, location) -- why does self: not work. but passing self in does?
    --local move_speed = 300
    print( distance / _G.movespeed)
    return distance / _G.movespeed
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
            local neuts = self:GetNearbyCreeps(1000, true)
            if _G.current_target == nil then
                for k, v in pairs(neuts) do
                    if v:GetHealth() > 0 or v:GetHealth() == -1 then _G.current_target = v
                    end
                end
            end
            if _G.current_target ~= nil then self:Action_AttackUnit(_G.current_target)
            else print "Current target still nil. no camp there?"
            end
        else
            self:Action_MoveToLocation(camp.pull_to)
        end
    end
    return
end

function CDOTA_Bot_Script:find_nearest_camp()
    -- theres probably going to be a minimum distance where you know if you're under that. no other camps can be closer
    -- oh my god. why is this game so complicated. if we use isAlive to filter out killed camps, how do we include ones that will respawn by time get there....
    local min_distance = 9000
    for k,v in pairs(camps) do
        local distance = GetUnitToLocationDistance(self, v.location) -- is this the optimal algo. cant i do lgn? n is small though
        if distance < min_distance then
            local nearest_camp = v
        end
    end

    return nearest_camp
end

--maybe camps should be a struct and define these functions on camps?
--function camp

function aggro_camp()
    return
end