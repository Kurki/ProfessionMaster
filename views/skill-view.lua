--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create view
local SkillView = _G.professionMaster:CreateView("skill-view");

--- Show professions view.
-- @param skillRow Skill row.
function SkillView:Show(skillRow, professionsView)
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- get skilla nd skill id
    local skill = skillRow.skill;
    local skillId = skillRow.skillId;

    -- check if view created
    if (self.view == nil) then
        -- define player rows and scroll top
        self.playerRows = {};
        self.reagentRows = {};
        self.playerScrollTop = 0;

        -- create view
        local view = uiService:CreateView("PmSkill", 480, 310, "");
        view:EnableKeyboard();
        self.view = view;

        -- add close button
        local closeButton = uiService:CreateFlatCloseButton(view, function()
            professionsView:HideSkillView();
        end);
        closeButton:SetHeight(22);
        closeButton:SetWidth(22);
        closeButton:SetPoint("TOPRIGHT", -12, -8);
        uiService:BindTooltip(closeButton, localeService:Get("CloseTooltip"));

        -- add players frame
        local playersFrame = uiService:CreatePanel(view);
        playersFrame:SetPoint("TOPLEFT", 12, -36);
        playersFrame:SetPoint("BOTTOMRIGHT", view, "BOTTOMLEFT", 222, 42);
        self.playersFrame = playersFrame;

        -- add recipe label
        local recipeLabel = CreateFrame("Button", nil, view);
        recipeLabel:SetPoint("BOTTOMLEFT", 16, 14);
        recipeLabel:SetHeight(14);
        recipeLabel.text = recipeLabel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
        recipeLabel.text:SetPoint("LEFT", 0, 0);
        recipeLabel:SetScript("OnEnter", function()
            if (self.recipeItemLink) then
                GameTooltip:SetOwner(recipeLabel, "ANCHOR_TOPRIGHT");
                GameTooltip:SetHyperlink(self.recipeItemLink);
                GameTooltip:Show();
            end
        end);
        recipeLabel:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
        self.recipeLabel = recipeLabel;

        -- add players label
        local playersLabel = playersFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        playersLabel:SetPoint("TOPLEFT", 13, -12);
        playersLabel:SetText(localeService:Get("SkillViewPlayers"));

        -- add players scroll frame 
        local playerScrollFrame, playerScrollChild, playerScrollElement = uiService:CreateScrollFrame(playersFrame);
        playerScrollFrame:SetPoint("TOPLEFT", 7, -32);
        playerScrollFrame:SetPoint("BOTTOMRIGHT", -7, 5);
        playerScrollChild:SetWidth(playerScrollFrame:GetWidth());
        playerScrollElement:SetScript("OnVerticalScroll", function(_, top)
            self.playerScrollTop = top;
            self:RefreshPlayerRows();
        end);
        self.playerScrollFrame = playerScrollFrame;
        self.playerScrollChild = playerScrollChild;
        self.playerScrollElement = playerScrollElement;

        -- add bucket list frame
        local bucketListFrame = uiService:CreatePanel(view);
        bucketListFrame:SetPoint("TOPLEFT", view, "TOPRIGHT", -252, -36);
        bucketListFrame:SetPoint("BOTTOMRIGHT", -12, 42);
        self.bucketListFrame = bucketListFrame;

        -- add bucket list label
        local bucketListLabel = bucketListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        bucketListLabel:SetPoint("TOPLEFT", 13, -12);
        bucketListLabel:SetText(localeService:Get("SkillViewOnBucketList") .. ":");

        -- add bucket list amount
        local bucketListAmountText = bucketListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        bucketListAmountText:SetPoint("LEFT", bucketListLabel, "RIGHT", 8, 0);
        self.bucketListAmountText = bucketListAmountText;

        -- amount plus button
        local amountPlusButton = uiService:CreateFlatSquareButton(bucketListFrame, "+", function()
            -- update amount by item yield
            local skillInfo = self:GetService("skills"):GetSkillById(self.skillId);
            local itemAmount = (skillInfo and skillInfo.itemAmount) or 1;
            PM_BucketList[self.skillId] = self.bucketListAmount + itemAmount;
            self:RefreshBucketListAmount();
            professionsView:CheckBucketList();

            -- check missing ragents
            self:GetService("inventory"):CheckMissingReagents();
        end, 20);
        amountPlusButton:SetPoint("LEFT", bucketListAmountText, "RIGHT", 10, 0);
        uiService:BindTooltip(amountPlusButton, localeService:Get("SkillViewAddToBucketList"));
        self.amountPlusButton = amountPlusButton;

        -- amount minus button
        local amountMinusButton = uiService:CreateFlatSquareButton(bucketListFrame, "-", function()
            -- update amount by item yield
            local skillInfo = self:GetService("skills"):GetSkillById(self.skillId);
            local itemAmount = (skillInfo and skillInfo.itemAmount) or 1;
            if (self.bucketListAmount <= itemAmount) then
                PM_BucketList[self.skillId] = nil;
            else
                PM_BucketList[self.skillId] = self.bucketListAmount - itemAmount;
            end
            self:RefreshBucketListAmount();
            professionsView:CheckBucketList();

            -- check missing ragents
            self:GetService("inventory"):CheckMissingReagents();
        end, 20);
        amountMinusButton:SetPoint("LEFT", amountPlusButton, "RIGHT", 3, 0);
        uiService:BindTooltip(amountMinusButton, localeService:Get("SkillViewRemoveOneFromBucketList"));
        self.amountMinusButton = amountMinusButton;

        -- add clear button
        local clearButton = uiService:CreateFlatSquareButton(bucketListFrame, "x", function()
            -- update amount
            PM_BucketList[self.skillId] = nil;
            self:RefreshBucketListAmount();
            professionsView:CheckBucketList();

            -- check missing ragents
            self:GetService("inventory"):CheckMissingReagents();
        end, 20);
        clearButton:SetPoint("LEFT", amountMinusButton, "RIGHT", 3, 0);
        uiService:BindTooltip(clearButton, localeService:Get("SkillViewRemoveFromBucketList"));
        self.clearButton = clearButton;

        -- create ok button
        local okButton = uiService:CreateFlatButton(view, localeService:Get("SkillViewOk"), function()
            professionsView:HideSkillView();
        end);
        okButton:SetWidth(100);
        okButton:SetHeight(22);
        okButton:SetPoint("BOTTOMRIGHT", -12, 8);
    end

    -- update item text and skill id
    self.parentSkillRow = skillRow;
    self.skill = skill;
    self.skillId = skillId;
    local skillInfo = self:GetService("skills"):GetSkillById(skillId);
    local itemAmount = skillInfo and skillInfo.itemAmount;
    local titleName = skill.itemColor and ("|c" .. skill.itemColor .. skill.name) or skill.name;
    if (itemAmount and itemAmount > 1) then
        titleName = titleName .. "|r x" .. itemAmount;
    end

    -- append difficulty colors
    if (skillInfo and skillInfo.difficulty) then
        local d = skillInfo.difficulty;
        titleName = titleName .. "|r - "
            .. "|cffff8040" .. d[1] .. "|r "
            .. "|cffffff00" .. d[2] .. "|r "
            .. "|cff40bf40" .. d[3] .. "|r "
            .. "|cff808080" .. d[4] .. "|r";
    end

    self.view.titleLabel:SetText(self.addon.shortcut .. titleName);

    -- update recipe label
    self.recipeItemLink = nil;
    local taughtByText = localeService:Get("SkillViewTaughtBy") .. " ";
    if (skillInfo and skillInfo.recipe and skillInfo.recipe.itemLink) then
        self.recipeItemLink = skillInfo.recipe.itemLink;
        local recipeColor = skillInfo.recipe.itemColor or "FF1EFF00";
        local recipeText = "|c" .. recipeColor .. (skillInfo.recipe.name or "") .. "|r";

        -- append recipe source type if known
        local sourceLabel = self:GetRecipeSourceLabel(skillInfo, localeService);
        if (sourceLabel) then
            recipeText = recipeText .. " |cff999999(" .. sourceLabel .. ")|r";
        end

        self.recipeLabel.text:SetText(taughtByText .. recipeText);
        self.recipeLabel:SetWidth(self.recipeLabel.text:GetStringWidth() + 4);
        self.recipeLabel:Show();
    else
        self.recipeLabel.text:SetText(taughtByText .. localeService:Get("SkillViewTrainer"));
        self.recipeLabel:SetWidth(self.recipeLabel.text:GetStringWidth() + 4);
        self.recipeLabel:Show();
    end

    -- set position
    self.view:ClearAllPoints();
    self.view:SetPoint("CENTER", professionsView.view, "CENTER", 0, 0);

    -- update bucket list amount
    self:RefreshBucketListAmount();

    -- get player names
    local players = skillRow.players or {};
    self.playerNames = self:GetService("player"):CombinePlayerNames(players);
    self.playerScrollChild:SetHeight(#self.playerNames * 20);
    self:RefreshPlayerRows();

    -- show view
    self.view:Show();
end

--- Refresh player rows (pooled).
function SkillView:RefreshPlayerRows()
    -- get services
    local uiService = self:GetService("ui");

    -- get visible range
    local startIndex = math.max(math.floor(self.playerScrollTop / 20) - 1, 1);
    local endIndex = math.min(startIndex + 25, #self.playerNames);
    local visibleCount = math.max(endIndex - startIndex + 1, 0);

    -- ensure pool has enough frames
    if (not self.playerRowPool) then
        self.playerRowPool = {};
    end
    while (#self.playerRowPool < visibleCount) do
        local poolIndex = #self.playerRowPool + 1;
        local row = CreateFrame("Button", nil, self.playerScrollChild, BackdropTemplateMixin and "BackdropTemplate");
        row:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]]
        });

        -- add name text
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        nameText:SetPoint("TOPLEFT", 6, -4);
        nameText:SetPoint("BOTTOMRIGHT", -6, -3);
        nameText:SetJustifyH("LEFT");
        nameText:SetJustifyV("TOP");
        row.nameText = nameText;

        self.playerRowPool[poolIndex] = row;
    end

    -- hide all pooled frames
    for _, row in ipairs(self.playerRowPool) do
        row:Hide();
    end

    -- bind pool frames to visible data
    for i = 0, visibleCount - 1 do
        local rowIndex = startIndex + i;
        local row = self.playerRowPool[i + 1];

        -- set background color by data index
        uiService:SetRowColor(row, rowIndex);

        -- position
        local top = (rowIndex - 1) * 20;
        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", self.playerScrollChild, "TOPLEFT", 0, -top);
        row:SetPoint("BOTTOMRIGHT", self.playerScrollChild, "TOPRIGHT", -28, -(top + 20));

        -- set text and show
        row.nameText:SetText(self.playerNames[rowIndex]);
        row:Show();
    end
