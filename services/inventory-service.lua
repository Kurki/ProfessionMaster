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
    local watchedReagents = PM_ReagentWatchList or {};

    -- scan inventory
    self:ScanInventory();

    -- build initial reagent demand from bucket list
    -- only count reagents for the MISSING amount of the end product
    local demanded = {};
    for skillId, skillAmount in pairs(PM_BucketList) do
        -- get skill reagents
        local skillInfo = skillsService:GetSkillById(skillId);
        if (skillInfo) then
            -- subtract stocks of the end product from the demanded amount
            local missingAmount = skillAmount;
            if (skillInfo.itemId and skillInfo.itemId > 0) then
                local productStocks = self.inventory[skillInfo.itemId] or 0;
                missingAmount = math.max(0, skillAmount - productStocks);
            end

            -- only demand reagents for the missing crafts
            if (missingAmount > 0) then
                for reagentItemId, reagentAmount in pairs(skillInfo.reagents) do
                    demanded[reagentItemId] = (demanded[reagentItemId] or 0) + missingAmount * reagentAmount;
                end
            end
        end
    end

    -- recursively expand watchlisted craftable reagents
    -- (watchlisted items themselves are removed from output)
    local loopGuard = 0;
    local hasChanges = true;
    while (hasChanges and loopGuard < 200) do
        loopGuard = loopGuard + 1;
        hasChanges = false;

        -- collect watchlisted nodes to expand in this pass
        local toExpand = {};
        for reagentItemId, totalNeeded in pairs(demanded) do
            local skillId = skillsService:GetSkillIdByItemId(reagentItemId);
            if (totalNeeded > 0 and watchedReagents[reagentItemId] and skillId) then
                table.insert(toExpand, {
                    itemId = reagentItemId,
                    needed = totalNeeded,
                    skillId = skillId,
                });
            end
        end

        -- expand selected nodes
        for _, node in ipairs(toExpand) do
            local skillInfo = skillsService:GetSkillById(node.skillId);
            demanded[node.itemId] = nil;
            hasChanges = true;

            if (skillInfo and skillInfo.reagents) then
                local stocks = self.inventory[node.itemId] or 0;
                local missing = math.max(0, node.needed - stocks);
                if (missing > 0) then
                    for subReagentItemId, subReagentAmount in pairs(skillInfo.reagents) do
                        local subNeeded = missing * subReagentAmount;
                        demanded[subReagentItemId] = (demanded[subReagentItemId] or 0) + subNeeded;
                    end
                end
            end
        end
    end

    -- prepare output structure
    local reagents = {};
    for reagentItemId, totalNeeded in pairs(demanded) do
        reagents[reagentItemId] = {
            amount = totalNeeded,
            stocks = self.inventory[reagentItemId] or 0;
        };
    end

    -- get reagent stocks
    for reagentItemId, reagent in pairs(reagents) do
        reagent.stocks = self.inventory[reagentItemId] or 0;
    end

    -- get reagents
    return reagents;
end

-- Check for missing reagents.
function InventoryService:CheckMissingReagents()
    -- get reagents
    local reagents = self:GetReagents();

    -- refresh bucket list in professions view when visible
    local professionsView = self.addon.professionsView;
    if (professionsView and professionsView.visible and professionsView.bucketListPanel) then
        professionsView.bucketListPanel:Refresh();
    end

    -- check if missing reagents should be hidden
    if (PM_Settings.hideMissingReagents) then
        return;
    end

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
        PM_Settings.hideMissingReagents = true;
        self.missingReagentsView:Hide();
        return;
    end

    -- do not hide missing ragents
    PM_Settings.hideMissingReagents = nil;
    self:CheckMissingReagents();
end

