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
ProfessionsView = {};
ProfessionsView.__index = ProfessionsView;

--- Show professions view.
function ProfessionsView:Show()
    -- get services
    local uiService = addon:GetService("ui");
    local localeService = addon:GetService("locale");

    -- check if view created
    if (self.view == nil) then
        -- prepare visible skill frames
        self.rows = {};
        self.bucketListReagentRows = {};
        self.skills = {};
        self.professionId = nil;
        self.skillView = addon:CreateView("skill-view");
        self.scrollTop = 0;

        -- create view
        local view = uiService:CreateView("PmProfessions", 1000, 540, localeService:Get("ProfessionsViewTitle"));
        view:EnableKeyboard();
        view:SetScript("OnKeyDown", function(_, key)
            -- check escape
            if (key == "ESCAPE") then
                if (self.skillViewVisible) then
                    self:HideSkillView();
                else
                    self:Hide();
                end
            elseif (key == "ENTER") then
                ChatFrame_OpenChat("", nil, nil);
            end
        end)
        self.view = view;

        -- add close button
        local closeButton = CreateFrame("Button", nil, view, "UIPanelCloseButton");
        closeButton:SetHeight(24);
        closeButton:SetWidth(24);
        closeButton:SetPoint("TOPRIGHT", -5, -7);
        closeButton:SetScript("OnClick", function()
            self:Hide();
        end);

        -- get profession ids
        local professionIds = addon:GetService("profession-names"):GetProfessionIdsToShow();

        -- add skills frame
        local skillsFrame = CreateFrame("Frame", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        skillsFrame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface/Buttons/WHITE8X8]],
            edgeSize = 1
        });
        skillsFrame:SetBackdropColor(0, 0, 0, 0.5);
        skillsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
        skillsFrame:SetPoint("TOPLEFT", 12, -36);
        skillsFrame:SetPoint("BOTTOMRIGHT", -12, 30);
        self.skillsFrame = skillsFrame;

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
        bucketListFrame:SetPoint("BOTTOMRIGHT", -12, 30);
        self.bucketListFrame = bucketListFrame;

        -- add footer
        local footerLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft");
        footerLabel:SetPoint("BOTTOMLEFT", 16, 10);
        footerLabel:SetText(localeService:Get("ProfessionsViewFooter"));

        -- add bucket list group text
        local bucketListTitleText = bucketListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        bucketListTitleText:SetPoint("TOPLEFT", 13, -15);
        bucketListTitleText:SetText(localeService:Get("ProfessionsViewReagentsForBucketList"));

        -- add bucket list clear button
        local bucketListClearButton = CreateFrame("Button", nil, bucketListFrame);
        bucketListClearButton:SetHeight(32);
        bucketListClearButton:SetWidth(32);
        bucketListClearButton:SetPoint("TOPRIGHT", -4, -7);
        bucketListClearButton:SetPushedTexture("Interface\\Buttons\\CancelButton-Down");
        bucketListClearButton:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight");
        bucketListClearButton:SetNormalTexture("Interface\\Buttons\\CancelButton-Up");
        bucketListClearButton:SetScript("OnClick", function()
            -- clear and refresh bucket list
            BucketList = {};
            self:CheckBucketList();
            addon:GetService("inventory"):CheckMissingReagents();
        end);

        -- add item search box
        local itemSearchLabel = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        itemSearchLabel:SetPoint("TOPLEFT", 18, -15);
        itemSearchLabel:SetText(localeService:Get("ProfessionsViewSearch"));
        local itemSearch = CreateFrame("EditBox", nil, skillsFrame, "InputBoxTemplate");
        itemSearch:SetPoint("TOPLEFT", 22, -33);
        itemSearch:SetPoint("BOTTOMRIGHT", skillsFrame, "TOPRIGHT", -332, -56);
        itemSearch:SetAutoFocus(false);
        self.itemSearch = itemSearch;
        itemSearch:SetScript("OnKeyDown", function(_, key)
            -- check escape
            if (key == "ESCAPE") then
                if (self.skillViewVisible) then
                    self:HideSkillView();
                else
                    self:Hide();
                end
            elseif (key == "ENTER") then
                ChatFrame_OpenChat("", nil, nil);
            end
        end)
        itemSearch:SetScript("OnTextChanged", function()
            -- add skills and hide bucket list
            self:AddSkills();
        end);
        
        -- add profession selection
        local professionLabel = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        professionLabel:SetPoint("TOPLEFT", 404, -15);
        professionLabel:SetText(localeService:Get("ProfessionsViewProfession"));
        local professionSelection = CreateFrame("Frame", nil, skillsFrame, "UIDropDownMenuTemplate");
        professionSelection:ClearAllPoints();
        professionSelection:SetPoint("TOPRIGHT", -153, -31);
        UIDropDownMenu_SetWidth(professionSelection, 140);
        self.professionSelection = professionSelection;
        UIDropDownMenu_Initialize(professionSelection, function()
            -- create item
            local item = UIDropDownMenu_CreateInfo();
            item.notCheckable = true;
            item.func = function(_self, professionId, arg2)
                -- select profession
                self:SelectProfession(professionId);
                self.itemSearch:SetFocus();

                -- add skills
                self:AddSkills();
            end;

            -- add all date
            item.text, item.arg1 = self:GetProfessionText(0), 0;
            UIDropDownMenu_AddButton(item);

            -- add dates
            for i, professionId in ipairs(professionIds) do
                item.text, item.arg1 = self:GetProfessionText(professionId), professionId;
                UIDropDownMenu_AddButton(item);
            end
        end);

        -- add addon selection
        local addonLabel = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        addonLabel:SetPoint("TOPRIGHT", -120, -15);
        addonLabel:SetText(localeService:Get("ProfessionsViewAddon"));
        local addonSelection = CreateFrame("Frame", nil, skillsFrame, "UIDropDownMenuTemplate");
        addonSelection:ClearAllPoints();
        addonSelection:SetPoint("TOPRIGHT", -20, -31);
        UIDropDownMenu_SetWidth(addonSelection, 110);
        self.addonSelection = addonSelection;
        UIDropDownMenu_Initialize(addonSelection, function()
            -- create item
            local item = UIDropDownMenu_CreateInfo();
            item.notCheckable = true;
            item.func = function(_self, addonId, arg2)
                -- select addon
                self:SelectAddon(addonId);
                self.itemSearch:SetFocus();

                -- add skills
                self:AddSkills();
            end;

            -- add all date
            item.text, item.arg1 = self:GetAddonText(nil), nil;
            UIDropDownMenu_AddButton(item);

            -- add dates
            for addonId = 0, 2, 1 do
                item.text, item.arg1 = self:GetAddonText(addonId), addonId;
                UIDropDownMenu_AddButton(item);
            end
        end);

        -- add bucket list icon
        local bucketListIcon = skillsFrame:CreateTexture(nil, "OVERLAY");
        bucketListIcon:SetSize(16, 16);
        bucketListIcon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up"); 
        bucketListIcon:SetPoint("TOPLEFT", skillsFrame, "TOPRIGHT", -56, -67);

        -- add skill text
        local skillText = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        skillText:SetPoint("TOPLEFT", 22, -69);
        self.skillText = skillText;

        -- add player text
        local playerText = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        playerText:SetPoint("TOPLEFT", 332, -69);
        playerText:SetText(localeService:Get("ProfessionsViewPlayers"));

        -- create scroll frame 
        local scrollFrame, scrollChild, scrollElement = uiService:CreateScrollFrame(skillsFrame);
        scrollFrame:SetPoint("TOPLEFT", 10, -82);
        scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12);
        scrollElement:SetScript("OnVerticalScroll", function(_, top)
            self.scrollTop = top;
            self:RefreshRows();
        end);
        self.scrollFrame = scrollFrame;
        self.scrollChild = scrollChild;
        self.scrollElement = scrollElement;

        -- add bucket list group text
        local bucketListGroupText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        bucketListGroupText:SetPoint("TOPLEFT", 4, -6);
        bucketListGroupText:SetText(localeService:Get("ProfessionsViewBucketList"));
        bucketListGroupText:SetFont("Fonts\\FRIZQT__.TTF", 10);
        self.bucketListGroupText = bucketListGroupText;

        -- add bucket other items text
        local otherGroupText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        otherGroupText:SetText(localeService:Get("ProfessionsViewNotOnBucketList"));
        otherGroupText:SetFont("Fonts\\FRIZQT__.TTF", 10);
        self.otherGroupText = otherGroupText;

        -- add skill view background
        local skillViewBackground = CreateFrame("Button", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        skillViewBackground:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]]
        });
        skillViewBackground:SetBackdropColor(0, 0, 0, 0.8);
        skillViewBackground:SetPoint("TOPLEFT", 1, -1);
        skillViewBackground:SetPoint("BOTTOMRIGHT", -1, 1);
        skillViewBackground:Hide();
        self.skillViewBackground = skillViewBackground;

        -- select first profession
        self:SelectProfession(Settings.lastProfession or 0);
        self:SelectAddon(Settings.lastAddon);
    end

    -- hide skill view
    self:HideSkillView(true);
    self:CheckBucketList();

    -- select first profession
    self.itemSearch:SetFocus();

    -- show view
    self.view:Show();
    self.visible = true;
