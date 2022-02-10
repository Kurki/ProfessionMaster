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
        self.skills = {};
        self.professionId = nil;
        self.bucketListAddView = addon:CreateView("bucket-list-add");
        self.scrollTop = 0;

        -- create view
        local view = uiService:CreateView("PmProfessions", 1000, 540, localeService:Get("ProfessionsViewTitle"));
        view:EnableKeyboard();
        view:SetScript("OnKeyDown", function(_, key)
            -- check escape
            if (key == "ESCAPE") then
                if (self.bucketListVisible) then
                    self:HideBucketList();
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

        -- add content frame
        local contentFrame = CreateFrame("Frame", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        contentFrame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface/Buttons/WHITE8X8]],
            edgeSize = 1
        });
        contentFrame:SetBackdropColor(0, 0, 0, 0.5);
        contentFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
        contentFrame:SetPoint("TOPLEFT", view, 12, -36);
        contentFrame:SetPoint("BOTTOMRIGHT", view, "BOTTOMRIGHT", -12, 12);
        
        local professionLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        professionLabel:SetPoint("TOPLEFT", 18, -15);
        professionLabel:SetText(localeService:Get("ProfessionsViewProfession"));
        local professionSelection = CreateFrame("Frame", nil, contentFrame, "UIDropDownMenuTemplate");
        professionSelection:ClearAllPoints();
        professionSelection:SetPoint("TOPLEFT", -2, -31);
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

        -- add item search box
        local itemSearchLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        itemSearchLabel:SetPoint("TOPLEFT", 196, -15);
        itemSearchLabel:SetText(localeService:Get("ProfessionsViewSearch"));
        local itemSearch = CreateFrame("EditBox", nil, contentFrame, "InputBoxTemplate");
        itemSearch:SetPoint("TOPLEFT", 200, -35);
        itemSearch:SetPoint("BOTTOMRIGHT", contentFrame, "TOPRIGHT", -20, -54);
        itemSearch:SetAutoFocus(false);
        self.itemSearch = itemSearch;
        itemSearch:SetScript("OnKeyDown", function(_, key)
            -- check escape
            if (key == "ESCAPE") then
                if (self.bucketListVisible) then
                    self:HideBucketList();
                else
                    self:Hide();
                end
            elseif (key == "ENTER") then
                ChatFrame_OpenChat("", nil, nil);
            end
        end)
        itemSearch:SetScript("OnTextChanged", function()
            -- add skills and hide bucket list
            self:HideBucketList();
            self:AddSkills();
        end);

        -- add bucket list icon
        local bucketListIcon = contentFrame:CreateTexture(nil, "OVERLAY");
        bucketListIcon:SetSize(16, 16);
        bucketListIcon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up"); 
        bucketListIcon:SetPoint("TOPLEFT", contentFrame, "TOPRIGHT", -56, -67);

        -- add skill text
        local skillText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        skillText:SetPoint("TOPLEFT", 22, -69);
        self.skillText = skillText;

        -- add player text
        local playerText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        playerText:SetPoint("TOPLEFT", 332, -69);
        playerText:SetText(localeService:Get("ProfessionsViewPlayers"));

        -- create scroll frame 
        local scrollFrame, scrollChild, scrollElement = uiService:CreateScrollFrame(contentFrame);
        scrollFrame:SetPoint("TOPLEFT", 10, -82);
        scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12);
        scrollChild:SetWidth(scrollFrame:GetWidth());
        scrollElement:SetScript("OnVerticalScroll", function(_, top)
            self.scrollTop = top;
            self:RefreshRows();
            self:HideBucketList();
        end);
        self.scrollFrame = scrollFrame;
        self.scrollChild = scrollChild;
        self.scrollElement = scrollElement;

        -- add bucket list background 
        local addBucketBackground = CreateFrame("Button", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        addBucketBackground:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]]
        });
        addBucketBackground:SetBackdropColor(0, 0, 0, 0.8);
        addBucketBackground:SetPoint("TOPLEFT", 1, -1);
        addBucketBackground:SetPoint("BOTTOMRIGHT", -1, 1);
        addBucketBackground:Hide();
        addBucketBackground:SetScript("OnClick", function()
            self:HideBucketList();
        end);
        self.addBucketBackground = addBucketBackground;
    end

    -- hide bucket list
    self:HideBucketList();

    -- select first profession
    self:SelectProfession(Settings.lastProfession or 0);
    self.itemSearch:SetFocus();

    -- show view
    self.view:Show();
    self.visible = true;
