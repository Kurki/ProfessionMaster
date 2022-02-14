--[[

@author Esperanza - Everlook/EU-Alliance
@copyright ©2022 The Profession Master Authors. All Rights Reserved.

Licensed under the GNU General Public License, Version 3.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.gnu.org/licenses/gpl-3.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]
local addon = _G.professionMaster;

-- define service
InventoryService = {};
InventoryService.__index = InventoryService;

--- Initialize service.
function InventoryService:Initialize()
    self.missingReagentsView = addon:CreateView("missing-reagents");
end

-- Scan inventory.
function InventoryService:ScanInventory()
    -- clear inventory
    self.inventory = {};

    -- iterate all bags
    for bag = 0, NUM_BAG_SLOTS do
        -- iterate all slots in bag
        for slot = 1, GetContainerNumSlots(bag) do
            -- get item id and amount
            local itemId = GetContainerItemID(bag, slot);
            local _, amount = GetContainerItemInfo(bag, slot);

            -- check if id and amount loaded
            if (itemId and amount) then
                -- check if contais item id
                if (self.inventory[itemId]) then
                    self.inventory[itemId] = self.inventory[itemId] + amount;
                else
                    self.inventory[itemId] = amount;
                end
            end
        end
    end
end

-- Get amount of item.
function InventoryService:GetItemAmount(itemId)
    return self.inventory[itemId] or 0;
end

--Get reagents.
function InventoryService:GetReagents()
    -- get profession reagents
    local ProfessionReagents = addon:GetModel("profession-reagents")

    -- iterate bucket list
    local reagents = {};
    for skillId, skillAmount in pairs(BucketList) do
        -- get skill reagents
        local skillReagents = ProfessionReagents[skillId];
        if (skillReagents) then
            -- iterate skill reagents
            for reagentItemId, reagentAmount in pairs(skillReagents) do
                -- check reagent
                if (not reagents[reagentItemId]) then
                    reagents[reagentItemId] = {
                        amount = skillAmount * reagentAmount,
                        stocks = 0;
                    };
                else
                    reagents[reagentItemId].amount = reagents[reagentItemId].amount + skillAmount * reagentAmount;
                end
            end
        end
    end

    -- acan inventory
    self:ScanInventory();

    -- get reagent stocks
    for reagentItemId, reagent in pairs(reagents) do
        reagent.stocks = self.inventory[reagentItemId] or 0;
    end

    -- get reagents
    return reagents;
end

-- Check for missing reagents.
function InventoryService:CheckMissingReagents()
    -- check if missing reagents should be hidden
    if (Settings.hideMissingReagents) then
        return;
    end

    -- get reagents
    local reagents = self:GetReagents();

    -- get missing reagents
    local hasMissingReagents = false;
    local missingReagents = {};

    -- get reagent stocks
    for reagentItemId, reagent in pairs(reagents) do
        -- check if reagent mising
        if (reagent.amount > reagent.stocks) then
            missingReagents[reagentItemId] = reagent.amount - reagent.stocks;
            hasMissingReagents = true;
        end
    end

    -- check if has missing reagents
    if (hasMissingReagents) then
        self.missingReagentsView:Show(missingReagents);
    else
        self.missingReagentsView:Hide();
    end
end

--- Toggle missing reagents.
function InventoryService:ToggleMissingReagents()
    -- check if visible
    if (self.missingReagentsView.visible) then
        --hide missing reagents
        Settings.hideMissingReagents = true;
        self.missingReagentsView:Hide();
        return;
    end

    -- do not hide missing ragents
    Settings.hideMissingReagents = nil;
    self:CheckMissingReagents();
end

-- register service
addon:RegisterService(InventoryService, "inventory");
