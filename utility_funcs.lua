function get_seconds(time)
    local time_int = math.floor(time) --will this round up as well. i only want rounding down I believe?
    local result = time_int % 60;
    return result
end

-- Useful for finding locations of map parts with player controlled hero
function printl()
    print (GetTeamMember(2, 1):GetLocation())
end

function LocationToLocationSquaredDistance(location_one, location_two)
    return
end