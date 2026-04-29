--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create panel
local BucketListPanel = _G.professionMaster:CreateView("bucket-list-panel");

--- Create bucket list panel frames.
-- @param parentFrame The parent view frame to attach to.
-- @param professionsView Reference to the parent professions view.
function BucketListPanel:Create(parentFrame, professionsView)
    self.professionsView = professionsView;
    self.reagentRows = {};

    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- add bucket list frame
    local frame = uiService:CreatePanel(parentFrame);
    frame:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", -302, 0);
    frame:SetPoint("BOTTOMRIGHT", 0, 0);
    self.frame = frame;

    -- add bucket list scroll frame
    local scrollParent, scrollChild, scrollElement = uiService:CreateScrollFrame(frame);
    scrollParent:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -35);
    scrollParent:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2);
    scrollParent:SetBackdropColor(0, 0, 0, 0);
    scrollChild:SetWidth(scrollParent:GetWidth());
    self.scrollChild = scrollChild;
    self.scrollElement = scrollElement;

    -- add bucket list title text
    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    titleText:SetPoint("TOPLEFT", 13, -15);
    titleText:SetText(localeService:Get("ProfessionsViewBucketList"));

    -- add bucket list clear button
    local clearButton = uiService:CreateFlatSquareButton(frame, "x", function()
        PM_BucketList = {};
        professionsView:CheckBucketList();
        self:GetService("inventory"):CheckMissingReagents();
    end, 20);
    clearButton:SetPoint("TOPRIGHT", -8, -10);
    uiService:BindTooltip(clearButton, localeService:Get("ProfessionsViewClearBucketList"), "ANCHOR_RIGHT");
end

--- Handle resize event.
function BucketListPanel:OnSizeChanged()
    if (self.scrollChild and self.scrollElement) then
        self.scrollChild:SetWidth(self.scrollElement:GetWidth());
    end
end

--- Check if bucket list has any items.
-- @return boolean True if bucket list has items.
function BucketListPanel:HasItems()
    for _ in pairs(PM_BucketList) do
        return true;
    end
    return false;
end

--- Show frame.
function BucketListPanel:Show()
    if (self.frame) then
        self.frame:Show();
    end
end

--- Hide frame.
function BucketListPanel:Hide()
    if (self.frame) then
        self.frame:Hide();
    end
end

