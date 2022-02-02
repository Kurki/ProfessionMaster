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
-- @param searchText Text to search for.
function ProfessionsView:Show(searchText)
    -- get services
    local uiService = addon:GetService("ui");
    local localeService = addon:GetService("locale");

    -- check if view created
    if (self.view == nil) then
        -- prepare visible skill frames
        self.visibleSkillFrames = {};
        self.professionId = nil;

        -- create view
        local view = uiService:CreateView("PMProfessions", 1000, 540, localeService:Get("ProfessionsViewTitle"));
        view:EnableKeyboard();
        self.view = view;

        -- add close button
        local closeButton = CreateFrame("Button", nil, view, "UIPanelCloseButton");
        closeButton:SetHeight(24);
        closeButton:SetWidth(24);
        closeButton:SetPoint("TOPRIGHT", -5, -5);
        closeButton:SetScript("OnClick", function()
            view:Hide();
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
        professionLabel:SetPoint("TOPLEFT", 22, -15);
        professionLabel:SetText(localeService:Get("ProfessionsViewProfession"));
        local professionSelection = CreateFrame("Frame", nil, contentFrame, "UIDropDownMenuTemplate");
        professionSelection:ClearAllPoints();
        professionSelection:SetPoint("TOPLEFT", 2, -31);
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
                view:Hide();
            elseif (key == "ENTER") then
                ChatFrame_OpenChat("", nil, nil);
            end
        end)
        itemSearch:SetScript("OnTextChanged", function()
            -- add skills
            self:AddSkills();
        end);

        -- add skill text
        local skillText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        skillText:SetPoint("TOPLEFT", 22, -68);
        self.skillText = skillText;

        -- add player text
        local playerText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        playerText:SetPoint("TOPLEFT", 332, -68);
        playerText:SetText(localeService:Get("ProfessionsViewPlayers"));

        -- create scroll frame 
        local scrollFrame, scrollChild = uiService:CreateScrollFrame(contentFrame);
        scrollFrame:SetPoint("TOPLEFT", 10, -82);
        scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12);
        scrollChild:SetWidth(scrollFrame:GetWidth());
        self.scrollFrame = scrollFrame;
        self.scrollChild = scrollChild;
    end

    -- select first profession
    self:SelectProfession(Settings.lastProfession or 333);
    self.itemSearch:SetFocus();

    -- show view
    self.view:Show();
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
    -- remove visible skill frames
    for i = 1, #self.visibleSkillFrames do
        self.visibleSkillFrames[i].frame:Hide();
        self.visibleSkillFrames[i] = nil;
    end

    -- get message service, locale service and date format
    local messageService = addon:GetService("message");
    local localeService = addon:GetService("locale");
    local playerService = addon:GetService("player");

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
    local skills = {};
    
    -- check if all should be shown
    if (self.professionId == 0) then
        -- get profession ids
        local professionIds = addon:GetService("profession-names"):GetProfessionIdsToShow();
        for i, professionId in ipairs(professionIds) do
            self:AddFilteredSkills(skills, professionId, searchParts);    
        end
    else
        self:AddFilteredSkills(skills, self.professionId, searchParts);
    end

    -- sort skills
    table.sort(skills, function(a, b)
        return a.data.name < b.data.name;
    end);

    -- add skills
    for i, skill in ipairs(skills) do
        self:AddSkill(i, skill, localeService, playerService);
    end

    -- set scroll height
    self.scrollChild:SetHeight(#skills * 20);
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
                        id = skillId,
                        data = skill
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
                            id = skillId,
                            data = skill
                        });
                    end
                end
            end
        end
    end
end

--- Add skill.
function ProfessionsView:AddSkill(index, skill, localeService, playerService)
    -- create frame
    local skillFrame = CreateFrame("Button", nil, self.scrollChild, BackdropTemplateMixin and "BackdropTemplate");
    local top = (index - 1) * 20;
    skillFrame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -top);
    skillFrame:SetPoint("BOTTOMRIGHT", self.scrollChild, "TOPRIGHT", -28, -(top + 20));
    skillFrame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]]
    });
    skillFrame.index = index;

    -- add frame to frames
    table.insert(self.visibleSkillFrames, {
        frame = skillFrame,
        skill = skill
    });

    -- check odd index
    if (index - math.floor(index / 2) * 2 == 0) then
        skillFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8);
    else
        skillFrame:SetBackdropColor(0.15, 0.15, 0.15, 0.8);
    end

    -- get colored item name
    local coloredItemName = skill.data.itemColor and ("|c" .. skill.data.itemColor .. skill.data.name) or skill.data.name;

    -- add item 
    local itemFrame = CreateFrame("Frame", nil, skillFrame);
    itemFrame:SetPoint("TOPLEFT", 6, -3);
    itemFrame:SetHeight(26);
    itemFrame:SetWidth(350);
    local itemText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    itemText:SetPoint("TOPLEFT", 0, 0);
    itemText:SetText("|T" .. skill.data.icon .. ":16|t " .. coloredItemName);

    -- add player text
    local playerText = skillFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    playerText:SetPoint("TOPLEFT", 316, -4);
    playerText:SetPoint("BOTTOMRIGHT", skillFrame, "BOTTOMRIGHT", -6, -4);
    playerText:SetJustifyH("LEFT");
    playerText:SetJustifyV("TOP");
    playerText:SetTextColor(1, 1, 1);
    playerText:SetText(playerService:CombinePlayerNames(skill.data.players, ", "));

    -- handle row mouse enter
    skillFrame:SetScript("OnEnter", function()
        -- update background color
        skillFrame:SetBackdropColor(0.2, 0.2, 0.2);

        -- show item tool tip
        GameTooltip:SetOwner(itemFrame, "ANCHOR_LEFT");
        GameTooltip:SetHyperlink(skill.data.skillLink);
        GameTooltip:Show();
    end);

    -- handle row mouse leave
    skillFrame:SetScript("OnLeave", function()
        -- update background color
        if (index - math.floor(index / 2) * 2 == 0) then
            skillFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8);
        else
            skillFrame:SetBackdropColor(0.15, 0.15, 0.15, 0.8);
        end

        -- hite item tool tip
        GameTooltip:Hide();
    end);

    -- handle row mouse click
    skillFrame:SetScript("OnMouseDown", function(_, button)
        -- check if link should be added to chat window
        if (button == "LeftButton") and IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
            ChatEdit_InsertLink(skill.data.skillLink);
            return;
        end

        -- show menu
        -- self:ShowActions(skill.data, skillFrame);
    end);
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