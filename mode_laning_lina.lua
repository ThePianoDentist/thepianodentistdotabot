
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
    local state = nil
    chain_pull = nil
    reset_pull_vars()
    _G.state = "pull_easy"
    --_G.state = "zone_offlaner"
	--print( "mode_generic_defend_ally.OnStart" );
end

function OnEnd()
    _G.state = "none"
    state = nil
    _G.current_target = nil
    _G.creeps_aggroed = nil
    _G.have_pulled = false
	--print( "mode_generic_defend_ally.OnEnd" );
end


function Think()
	local bot = GetBot()
    local name = bot:GetUnitName()
    _G.seconds = get_seconds()
    _G.minutes = math.floor(DotaTime() / 60)
    --print (GetTeamMember(2, 1):GetLocation());
    if GetGameState() == 5 then  -- 5 is creeps spawned i.e 0 seconds
        if _G.state == "none" and NEUTRAL_CAMPS.rad_safe_ez.is_alive then
            _G.state = "pull_easy"
        end

        if _G.state == "zone_offlaner" then
            bot:zone_offlaner()
        elseif _G.state == "chain_pull_hard" and RAD_SAFE_HARD.is_alive then
            print ("CHAING PULLING")
            bot:pull_camp(RAD_SAFE_HARD, 59, false, 1)
        elseif _G.state == "pull_easy" then
            --_G.state = "pull_easy"
            bot:pull_camp(RAD_SAFE_EASY, 44, true, 0)
        end

--    elseif GetGameState() == 4 and _G.movespeed == nil then
--        _G.movespeed = bot:calibrate_move_speed()
--    end
    end
    --last_health = bot:GetHealth();



end

----------------------------------------------------------------------------------------------------

for k,v in pairs( mode_generic_laning ) do	_G._savedEnv[k] = v end

----------------------------------------------------------------------------------------------------
