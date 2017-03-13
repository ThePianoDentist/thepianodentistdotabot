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

function split(inputstr, sep)
    -- http://stackoverflow.com/a/7615129
    if sep == nil then
        sep = "%s"
    end
    local t={} ; local i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function effective_hp(total_hp, armour)
    -- http://dota2.gamepedia.com/Armor#Effective_HP
    -- TODO check this with 2183 HP ÷ ( 1 - (11.46 × 0.06) ÷ (1 + 11.46 × 0.06) ) = 2183 HP ÷ 0.5925 = 3684 effective HP
    local damage_multiplier = 1 - (0.06 * armour) / (1 + (0.06 * math.abs(armour)))
    return total_hp / damage_multiplier
end

function CDOTA_Bot_Script:IsFacedToUnit(handle, maximum_deviation)
    local facing = self:GetFacing()
    local our_loc = self:GetLocation()
    local enemy_loc = handle:GetLocation()
    local distance_to_target = GetUnitToUnitDistance(self, handle)
    local unit_vector = Vector(
        (enemy_loc.x - our_loc.x) / distance_to_target,
        (enemy_loc.y - our_loc.y) / distance_to_target,
        (enemy_loc.z - our_loc.z) / distance_to_target
    )
    -- Below from http://onlinemschool.com/math/library/vector/angl/ using unit vector and east vector but magnitude 1 vectors simplify things
    local unit_vector_angle = math.acos(unit_vector.x) * 180 / math.pi
    -- This needed due to arccos being many-to-one I think? (arccos func can only return between 0-180 degrees)
    if unit_vector.y < 0 then unit_vector_angle = 360 - unit_vector_angle end
    local angle_between = math.abs(unit_vector_angle - facing)
    if angle_between > 180 then angle_between = 360 - angle_between end
    return angle_between < maximum_deviation and true or false
end

