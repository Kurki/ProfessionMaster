--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local ProfessionsView = _G.professionMaster:CreateView("professions");

--- Show professions view.
function ProfessionsView:Show()
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- check if view created
    if (self.view == nil) then
        -- prepare visible skill frames
        self.rowPool = {};
        self.bucketListReagentRows = {};
        self.skills = {};
        self.professionId = nil;
        self.skillView = self.addon:NewView("skill-view");
        self.scrollTop = 0;

        -- create view
        local view = uiService:CreateView("PmProfessions", 1000, 540, localeService:Get("ProfessionsViewTitle"), false);
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

        -- set sizeable
        view:SetResizable(true);

        -- create resize handlers
        view:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and IsShiftKeyDown() then
                self:StartSizing("BOTTOMRIGHT");
                self:SetUserPlaced(true);
                self:SetBackdropBorderColor(1, 1, 1, 1);
            end
        end);
        view:SetScript("OnMouseUp", function(self, button)
            self:StopMovingOrSizing();
            self:SetBackdropBorderColor(0, 0, 0, 1);
        end);
        self.view = view;

        -- add close button
        local closeButton = uiService:CreateFlatCloseButton(view, function()
            self:Hide();
        end);
        closeButton:SetHeight(22);
        closeButton:SetWidth(22);
        closeButton:SetPoint("TOPRIGHT", -12, -8);

        -- get profession ids
        local professionIds = self:GetService("profession-names"):GetProfessionIdsToShow();

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
        bucketListFrame:SetPoint("TOPLEFT", view, "TOPRIGHT", -302, -36);
        bucketListFrame:SetPoint("BOTTOMRIGHT", -12, 30);
        self.bucketListFrame = bucketListFrame;

        -- add bucket list scroll frame
        local uiService = self:GetService("ui");
        local bucketListScrollParent, bucketListScrollChild, bucketListScrollElement = uiService:CreateScrollFrame(bucketListFrame);
        bucketListScrollParent:SetPoint("TOPLEFT", bucketListFrame, "TOPLEFT", 2, -35);
        bucketListScrollParent:SetPoint("BOTTOMRIGHT", bucketListFrame, "BOTTOMRIGHT", -2, 2);
        bucketListScrollParent:SetBackdropColor(0, 0, 0, 0);
        bucketListScrollChild:SetWidth(bucketListScrollParent:GetWidth());
        self.bucketListScrollChild = bucketListScrollChild;
        self.bucketListScrollElement = bucketListScrollElement;

        -- add footer
        local footerLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft");
        footerLabel:SetPoint("BOTTOMLEFT", 16, 10);
        footerLabel:SetText(localeService:Get("ProfessionsViewFooter"));

        -- add bucket list group text
        local bucketListTitleText = bucketListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        bucketListTitleText:SetPoint("TOPLEFT", 13, -15);
        bucketListTitleText:SetText(localeService:Get("ProfessionsViewBucketList"));

        -- add bucket list clear button
        local bucketListClearButton = uiService:CreateFlatSquareButton(bucketListFrame, "x", function()
            -- clear and refresh bucket list
            BucketList = {};
            self:CheckBucketList();
            self:GetService("inventory"):CheckMissingReagents();
        end, 20);
        bucketListClearButton:SetPoint("TOPRIGHT", -8, -10);

        -- add item search box
        local itemSearchLabel = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        itemSearchLabel:SetPoint("TOPLEFT", 18, -15);
        itemSearchLabel:SetText(localeService:Get("ProfessionsViewSearch"));
        local itemSearch = CreateFrame("EditBox", nil, skillsFrame, "InputBoxTemplate");
        itemSearch:SetPoint("TOPLEFT", 22, -33);
        if (self.addon.isVanilla) then
            itemSearch:SetPoint("BOTTOMRIGHT", skillsFrame, "TOPRIGHT", -199, -56);
        else
            itemSearch:SetPoint("BOTTOMRIGHT", skillsFrame, "TOPRIGHT", -332, -56);
        end
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
            -- debounce: delay skill filtering by 0.2s
            if (self.searchPending) then
                self.searchPending:Cancel();
            end
            self.searchPending = C_Timer.NewTimer(0.2, function()
                self.searchPending = nil;
                self:AddSkills();
            end);
        end);
        
        -- add profession selection
        local professionLabel = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        professionLabel:SetText(localeService:Get("ProfessionsViewProfession"));
        local professionSelection = CreateFrame("Frame", nil, skillsFrame, "UIDropDownMenuTemplate");
        professionSelection:ClearAllPoints();
        if (self.addon.isVanilla) then
            professionLabel:SetPoint("TOPLEFT", skillsFrame, "TOPRIGHT", -190, -15);
            professionSelection:SetPoint("TOPRIGHT", -20, -31);
        else
            professionLabel:SetPoint("TOPLEFT", skillsFrame, "TOPRIGHT", -323, -15);
            professionSelection:SetPoint("TOPRIGHT", -153, -31);
        end
        UIDropDownMenu_SetWidth(professionSelection, 140);
        if (professionSelection.Button) then
            professionSelection.Button:HookScript("OnClick", function()
                C_Timer.After(0, function()
                    if (DropDownList1 and DropDownList1:IsShown() and DropDownList1.dropdown == professionSelection) then
                        DropDownList1:ClearAllPoints();
                        DropDownList1:SetPoint("TOPRIGHT", professionSelection, "BOTTOMRIGHT", -18, 6);
                    end
                end);
            end);
        end
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

        -- check if is not vanilla
        if (not self.addon.isVanilla) then
            -- add addon selection
            local addonLabel = skillsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            addonLabel:SetPoint("TOPRIGHT", -120, -15);
            addonLabel:SetText(localeService:Get("ProfessionsViewAddon"));
            local addonSelection = CreateFrame("Frame", nil, skillsFrame, "UIDropDownMenuTemplate");
            addonSelection:ClearAllPoints();
            addonSelection:SetPoint("TOPRIGHT", -20, -31);
            UIDropDownMenu_SetWidth(addonSelection, 110);
            if (addonSelection.Button) then
                addonSelection.Button:HookScript("OnClick", function()
                    C_Timer.After(0, function()
                        if (DropDownList1 and DropDownList1:IsShown() and DropDownList1.dropdown == addonSelection) then
                            DropDownList1:ClearAllPoints();
                            DropDownList1:SetPoint("TOPRIGHT", addonSelection, "BOTTOMRIGHT", -18, 6);
                        end
                    end);
                end);
            end
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

                -- add all addons
                item.text, item.arg1 = self:GetAddonText(nil), nil;
                UIDropDownMenu_AddButton(item);

                -- add vanilla
                item.text, item.arg1 = self:GetAddonText(1), 1;
                UIDropDownMenu_AddButton(item);

                -- add bcc
                if (self.addon.isBccAtLeast) then
                    item.text, item.arg1 = self:GetAddonText(2), 2;
                    UIDropDownMenu_AddButton(item);
                end

                -- add wrath
                if (self.addon.isWrathAtLeast) then
                    item.text, item.arg1 = self:GetAddonText(3), 3;
                    UIDropDownMenu_AddButton(item);
                end

                -- add cata
                if (self.addon.isCataAtLeast) then
                    item.text, item.arg1 = self:GetAddonText(4), 4;
                    UIDropDownMenu_AddButton(item);
                end

                -- add mop
                if (self.addon.isMopAtLeast) then
                    item.text, item.arg1 = self:GetAddonText(5), 5;
                    UIDropDownMenu_AddButton(item);
                end
            end);
        end

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
        self:SelectProfession(PMSettings.lastProfession or 0);
        self:SelectAddon(PMSettings.lastAddon);

        -- create ok button
        local okButton = uiService:CreateFlatButton(view, localeService:Get("ProfessionsViewAnnounce"), function()
            SendChatMessage(localeService:Get("GuildAnnouncement"), "GUILD");
        end);
        okButton:SetWidth(200);
        okButton:SetHeight(22);
        okButton:SetPoint("BOTTOMRIGHT", -12, 6);
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
        self.skillsFrame:SetPoint("BOTTOMRIGHT", -310, 30);
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
        return "|T133745:16|t " .. self:GetService("locale"):Get("ProfessionsViewAllProfessions");
    end

    -- get icon and name of profession
    local service = self:GetService("profession-names");
    return "|T" .. service:GetProfessionIcon(professionId) .. ":16|t  " .. service:GetProfessionName(professionId);
