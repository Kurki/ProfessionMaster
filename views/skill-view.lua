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

-- define view
SkillView = {};
SkillView.__index = SkillView;

--- Show professions view.
-- @param skillRow Skill row.
function SkillView:Show(skillRow, professionsView)
    -- get services
    local uiService = addon:GetService("ui");
    local localeService = addon:GetService("locale");

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
        local closeButton = CreateFrame("Button", nil, view, "UIPanelCloseButton");
        closeButton:SetHeight(24);
        closeButton:SetWidth(24);
        closeButton:SetPoint("TOPRIGHT", -5, -7);
        closeButton:SetScript("OnClick", function()
            professionsView:HideSkillView();
        end);

        -- add players frame
        local playersFrame = CreateFrame("Frame", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        playersFrame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface/Buttons/WHITE8X8]],
            edgeSize = 1
        });
        playersFrame:SetBackdropColor(0, 0, 0, 0.5);
        playersFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
        playersFrame:SetPoint("TOPLEFT", 12, -36);
        playersFrame:SetPoint("BOTTOMRIGHT", view, "BOTTOMLEFT", 222, 40);
        self.playersFrame = playersFrame;

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
        local bucketListFrame = CreateFrame("Frame", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        bucketListFrame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface/Buttons/WHITE8X8]],
            edgeSize = 1
        });
        bucketListFrame:SetBackdropColor(0, 0, 0, 0.5);
        bucketListFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
        bucketListFrame:SetPoint("TOPLEFT", view, "TOPRIGHT", -252, -36);
        bucketListFrame:SetPoint("BOTTOMRIGHT", -12, 40);
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
        local amountPlusButton = CreateFrame("Button", nil, bucketListFrame);
        amountPlusButton:SetHeight(20);
        amountPlusButton:SetWidth(20);
        amountPlusButton:SetPoint("LEFT", bucketListAmountText, "RIGHT", 10, 0);
        amountPlusButton:SetPushedTexture("Interface\\Buttons\\UI-AttributeButton-Encourage-Down");
        amountPlusButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
        amountPlusButton:SetNormalTexture("Interface\\Buttons\\UI-AttributeButton-Encourage-Up");
        amountPlusButton:SetScript("OnClick", function()
            -- update amount
            BucketList[self.skillId] = self.bucketListAmount + 1;
            self:RefreshBucketListAmount();
            professionsView:CheckBucketList();

            -- check missing ragents
            addon:GetService("inventory"):CheckMissingReagents();
        end);
        self.amountPlusButton = amountPlusButton;

        -- amount minus button
        local amountMinusButton = CreateFrame("Button", nil, bucketListFrame);
        amountMinusButton:SetHeight(20);
        amountMinusButton:SetWidth(20);
        amountMinusButton:SetPoint("LEFT", amountPlusButton, "RIGHT", 3, 0);
        amountMinusButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down");
        amountMinusButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
        amountMinusButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
        amountMinusButton:SetScript("OnClick", function()
            -- update amount
            if (self.bucketListAmount <= 1) then
                BucketList[self.skillId] = nil;
            else
                BucketList[self.skillId] = self.bucketListAmount - 1;
            end
            self:RefreshBucketListAmount();
            professionsView:CheckBucketList();

            -- check missing ragents
            addon:GetService("inventory"):CheckMissingReagents();
        end);
        self.amountMinusButton = amountMinusButton;

        -- add clear button
        local clearButton = CreateFrame("Button", nil, bucketListFrame);
        clearButton:SetHeight(32);
        clearButton:SetWidth(32);
        clearButton:SetPoint("LEFT", amountMinusButton, "RIGHT", -5, -1.5);
        clearButton:SetPushedTexture("Interface\\Buttons\\CancelButton-Down");
        clearButton:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight");
        clearButton:SetNormalTexture("Interface\\Buttons\\CancelButton-Up");
        clearButton:SetScript("OnClick", function()
            -- update amount
            BucketList[self.skillId] = nil;
            self:RefreshBucketListAmount();
            professionsView:CheckBucketList();

            -- check missing ragents
            addon:GetService("inventory"):CheckMissingReagents();
        end);
        self.clearButton = clearButton;

        -- create ok button
        local okButton = uiService:CreateButton(view, localeService:Get("SkillViewOk"), function()
            professionsView:HideSkillView();
        end);
        okButton:SetWidth(100);
        okButton:SetHeight(27);
        okButton:SetPoint("BOTTOMRIGHT", -10, 8);
    end

    -- update item text and skill id
    self.parentSkillRow = skillRow;
    self.skill = skill;
    self.skillId = skillId;
    self.view.titleLabel:SetText(addon.shortcut .. (skill.itemColor and ("|c" .. skill.itemColor .. skill.name) or skill.name));

    -- set position
    self.view:ClearAllPoints();
    self.view:SetPoint("CENTER", professionsView.view, "CENTER", 0, 0);

    -- update bucket list amount
    self:RefreshBucketListAmount();

    -- invalidate all player rows
    for index, row in pairs(self.playerRows) do
        -- set invalid an hide
        row.invalid = true;
        row:Hide();
    end

    -- get player names
    self.playerNames = addon:GetService("player"):CombinePlayerNames(skill.players);
    self.playerScrollChild:SetHeight(#self.playerNames * 20);
    self:RefreshPlayerRows();

    -- show view
    self.view:Show();
end

--- Refresh palyer rows.
function SkillView:RefreshPlayerRows() 
    -- get start and end index
    local startIndex = math.max(math.floor(self.playerScrollTop / 20) - 1, 1);
    local endIndex = math.min(startIndex + 25, #self.playerNames);
    local newRow = false;

    -- iterate rows
    for rowIndex = startIndex, endIndex do
        -- get row 
        local row = self.playerRows[rowIndex];

        -- check if frame crated
        if (not row) then
            -- create row frame
            newRow = true;
            row = CreateFrame("Button", nil, self.playerScrollChild, BackdropTemplateMixin and "BackdropTemplate");
            local top = (rowIndex - 1) * 20;
            row:SetPoint("TOPLEFT", self.playerScrollChild, "TOPLEFT", 0, -top);
            row:SetPoint("BOTTOMRIGHT", self.playerScrollChild, "TOPRIGHT", -28, -(top + 20));
            row:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]]
            });
            self.playerRows[rowIndex] = row;

            -- set background color by index
            local backgroundColor = nil;
            if (rowIndex - math.floor(rowIndex / 2) * 2 == 0) then
                backgroundColor = 0.1;
            else
                backgroundColor = 0.15;
            end
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

            -- add name text
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            nameText:SetPoint("TOPLEFT", 6, -4);
            nameText:SetPoint("BOTTOMRIGHT", -6, -3);
            nameText:SetJustifyH("LEFT");
            nameText:SetJustifyV("TOP");
            row.nameText = nameText;
        end

        -- check if new or invalid
        if (newRow or row.invalid) then
            row.nameText:SetText(self.playerNames[rowIndex]);
            row:Show();
        end
    end
