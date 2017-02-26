
----------------------------------------------------------------------------------------------------

_G._savedEnv = getfenv()
module( "mode_generic_laning", package.seeall )

----------------------------------------------------------------------------------------------------
require( GetScriptDirectory().."/hero_funcs/pulling" )
require( GetScriptDirectory().."/hero_funcs/stacking" )
require( GetScriptDirectory().."/hero_funcs/zoning" )

require( GetScriptDirectory().."/utility_funcs" )
require( GetScriptDirectory().."/locations2" )
function OnStart()
    print("DOING START")
    _G.test = "test"
    print(_G.test)
    --TODO replace current_mode with current_laning_mode
    _G.state = {action_queue={current_action}, current_action=nil, current_target=nil, temp_memory={}, current_mode="pull_easy" }
    _G.state.neutrals = NEUTRAL_CAMPS -- this really should be outside onstart. should be gloabl...er
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

    if _G.state.current_mode == "none" then
        _G.state.current_mode = "zone_offlaner" -- kind of default mode
    end

    local bot = GetBot()
    local name = bot:GetUnitName()
    _G.seconds = get_seconds(DotaTime())
    _G.minutes = math.floor(DotaTime() / 60)
    local timing = 45
    local radiant_front = _G.minutes > 0 and GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, 0) or Vector(5900, -6000, 0)
    -- TODO should I add randomness to this decision?
--    print("radiant_front.y: " .. radiant_front.y)
--    print("_G.state.neutrals.rad_safe_ez.is_alive: " .. tostring(_G.state.neutrals.rad_safe_ez.is_alive))
--    print("(timing - bot:estimate_travel_time(_G.state.neutrals.rad_safe_ez.location) - 1): " .. tostring(timing - bot:estimate_travel_time(_G.state.neutrals.rad_safe_ez.location) - 1))
    if _G.state.neutrals.rad_safe_ez.is_alive and _G.seconds == (timing - get_seconds(bot:estimate_travel_time(_G.state.neutrals.rad_safe_ez.location) - 1)) and radiant_front.y > -3800 then --TODO check -4000 sensible
        _G.state.current_mode = "pull_easy"
    end

    if GetGameState() == 5 then  -- 5 is creeps spawned i.e 0 seconds
        if _G.state.current_mode == "zone_offlaner" then
            bot:zone_offlaner()
        elseif _G.state.current_mode == "chain_pull_hard" and RAD_SAFE_HARD.is_alive then
            print ("CHAING PULLING")
            bot:pull_camp(RAD_SAFE_HARD, 59, false, 1)
        elseif _G.state.current_mode == "pull_easy" then
            --_G.state = "pull_easy"
            bot:pull_camp(RAD_SAFE_EASY, 44, true, 0)
        end

    end
end

----------------------------------------------------------------------------------------------------

for k,v in pairs( mode_generic_laning ) do	_G._savedEnv[k] = v end

----------------------------------------------------------------------------------------------------