end

--- Select profession.
function ProfessionsView:SelectProfession(professionId)
    -- set profession id
    self.professionId = professionId;
    PMSettings.lastProfession = professionId;

    -- select dropdown
    UIDropDownMenu_SetText(self.professionSelection, self:GetProfessionText(professionId));
end

--- Get Text of addon.
function ProfessionsView:GetAddonText(addonId)
    -- check classic
    if (addonId == 1) then
        return "|T135954:16|t Vanilla";
    end
    
    -- check classic
    if (addonId == 2) then
        return "|T135804:16|t TBC";
    end
    
    -- check wotlk
    if (addonId == 3) then
        return "|T135773:16|t WOTLK";
    end

    -- check cata
    if (addonId == 4) then
        return "|T134158:16|t Cata";
    end

    -- check mop
    if (addonId == 5) then
        return "|T132183:16|t MoP";
    end

    -- use all addons
    return "|T135749:16|t " .. self:GetService("locale"):Get("ProfessionsViewAllAddons");
end

--- Select addon.
function ProfessionsView:SelectAddon(addonId)
    -- check if is vanilla
    if (self.addon.isVanilla) then
        -- select all addons in vani
        addonId = nil;
    end

    -- set addon id
    self.addonId = addonId;
    PMSettings.lastAddon = addonId;

    -- select dropdown
    if (self.addonSelection) then
        UIDropDownMenu_SetText(self.addonSelection, self:GetAddonText(addonId));
    end