end

--- Show bucket list.
function ProfessionsView:ShowBucketList(row)
     -- show bucket list add view
     self.addBucketBackground:Show();
     self.addBucketBackground:SetFrameLevel(2000);
     self.bucketListAddView:Show(row, self);
     self.bucketListAddView.view:SetFrameLevel(2001);
     self.bucketListVisible = true;
end

--- Hide bucket list.
function ProfessionsView:HideBucketList()
    self.addBucketBackground:Hide();
    self.bucketListAddView:Hide();
    self.bucketListVisible = false;
end

--- Hide professions view.
function ProfessionsView:Hide()
    -- hide view
    if (self.view) then
        self.bucketListAddView:Hide();
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

--- Refresh rows.
function ProfessionsView:RefreshRows()
    -- get start and end index
    local startIndex = math.max(math.floor(self.scrollTop / 20) - 1, 1);
    local endIndex = math.min(startIndex + 25, #self.skills);

    -- get player service
    local playerService = addon:GetService("player");
    local newRow = false;

    -- iterate rows
    for rowIndex = startIndex, endIndex do
        -- getr row and skill
        local row = self.rows[rowIndex];
        local skillId = self.skills[rowIndex].skillId;
        local skill = self.skills[rowIndex].skill;

        -- check if frame crated
        if (not row) then
            -- create row frame
            newRow = true;
            row = CreateFrame("Button", nil, self.scrollChild, BackdropTemplateMixin and "BackdropTemplate");
            local top = (rowIndex - 1) * 20;
            row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -top);
            row:SetPoint("BOTTOMRIGHT", self.scrollChild, "TOPRIGHT", -28, -(top + 20));
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
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.8);

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

            -- add bucket plus button
            local bucketPlusButton = CreateFrame("Button", nil, row);
            bucketPlusButton:SetHeight(16);
            bucketPlusButton:SetWidth(16);
            bucketPlusButton:SetPoint("TOPLEFT", row, "TOPRIGHT", -21, -2);
            bucketPlusButton:SetScript("OnClick", function()
                self:ShowBucketList(row);
            end);
            bucketPlusButton:Hide();
            row.bucketPlusButton = bucketPlusButton;

            -- add bucket list text
            local bucketListText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            bucketListText:SetPoint("TOPLEFT", row, "TOPRIGHT", -28, -4);
            bucketListText:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -4);
            bucketListText:SetJustifyH("CENTER");
            bucketListText:SetJustifyV("TOP");
            row.bucketListText = bucketListText;

            -- prepare enter function
            local onEnter = function()
                -- update background color
                row:SetBackdropColor(0.2, 0.2, 0.2);

                -- show item tool tip
                GameTooltip:SetOwner(row, "ANCHOR_LEFT");
                GameTooltip:SetHyperlink(row.skill.skillLink);
                GameTooltip:Show();

                -- show plus button
                bucketPlusButton:Show();
            end;

            -- prepare leave function
            local onLeave = function()
                -- update background color
                row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.8);

                -- hide item tool tip
                GameTooltip:Hide();

                -- hide plus button
                bucketPlusButton:Hide();
            end;

            -- bind row mouse event
            bucketPlusButton:SetScript("OnEnter", onEnter);
            bucketPlusButton:SetScript("OnLeave", onLeave);
            row:SetScript("OnLeave", onLeave);
            row:SetScript("OnEnter", onEnter);

            -- handle row mouse click
            row:SetScript("OnMouseDown", function(_, button)
                -- check if link should be added to chat window
                if (button == "LeftButton") and IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
                    ChatEdit_InsertLink(row.skill.skillLink);
                    return;
                end
            end);
        end

        -- check if new or invalid
        if (newRow or row.invalid) then
            -- set item text
            local itemName = skill.itemColor and ("|c" .. skill.itemColor .. skill.name) or skill.name;
            row.itemText:SetText("|T" .. skill.icon .. ":16|t " .. itemName);

            -- set player text
            row.playerText:SetText(playerService:CombinePlayerNames(skill.players, ", "));

            -- set bucket list text
            local bucketListAmount = BucketList[skillId];
            row.bucketListText:SetText(bucketListAmount);

            -- check bucket list amount
            if (bucketListAmount) then
                row.bucketPlusButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-BiggerButton-Down");
                row.bucketPlusButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
                row.bucketPlusButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-BiggerButton-Up");
            else
                row.bucketPlusButton:SetPushedTexture("Interface\\Buttons\\UI-AttributeButton-Encourage-Down");
                row.bucketPlusButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
                row.bucketPlusButton:SetNormalTexture("Interface\\Buttons\\UI-AttributeButton-Encourage-Up");
            end

            -- show and set valid
            row:Show();
            row.skill = skill;
            row.skillId = skillId;
            row.invalid = nil;
        end
    end
