
----------------------------------------------------------------------------------------------------

_G._savedEnv = getfenv()
module( "mode_generic_laning", package.seeall )

----------------------------------------------------------------------------------------------------

--function OnStart()
--	--print( "mode_generic_defend_ally.OnStart" );
--end
--

function OnEnd()
    _G.current_target = nil
	--print( "mode_generic_defend_ally.OnEnd" );
end


require( GetScriptDirectory().."/utility_funcs" )
require( GetScriptDirectory().."/locations" )
require( GetScriptDirectory().."/hero_funcs" )
_G.radiant_easy_camp_is_there = true
function Think()
	local bot = GetBot()
    local name = bot:GetUnitName()

    --print (GetTeamMember(2, 1):GetLocation());
    if GetGameState() == 5 then  -- 5 is creeps spawned i.e 0 seconds
        _G.seconds = get_seconds(DotaTime());
        if seconds == 0 and math.floor(DotaTime()) % 120 == 60 then  --function this
            _G.radiant_easy_camp_is_there = true
        end
        if _G.radiant_easy_camp_is_there == true then
            local lane_spot = Vector(3747, -6344 , 0);
            bot:pull_camp(RAD_SAFE_EASY, lane_spot, lane_spot, 43, true);
        end

    elseif GetGameState() == 4 and _G.movespeed == nil then
        _G.movespeed = bot:calibrate_move_speed()
    end
    --last_health = bot:GetHealth();



end

------------------------------------------------------------------------------------------------------
--
--
------------------------------------------------------------------------------------------------------
--
--function GetDefendScore( npcAlly, tableNearbyEnemyHeroes )
--
--	local nTotalEstimatedDamageToAlly = 0;
--	local nTotalEstimatedDamageToMe = 0;
--	local nMostEstimatedDamage = 0;
--	local npcMostDangerousEnemy = nil;
--
--	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
--	do
--		local nEstimatedDamageToAlly = npcEnemy:GetEstimatedDamageToTarget( false, npcAlly, 3.0, DAMAGE_TYPE_ALL );
--		local nEstimatedDamageToMe = npcEnemy:GetEstimatedDamageToTarget( false, GetBot(), 3.0, DAMAGE_TYPE_ALL );
--
--		nTotalEstimatedDamageToAlly = nTotalEstimatedDamageToAlly + nEstimatedDamageToAlly;
--		nTotalEstimatedDamageToMe = nTotalEstimatedDamageToMe + nEstimatedDamageToMe;
--
--		if ( nEstimatedDamageToAlly > nMostEstimatedDamage )
--		then
--			nMostEstimatedDamage = nEstimatedDamageToAlly;
--			npcMostDangerousEnemy = npcEnemy;
--		end
--	end
--
--	if ( npcMostDangerousEnemy ~= nil )
--	then
--		local fDefendAllyDesire = RemapValClamped( nTotalEstimatedDamageToAlly / npcAlly:GetHealth(), 0.5, 1.5, 0.0, 1.0 );
--		local fSelfPreservationDesire = RemapValClamped( nTotalEstimatedDamageToMe / npcAlly:GetHealth(), 0.5, 1.5, 1.0, 0.0 );
--
--		return 0.5 * fDefendAllyDesire * fSelfPreservationDesire, npcMostDangerousEnemy;
--	end
--
--	return 0, nil;
--end

----------------------------------------------------------------------------------------------------

for k,v in pairs( mode_generic_laning ) do	_G._savedEnv[k] = v end

----------------------------------------------------------------------------------------------------