end

--- Check bucket list.
function ProfessionsView:CheckBucketList()
    -- check view
    if (not self.view) then
        return;
    end
    
    -- check bucket list has values
    local hasBucketList = false;
    for _ in pairs(BucketList) do
        hasBucketList = true;
        break;
    end

    -- Check bucket list
    if (hasBucketList) then
        self.skillsFrame:SetPoint("BOTTOMRIGHT", -260, 30);
        self.bucketListFrame:Show();
    else
        self.skillsFrame:SetPoint("BOTTOMRIGHT", -12, 30);
        self.bucketListFrame:Hide();
    end
    self.scrollChild:SetWidth(self.scrollFrame:GetWidth());

    -- Refresh bucket list rows
    self:RefreshBucketListRows();
end

--- Show skill view.
function ProfessionsView:ShowSkillView(row)
     -- show bucket list add view
     self.skillViewBackground:Show();
     self.skillViewBackground:SetFrameLevel(2000);
     self.skillView:Show(row, self);
     self.skillView.view:SetFrameLevel(2001);
     self.skillViewVisible = true;
end

--- Hide kill view.
function ProfessionsView:HideSkillView(supressLoading)
    self.skillViewBackground:Hide();
    self.skillView:Hide();
    self.skillViewVisible = false;

    if (not supressLoading) then
        self:AddSkills();
    end
