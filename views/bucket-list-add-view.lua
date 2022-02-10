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
BucketListAddView = {};
BucketListAddView.__index = BucketListAddView;

--- Show professions view.
-- @param skillRow Skill row.
function BucketListAddView:Show(skillRow, professionsView)
    -- get services
    local uiService = addon:GetService("ui");
    local localeService = addon:GetService("locale");

    -- get skilla nd skill id
    local skill = skillRow.skill;
    local skillId = skillRow.skillId;

    -- check if view created
    if (self.view == nil) then
        -- create view
        local view = uiService:CreateView("PmBucketListAdd", 360, 140, localeService:Get("BucketListAddViewTitle"));
        view:EnableKeyboard();
        self.view = view;
        self.rows = {};

        -- add amount item label
        local itemLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        itemLabel:SetTextColor(1, 1, 1);
        itemLabel:SetPoint("TOPLEFT", 16, -50);
        itemLabel:SetText(localeService:Get("BucketListAddViewItem") .. ":");

        -- add itemText
        local itemText = view:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        itemText:SetTextColor(1, 1, 1);
        itemText:SetPoint("TOPLEFT", 100, -50);
        self.itemText = itemText;

        -- add amount input label
        local amountInputLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        amountInputLabel:SetTextColor(1, 1, 1);
        amountInputLabel:SetPoint("TOPLEFT", 16, -80);
        amountInputLabel:SetText(localeService:Get("BucketListAddViewAmount") .. ":");

        -- add amount input
        local amountInput = uiService:CreateNumberEditBox(view, 40);
        amountInput:SetPoint("TOPLEFT", 100, -76);
        amountInput.text:SetScript("OnTextChanged", function()
            -- refresh reagents
            self:RefreshReagents();
        end);
        self.amountInput = amountInput;

        -- amount plus button
        local amountPlusButton = CreateFrame("Button", nil, view);
        amountPlusButton:SetHeight(16);
        amountPlusButton:SetWidth(16);
        amountPlusButton:SetPoint("TOPLEFT", 152, -78);
        amountPlusButton:SetPushedTexture("Interface\\Buttons\\UI-AttributeButton-Encourage-Down");
        amountPlusButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
        amountPlusButton:SetNormalTexture("Interface\\Buttons\\UI-AttributeButton-Encourage-Up");
        amountPlusButton:SetScript("OnClick", function()
            -- increase amount
            local amount = tonumber(self.amountInput.text:GetText());
            self.amountInput.text:SetText(amount + 1);
            self.amountMinusButton:SetEnabled(true);
        end);
        self.amountPlusButton = amountPlusButton;

        -- amount minus button
        local amountMinusButton = CreateFrame("Button", nil, view);
        amountMinusButton:SetHeight(16);
        amountMinusButton:SetWidth(16);
        amountMinusButton:SetPoint("TOPLEFT", 171, -78);
        amountMinusButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down");
        amountMinusButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
        amountMinusButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
        amountMinusButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled");
        amountMinusButton:SetScript("OnClick", function()
            -- decrease amount
            local amount = tonumber(self.amountInput.text:GetText());
            if (amount > 1) then
                self.amountInput.text:SetText(amount - 1);
            end
            self.amountMinusButton:SetEnabled(amount > 2);
        end);
        self.amountMinusButton = amountMinusButton;

        -- add reagents label
        local reagentsLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        reagentsLabel:SetTextColor(1, 1, 1);
        reagentsLabel:SetPoint("TOPLEFT", 16, -110);
        reagentsLabel:SetText(localeService:Get("BucketListAddViewReagents") .. ":");

        -- create delete button
        local deleteButton = uiService:CreateButton(self.view, "", function()
            -- clear amount
            BucketList[self.skillId] = nil;
            self.parentSkillRow.bucketListText:SetText(nil);
            professionsView:HideBucketList();
        end);
        deleteButton:SetPoint("BOTTOMLEFT", 16, 10);
        deleteButton:SetWidth(26);
        deleteButton:SetHeight(26);
        self.deleteButton = deleteButton;

        -- add delet ebutton icon glow
        local deleteButtonIcon = deleteButton:CreateTexture(nil, "ARTWORK");
        deleteButtonIcon:SetPoint("TOPLEFT", 5, -5);
        deleteButtonIcon:SetWidth(16);
        deleteButtonIcon:SetHeight(16);
        deleteButtonIcon:SetTexture("Interface/Buttons/UI-GroupLoot-Pass-Down");

        -- create add button
        local addButton = uiService:CreateButton(self.view, "", function()
            -- get amount
            local amount = tonumber(self.amountInput.text:GetText());

            -- check if is in bucket list
            BucketList[self.skillId] = amount;

            -- update amount and close dialog
            self.parentSkillRow.bucketListText:SetText(BucketList[self.skillId]);
            professionsView:HideBucketList();
        end);
        addButton:SetPoint("BOTTOMRIGHT", -16, 10);
        addButton:SetWidth(100);
        addButton:SetHeight(26);
        self.addButton = addButton;
    end

    -- update item text and skill id
    self.parentSkillRow = skillRow;
    self.skill = skill;
    self.skillId = skillId;
    self.itemText:SetText("|T" .. skill.icon .. ":16|t " .. (skill.itemColor and ("|c" .. skill.itemColor .. skill.name) or skill.name));

    -- set position
    self.view:ClearAllPoints();
    self.view:SetPoint("CENTER", professionsView.view, "CENTER", 0, 0);

    -- get bucket list amount
    local bucketListAmount = BucketList[skillId];
    if (bucketListAmount) then
        self.addButton:SetText(localeService:Get("BucketListAddViewChange"));
        self.deleteButton:Show();
    else
        self.addButton:SetText(localeService:Get("BucketListAddViewAdd"));
        self.deleteButton:Hide();
    end

    -- set value
    self.amountInput.text:SetText(bucketListAmount or 1);
    self.amountMinusButton:SetEnabled(bucketListAmount and bucketListAmount > 1);

    -- refresh reagents
    self:RefreshReagents();

    -- show view
    self.view:Show();
