local next = next -- makes things quicker apparently :|
require( GetScriptDirectory().."/locations2" )
require( GetScriptDirectory().."/hero_funcs/pulling" )

--maybe camps should be a struct and define these functions on camps?
--function camp
function CDOTA_Bot_Script:find_nearest_camp()
    -- theres probably going to be a minimum distance where you know if you're under that. no other camps can be closer
    -- oh my god. why is this game so complicated. if we use isAlive to filter out killed camps, how do we include ones that will respawn by time get there....
    local min_distance = 9000
    local nearest_camp
    for k,v in pairs(_G.state.neutrals) do
        local distance = GetUnitToLocationDistance(self, v.location) -- is this the optimal algo?
        local time_to_spawn = 60 - _G.seconds
        if _G.minutes % 2 ~= 0 then time_to_spawn = time_to_spawn + 60
        end
        if v.IsAlive() or self:estimate_travel_time(v.location) < time_to_spawn then  -- creeps only spawn every other minute... :/
            if distance < min_distance then
                nearest_camp = v
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
        if not _G.state.temp_memory.creeps_aggroed then
            self:aggro_camp(camp)
        else
            self:Action_MoveToLocation(camp.pull_to)
        end
    end
    return
end