end

--- Hide professions view.
function ProfessionsView:Hide()
    -- hide view
    if (self.view) then
        self:HideSkillView();
        self.view:Hide();
    end
    self.visible = false;
end

--- Toggle visibility.
function ProfessionsView:ToggleVisibility()
    -- show view if not visible
    if (not self.visible) then
        self:Show();
        return;
    end

    -- hide view if visible
    self:Hide();
end

--- Get Text of profession.
function ProfessionsView:GetProfessionText(professionId)
    -- check if all selected
    if (professionId == 0) then
        return "|T133745:16|t " .. addon:GetService("locale"):Get("ProfessionsViewAllProfessions");
    end

    -- get icon and name of profession
    local service = addon:GetService("profession-names");
    return "|T" .. service:GetProfessionIcon(professionId) .. ":16|t  " .. service:GetProfessionName(professionId);
end

--- Select profession.
function ProfessionsView:SelectProfession(professionId)
    -- set profession id
    self.professionId = professionId;
    Settings.lastProfession = professionId;

    -- select dropdown
    UIDropDownMenu_SetText(self.professionSelection, self:GetProfessionText(professionId));
end

--- Get Text of addon.
function ProfessionsView:GetAddonText(addonId)
    -- check classic
    if (addonId == 0) then
        return "|T135954:16|t Classic";
    end
    
    -- check classic
    if (addonId == 1) then
        return "|T135804:16|t TBC";
    end
    
    -- check wotlk
    if (addonId == 2) then
        return "|T135773:16|t WOTLK";
    end

    -- use all addons
    return "|T135749:16|t " .. addon:GetService("locale"):Get("ProfessionsViewAllAddons");
end