end

--- Add skills.
function ProfessionsView:AddSkills()
    -- get services
    local messageService = self:GetService("message");
    local localeService = self:GetService("locale");

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
        local professionIds = self:GetService("profession-names"):GetProfessionIdsToShow();
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

    -- refresh rows
    self:RefreshRows();
end

--- Add filtered skills.
function ProfessionsView:AddFilteredSkills(professionId, addonId, searchParts)
    -- get profession and all skills
    local profession = Professions[professionId];
    local skillsService = self:GetService("skills");

    -- filter skills
    if (profession) then
        for skillId, skill in pairs(profession) do
            -- check if skill ok
            if (skill.name ~= nil) then
                -- get skill info
                local skillInfo = skillsService:GetSkillById(skillId);
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
    -- get visible range
    local startIndex = math.max(math.floor(self.scrollTop / 20) - 3, 1);
    local endIndex = math.min(startIndex + 28, #self.skills);
    local visibleCount = endIndex - startIndex + 1;

    -- get player service
    local playerService = self:GetService("player");

    -- ensure pool has enough frames
    if (not self.rowPool) then
        self.rowPool = {};
    end
    while (#self.rowPool < visibleCount) do
        local poolIndex = #self.rowPool + 1;
        local row = CreateFrame("Button", nil, self.scrollChild, BackdropTemplateMixin and "BackdropTemplate");
        row:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]]
        });

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
            if (row.bgColor) then
                row:SetBackdropColor(row.bgColor, row.bgColor, row.bgColor, 0.5);
            end
            GameTooltip:Hide();
        end);
        row:SetScript("OnEnter", function()
            row:SetBackdropColor(0.2, 0.2, 0.2);
            GameTooltip:SetOwner(row, "ANCHOR_LEFT");
            self:GetService("tooltip"):ShowTooltip(GameTooltip, row.professionId, row.skillId, row.skill);
        end);

        -- handle row mouse click
        row:SetScript("OnMouseDown", function(_, button)
            if (button == "LeftButton") and IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
                if (IsControlKeyDown()) then
                    if (row.skill.name and row.skillId) then
                        local editbox = GetCurrentKeyBoardFocus();
                        if (editbox) then
                            editbox:Insert("[PM: " .. row.skill.name .. " : " .. row.skillId .. "]");
                        end
                    end
                else
                    if (row.skill.itemLink) then
                        ChatEdit_InsertLink(row.skill.itemLink);
                    end
                end
            elseif (button == "LeftButton") then
                self:ShowSkillView(row);
            end
        end);

        self.rowPool[poolIndex] = row;
    end

    -- hide all pooled frames first
    for _, row in ipairs(self.rowPool) do
        row:Hide();
    end

    -- bind pool frames to visible data
    for i = 0, visibleCount - 1 do
        local rowIndex = startIndex + i;
        local row = self.rowPool[i + 1];
        local skillData = self.skills[rowIndex];
        local professionId = skillData.professionId;
        local skillId = skillData.skillId;
        local skill = skillData.skill;
        local bucketListAmount = skillData.bucketListAmount;

        -- set background color by data index
        local backgroundColor;
        if (rowIndex % 2 == 0) then
            backgroundColor = 0.1;
        else
            backgroundColor = 0.15;
        end
        row.bgColor = backgroundColor;
        row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

        -- calculate top position
        local top = (rowIndex - 1) * 20;
        if (self.bucketListSkillAmount > 0 and bucketListAmount) then
            top = top + 20;
        elseif(self.bucketListSkillAmount > 0 and not bucketListAmount) then
            top = top + 40;
        end
        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -top);
        row:SetPoint("BOTTOMRIGHT", self.scrollChild, "TOPRIGHT", -28, -(top + 20));

        -- set item text
        local itemName = skill.itemColor and ("|c" .. skill.itemColor .. skill.name) or skill.name;
        row.itemText:SetText("|T" .. skill.icon .. ":16|t " .. itemName);

        -- set player text
        row.playerText:SetText(table.concat(playerService:CombinePlayerNames(skill.players, 12), ", "));

        -- set bucket list text
        row.bucketListText:SetText(bucketListAmount);

        -- store data on row
        row.professionId = professionId;
        row.skill = skill;
        row.skillId = skillId;

        -- show
        row:Show();
    end