--- Refresh bucket list rows.
function BucketListPanel:Refresh()
    -- hide rows
    for _, row in ipairs(self.reagentRows) do
        row:Hide();
    end

    -- get services
    local inventoryService = self:GetService("inventory");
    local skillsService = self:GetService("skills");
    local professionNamesService = self:GetService("profession-names");

    -- scan inventory once
    inventoryService:ScanInventory();

    -- build tree
    local treeRows = self:BuildTree(skillsService, inventoryService);

    -- calculate vertical positions with spacing before root nodes
    local currentTop = 0;
    for i, treeRow in ipairs(treeRows) do
        if (treeRow.isSeparator) then
            currentTop = currentTop + 10;
            treeRow.top = currentTop;
            currentTop = currentTop + 23;
        else
            if (treeRow.isNode and i > 1) then
                currentTop = currentTop + 6;
            end
            treeRow.top = currentTop;
            currentTop = currentTop + 20;
        end
    end

    -- render separator line
    if (not self.separator) then
        local separator = self.scrollChild:CreateTexture(nil, "OVERLAY");
        separator:SetColorTexture(0.4, 0.4, 0.4, 0.6);
        separator:SetHeight(1);
        self.separator = separator;
    end
    self.separator:Hide();

    -- create missing reagents header if not exists
    if (not self.missingReagentsHeader) then
        local header = self.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        self.missingReagentsHeader = header;
    end
    self.missingReagentsHeader:Hide();

    -- render tree rows
    local rowIndex = 0;
    local localeService = self:GetService("locale");
    for _, treeRow in ipairs(treeRows) do
        -- handle separator
        if (treeRow.isSeparator) then
            self.separator:ClearAllPoints();
            self.separator:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 10, -treeRow.top);
            self.separator:SetPoint("RIGHT", self.scrollChild, "RIGHT", -30, 0);
            self.separator:Show();

            -- show missing reagents header below separator
            self.missingReagentsHeader:ClearAllPoints();
            self.missingReagentsHeader:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 10, -(treeRow.top + 9));
            self.missingReagentsHeader:SetText(localeService:Get("ProfessionsViewCraftSelf"));
            self.missingReagentsHeader:Show();
        else

        rowIndex = rowIndex + 1;
        if (#self.reagentRows < rowIndex) then
            -- create row frame
            local reagentRow = CreateFrame("Button", nil, self.scrollChild, BackdropTemplateMixin and "BackdropTemplate");
            reagentRow:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]]
            });

            -- bind row mouse events
            reagentRow:SetScript("OnLeave", function()
                C_Timer.After(0, function()
                    if (not reagentRow:IsVisible()) then return; end
                    local overRow = reagentRow:IsMouseOver();
                    local overButton = reagentRow.craftButton:IsVisible() and reagentRow.craftButton:IsMouseOver();
                    self:UpdateReagentRowHoverState(reagentRow);
                    if (not overRow and not overButton) then
                        GameTooltip:Hide();
                    end
                end);
            end);
            reagentRow:SetScript("OnEnter", function()
                self:UpdateReagentRowHoverState(reagentRow);
                if (reagentRow.itemLink) then
                    GameTooltip:SetOwner(reagentRow, "ANCHOR_LEFT");
                    GameTooltip:SetHyperlink(reagentRow.itemLink);
                    GameTooltip:Show();
                end
            end);

            -- add icon text
            local iconText = reagentRow:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            reagentRow.iconText = iconText;

            -- add amount text
            local amountText = reagentRow:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            amountText:SetPoint("TOPRIGHT", -3, -4);
            amountText:SetJustifyH("RIGHT");
            reagentRow.amountText = amountText;

            -- add craft button (hammer)
            local craftButton = CreateFrame("Button", nil, reagentRow);
            craftButton:SetSize(14, 14);
            craftButton:SetPoint("RIGHT", amountText, "LEFT", -8, 0);
            local craftIcon = craftButton:CreateTexture(nil, "ARTWORK");
            craftIcon:SetAllPoints();
            craftIcon:SetTexture([[Interface\Icons\INV_Hammer_01]]);
            craftButton.icon = craftIcon;
            local craftText = craftButton:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            craftText:SetAllPoints();
            craftText:SetJustifyH("CENTER");
            craftText:SetJustifyV("MIDDLE");
            craftText:SetText("x");
            craftText:SetTextColor(1, 0.4, 0.4);
            craftText:Hide();
            craftButton.text = craftText;
            craftButton:SetScript("OnClick", function()
                self:OnCraftButtonClicked(reagentRow);
            end);
            craftButton:SetScript("OnEnter", function()
                self:UpdateReagentRowHoverState(reagentRow);
                GameTooltip:SetOwner(craftButton, "ANCHOR_RIGHT");
                local tooltipKey = "ProfessionsViewCraftSelf";
                if (reagentRow.craftButtonMode == "remove-watch") then
                    tooltipKey = "ProfessionsViewRemoveFromWatchList";
                elseif (reagentRow.craftButtonMode == "remove-bucket") then
                    tooltipKey = "ProfessionsViewRemoveFromBucketList";
                end
                GameTooltip:SetText(self:GetService("locale"):Get(tooltipKey));
                GameTooltip:Show();
            end);
            craftButton:SetScript("OnLeave", function()
                C_Timer.After(0, function()
                    self:UpdateReagentRowHoverState(reagentRow);
                    if (reagentRow:IsMouseOver() and reagentRow.itemLink) then
                        GameTooltip:SetOwner(reagentRow, "ANCHOR_LEFT");
                        GameTooltip:SetHyperlink(reagentRow.itemLink);
                        GameTooltip:Show();
                    else
                        GameTooltip:Hide();
                    end
                end);
            end);
            craftButton:Hide();
            reagentRow.craftButton = craftButton;

            -- add item text
            local itemText = reagentRow:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("BOTTOMRIGHT", craftButton, "BOTTOMLEFT", -6, 0);
            itemText:SetJustifyH("LEFT");
            itemText:SetJustifyV("TOP");
            reagentRow.itemText = itemText;

            -- add row
            table.insert(self.reagentRows, reagentRow);
        end

        -- get row
        local reagentRow = self.reagentRows[rowIndex];
        local indent = treeRow.indent;
        local top = treeRow.top;
        reagentRow:ClearAllPoints();
        reagentRow:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 8 + indent * 12, -top);
        reagentRow:SetPoint("BOTTOMRIGHT", self.scrollChild, "TOPRIGHT", -26, -(top + 20));

        -- set background color
        local backgroundColor;
        if (treeRow.isNode) then
            backgroundColor = 0.2;
        elseif (rowIndex % 2 == 0) then
            backgroundColor = 0.08;
        else
            backgroundColor = 0.12;
        end
        reagentRow.bgColor = backgroundColor;
        reagentRow:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

        -- position icon and item text
        reagentRow.iconText:ClearAllPoints();
        reagentRow.iconText:SetPoint("TOPLEFT", 3, -3);
        reagentRow.itemText:ClearAllPoints();
        reagentRow.itemText:SetPoint("TOPLEFT", 24, -4);
        reagentRow.itemText:SetPoint("BOTTOMRIGHT", reagentRow.craftButton, "BOTTOMLEFT", -6, 0);

        reagentRow:Show();
        reagentRow.itemLink = nil;
        reagentRow.craftButton:Hide();
        reagentRow.isIndented = indent > 0;
        reagentRow.craftItemId = treeRow.itemId;
        reagentRow.isWatchListRoot = treeRow.isWatchListRoot == true;
        reagentRow.isBucketListRoot = treeRow.isBucketListRoot == true;
        reagentRow.bucketSkillId = treeRow.skillId;
        reagentRow.craftSkillId = nil;
        if (reagentRow.isIndented and treeRow.itemId and treeRow.itemId > 0) then
            reagentRow.craftSkillId = skillsService:GetSkillIdByItemId(treeRow.itemId);
        end
        reagentRow.craftButtonMode = nil;
        if (reagentRow.isWatchListRoot) then
            reagentRow.craftButtonMode = "remove-watch";
            reagentRow.craftButton.icon:Hide();
            reagentRow.craftButton.text:Show();
        elseif (reagentRow.isBucketListRoot and reagentRow.bucketSkillId) then
            reagentRow.craftButtonMode = "remove-bucket";
            reagentRow.craftButton.icon:Hide();
            reagentRow.craftButton.text:Show();
        elseif (reagentRow.isIndented and reagentRow.craftSkillId) then
            reagentRow.craftButtonMode = "toggle-watch";
            reagentRow.craftButton.icon:SetTexture([[Interface\Icons\INV_Hammer_01]]);
            reagentRow.craftButton.icon:Show();
            reagentRow.craftButton.text:Hide();
        else
            reagentRow.craftButton.icon:SetTexture([[Interface\Icons\INV_Hammer_01]]);
            reagentRow.craftButton.icon:Show();
            reagentRow.craftButton.text:Hide();
        end

        -- update amount
        local stocks = treeRow.stocks;
        local amount = treeRow.amount;
        if (amount > 0) then
            if (treeRow.itemId and treeRow.itemId > 0) then
                reagentRow.amountText:SetText(math.min(stocks, amount) .. "/" .. amount);
                if (stocks >= amount) then
                    reagentRow.amountText:SetTextColor(0, 1, 0);
                else
                    reagentRow.amountText:SetTextColor(1, 1, 1);
                end
            else
                reagentRow.amountText:SetText(amount);
                reagentRow.amountText:SetTextColor(1, 1, 1);
            end
        else
            reagentRow.amountText:SetText("");
        end

        -- set text style based on node type
        if (treeRow.isNode) then
            reagentRow.itemText:SetFontObject("GameFontNormal");
            reagentRow.amountText:SetFontObject("GameFontNormal");
        else
            reagentRow.itemText:SetFontObject("GameFontHighlightSmall");
            reagentRow.amountText:SetFontObject("GameFontHighlightSmall");
        end

        -- load item or spell info
        local reagentItemId = treeRow.itemId;
        local rowItemAmount = treeRow.itemAmount;
        if (reagentItemId and reagentItemId > 0 and C_Item.DoesItemExistByID(reagentItemId)) then
            local item = Item:CreateFromItemID(reagentItemId);
            if (not item:IsItemEmpty()) then
                pcall(function()
                    item:ContinueOnItemLoad(function()
                        reagentRow.itemLink = item:GetItemLink();
                        reagentRow.iconText:SetText("|T" .. item:GetItemIcon() .. ":16|t");
                        local itemName = "|c" .. professionNamesService:GetItemColor(reagentRow.itemLink) .. item:GetItemName();
                        if (rowItemAmount and rowItemAmount > 1) then
                            itemName = itemName .. "|r x" .. rowItemAmount;
                        end
                        reagentRow.itemText:SetText(itemName);
                    end);
                end);
            end
        elseif (treeRow.skillId) then
            local spellName, _, spellIcon = GetSpellInfo(treeRow.skillId);
            if (spellName) then
                reagentRow.itemLink = GetSpellLink(treeRow.skillId);
                reagentRow.iconText:SetText("|T" .. (spellIcon or 136243) .. ":16|t");
                local itemName = "|cFF71D5FF" .. spellName;
                if (rowItemAmount and rowItemAmount > 1) then
                    itemName = itemName .. "|r x" .. rowItemAmount;
                end
                reagentRow.itemText:SetText(itemName);
            end
        end
    end -- if not separator
    end -- for treeRows

    -- update scroll child height
    self.scrollChild:SetHeight(currentTop + 5);