--- Select addon.
function ProfessionsView:SelectAddon(addonId)
    -- set addon id
    self.addonId = addonId;
    Settings.lastAddon = addonId;

    -- select dropdown
    UIDropDownMenu_SetText(self.addonSelection, self:GetAddonText(addonId));
end

--- Add skills.
function ProfessionsView:AddSkills()
    -- get services
    local messageService = addon:GetService("message");
    local localeService = addon:GetService("locale");

    -- set skill text
    if (self.professionId == 333) then
        self.skillText:SetText(localeService:Get("ProfessionsViewEnchantment"));
    else
        self.skillText:SetText(localeService:Get("ProfessionsViewItem"));
    end

    -- get search parts
    local searchText = string.lower(messageService:TrimString(self.itemSearch:GetText()));
    local searchParts = messageService:SplitString(string.gsub(searchText, "%-", "%%-"), " ");
    for i, part in ipairs(searchParts) do
        searchParts[i] = messageService:TrimString(searchParts[i]);
    end

    -- check professions
    self.skills = {};
    
    -- check if all should be shown
    self.bucketListSkillAmount = 0;
    if (self.professionId == 0) then
        -- get profession ids
        local professionIds = addon:GetService("profession-names"):GetProfessionIdsToShow();
        for i, professionId in ipairs(professionIds) do
            self:AddFilteredSkills(professionId, self.addonId, searchParts);    
        end
    else
        self:AddFilteredSkills(self.professionId, self.addonId, searchParts);
    end

    -- sort skills
    table.sort(self.skills, function(a, b)
        if (a.bucketListAmount and not b.bucketListAmount) then
            return true;
        end

        if (not a.bucketListAmount and b.bucketListAmount) then
            return false;
        end

        return a.skill.name < b.skill.name;
    end);

    -- set bucket list group text visibility
    if (self.bucketListSkillAmount > 0) then
        self.bucketListGroupText:Show();
        if (self.bucketListSkillAmount < #self.skills) then
            self.otherGroupText:SetPoint("TOPLEFT", 4, -(self.bucketListSkillAmount * 20 + 26));
            self.otherGroupText:Show();
        else
            self.otherGroupText:Hide();
        end
    else
        self.bucketListGroupText:Hide();
        self.otherGroupText:Hide();
    end

    -- set scroll height
    self.scrollChild:SetHeight(#self.skills * 20 + (self.bucketListSkillAmount > 0 and 40 or 0));

    -- invalidate all rows
    for index, row in pairs(self.rows) do
        -- set invalid an hide
        row.invalid = true;
        row:Hide();
    end

    -- refresh rows
    self:RefreshRows();
end

--- Add filtered skills.
function ProfessionsView:AddFilteredSkills(professionId, addonId, searchParts)
    -- get profession and all skills
    local profession = Professions[professionId];
    local allSkills = addon:GetModel("all-skills");

    -- filter skills
    if (profession) then
        for skillId, skill in pairs(profession) do
            -- check if skill ok
            if (skill.name ~= nil and skill.itemId ~= nil) then
                -- get skill info
                local skillInfo = allSkills[skillId];
                if ((not skillInfo) or addonId == nil or addonId == skillInfo.addon) then
                    -- get bucket list amount
                    local bucketListAmount = BucketList[skillId];

                    -- check if has search parts
                    if (#searchParts == 0) then
                        -- add to skills
                        table.insert(self.skills, {
                            professionId = professionId,
                            skillId = skillId,
                            skill = skill,
                            bucketListAmount = bucketListAmount
                        });

                        -- increase bucket list skill amount
                        if (bucketListAmount) then
                            self.bucketListSkillAmount = self.bucketListSkillAmount + 1;
                        end
                    else
                        -- check if skill valid
                        local skillValid = true;
                        for i, part in ipairs(searchParts) do
                            if (string.len(part) > 0 and string.find(string.lower(skill.name), part) == nil) then
                                skillValid = false;
                                break;
                            end
                        end

                        -- check if recip valid
                        if (skillValid) then
                            -- add to skills
                            table.insert(self.skills, {
                                professionId = professionId,
                                skillId = skillId,
                                skill = skill,
                                bucketListAmount = bucketListAmount
                            });

                            -- increase bucket list skill amount
                            if (bucketListAmount) then
                                self.bucketListSkillAmount = self.bucketListSkillAmount + 1;
                            end
                        end
                    end
                end
            end
        end
    end
end

--- Refresh rows.
function ProfessionsView:RefreshRows()
    -- get start and end index
    local startIndex = math.max(math.floor(self.scrollTop / 20) - 3, 1);
    local endIndex = math.min(startIndex + 28, #self.skills);

    -- get player service
    local playerService = addon:GetService("player");
    local newRow = false;

    -- iterate rows
    for rowIndex = startIndex, endIndex do
        -- getr row and skill
        local row = self.rows[rowIndex];
        local professionId = self.skills[rowIndex].professionId;
        local skillId = self.skills[rowIndex].skillId;
        local skill = self.skills[rowIndex].skill;
        local bucketListAmount = self.skills[rowIndex].bucketListAmount;

        -- check if frame crated
        if (not row) then
            -- create row frame
            newRow = true;
            row = CreateFrame("Button", nil, self.scrollChild, BackdropTemplateMixin and "BackdropTemplate");
            row:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]]
            });
            self.rows[rowIndex] = row;

            -- set background color by index
            local backgroundColor = nil;
            if (rowIndex - math.floor(rowIndex / 2) * 2 == 0) then
                backgroundColor = 0.1;
            else
                backgroundColor = 0.15;
            end
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

            -- add item text
            local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("TOPLEFT", 6, -3);
            row.itemText = itemText;

            -- add player text
            local playerText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            playerText:SetPoint("TOPLEFT", 316, -4);
            playerText:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -26, -4);
            playerText:SetJustifyH("LEFT");
            playerText:SetJustifyV("TOP");
            playerText:SetTextColor(1, 1, 1);
            row.playerText = playerText;

            -- add bucket list text
            local bucketListText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            bucketListText:SetPoint("TOPLEFT", row, "TOPRIGHT", -27, -4);
            bucketListText:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -4);
            bucketListText:SetJustifyH("CENTER");
            bucketListText:SetJustifyV("TOP");
            row.bucketListText = bucketListText;

            -- bind row mouse event
            row:SetScript("OnLeave", function()
                -- update background color
                row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

                -- hide item tool tip
                GameTooltip:Hide();
            end);
            row:SetScript("OnEnter", function()
                -- update background color
                row:SetBackdropColor(0.2, 0.2, 0.2);

                -- show item tool tip
                GameTooltip:SetOwner(row, "ANCHOR_LEFT");
                addon:GetService("tooltip"):ShowTooltip(GameTooltip, row.professionId, row.skillId, row.skill);
            end);

            -- handle row mouse click
            row:SetScript("OnMouseDown", function(_, button)
                -- check if link should be added to chat window
                if (button == "LeftButton") and IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
                    -- check if era
                    if (addon.isEra) then
                        if (row.skill.skillLink) then
                            local editbox = GetCurrentKeyBoardFocus();
                            if (editbox) then
                                editbox:Insert("[PM: " .. row.skill.name .. " : " .. row.skillId .. "]");
                            end
                        else
                            ChatEdit_InsertLink(row.skill.itemLink);
                        end
                    else
                        ChatEdit_InsertLink(row.skill.skillLink);
                    end
                    return;
                elseif (button == "LeftButton") then
                    self:ShowSkillView(row);
                end
            end);
        end

        -- check if new or invalid
        if (newRow or row.invalid) then
            -- calcualte top position
            local top = (rowIndex - 1) * 20;
            if (self.bucketListSkillAmount > 0 and bucketListAmount) then
                top = top + 20;
            elseif(self.bucketListSkillAmount > 0 and not bucketListAmount) then
                top = top + 40;
            end
            row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -top);
            row:SetPoint("BOTTOMRIGHT", self.scrollChild, "TOPRIGHT", -28, -(top + 20));

            -- set item text
            local itemName = skill.itemColor and ("|c" .. skill.itemColor .. skill.name) or skill.name;
            row.itemText:SetText("|T" .. skill.icon .. ":16|t " .. itemName);

            -- set player text
            row.playerText:SetText(table.concat(playerService:CombinePlayerNames(skill.players, 12), ", "));

            -- set bucket list text
            row.bucketListText:SetText(bucketListAmount);

            -- show and set valid
            row:Show();
            row.professionId = professionId;
            row.skill = skill;
            row.skillId = skillId;
            row.invalid = nil;
        end
    end
