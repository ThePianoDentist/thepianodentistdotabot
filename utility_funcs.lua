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

function logJson(encodedData)
    return "JSON_OUT:" .. encodedData
end


function effective_hp(total_hp, armour)
    -- http://dota2.gamepedia.com/Armor#Effective_HP
    -- TODO check this with 2183 HP ÷ ( 1 - (11.46 × 0.06) ÷ (1 + 11.46 × 0.06) ) = 2183 HP ÷ 0.5925 = 3684 effective HP
    local damage_multiplier = 1 - (0.06 * armour) / (1 + (0.06 * math.abs(armour)))
    return total_hp / damage_multiplier
end