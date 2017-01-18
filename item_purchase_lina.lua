

local tableItemsToBuy = {
				"item_tango",
				"item_tango",
				"item_clarity",
				"item_clarity",
				"item_branches",
				"item_branches",
--				"item_magic_stick",
--				"item_circlet",
--				"item_boots",
--				"item_energy_booster",
--				"item_staff_of_wizardry",
--				"item_ring_of_regen",
--				"item_recipe_force_staff",
--				"item_point_booster",
--				"item_staff_of_wizardry",
--				"item_ogre_axe",
--				"item_blade_of_alacrity",
--				"item_mystic_staff",
--				"item_ultimate_orb",
--				"item_void_stone",
--				"item_staff_of_wizardry",
--				"item_wind_lace",
--				"item_void_stone",
--				"item_recipe_cyclone",
--				"item_cyclone",
			};


----------------------------------------------------------------------------------------------------
require( GetScriptDirectory().."/locations2" )
function ItemPurchaseThink()
    -- throwing things in here because this called every frame right?
    if seconds == 0 and _G.minutes % 2 == 1 or seconds == 30 and _G.minutes == 0 then  --function this
        for k,v in pairs(NEUTRAL_CAMPS) do
            v.is_alive = true
        end
	end
	local sNextItem = tableItemsToBuy[1];
	local npcBot = GetBot();

	if ( #tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
		npcBot:Action_PurchaseItem( sNextItem );
		table.remove( tableItemsToBuy, 1 );
	end

end

----------------------------------------------------------------------------------------------------
