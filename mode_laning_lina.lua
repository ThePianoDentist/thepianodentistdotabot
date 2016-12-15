
----------------------------------------------------------------------------------------------------

_G._savedEnv = getfenv()
module( "mode_generic_laning", package.seeall )

----------------------------------------------------------------------------------------------------

--function OnStart()
--	--print( "mode_generic_defend_ally.OnStart" );
--end
--
------------------------------------------------------------------------------------------------------
--
--function OnEnd()
--	--print( "mode_generic_defend_ally.OnEnd" );
--end
--
------------------------------------------------------------------------------------------------------
--

require( GetScriptDirectory().."/utility_funcs" )
function Think()
	local bot = GetBot();
    local name = bot:GetUnitName()

    if GetGameState() == 5  -- 5 is creeps spawned i.e 0 seconds
    then
        local seconds = getSeconds(DotaTime());
--        for k,v in bot:GetNearbyCreeps() do -- why does this require 2 non self arguments?
--            print(k, v)
--        end
        for k,v in pairs(bot) do -- why does this require 2 non self arguments?
            print(k)
            print ("space")
            print (tostring(v))

        end
        local lane_spot = Vector(3747, -6344 , 0);
        local camp_spot = Vector(3000, -4700, 0); -- Can I be using GetNeutralSpawners for getting camp location?
        if (bot:GetHealth() == bot:GetMaxHealth())  -- If we havent yet tried to pull (probably a better way to check if aggro'd)
        then
            if (seconds > 35)  -- obviously this doesnt work for the other pull timing
            then
                bot:Action_AttackMove(camp_spot); -- now is a good time to try and pull
            else
                bot:Action_MoveToLocation(lane_spot); -- now is too early. stand in waiting spot
            end
        else -- we've 'initiated' the pull
            -- when we aggro camp and when we arrive back in lane we have vel_y = 0 so need check location as well
            -- or find way to query state from previous frame
            -- or jsut use GetFacing!!!
            if (bot:GetVelocity().y <= 0 and bot:GetLocation().y > -6000) -- we have pulled and are dragging creeps into lane
            then
                bot:Action_MoveToLocation(lane_spot);
            else
                bot:Action_AttackMove(camp_spot); -- go to farm the creeps we've pulled
                -- I say farm. I meant shake it all about.
                -- Setting attack move when already in one cancels animation and starts again
                -- I believe/hope replacing with AttackUnit will not do the cancelling
            end
        end
    end



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
