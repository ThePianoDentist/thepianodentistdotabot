
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
            local t_end = dtime -- second time we can now compare and calculate a speed
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
    print( distance / self:GetCurrentMovementSpeed())
    return distance / self:GetCurrentMovementSpeed()
end