end

--- Get Text of profession.
function ProfessionsView:GetProfessionText(professionId)
    -- check if all selected
    if (professionId == 0) then
        return "|T133745:16|t  " .. addon:GetService("locale"):Get("ProfessionsViewAllProfessions");
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
    if (self.professionId == 0) then
        -- get profession ids
        local professionIds = addon:GetService("profession-names"):GetProfessionIdsToShow();
        for i, professionId in ipairs(professionIds) do
            self:AddFilteredSkills(self.skills, professionId, searchParts);    
        end
    else
        self:AddFilteredSkills(self.skills, self.professionId, searchParts);
    end

    -- sort skills
    table.sort(self.skills, function(a, b)
        return a.skill.name < b.skill.name;
    end);

    -- set scroll height
    self.scrollChild:SetHeight(#self.skills * 20);

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
function ProfessionsView:AddFilteredSkills(skills, professionId, searchParts)
    -- get profession
    local profession = Professions[professionId];

    -- filter skills
    if (profession) then
        for skillId, skill in pairs(profession) do
            -- check if bop
            if (not skill.bop) then
                 -- check if has search parts
                if (#searchParts == 0) then
                    -- add to skills
                    table.insert(skills, {
                        skillId = skillId,
                        skill = skill
                    });
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
                        table.insert(skills, {
                            skillId = skillId,
                            skill = skill
                        });
                    end
                end
            end
        end
    end
end

--- Show actions.
function ProfessionsView:ShowActions(skill, frame)
    -- create conext menu and get locale service
    local contextMenu = CreateFrame("Frame", "DLMHistory_ContextMenu", UIParent, "UIDropDownMenuTemplate");
    local localeService = addon:GetService("locale");

    -- init drop down
    UIDropDownMenu_Initialize(contextMenu, function(_self, level)
        -- add main entries
        UIDropDownMenu_AddButton({
            text = skill.name,
            isTitle = true,
            notCheckable = true
        });

        -- add to favorites
        UIDropDownMenu_AddButton({
            text = localeService:Get("ProfessionsViewToFavorites"),
            notCheckable = true,
            func = function()
            end
        });

        -- add to shopping list 
        UIDropDownMenu_AddButton({
            text = localeService:Get("ProfessionsViewToShoppingList"),
            notCheckable = true,
            func = function()
            end
        });

        -- add empty entry
        UIDropDownMenu_AddButton({
            text = nil,
            disabled = true
        });

        -- add remove entry menu
        UIDropDownMenu_AddButton({
            text = localeService:Get("ProfessionsViewCancel"),
            notCheckable = true,
            func = function()
               
            end
        });
    end, "MENU");

    -- show drop down
    ToggleDropDownMenu(1, nil, contextMenu, frame, 0, 0);
end

-- register view
addon:RegisterView(ProfessionsView, "professions");