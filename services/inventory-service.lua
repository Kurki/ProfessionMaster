--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local InventoryService = _G.professionMaster:CreateService("inventory");

--- Initialize service.
function InventoryService:Initialize()
    self.missingReagentsView = self.addon:NewView("missing-reagents");
    self.inventory = {};
    self.inventoryDirty = true;
end

-- Mark inventory cache as dirty (needs rescan).
function InventoryService:InvalidateInventory()
    self.inventoryDirty = true;
end

-- Scan inventory (only if cache is dirty).
function InventoryService:ScanInventory()
    -- skip scan if cache is still valid
    if (not self.inventoryDirty) then
        return;
    end

    -- clear inventory
    if (self.inventory) then
        wipe(self.inventory);
    else
        self.inventory = {};
    end

    -- mark cache as clean
    self.inventoryDirty = false;

    -- log trace
    self.addon:LogTrace("InventoryService", "ScanInventory", "Scanning inventory...");

    -- iterate all bags
    for bag = 0, NUM_BAG_SLOTS do
        -- iterate all slots in bag
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            -- get item id and amount
            local itemId = C_Container.GetContainerItemID(bag, slot);
            local slotInfo = C_Container.GetContainerItemInfo(bag, slot);
 
            -- check if id and amount loaded
            if (itemId and slotInfo.stackCount) then
                -- check if contais item id
                if (self.inventory[itemId]) then
                    self.inventory[itemId] = self.inventory[itemId] + slotInfo.stackCount;
                else
                    self.inventory[itemId] = slotInfo.stackCount;
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
    -- get skills service
    local skillsService = self:GetService("skills");

    -- iterate bucket list
    local reagents = {};
    for skillId, skillAmount in pairs(BucketList) do
        -- get skill reagents
        local skillInfo = skillsService:GetSkillById(skillId);
        if (skillInfo) then
            -- iterate skill reagents
            for reagentItemId, reagentAmount in pairs(skillInfo.reagents) do
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
    if (PMSettings.hideMissingReagents) then
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
        PMSettings.hideMissingReagents = true;
        self.missingReagentsView:Hide();
        return;
    end

    -- do not hide missing ragents
    PMSettings.hideMissingReagents = nil;
    self:CheckMissingReagents();
end

