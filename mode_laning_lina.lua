
----------------------------------------------------------------------------------------------------

_G._savedEnv = getfenv()
module( "mode_generic_laning", package.seeall )

----------------------------------------------------------------------------------------------------
require( GetScriptDirectory().."/hero_funcs/pulling" )
require( GetScriptDirectory().."/hero_funcs/stacking" )
require( GetScriptDirectory().."/hero_funcs/zoning" )

require( GetScriptDirectory().."/utility_funcs" )
require( GetScriptDirectory().."/locations2" )
require(GetScriptDirectory().."/storageapi/json")
require(GetScriptDirectory().."/storageapi/storage")
--curl=assert(loadlib(GetScriptDirectory().."[lib]luacurl[.so|.dll]", "luaopen_luacurl"))()
--local http_request = require "http.request"
--local io = require("io")
--require "io"
function OnStart()
    --TODO replace current_mode with current_laning_mode
    _G.random_time = RandomInt(51, 60)
    _G.state = {action_queue={}, current_action=nil, current_target=nil, success=nil, temp_memory={}, current_mode="pull_easy" }
    _G.state.neutrals = NEUTRAL_CAMPS -- this really should be outside onstart. should be gloabl...er
--    Storage:Put(a, function( resultTable, successBool )
--        if successBool then
--            print("Successfully put data in storage")
--        end
--    end)
    --print("JSN:" .. tostring(JSON:encode(_G.double_timing)))
end

function OnEnd()
    if _G.state ~= nil then
        _G.state.current_mode = "none"
        _G.state.current_target = nil
        _G.state.temp_memory.creeps_aggroed = nil
        _G.state.temp_memory.have_pulled = false
    end


	--print( "mode_generic_defend_ally.OnEnd" );
end


function Think()
    --local headers, stream = assert(http_request.new_from_uri("http://example.com"):go())
    if _G.state.current_mode == "none" then
        _G.state.current_mode = "pull_easy" -- kind of default mode
    end

    local bot = GetBot()
    local name = bot:GetUnitName()
    local game_state = GetGameState()
    _G.seconds = get_seconds(DotaTime())
    _G.minutes = math.floor(DotaTime() / 60)
    local minutes = _G.minutes
    local timing = 45
    local radiant_front = minutes > 0 and GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, 0) or Vector(5900, -6000, 0)

    if game_state == 4 then
        bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1))
    elseif game_state == 5 then  -- 5 is creeps spawned i.e 0 seconds
--        local data = "test"
--        Storage:Put( 1, data, function( resultTable, successBool )
--            if successBool then
--                print("Successfully put data in storage")
--            end
--        end)
        if _G.state.neutrals.rad_safe_ez.is_alive and math.abs(_G.seconds - (timing - get_seconds(bot:estimate_travel_time(_G.state.neutrals.rad_safe_ez.pull_to) - 1))) < 3 and radiant_front.y > -3800 then --TODO check -4000 sensible
            if _G.state.current_mode ~= "pull_easy" then
                _G.state.current_target = nil
                _G.state.current_mode = "pull_easy"
            end
        end
--        -- should take into account attack range of person
--        if minutes >= 2 and minutes % 2 == 0 and math.abs(_G.seconds - (_G.state.neutrals.rad_safe_med.stack_t - get_seconds(bot:estimate_travel_time(_G.state.neutrals.rad_safe_med.location) - 2))) < 2 then
--            print("Stacking radiant medium camp")
--            _G.state.current_mode = "stack_dire_safe_med"
--        end

        if _G.state.current_mode == "zone_offlaner" then
            bot:zone_offlaner()
        elseif _G.state.current_mode == "chain_pull_hard" and RAD_SAFE_HARD.is_alive then
            bot:pull_camp(RAD_SAFE_HARD, 59, false, 1)
        elseif _G.state.current_mode == "pull_easy" then
            --_G.state = "pull_easy"
            bot:pull_camp(RAD_SAFE_EASY, 42.5, true, 0, 58)
        elseif _G.state.current_mode == "stack_dire_safe_med" then
            bot:stack_camp(_G.state.neutrals.rad_safe_med)
        end

    end
end

----------------------------------------------------------------------------------------------------

for k,v in pairs( mode_generic_laning ) do	_G._savedEnv[k] = v end

----------------------------------------------------------------------------------------------------
