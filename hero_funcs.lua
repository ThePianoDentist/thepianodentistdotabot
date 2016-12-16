
function pull_easy_radiant()
    local lane_spot = Vector(3747, -6344 , 0);
    local camp_spot = Vector(3000, -4700, 0); -- Can I be using GetNeutralSpawners for getting camp location? GetNeutralSpwaners just returns empty table
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

function stack_camp(camp)
    return
end