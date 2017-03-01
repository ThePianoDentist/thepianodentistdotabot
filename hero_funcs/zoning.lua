local next = next
AGGRO_RANGE = 500

--TODO dont attack/zone if in enemy tower range lol!
function CDOTA_Bot_Script:zone_offlaner()
    if self:WasRecentlyDamagedByCreep(2) or self:WasRecentlyDamagedByTower(2) then --retreat
        print("Tower: " .. tostring(GetTower(TEAM_RADIANT, TOWER_BOT_1)))
        self:Action_MoveToUnit(GetTower(TEAM_RADIANT, TOWER_BOT_1))
        return
    end

    print("GetUnitToLocationDistance(self, GetTower(TEAM_DIRE, TOWER_BOT_1):GetLocation()): " .. tostring(GetUnitToLocationDistance(self, GetTower(TEAM_DIRE, TOWER_BOT_1):GetLocation())) .. "/n")
    -- this distance just seems a bit...off?
    if GetUnitToLocationDistance(self, GetTower(TEAM_DIRE, TOWER_BOT_1):GetLocation()) < 900 then -- 700 is attack range
        print("Getting out of enemy tower range")
        self:Action_MoveToUnit(GetTower(TEAM_RADIANT, TOWER_BOT_1))
        _G.state.current_mode = "none"
        _G.state.current_target = nil
        return
    end


    local enemy_heroes = self:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local radiant_front = _G.minutes > 0 and GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, 0) or Vector(5900, -5500, 0)
    local dire_front = GetLaneFrontLocation(2, 3, 0)
    if GetUnitToLocationDistance(self, radiant_front) > 2000 then
        print("Move -> radiant front")
        self:Action_MoveToLocation(radiant_front)
        return

    elseif next(enemy_heroes) == nil then -- may need to account for heroes fogging us so still being close by
        if _G.state.current_target ~= nil then
            print("Quit")
            _G.state.current_target = nil
            _G.state.current_mode = "none"
            return
        else
            print("Move -> radiant front")
            self:Action_MoveToLocation(radiant_front)
            return
        end



    else
        print("Doing zoning")

        if next(enemy_heroes) then
            print("Enemy hearoes nearby: " .. tostring(enemy_heroes[1]))
            _G.state.current_target = enemy_heroes[1]
        end
        if _G.state.current_target == nil then
            _G.state.current_target = enemy_heroes[1]
        end

        local target = _G.state.current_target
        local attack_range = self:GetAttackRange()
        local creeps_in_aggro_range = self:GetNearbyLaneCreeps(AGGRO_RANGE, true)
        local distance_to_target = GetUnitToUnitDistance(self, target)

        -- check if we're already attacking. This is necessary as enemy can move out of attack range mid animation...but animation still goes through
        if next(creeps_in_aggro_range) == nil and (self:GetCurrentActionType() == BOT_ACTION_TYPE_ATTACK or distance_to_target < attack_range) then
            print("Attack target")
            self:Action_AttackUnit(target, true)
            return
        end

        local our_loc = self:GetLocation()

        local enemy_loc = GetHeroLastSeenInfo(target:GetPlayerID()).location -- what if nil, cant be nil right?
        local extra_creeps = AGGRO_RANGE + distance_to_target > 2000 and {} or self:GetNearbyLaneCreeps(AGGRO_RANGE + distance_to_target, true)
        print("enemy_loc.x: " .. tostring(enemy_loc.x))
        print("our_loc.x: " .. tostring(our_loc.x))
        print("distance_to_target: " .. tostring(distance_to_target))
        local us_to_hero_unit_vec = Vector((enemy_loc.x - our_loc.x) / distance_to_target, (enemy_loc.y - our_loc.y) / distance_to_target, 0)
        local predicted_attack_loc = our_loc + us_to_hero_unit_vec * (distance_to_target - attack_range)
        print("GetUnitToLocationDistance(extra_creeps[1], predicted_attack_loc)")
        print(GetUnitToLocationDistance(extra_creeps[1], predicted_attack_loc))
        print("next(creeps_in_aggro_range)")
        print(next(creeps_in_aggro_range))
        print("predicted_attack_loc")
        print(predicted_attack_loc)
        if next(creeps_in_aggro_range) == nil  and next(extra_creeps) and GetUnitToLocationDistance(extra_creeps[1], predicted_attack_loc) > AGGRO_RANGE then --going to run into problem where an if makes unit 'vibrate' in and out of boundary
            print("Move directly at target")
            self:Action_MoveToLocation(target:GetLocation())
            return
        end

        -- THis has issues when creep wave is under enemy tower
        local distance_to_closest_creep = GetUnitToUnitDistance(self, creeps_in_aggro_range[1])
        if our_loc.y <= enemy_loc.y + attack_range then
            print (our_loc.y)
            print (enemy_loc.y)
            print (attack_range)
            print("Move left out of way of creeps")
            -- TODO wrap this in closest pathable loc
            self:Action_MoveToLocation(Vector(our_loc.x - distance_to_closest_creep, our_loc.y, 0))
        else
            print("Move right as now away from wave")
            -- TODO wrap this in closest pathable loc
            self:Action_MoveToLocation(Vector(enemy_loc.x, our_loc.y, 0))
        end

        --        else -- move so that we can hit hero without aggroing creeps
        --            print("Move behind target")
        --            print(_G.state.current_target)
        --            local target_x = enemy_loc.x > our_loc.x and (enemy_loc.x + AGGRO_RANGE) or (enemy_loc.x - AGGRO_RANGE)
        --            local target_y = enemy_loc.y > our_loc.y and (enemy_loc.y + AGGRO_RANGE) or (enemy_loc.y - AGGRO_RANGE)
        --            self:Action_MoveToLocation(Vector(target_x, target_y, 0))
        --            -- get vector between us and hero
        --            -- move to a location AGGRO_RANGE + that vector. but going around creeps?
        --        end


    end
end