end

--- Refresh bucket lsit rows.
function ProfessionsView:RefreshBucketListRows()
    -- hide rows
    for _, row in ipairs(self.bucketListReagentRows) do
        row:Hide();
    end

    -- get reagents
    local reagents = addon:GetService("inventory"):GetReagents();

    -- get service
    local professionNamesService = addon:GetService("profession-names");

    -- show reagents
    local reagentRowAmount = 0;
    for reagentItemId, reagent in pairs(reagents) do
        reagentRowAmount = reagentRowAmount + 1;
        if (#self.bucketListReagentRows < reagentRowAmount) then
            -- create row frame
            local reagentRow = CreateFrame("Button", nil, self.bucketListFrame, BackdropTemplateMixin and "BackdropTemplate");
            local top = 35 + ((reagentRowAmount - 1) * 20);
            reagentRow:SetPoint("TOPLEFT", self.bucketListFrame, "TOPLEFT", 10, -top);
            reagentRow:SetPoint("BOTTOMRIGHT", self.bucketListFrame, "TOPRIGHT", -10, -(top + 20));
            reagentRow:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]]
            });

            -- set background color by index
            local backgroundColor = nil;
            if (reagentRowAmount - math.floor(reagentRowAmount / 2) * 2 == 0) then
                backgroundColor = 0.1;
            else
                backgroundColor = 0.15;
            end
            reagentRow:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

            -- bind row mouse events
            reagentRow:SetScript("OnLeave", function()
                -- update background color
                reagentRow:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

                -- hide item tool tip
                GameTooltip:Hide();
            end);
            reagentRow:SetScript("OnEnter", function()
                -- update background color
                reagentRow:SetBackdropColor(0.2, 0.2, 0.2);

                -- show item tool tip
                GameTooltip:SetOwner(reagentRow, "ANCHOR_LEFT");
                GameTooltip:SetHyperlink(reagentRow.itemLink);
                GameTooltip:Show();
            end);

            -- add icon text
            local iconText = reagentRow:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            iconText:SetPoint("TOPLEFT", 3, -3);
            reagentRow.iconText = iconText;

            -- add amount text
            local amountText = reagentRow:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            amountText:SetPoint("TOPRIGHT", -3, -4);
            amountText:SetJustifyH("RIGHT");
            reagentRow.amountText = amountText;

            -- add item text
            local itemText = reagentRow:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("TOPLEFT", 24, -4);
            itemText:SetPoint("BOTTOMRIGHT", amountText, "BOTTOMLEFT", -8, 0);
            itemText:SetJustifyH("LEFT");
            itemText:SetJustifyV("TOP");
            reagentRow.itemText = itemText;

            -- add row
            table.insert(self.bucketListReagentRows, reagentRow);
        end

        -- get row
        local reagentRow = self.bucketListReagentRows[reagentRowAmount];
        reagentRow:Show();

        -- update amount
        if (reagent.amount > 0) then
            reagentRow.amountText:SetText(math.min(reagent.stocks, reagent.amount) .. "/" .. reagent.amount);
        else
            reagentRow.amountText:SetText("");
        end
        
        -- set if amount required
        if (reagent.amount > 0 and reagent.stocks >= reagent.amount) then
            reagentRow.amountText:SetTextColor(0, 1, 0);
        else
            reagentRow.amountText:SetTextColor(1, 1, 1);
        end

        -- get item
        local item = Item:CreateFromItemID(reagentItemId);
        if (not item:IsItemEmpty()) then
            -- wait until loaded
            item:ContinueOnItemLoad(function()
                -- update item
                reagentRow.itemLink = item:GetItemLink();
                reagentRow.iconText:SetText("|T" .. item:GetItemIcon() .. ":16|t");
                reagentRow.itemText:SetText("|c" .. professionNamesService:GetItemColor(reagentRow.itemLink) .. item:GetItemName());
            end);
        end
    end
end

-- register view
addon:RegisterView(ProfessionsView, "professions");