end

--- Refresh bucket lsit rows.
function ProfessionsView:RefreshBucketListRows()
    -- hide rows
    for _, row in ipairs(self.bucketListReagentRows) do
        row:Hide();
    end

    -- get services
    local inventoryService = self:GetService("inventory");
    local skillsService = self:GetService("skills");
    local professionNamesService = self:GetService("profession-names");

    -- scan inventory once
    inventoryService:ScanInventory();

    -- build tree
    local treeRows = self:BuildBucketListTree(skillsService, inventoryService);

    -- calculate vertical positions with spacing before root nodes
    local currentTop = 0;
    for i, treeRow in ipairs(treeRows) do
        if (treeRow.isSeparator) then
            currentTop = currentTop + 10;
            treeRow.top = currentTop;
            currentTop = currentTop + 23;  -- increased from 8 to 23 to make room for missing reagents header
        else
            if (treeRow.isNode and i > 1) then
                currentTop = currentTop + 6;
            end
            treeRow.top = currentTop;
            currentTop = currentTop + 20;
        end
    end

    -- render separator line
    if (not self.bucketListSeparator) then
        local sep = self.bucketListScrollChild:CreateTexture(nil, "OVERLAY");
        sep:SetColorTexture(0.4, 0.4, 0.4, 0.6);
        sep:SetHeight(1);
        self.bucketListSeparator = sep;
    end
    self.bucketListSeparator:Hide();

    -- create missing reagents header if not exists
    if (not self.bucketListMissingReagentsHeader) then
        local header = self.bucketListScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        self.bucketListMissingReagentsHeader = header;
    end
    self.bucketListMissingReagentsHeader:Hide();

    -- render tree rows
    local rowIndex = 0;
    local localeService = self:GetService("locale");
    for _, treeRow in ipairs(treeRows) do
        -- handle separator
        if (treeRow.isSeparator) then
            self.bucketListSeparator:ClearAllPoints();
            self.bucketListSeparator:SetPoint("TOPLEFT", self.bucketListScrollChild, "TOPLEFT", 10, -treeRow.top);
            self.bucketListSeparator:SetPoint("RIGHT", self.bucketListScrollChild, "RIGHT", -30, 0);
            self.bucketListSeparator:Show();

            -- show missing reagents header below separator
            self.bucketListMissingReagentsHeader:ClearAllPoints();
            self.bucketListMissingReagentsHeader:SetPoint("TOPLEFT", self.bucketListScrollChild, "TOPLEFT", 10, -(treeRow.top + 9));
            self.bucketListMissingReagentsHeader:SetText(localeService:Get("ProfessionsViewCraftSelf"));
            self.bucketListMissingReagentsHeader:Show();
        else

        rowIndex = rowIndex + 1;
        if (#self.bucketListReagentRows < rowIndex) then
            -- create row frame
            local reagentRow = CreateFrame("Button", nil, self.bucketListScrollChild, BackdropTemplateMixin and "BackdropTemplate");
            reagentRow:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]]
            });

            -- bind row mouse events
            reagentRow:SetScript("OnLeave", function()
                C_Timer.After(0, function()
                    self:UpdateBucketListReagentRowHoverState(reagentRow);
                    if (not reagentRow:IsMouseOver() and not reagentRow.craftButton:IsMouseOver()) then
                        GameTooltip:Hide();
                    end
                end);
            end);
            reagentRow:SetScript("OnEnter", function()
                self:UpdateBucketListReagentRowHoverState(reagentRow);
                if (reagentRow.itemLink and not reagentRow.craftButton:IsMouseOver()) then
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
            craftButton:SetScript("OnClick", function()
                self:OnBucketListCraftButtonClicked(reagentRow);
            end);
            craftButton:SetScript("OnEnter", function()
                self:UpdateBucketListReagentRowHoverState(reagentRow);
                GameTooltip:SetOwner(craftButton, "ANCHOR_RIGHT");
                GameTooltip:SetText(self:GetService("locale"):Get("ProfessionsViewCraftSelf"));
                GameTooltip:Show();
            end);
            craftButton:SetScript("OnLeave", function()
                C_Timer.After(0, function()
                    self:UpdateBucketListReagentRowHoverState(reagentRow);
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
            table.insert(self.bucketListReagentRows, reagentRow);
        end

        -- get row
        local reagentRow = self.bucketListReagentRows[rowIndex];
        local indent = treeRow.indent;
        local top = treeRow.top;
        reagentRow:ClearAllPoints();
        reagentRow:SetPoint("TOPLEFT", self.bucketListScrollChild, "TOPLEFT", 8 + indent * 12, -top);
        reagentRow:SetPoint("BOTTOMRIGHT", self.bucketListScrollChild, "TOPRIGHT", -26, -(top + 20));

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
        reagentRow.craftSkillId = nil;
        if (reagentRow.isIndented and treeRow.itemId and treeRow.itemId > 0) then
            reagentRow.craftSkillId = skillsService:GetSkillIdByItemId(treeRow.itemId);
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
        if (reagentItemId and reagentItemId > 0 and C_Item.DoesItemExistByID(reagentItemId)) then
            local item = Item:CreateFromItemID(reagentItemId);
            if (not item:IsItemEmpty()) then
                pcall(function()
                    item:ContinueOnItemLoad(function()
                        reagentRow.itemLink = item:GetItemLink();
                        reagentRow.iconText:SetText("|T" .. item:GetItemIcon() .. ":16|t");
                        reagentRow.itemText:SetText("|c" .. professionNamesService:GetItemColor(reagentRow.itemLink) .. item:GetItemName());
                    end);
                end);
            end
        elseif (treeRow.skillId) then
            local spellName, _, spellIcon = GetSpellInfo(treeRow.skillId);
            if (spellName) then
                reagentRow.itemLink = GetSpellLink(treeRow.skillId);
                reagentRow.iconText:SetText("|T" .. (spellIcon or 136243) .. ":16|t");
                reagentRow.itemText:SetText("|cFF71D5FF" .. spellName);
            end
        end
    end -- if not separator
    end -- for treeRows

    -- update scroll child height
    self.bucketListScrollChild:SetHeight(currentTop + 5);
end

--- Show or hide craft button for a hovered bucket list row.
-- @param reagentRow Bucket list reagent row.
function ProfessionsView:UpdateBucketListCraftButtonVisibility(reagentRow)
    if (not reagentRow or not reagentRow.craftButton) then
        return;
    end

    if (reagentRow.isIndented and reagentRow.craftSkillId and reagentRow:IsMouseOver()) then
        reagentRow.craftButton:Show();
    else
        reagentRow.craftButton:Hide();
    end
end

--- Update hover visuals for bucket list row and craft button.
-- @param reagentRow Bucket list reagent row.
function ProfessionsView:UpdateBucketListReagentRowHoverState(reagentRow)
    if (not reagentRow) then
        return;
    end

    local isHovered = reagentRow:IsMouseOver() or (reagentRow.craftButton and reagentRow.craftButton:IsMouseOver());
    if (isHovered) then
        reagentRow:SetBackdropColor(0.2, 0.2, 0.2);
    else
        reagentRow:SetBackdropColor(reagentRow.bgColor, reagentRow.bgColor, reagentRow.bgColor, 0.5);
    end

    self:UpdateBucketListCraftButtonVisibility(reagentRow);
end

--- Handle click on craft button in bucket list row.
-- @param reagentRow Bucket list reagent row.
function ProfessionsView:OnBucketListCraftButtonClicked(reagentRow)
    if (not reagentRow or not reagentRow.craftSkillId or not reagentRow.craftItemId) then
        return;
    end

    if (not ReagentWatchList) then
        ReagentWatchList = {};
    end

    if (ReagentWatchList[reagentRow.craftItemId]) then
        ReagentWatchList[reagentRow.craftItemId] = nil;
    else
        ReagentWatchList[reagentRow.craftItemId] = true;
    end

    self:RefreshBucketListRows();
end

--- Build a flat tree of bucket list nodes and their reagents.
-- Top-level nodes are bucket list items and promoted craftable reagents.
-- Each node shows its direct reagents indented below, scaled to the missing amount.
-- @param skillsService Skills service reference.
-- @param inventoryService Inventory service reference.
-- @return Array of { itemId, skillId, amount, stocks, indent, isNode }.
function ProfessionsView:BuildBucketListTree(skillsService, inventoryService)
    local directRows = {};
    local derivedRows = {};
    local visited = {};
    local watchedReagents = ReagentWatchList or {};

    -- collect initial nodes from bucket list
    local currentNodes = {};
    for skillId, skillAmount in pairs(BucketList) do
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
    local leafReagents = {};
    for _, node in ipairs(currentNodes) do
        local stocks = 0;
        if (node.itemId and node.itemId > 0) then
            stocks = inventoryService:GetItemAmount(node.itemId);
        end

        -- add main node row
        table.insert(directRows, {
            itemId = node.itemId,
            skillId = node.skillId,
            amount = node.amount,
            stocks = stocks,
            indent = 0,
            isNode = true,
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
                for reagentItemId, reagentPerCraft in pairs(skillInfo.reagents) do
                    local needed = missing * reagentPerCraft;
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

            table.insert(derivedRows, {
                itemId = node.itemId,
                skillId = node.skillId,
                amount = node.amount,
                stocks = stocks,
                indent = 0,
                isNode = true,
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
                    for reagentItemId, reagentPerCraft in pairs(skillInfo.reagents) do
                        local needed = missing * reagentPerCraft;
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
                                if (not visited[reagentItemId]) then
                                    if (not nextLevel[reagentItemId]) then
                                        nextLevel[reagentItemId] = { skillId = reagentSkillId, amount = 0 };
                                    end
                                    nextLevel[reagentItemId].amount = nextLevel[reagentItemId].amount + needed;
                                end
                            else
                                if (not leafReagents[reagentItemId]) then
                                    leafReagents[reagentItemId] = 0;
                                end
                                leafReagents[reagentItemId] = leafReagents[reagentItemId] + needed;
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

    -- add non-craftable leaf reagents as root nodes in derived section
    for reagentItemId, totalNeeded in pairs(leafReagents) do
        local stocks = inventoryService:GetItemAmount(reagentItemId);
        table.insert(derivedRows, {
            itemId = reagentItemId,
            amount = totalNeeded,
            stocks = stocks,
            indent = 0,
            isNode = true,
        });
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
--- Format price in copper to display string.
-- @param copper Amount in copper.
-- @return Formatted price string.
function ProfessionsView:FormatPrice(copper)
    if (copper >= 10000) then
        return string.format('%.2f|cffffaa00g|r', copper / 10000);
    elseif (copper >= 100) then
        return string.format('%.1f|cffc7b377s|r', copper / 100);
    else
        return copper .. '|cff95524c|rp';
    end
end