end

--- Show or hide craft button for a hovered bucket list row.
-- @param reagentRow Bucket list reagent row.
function BucketListPanel:UpdateCraftButtonVisibility(reagentRow)
    if (not reagentRow or not reagentRow.craftButton) then
        return;
    end

    local canShowButton = reagentRow.craftButtonMode ~= nil;
    if (canShowButton and (reagentRow:IsMouseOver() or reagentRow.craftButton:IsMouseOver())) then
        reagentRow.craftButton:Show();
    else
        reagentRow.craftButton:Hide();
    end
end

--- Update hover visuals for bucket list row and craft button.
-- @param reagentRow Bucket list reagent row.
function BucketListPanel:UpdateReagentRowHoverState(reagentRow)
    if (not reagentRow) then
        return;
    end

    local isHovered = reagentRow:IsMouseOver() or (reagentRow.craftButton and reagentRow.craftButton:IsMouseOver());
    if (isHovered) then
        reagentRow:SetBackdropColor(0.2, 0.2, 0.2);
    else
        reagentRow:SetBackdropColor(reagentRow.bgColor, reagentRow.bgColor, reagentRow.bgColor, 0.5);
    end

    self:UpdateCraftButtonVisibility(reagentRow);
end

--- Handle click on craft button in bucket list row.
-- @param reagentRow Bucket list reagent row.
function BucketListPanel:OnCraftButtonClicked(reagentRow)
    if (not reagentRow or not reagentRow.craftButtonMode) then
        return;
    end

    local inventoryService = self:GetService("inventory");

    if (not PM_ReagentWatchList) then
        PM_ReagentWatchList = {};
    end

    if (reagentRow.craftButtonMode == "remove-watch") then
        PM_ReagentWatchList[reagentRow.craftItemId] = nil;
    elseif (reagentRow.craftButtonMode == "remove-bucket") then
        PM_BucketList[reagentRow.bucketSkillId] = nil;
        self.professionsView:RefreshActiveTab();
        self.professionsView:CheckBucketList();
        inventoryService:CheckMissingReagents();
        return;
    elseif (PM_ReagentWatchList[reagentRow.craftItemId]) then
        PM_ReagentWatchList[reagentRow.craftItemId] = nil;
    else
        PM_ReagentWatchList[reagentRow.craftItemId] = true;
    end

    inventoryService:CheckMissingReagents();
