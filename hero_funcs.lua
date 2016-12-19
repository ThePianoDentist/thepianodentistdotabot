
require( GetScriptDirectory().."/locations" )
function CDOTA_Bot_Script:pull_easy_radiant()
    -- if it switches decison midway through pull this can cause crashes I think. due to not unassigning current_target and/or camp_is_there
    local lane_spot = Vector(3747, -6344 , 0);
    -- someone damaging the camp without pulling might break this?
    if (current_target == nil or (current_target ~= nil and (current_target:GetVelocity().x == 0 and current_target:GetVelocity().y == 0
        and current_target:GetHealth() == current_target:GetMaxHealth() and next(self:GetNearbyCreeps(500, false)) == nil))
    ) then
        if (_G.seconds > 53 - self:estimate_travel_time(RAD_SAFE_EASY)) then  -- obviously this doesnt work for the other pull timing
            if current_target ~= nil then
                if current_target:GetHealth() == -1 then -- we just got fogged....motherfucker
                    print ("Got fogged: self:Action_AttackMove(RAD_SAFE_EASY)")
                    self:Action_AttackMove(RAD_SAFE_EASY)
                else
                    print ("self:Action_AttackUnit(current_target, true);")
                    self:Action_AttackUnit(current_target, true)
                end
            else
                local neuts = self:GetNearbyCreeps(1000, true)
                if next(neuts) == nil then
                    print ("doing attack move")
                    self:Action_AttackMove(RAD_SAFE_EASY) -- now is a good time to try and pull
                else
                    current_target = neuts[1]
                    print ("self:Action_AttackUnit(current_target, true)")
                    self:Action_AttackUnit(current_target, true)
                end

            end
        else
            print ("self:Action_MoveToLocation(lane_spot)")
            self:Action_MoveToLocation(lane_spot) -- now is too early. stand in waiting spot
        end
    else -- we've 'initiated' the pull
    -- gonna be a bug where creep gone back
        if (current_target:GetVelocity().y <= 0 and next(self:GetNearbyCreeps(500, false)) == nil) then -- we have pulled and are dragging creeps into lane
            self:Action_MoveToLocation(lane_spot)
        else
            --if current_target:GetHealth() <= 0 or not current_target:IsAlive() then  -- was IsAlive working. can i drop back to 1 check?
            if current_target:GetHealth() == 0 then
                print ("current_target dead. Choosing new")
                current_target = nil
                local neuts = self:GetNearbyCreeps(1000, true)
                for k, v in pairs(neuts) do
                    if v:GetHealth() > 0 or v:GetHealth() == -1 then
                        current_target = v
                    end
                end
            end

            if current_target ~= nil then
                print ("self:Action_AttackUnit(current_target, true)")
                self:Action_AttackUnit(current_target, true)
            else -- camp is dead. go do some other stuff
                _G.radiant_easy_camp_is_there = false
            end
        end
    end
end

function CDOTA_Bot_Script:calibrate_move_speed()
    self:Action_MoveToLocation(Vector(0, 0, 0))
    local newPos = self:GetExtrapolatedLocation(1.0)
    local distance = self:GetUnitToLocationDistance(self, newPos)
    print ("Distance calibrated")
    print (distance)
    return distance
end

function CDOTA_Bot_Script:estimate_travel_time(location)
    -- do I need to factor in turn rate as well?
    local distance = GetUnitToLocationDistance(self, location) -- why does self: not work. but passing self in does?
    local move_speed = 300
    --return distance / move_speed
    return 16
end

function stack_camp(camp)
    return
end

function aggro_camp()
    return
end