end

-- Update amount.
function BucketListAddView:RefreshReagents()
    -- get amount
    local amount = tonumber(self.amountInput.text:GetText());
    if (not amount or amount < 1) then
        return;
    end

    -- get reagents
    local reagents = addon:GetModel("profession-reagents")[self.skillId];
    if (not reagents) then
        return;
    end

    -- hide rows
    for _, row in ipairs(self.rows) do
        row:Hide();
    end

    -- get service
    local professionNamesService = addon:GetService("profession-names");

    -- show materials
    local rowAmount = 0;
    for reagentItemId, reagentAmount in pairs(reagents) do
        rowAmount = rowAmount + 1;
        if (#self.rows < rowAmount) then
            -- create row frame
            local row = CreateFrame("Button", nil, self.view, BackdropTemplateMixin and "BackdropTemplate");
            local top = 130 + ((rowAmount - 1) * 20);
            row:SetPoint("TOPLEFT", self.view, "TOPLEFT", 16, -top);
            row:SetPoint("BOTTOMRIGHT", self.view, "TOPRIGHT", -16, -(top + 20));
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
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.4);

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

            -- add amount text
            local amountText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            amountText:SetPoint("TOPLEFT", 0, -4);
            amountText:SetWidth(30);
            amountText:SetJustifyH("RIGHT");
            row.amountText = amountText;

            -- add icon text
            local iconText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            iconText:SetPoint("TOPLEFT", 40, -3);
            row.iconText = iconText;

            -- add item text
            local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("TOPLEFT", 62, -4);
            itemText:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, -3);
            itemText:SetJustifyH("LEFT");
            itemText:SetJustifyV("TOP");
            row.itemText = itemText;

            -- add row
            table.insert(self.rows, row);
        end

        -- get row
        row = self.rows[rowAmount];
        row:Show();

        -- update amount
        row.amountText:SetText(amount * reagentAmount);

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

        row.amountText:SetText(amount * reagentAmount);
    end

    -- set view height
    self.view:SetHeight(174 + (rowAmount * 20));
end

-- Hide view.
function BucketListAddView:Hide()
    if (self.view) then
        self.view:Hide();
    end
end

-- register view
addon:RegisterView(BucketListAddView, "bucket-list-add");