end

--- Build a flat tree of bucket list nodes and their reagents.
-- @param skillsService Skills service reference.
-- @param inventoryService Inventory service reference.
-- @return Array of { itemId, skillId, amount, stocks, indent, isNode }.
function BucketListPanel:BuildTree(skillsService, inventoryService)
    local directRows = {};
    local derivedRows = {};
    local visited = {};
    local watchedReagents = PM_ReagentWatchList or {};

    -- collect initial nodes from bucket list
    local currentNodes = {};
    for skillId, skillAmount in pairs(PM_BucketList) do
        local skillInfo = skillsService:GetSkillById(skillId);
        if (skillInfo) then
            table.insert(currentNodes, {
                itemId = skillInfo.itemId,
                skillId = skillId,
                amount = skillAmount,
            });
        end
    end

    -- first pass: direct bucket list items and their reagents
    local nextReagents = {};
    for _, node in ipairs(currentNodes) do
        local stocks = 0;
        if (node.itemId and node.itemId > 0) then
            stocks = inventoryService:GetItemAmount(node.itemId);
        end

        -- get skill info for item amount
        local nodeSkillInfo = skillsService:GetSkillById(node.skillId);
        local nodeItemAmount = nodeSkillInfo and nodeSkillInfo.itemAmount;

        -- convert to craft units for display
        local displayAmount = node.amount;
        local displayStocks = stocks;
        if (nodeItemAmount and nodeItemAmount > 1) then
            displayAmount = math.ceil(node.amount / nodeItemAmount);
            displayStocks = math.floor(stocks / nodeItemAmount);
        end

        -- add main node row
        table.insert(directRows, {
            itemId = node.itemId,
            skillId = node.skillId,
            amount = displayAmount,
            stocks = displayStocks,
            indent = 0,
            isNode = true,
            isBucketListRoot = true,
            itemAmount = nodeItemAmount,
        });

        -- calculate missing quantity
        local missing;
        if (node.itemId and node.itemId > 0) then
            missing = math.max(0, node.amount - stocks);
        else
            missing = node.amount;
        end

        -- add reagent rows for missing amount
        if (missing > 0) then
            local skillInfo = skillsService:GetSkillById(node.skillId);
            if (skillInfo and skillInfo.reagents) then
                local craftsNeeded = math.ceil(missing / (skillInfo.itemAmount or 1));
                for reagentItemId, reagentPerCraft in pairs(skillInfo.reagents) do
                    local needed = craftsNeeded * reagentPerCraft;
                    local reagentStocks = inventoryService:GetItemAmount(reagentItemId);
                    local reagentMissing = math.max(0, needed - reagentStocks);

                    -- always show reagents under parent
                    table.insert(directRows, {
                        itemId = reagentItemId,
                        amount = needed,
                        stocks = reagentStocks,
                        indent = 1,
                        isNode = false,
                    });

                    -- only promote missing reagents
                    if (reagentMissing > 0) then
                        local reagentSkillId = skillsService:GetSkillIdByItemId(reagentItemId);
                        if (reagentSkillId) then
                            if (watchedReagents[reagentItemId] and not visited[reagentItemId]) then
                                if (not nextReagents[reagentItemId]) then
                                    nextReagents[reagentItemId] = { skillId = reagentSkillId, amount = 0 };
                                end
                                nextReagents[reagentItemId].amount = nextReagents[reagentItemId].amount + needed;
                            end
                        end
                    end
                end
            end
        end
    end

    -- subsequent passes: derived craftable reagents
    currentNodes = {};
    for reagentItemId, info in pairs(nextReagents) do
        visited[reagentItemId] = true;
        table.insert(currentNodes, {
            itemId = reagentItemId,
            skillId = info.skillId,
            amount = info.amount,
        });
    end

    -- check current nodes
    while (#currentNodes > 0) do
        local nextLevel = {};

        for _, node in ipairs(currentNodes) do
            local stocks = 0;
            if (node.itemId and node.itemId > 0) then
                stocks = inventoryService:GetItemAmount(node.itemId);
            end

            -- get skill info for item amount
            local nodeSkillInfo = skillsService:GetSkillById(node.skillId);
            local nodeItemAmount = nodeSkillInfo and nodeSkillInfo.itemAmount;

            -- convert to craft units for display
            local displayAmount = node.amount;
            local displayStocks = stocks;
            if (nodeItemAmount and nodeItemAmount > 1) then
                displayAmount = math.ceil(node.amount / nodeItemAmount);
                displayStocks = math.floor(stocks / nodeItemAmount);
            end

            table.insert(derivedRows, {
                itemId = node.itemId,
                skillId = node.skillId,
                amount = displayAmount,
                stocks = displayStocks,
                indent = 0,
                isNode = true,
                isWatchListRoot = watchedReagents[node.itemId] == true,
                itemAmount = nodeItemAmount,
            });

            -- calculate missing
            local missing;
            if (node.itemId and node.itemId > 0) then
                missing = math.max(0, node.amount - stocks);
            else
                missing = node.amount;
            end
            if (missing > 0) then
                local skillInfo = skillsService:GetSkillById(node.skillId);
                if (skillInfo and skillInfo.reagents) then
                    local craftsNeeded = math.ceil(missing / (skillInfo.itemAmount or 1));
                    for reagentItemId, reagentPerCraft in pairs(skillInfo.reagents) do
                        local needed = craftsNeeded * reagentPerCraft;
                        local reagentStocks = inventoryService:GetItemAmount(reagentItemId);
                        local reagentMissing = math.max(0, needed - reagentStocks);

                        table.insert(derivedRows, {
                            itemId = reagentItemId,
                            amount = needed,
                            stocks = reagentStocks,
                            indent = 1,
                            isNode = false,
                        });

                        if (reagentMissing > 0) then
                            local reagentSkillId = skillsService:GetSkillIdByItemId(reagentItemId);
                            if (reagentSkillId) then
                                if (watchedReagents[reagentItemId] and not visited[reagentItemId]) then
                                    if (not nextLevel[reagentItemId]) then
                                        nextLevel[reagentItemId] = { skillId = reagentSkillId, amount = 0 };
                                    end
                                    nextLevel[reagentItemId].amount = nextLevel[reagentItemId].amount + needed;
                                end
                            end
                        end
                    end
                end
            end
        end

        currentNodes = {};
        for reagentItemId, info in pairs(nextLevel) do
            visited[reagentItemId] = true;
            table.insert(currentNodes, {
                itemId = reagentItemId,
                skillId = info.skillId,
                amount = info.amount,
            });
        end
    end

    -- combine: direct rows, separator, derived rows
    local treeRows = {};
    for _, row in ipairs(directRows) do
        table.insert(treeRows, row);
    end
    if (#derivedRows > 0) then
        table.insert(treeRows, { isSeparator = true });
        for _, row in ipairs(derivedRows) do
            table.insert(treeRows, row);
        end
    end

    return treeRows;
end