end

-- Update bucket list amount.
function SkillView:RefreshBucketListAmount()
    -- get amount and set amount text
    self.bucketListAmount = BucketList[self.skillId] or 0;
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

    -- get all skills
    local skillInfo = addon:GetModel("all-skills")[self.skillId];
    if (not skillInfo) then
        return;
    end

    -- get service
    local professionNamesService = addon:GetService("profession-names");

    -- scan inventory
    local inventoryService = addon:GetService("inventory");
    inventoryService:ScanInventory();

    -- show reagents
    local rowAmount = 0;
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
                GameTooltip:SetHyperlink(row.itemLink);
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
        row = self.reagentRows[rowAmount];
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

        -- get item
        local item = Item:CreateFromItemID(reagentItemId);
        if (not item:IsItemEmpty()) then
            -- wait until loaded
            item:ContinueOnItemLoad(function()
                -- update item
                row.itemLink = item:GetItemLink();
                row.iconText:SetText("|T" .. item:GetItemIcon() .. ":16|t");
                row.itemText:SetText("|c" .. professionNamesService:GetItemColor(row.itemLink) .. item:GetItemName());
            end);
        end
    end
end

-- Hide view.
function SkillView:Hide()
    if (self.view) then
        self.view:Hide();
    end
end

-- register view
addon:RegisterView(SkillView, "skill-view");