
require( GetScriptDirectory().."/locations" )
function CDOTA_Bot_Script:pull_easy_radiant(seconds)

    local lane_spot = Vector(3747, -6344 , 0);
    if current_target ~= nil then
        print(current_target:GetVelocity().x)
        print(current_target:GetVelocity().y)
        print (current_target:GetHealth())
        print (current_target:GetMaxHealth())
        print ("-------------------------")
        print (current_target:GetAttackTarget())
        print ("-------------------------")
        print (current_target:GetAggroTarget())
    end
    -- sigh this doesnt work with creeps that dont move and just fight back immediately :/
    if (current_target == nil or (current_target ~= nil and (current_target:GetVelocity().x == 0 and current_target:GetVelocity().y == 0
        and current_target:GetHealth() == current_target:GetMaxHealth()))
    ) then
        print ("not aggroed")
    --if (self:GetHealth() == self:GetMaxHealth()) then -- If we havent yet tried to pull (probably a better way to check if aggro'd)
        if (seconds > 37) then  -- obviously this doesnt work for the other pull timing
            if current_target ~= nil then
                self:Action_AttackUnit(current_target, true);
            else
                local neuts = self:GetNearbyCreeps(1000, true);
                if next(neuts) == nil then
                    print ("doing attack move");
                    self:Action_AttackMove(RAD_SAFE_EASY); -- now is a good time to try and pull
                else
                    current_target = neuts[1]
                    print ("doing attack unit")
                    self:Action_AttackUnit(current_target, true);
                end

            end
        else
            self:Action_MoveToLocation(lane_spot); -- now is too early. stand in waiting spot
        end
    else -- we've 'initiated' the pull
        -- when we aggro camp and when we arrive back in lane we have vel_y = 0 so need check location as well
        -- or find way to query state from previous frame
        -- or jsut use GetFacing!!!
        print ("aggroed")
    -- gonna be a bug where creep gone back
        local a = self:GetNearbyCreeps(400, false)
        if a ~= nil then
            for k, v in pairs(a) do
                print (k, v)
            end
        else
            print ("no nearby friendlies")
        end

        if (current_target:GetVelocity().y <= 0 and next(self:GetNearbyCreeps(300, false)) == nil) then -- we have pulled and are dragging creeps into lane
            self:Action_MoveToLocation(lane_spot);
        else
--            local neuts = self:GetNearbyCreeps(1000, true);
--            if next(neuts) == nil then
--                self:Action_AttackMove(RAD_SAFE_EASY); -- now is a good time to try and pull
--                print ("doing attack move");
--            else
            print ("doing attack unit")
            print (current_target:IsAlive())
            -- if current_target:GetHealth() <= 0 or
            if current_target:GetHealth() <= 0 or not current_target:IsAlive() then  -- was IsAlive working. can i drop back to 1 check?
                current_target = nil
                local neuts = self:GetNearbyCreeps(1000, true);
                for k, v in pairs(neuts) do
                    if v:GetHealth() > 0 and v:IsAlive() then
                        current_target = v -- if this fails theyre all dead go back to lane?
                    end
                end
            end

            if current_target ~= nil then
                self:Action_AttackUnit(current_target, true);
            end
            -- go to farm the creeps we've pulled
            -- I say farm. I meant shake it all about.
            -- Setting attack move when already in one cancels animation and starts again
            -- I believe/hope replacing with AttackUnit will not do the cancelling
        end
    end
end

function stack_camp(camp)
    return
end

function aggro_camp()
    return
end