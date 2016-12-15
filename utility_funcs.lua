function getSeconds(time_)
    local time_int = math.floor(time_) --will this round up as well. i only want rounding down I believe?
    local result = time_int % 60;
    return result
end