end

-- Update bucket list amount.
function SkillView:RefreshBucketListAmount()
    -- get amount and set amount text
    self.bucketListAmount = PM_BucketList[self.skillId] or 0;
    self.bucketListAmountText:SetText(self.bucketListAmount);

    -- set width
    if (self.bucketListAmount >= 100) then
        self.bucketListAmountText:SetWidth(26);
    elseif (self.bucketListAmount >= 10) then
        self.bucketListAmountText:SetWidth(18);
    else
        self.bucketListAmountText:SetWidth(10);
    end

    -- set button visiblity
    if (self.bucketListAmount > 0) then
        self.amountMinusButton:Show();
        self.clearButton:Show();
    else
        self.amountMinusButton:Hide();
        self.clearButton:Hide();
    end

    -- hide rows
    for _, row in ipairs(self.reagentRows) do
        row:Hide();
    end

    -- get skills service
    local skillsService = self:GetService("skills");

    -- get all skills
    local skillInfo = skillsService:GetSkillById(self.skillId);
    if (not skillInfo) then
        return;
    end

    -- get service
    local professionNamesService = self:GetService("profession-names");

    -- scan inventory
    local inventoryService = self:GetService("inventory");
    inventoryService:ScanInventory();

    -- show reagents
    local rowAmount = 0;
    if (not skillInfo.reagents) then return; end
    for reagentItemId, reagentAmount in pairs(skillInfo.reagents) do
        rowAmount = rowAmount + 1;
        if (#self.reagentRows < rowAmount) then
            -- create row frame
            local row = CreateFrame("Button", nil, self.bucketListFrame, BackdropTemplateMixin and "BackdropTemplate");
            local top = 36 + ((rowAmount - 1) * 20);
            row:SetPoint("TOPLEFT", self.bucketListFrame, "TOPLEFT", 10, -top);
            row:SetPoint("BOTTOMRIGHT", self.bucketListFrame, "TOPRIGHT", -10, -(top + 20));
            row:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]]
            });

            -- set background color by index
            local backgroundColor = nil;
            if (rowAmount - math.floor(rowAmount / 2) * 2 == 0) then
                backgroundColor = 0.1;
            else
                backgroundColor = 0.15;
            end
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

            -- bind row mouse events
            row:SetScript("OnLeave", function()
                -- update background color
                row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.8);

                -- hide item tool tip
                GameTooltip:Hide();
            end);
            row:SetScript("OnEnter", function()
                -- update background color
                row:SetBackdropColor(0.2, 0.2, 0.2);

                -- show item tool tip
                GameTooltip:SetOwner(row, "ANCHOR_LEFT");
                if row.itemLink then GameTooltip:SetHyperlink(row.itemLink); end
                GameTooltip:Show();
            end);

            -- add icon text
            local iconText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            iconText:SetPoint("TOPLEFT", 3, -3);
            row.iconText = iconText;

            -- add amount text
            local amountText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            amountText:SetPoint("TOPRIGHT", -3, -4);
            amountText:SetJustifyH("RIGHT");
            row.amountText = amountText;

            -- add item text
            local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("TOPLEFT", 24, -4);
            itemText:SetPoint("BOTTOMRIGHT", amountText, "BOTTOMLEFT", -8, 0);
            itemText:SetJustifyH("LEFT");
            itemText:SetJustifyV("TOP");
            row.itemText = itemText;

            -- add row
            table.insert(self.reagentRows, row);
        end

        -- get row
        local row = self.reagentRows[rowAmount];
        row:Show();

        -- update amount
        local inventoryAmount = inventoryService:GetItemAmount(reagentItemId);
        local requiredAmount = self.bucketListAmount * reagentAmount;
        if (requiredAmount > 0) then
            row.amountText:SetText(math.min(inventoryAmount, requiredAmount) .. "/" .. requiredAmount);
        else
            row.amountText:SetText(reagentAmount);
        end
        
        -- set if amount required
        if (requiredAmount > 0 and inventoryAmount >= requiredAmount) then
            row.amountText:SetTextColor(0, 1, 0);
        else
            row.amountText:SetTextColor(1, 1, 1);
        end

        -- check if item id known
        if (C_Item.DoesItemExistByID(reagentItemId)) then
            -- get item
            local item = Item:CreateFromItemID(reagentItemId);
            if (not item:IsItemEmpty()) then
                pcall(function() 
                    -- wait until loaded
                    item:ContinueOnItemLoad(function()
                        -- update item
                        row.itemLink = item:GetItemLink();
                        row.iconText:SetText("|T" .. item:GetItemIcon() .. ":16|t");
                        row.itemText:SetText("|c" .. professionNamesService:GetItemColor(row.itemLink) .. item:GetItemName());
                    end);
                end);
            end
        end
    end
end

-- Hide view.
function SkillView:Hide()
    if (self.view) then
        self.view:Hide();
    end
end

--- Get a localized label for the recipe source type, including source name if available.
function SkillView:GetRecipeSourceLabel(skillInfo, localeService)
    if (not skillInfo) then return nil; end
    local source = skillInfo.recipeSource;
    if (not source) then return nil; end

    local sourceLabel = nil;
    if (source == "V") then sourceLabel = localeService:Get("SkillViewVendor"); end
    if (source == "D") then sourceLabel = localeService:Get("SkillViewDrop"); end
    if (source == "W") then sourceLabel = localeService:Get("SkillViewWorldDrop"); end
    if (source == "Q") then sourceLabel = localeService:Get("SkillViewQuest"); end

    if (sourceLabel and skillInfo.recipeSourceName) then
        sourceLabel = sourceLabel .. ": " .. skillInfo.recipeSourceName;
    end

    return sourceLabel;
end