--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create panel
local SkillsListPanel = _G.professionMaster:CreateView("skills-list-panel");

--- Create skills list panel frames.
-- @param parentFrame The parent view frame to attach to.
-- @param professionsView Reference to the parent professions view.
function SkillsListPanel:Create(parentFrame, professionsView)
    self.professionsView = professionsView;
    self.rowPool = {};
    self.groupHeaderPool = {};
    self.specRowPool = {};
    self.skills = {};
    self.professionId = nil;
    self.scrollTop = 0;
    self.hidePlayerColumn = false;
    self.bucketListSkillAmount = 0;

    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- get profession ids
    local professionIds = self:GetService("profession-names"):GetProfessionIdsToShow();

    -- add skills frame
    local frame = uiService:CreatePanel(parentFrame);
    frame:SetPoint("TOPLEFT", 12, -36);
    frame:SetPoint("BOTTOMRIGHT", -12, 30);
    self.frame = frame;

    -- add item search box
    local itemSearchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    itemSearchLabel:SetPoint("TOPLEFT", 18, -15);
    itemSearchLabel:SetText(localeService:Get("ProfessionsViewSearch"));
    self.itemSearchLabel = itemSearchLabel;
    local itemSearchContainer = uiService:CreateEditBox(frame, 100);
    itemSearchContainer:SetPoint("TOPLEFT", 18, -33);
    if (professionsView.addon.isVanilla) then
        itemSearchContainer:SetPoint("RIGHT", frame, "RIGHT", -199, 0);
    else
        itemSearchContainer:SetPoint("RIGHT", frame, "RIGHT", -332, 0);
    end
    itemSearchContainer:SetHeight(22);
    local itemSearch = itemSearchContainer.editBox;
    self.itemSearch = itemSearch;
    self.itemSearchContainer = itemSearchContainer;
    itemSearch:SetScript("OnKeyDown", function(_, key)
        if (key == "ESCAPE") then
            if (professionsView.skillViewVisible) then
                professionsView:HideSkillView();
            else
                professionsView:Hide();
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
            PM_CharacterSettings.lastSearchText = itemSearch:GetText();
            self:AddSkills();
        end);
    end);

    -- add profession selection
    local professionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    professionLabel:SetText(localeService:Get("ProfessionsViewProfession"));
    self.professionLabel = professionLabel;

    -- build profession items for dropdown
    local professionItems = {{ value = 0, text = self:GetProfessionText(0) }};
    for _, professionId in ipairs(professionIds) do
        table.insert(professionItems, { value = professionId, text = self:GetProfessionText(professionId) });
    end
    if (not professionsView.addon.isVanilla) then
        table.insert(professionItems, { value = -1, text = self:GetProfessionText(-1) });
    end

    local professionSelection = uiService:CreateDropdown(frame, 160, professionItems, function(value)
        self:SelectProfession(value);
        self.itemSearch:SetFocus();
        self:AddSkills();
    end);
    if (professionsView.addon.isVanilla) then
        professionLabel:SetPoint("TOPLEFT", frame, "TOPRIGHT", -190, -15);
        professionSelection:SetPoint("TOPLEFT", frame, "TOPRIGHT", -192, -31);
    else
        professionLabel:SetPoint("TOPLEFT", frame, "TOPRIGHT", -323, -15);
        professionSelection:SetPoint("TOPLEFT", frame, "TOPRIGHT", -325, -31);
    end
    self.professionSelection = professionSelection;

    -- check if is not vanilla
    if (not professionsView.addon.isVanilla) then
        -- add addon selection
        local addonLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        addonLabel:SetPoint("TOPLEFT", frame, "TOPRIGHT", -155, -15);
        addonLabel:SetText(localeService:Get("ProfessionsViewAddon"));
        self.addonLabel = addonLabel;

        -- build addon items
        local addonItems = {{ value = nil, text = self:GetAddonText(nil) }};
        table.insert(addonItems, { value = 1, text = self:GetAddonText(1) });
        if (professionsView.addon.isBccAtLeast) then
            table.insert(addonItems, { value = 2, text = self:GetAddonText(2) });
        end
        if (professionsView.addon.isWrathAtLeast) then
            table.insert(addonItems, { value = 3, text = self:GetAddonText(3) });
        end
        if (professionsView.addon.isCataAtLeast) then
            table.insert(addonItems, { value = 4, text = self:GetAddonText(4) });
        end
        if (professionsView.addon.isMopAtLeast) then
            table.insert(addonItems, { value = 5, text = self:GetAddonText(5) });
        end

        local addonSelection = uiService:CreateDropdown(frame, 130, addonItems, function(value)
            self:SelectAddon(value);
            self.itemSearch:SetFocus();
            self:AddSkills();
        end);
        addonSelection:SetPoint("TOPLEFT", frame, "TOPRIGHT", -157, -31);
        self.addonSelection = addonSelection;
    end

    -- add category filter dropdown
    local categoryLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    categoryLabel:SetPoint("TOPLEFT", 18, -64);
    categoryLabel:SetText(localeService:Get("ProfessionsViewCategory"));
    self.categoryLabel = categoryLabel;
    local categorySelection = uiService:CreateDropdown(frame, 150, {
        { value = nil, text = localeService:Get("ProfessionsViewCategoryAll") }
    }, function(value)
        self:SelectCategory(value);
        self:AddSkills();
    end);
    categorySelection:SetPoint("TOPLEFT", 18, -80);
    self.categorySelection = categorySelection;
    self.categoryId = nil;

    -- add subcategory filter dropdown
    local subcategoryLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    subcategoryLabel:SetPoint("TOPLEFT", 188, -64);
    subcategoryLabel:SetText(localeService:Get("ProfessionsViewSubcategory"));
    self.subcategoryLabel = subcategoryLabel;
    local subcategorySelection = uiService:CreateDropdown(frame, 150, {
        { value = nil, text = localeService:Get("ProfessionsViewSubcategoryAll") }
    }, function(value)
        self:SelectSubcategory(value);
        self:AddSkills();
    end);
    subcategorySelection:SetPoint("TOPLEFT", 188, -80);
    self.subcategorySelection = subcategorySelection;
    self.subcategoryId = nil;
    self.showSubcategory = false;
    subcategoryLabel:Hide();
    subcategorySelection:Hide();

    -- add bucket list icon
    local bucketListIcon = frame:CreateTexture(nil, "OVERLAY");
    bucketListIcon:SetSize(16, 16);
    bucketListIcon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up");
    bucketListIcon:SetPoint("TOPLEFT", frame, "TOPRIGHT", -56, -113);
    self.bucketListIcon = bucketListIcon;

    -- add specialization area (between search and item list)
    local specArea = CreateFrame("Frame", nil, frame);
    specArea:SetPoint("TOPLEFT", 10, -115);
    specArea:SetPoint("RIGHT", frame, "RIGHT", -12, 0);
    specArea:SetHeight(1);
    specArea:Hide();
    self.specArea = specArea;

    -- add specialization header
    local specHeaderLabel = specArea:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    specHeaderLabel:SetPoint("TOPLEFT", 8, 0);
    specHeaderLabel:SetText(localeService:Get("Specialization"));
    self.specHeaderLabel = specHeaderLabel;

    -- add specialization players header
    local specPlayersHeader = specArea:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    specPlayersHeader:SetPoint("TOPLEFT", 282, 0);
    specPlayersHeader:SetText(localeService:Get("ProfessionsViewPlayers"));
    self.specPlayersHeader = specPlayersHeader;

    -- add skill text (anchored below spec area)
    local skillText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    skillText:SetPoint("TOPLEFT", 18, -115);
    self.skillText = skillText;
    self.skillTextDefaultTop = -115;

    -- add player text
    local playerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    playerText:SetPoint("TOPLEFT", 292, -115);
    playerText:SetText(localeService:Get("ProfessionsViewPlayers"));
    self.playerHeaderText = playerText;
    self.playerHeaderDefaultTop = -115;

    -- create scroll frame
    local scrollFrame, scrollChild, scrollElement = uiService:CreateScrollFrame(frame);
    scrollFrame:SetPoint("TOPLEFT", 10, -128);
    scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12);
    self.scrollFrameDefaultTop = -128;
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

    -- restore last settings
    self:SelectProfession(PM_CharacterSettings.lastProfession or 0);
    self:SelectAddon(PM_CharacterSettings.lastAddon);
    if (PM_CharacterSettings.lastCategory) then
        self:SelectCategory(PM_CharacterSettings.lastCategory);
        if (PM_CharacterSettings.lastSubcategory) then
            self:SelectSubcategory(PM_CharacterSettings.lastSubcategory);
        end
    end
    if (PM_CharacterSettings.lastSearchText and PM_CharacterSettings.lastSearchText ~= "") then
        self.itemSearch:SetText(PM_CharacterSettings.lastSearchText);
    end
end

--- Handle resize event.
function SkillsListPanel:OnSizeChanged()
    if (self.scrollChild and self.scrollFrame) then
        self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
    end
end

--- Focus the search box.
function SkillsListPanel:FocusSearch()
    if (self.itemSearch) then
        self.itemSearch:SetFocus();
    end
end

--- Set right margin of skills frame for bucket list visibility.
-- @param margin Right margin in pixels.
function SkillsListPanel:SetRightMargin(margin)
    if (self.frame) then
        self.frame:SetPoint("BOTTOMRIGHT", -margin, 30);
        self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
    end
end

--- Update responsive layout based on frame width.
function SkillsListPanel:UpdateResponsiveLayout()
    if (not self.frame or not self.itemSearchContainer) then return; end
    local frameWidth = self.frame:GetWidth();
    if (frameWidth < 500) then
        self.itemSearchContainer:SetPoint("RIGHT", self.frame, "RIGHT", -10, 0);
        if (self.professionLabel) then self.professionLabel:Hide(); end
        if (self.professionSelection) then self.professionSelection:Hide(); end
        if (self.addonLabel) then self.addonLabel:Hide(); end
        if (self.addonSelection) then self.addonSelection:Hide(); end
        if (self.playerHeaderText) then self.playerHeaderText:Hide(); end
        if (self.specPlayersHeader) then self.specPlayersHeader:Hide(); end
        if (self.bucketListIcon) then self.bucketListIcon:Hide(); end
        self.hidePlayerColumn = true;
    else
        if (self.professionsView.addon.isVanilla) then
            self.itemSearchContainer:SetPoint("RIGHT", self.frame, "RIGHT", -199, 0);
        else
            self.itemSearchContainer:SetPoint("RIGHT", self.frame, "RIGHT", -332, 0);
        end
        if (self.professionLabel) then self.professionLabel:Show(); end
        if (self.professionSelection) then self.professionSelection:Show(); end
        if (self.addonLabel) then self.addonLabel:Show(); end
        if (self.addonSelection) then self.addonSelection:Show(); end
        if (self.playerHeaderText) then self.playerHeaderText:Show(); end
        if (self.specPlayersHeader) then self.specPlayersHeader:Show(); end
        if (self.bucketListIcon) then self.bucketListIcon:Show(); end
        self.hidePlayerColumn = false;
    end
end

--- Get text of profession.
-- @param professionId Profession ID.
-- @return Formatted profession text with icon.
function SkillsListPanel:GetProfessionText(professionId)
    if (professionId == 0) then
        return "|T133745:16|t " .. self:GetService("locale"):Get("ProfessionsViewAllProfessions");
    end
    if (professionId == -1) then
        return "|T133739:16|t " .. self:GetService("locale"):Get("AllSpecializations");
    end
    local service = self:GetService("profession-names");
    return "|T" .. service:GetProfessionIcon(professionId) .. ":16|t  " .. service:GetProfessionName(professionId);
end

--- Select profession.
-- @param professionId Profession ID.
function SkillsListPanel:SelectProfession(professionId)
    self.professionId = professionId;
    PM_CharacterSettings.lastProfession = professionId;
    self.professionSelection:SetValue(professionId);
    self:RefreshCategoryItems();
    self:SelectCategory(nil);
end

--- Get text of addon.
-- @param addonId Addon ID.
-- @return Formatted addon text with icon.
function SkillsListPanel:GetAddonText(addonId)
    if (addonId == 1) then
        return "|T135954:16|t Vanilla";
    end
    if (addonId == 2) then
        return "|T135804:16|t TBC";
    end
    if (addonId == 3) then
        return "|T135773:16|t WOTLK";
    end
    if (addonId == 4) then
        return "|T134158:16|t Cata";
    end
    if (addonId == 5) then
        return "|T132183:16|t MoP";
    end
    return "|T135749:16|t " .. self:GetService("locale"):Get("ProfessionsViewAllAddons");
end

--- Select addon.
-- @param addonId Addon ID.
function SkillsListPanel:SelectAddon(addonId)
    if (self.professionsView.addon.isVanilla) then
        addonId = nil;
    end
    self.addonId = addonId;
    PM_CharacterSettings.lastAddon = addonId;
    if (self.addonSelection) then
        self.addonSelection:SetValue(addonId);
    end
    self:RefreshCategoryItems();
end

--- Select category filter.
function SkillsListPanel:SelectCategory(categoryId)
    self.categoryId = categoryId;
    self.subcategoryId = nil;
    PM_CharacterSettings.lastCategory = categoryId;
    PM_CharacterSettings.lastSubcategory = nil;
    if (not self.categorySelection) then
        return;
    end
    self.categorySelection:SetValue(categoryId);
    self:RefreshCategoryItems();
    if (self.subcategorySelection) then
        self.subcategorySelection:SetValue(nil);
        self:RefreshSubcategoryItems();
        if (categoryId and self:HasSubcategories()) then
            self.showSubcategory = true;
            self.subcategoryLabel:Show();
            self.subcategorySelection:Show();
        else
            self.showSubcategory = false;
            self.subcategoryLabel:Hide();
            self.subcategorySelection:Hide();
        end
    end
end

--- Select subcategory filter.
function SkillsListPanel:SelectSubcategory(subcategoryId)
    self.subcategoryId = subcategoryId;
    PM_CharacterSettings.lastSubcategory = subcategoryId;
    if (not self.subcategorySelection) then
        return;
    end
    self.subcategorySelection:SetValue(subcategoryId);
end

--- Get localized text for a main category id.
-- Category IDs: "2" (Weapons), "4:1" (Armor-Cloth), "4:2" (Armor-Leather), "4:3" (Armor-Mail),
-- "4:4" (Armor-Plate), "4:6" (Armor-Shield), "0" (Consumable), "7" (Trade Goods), "enchant" (Enchantments)
function SkillsListPanel:GetCategoryText(categoryId)
    if (not categoryId) then
        return self:GetService("locale"):Get("ProfessionsViewCategoryAll");
    end

    if (categoryId == "enchant") then
        return self:GetService("locale"):Get("ProfessionsViewEnchantment");
    end

    local parts = {strsplit(":", categoryId)};
    local classId = tonumber(parts[1]);
    local subclassId = tonumber(parts[2]);

    if (classId and subclassId) then
        -- Armor subtypes: "Armor - Cloth"
        return GetItemClassInfo(classId) .. " - " .. GetItemSubClassInfo(classId, subclassId);
    elseif (classId) then
        return GetItemClassInfo(classId);
    end

    return categoryId;
end

--- Get localized text for a subcategory id.
-- Subcategory IDs: "sub:classId:subclassId" (weapon types), "slot:INVTYPE_X" (equip slots),
-- or "ec:CategoryName" (enchant categories from spell name)
function SkillsListPanel:GetSubcategoryText(subcategoryId)
    if (not subcategoryId) then
        return self:GetService("locale"):Get("ProfessionsViewSubcategoryAll");
    end

    if (string.sub(subcategoryId, 1, 3) == "ec:") then
        return string.sub(subcategoryId, 4);
    end

    if (string.sub(subcategoryId, 1, 4) == "sub:") then
        local parts = {strsplit(":", string.sub(subcategoryId, 5))};
        local classId = tonumber(parts[1]);
        local subclassId = tonumber(parts[2]);
        if (classId and subclassId) then
            return GetItemSubClassInfo(classId, subclassId);
        end
    end

    if (string.sub(subcategoryId, 1, 5) == "slot:") then
        local equipLoc = string.sub(subcategoryId, 6);
        return _G[equipLoc] or equipLoc;
    end

    return subcategoryId;
end

--- Collect visible skill data for populating dropdowns.
function SkillsListPanel:CollectVisibleSkillData()
    local skillsService = self:GetService("skills");
    local playerService = self:GetService("player");
    local result = {};
    local professionIds;

    if (self.professionId == 0) then
        professionIds = self:GetService("profession-names"):GetProfessionIdsToShow();
    elseif (self.professionId and self.professionId > 0) then
        professionIds = {self.professionId};
    else
        return result;
    end

    for _, professionId in ipairs(professionIds) do
        local profession = PM_Professions[professionId];
        if (profession) then
            for skillId, skillEntry in pairs(profession) do
                local skillData = skillsService:GetSkillById(skillId);
                if (skillData and skillData.name) then
                    if (self.addonId == nil or self:MatchesAddon(skillData, self.addonId)) then
                        if (skillEntry.players and playerService:HasVisiblePlayers(skillEntry.players)) then
                            table.insert(result, {professionId = professionId, skillData = skillData});
                        end
                    end
                end
            end
        end
    end

    return result;
end

--- Refresh category dropdown items based on visible skills.
function SkillsListPanel:RefreshCategoryItems()
    local localeService = self:GetService("locale");
    local items = {{ value = nil, text = localeService:Get("ProfessionsViewCategoryAll") }};

    local visibleSkills = self:CollectVisibleSkillData();
    local categories = {};
    local categoryOrder = {};

    for _, entry in ipairs(visibleSkills) do
        local skillData = entry.skillData;
        local professionId = entry.professionId;
        local catId = nil;

        if (professionId == 333 and (not skillData.itemId or skillData.itemId == 0)) then
            catId = "enchant";
        elseif (skillData.classId == 4 and skillData.subclassId) then
            catId = "4:" .. skillData.subclassId;
        elseif (skillData.classId) then
            catId = tostring(skillData.classId);
        end

        if (catId and not categories[catId]) then
            categories[catId] = true;
            table.insert(categoryOrder, catId);
        end
    end

    table.sort(categoryOrder, function(a, b)
        return self:GetCategoryText(a) < self:GetCategoryText(b);
    end);

    for _, catId in ipairs(categoryOrder) do
        table.insert(items, { value = catId, text = self:GetCategoryText(catId) });
    end

    self.categorySelection:SetItems(items);
end

--- Refresh subcategory dropdown items based on visible skills and current category.
function SkillsListPanel:RefreshSubcategoryItems()
    local localeService = self:GetService("locale");
    local items = {{ value = nil, text = localeService:Get("ProfessionsViewSubcategoryAll") }};

    if (self.categoryId) then
        local visibleSkills = self:CollectVisibleSkillData();
        local subcategories = {};
        local subcategoryOrder = {};

        for _, entry in ipairs(visibleSkills) do
            local skillData = entry.skillData;
            local professionId = entry.professionId;
            local subId = nil;

            if (self.categoryId == "enchant") then
                if (professionId == 333 and skillData.enchantCategory) then
                    subId = "ec:" .. skillData.enchantCategory;
                end
            elseif (string.sub(self.categoryId, 1, 2) == "4:") then
                local catSubclassId = tonumber(string.sub(self.categoryId, 3));
                if (skillData.classId == 4 and skillData.subclassId == catSubclassId and skillData.equipLoc and skillData.equipLoc ~= "") then
                    subId = "slot:" .. skillData.equipLoc;
                end
            else
                local catClassId = tonumber(self.categoryId);
                if (catClassId and skillData.classId == catClassId and skillData.subclassId) then
                    subId = "sub:" .. skillData.classId .. ":" .. skillData.subclassId;
                end
            end

            if (subId and not subcategories[subId]) then
                subcategories[subId] = true;
                table.insert(subcategoryOrder, subId);
            end
        end

        table.sort(subcategoryOrder, function(a, b)
            return self:GetSubcategoryText(a) < self:GetSubcategoryText(b);
        end);

        for _, subId in ipairs(subcategoryOrder) do
            table.insert(items, { value = subId, text = self:GetSubcategoryText(subId) });
        end
    end

    self.subcategorySelection:SetItems(items);
end

--- Check if there are subcategories available for the current category.
function SkillsListPanel:HasSubcategories()
    if (not self.categoryId) then
        return false;
    end

    local visibleSkills = self:CollectVisibleSkillData();
    local subcategories = {};
    local count = 0;

    for _, entry in ipairs(visibleSkills) do
        local skillData = entry.skillData;
        local professionId = entry.professionId;
        local subId = nil;

        if (self.categoryId == "enchant") then
            if (professionId == 333 and skillData.enchantCategory) then
                subId = "ec:" .. skillData.enchantCategory;
            end
        elseif (string.sub(self.categoryId, 1, 2) == "4:") then
            local catSubclassId = tonumber(string.sub(self.categoryId, 3));
            if (skillData.classId == 4 and skillData.subclassId == catSubclassId and skillData.equipLoc and skillData.equipLoc ~= "") then
                subId = "slot:" .. skillData.equipLoc;
            end
        else
            local catClassId = tonumber(self.categoryId);
            if (catClassId and skillData.classId == catClassId and skillData.subclassId) then
                subId = "sub:" .. skillData.classId .. ":" .. skillData.subclassId;
            end
        end

        if (subId and not subcategories[subId]) then
            subcategories[subId] = true;
            count = count + 1;
            if (count > 1) then
                return true;
            end
        end
    end

    return false;
end

--- Check if a skill matches the given addon filter.
-- A skill matches if it originated in this addon OR has new recipes in this addon.
function SkillsListPanel:MatchesAddon(skillData, addonId)
    if (skillData.addonIds) then
        return tContains(skillData.addonIds, addonId);
    end
    return addonId == skillData.addon;
end

--- Check if a skill matches the currently selected category and subcategory filters.
function SkillsListPanel:MatchesCategory(skillData, professionId)
    -- no category filter
    if (not self.categoryId) then
        return true;
    end

    -- enchantment category (spells without item result)
    if (self.categoryId == "enchant") then
        if (professionId ~= 333 or (skillData.itemId and skillData.itemId ~= 0)) then
            return false;
        end
        if (self.subcategoryId) then
            local filterCategory = string.sub(self.subcategoryId, 4);
            return skillData.enchantCategory == filterCategory;
        end
        return true;
    end

    -- armor category (e.g. "4:1" for Cloth)
    if (string.sub(self.categoryId, 1, 2) == "4:") then
        local catSubclassId = tonumber(string.sub(self.categoryId, 3));
        if (skillData.classId ~= 4 or skillData.subclassId ~= catSubclassId) then
            return false;
        end
        if (self.subcategoryId) then
            local filterEquipLoc = string.sub(self.subcategoryId, 6);
            return skillData.equipLoc == filterEquipLoc;
        end
        return true;
    end

    -- other class categories (e.g. "2" for Weapons)
    local catClassId = tonumber(self.categoryId);
    if (catClassId) then
        if (skillData.classId ~= catClassId) then
            return false;
        end
        if (self.subcategoryId and string.sub(self.subcategoryId, 1, 4) == "sub:") then
            local parts = {strsplit(":", string.sub(self.subcategoryId, 5))};
            local filterSubclassId = tonumber(parts[2]);
            return skillData.subclassId == filterSubclassId;
        end
        return true;
    end

    return true;
end

--- Add skills.
function SkillsListPanel:AddSkills()
    local messageService = self:GetService("message");
    local localeService = self:GetService("locale");

    -- set skill text
    if (self.professionId == -1) then
        self.skillText:SetText(localeService:Get("Specialization"));
    elseif (self.professionId == 333) then
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

    -- refresh specialization rows
    self:RefreshSpecializationRows();

    -- check professions
    self.skills = {};

    -- check if all should be shown
    self.bucketListSkillAmount = 0;
    if (self.professionId == -1) then
        self:AddSpecializationSkills(searchParts);
    elseif (self.professionId == 0) then
        local professionIds = self:GetService("profession-names"):GetProfessionIdsToShow();
        for i, professionId in ipairs(professionIds) do
            self:AddFilteredSkills(professionId, self.addonId, searchParts);
        end
    else
        self:AddFilteredSkills(self.professionId, self.addonId, searchParts);
    end

    -- sort skills (skip for All Specializations mode which is pre-ordered)
    if (self.professionId ~= -1) then
        table.sort(self.skills, function(a, b)
            if (a.bucketListAmount and not b.bucketListAmount) then
                return true;
            end
            if (not a.bucketListAmount and b.bucketListAmount) then
                return false;
            end
            return a.skill.name < b.skill.name;
        end);
    end

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

    -- pre-compute player name strings
    local playerService = self:GetService("player");
    for _, skillData in ipairs(self.skills) do
        local players = skillData.players or (skillData.skill and skillData.skill.players);
        if (players) then
            skillData.playerNamesText = table.concat(playerService:CombinePlayerNames(players, 12, skillData.professionId, skillData.skillId), ", ");
        end
    end

    -- set scroll height
    self.scrollChild:SetHeight(#self.skills * 20 + (self.bucketListSkillAmount > 0 and 40 or 0));

    -- refresh rows
    self:RefreshRows();
end

--- Add filtered skills.
-- @param professionId Profession ID to filter.
-- @param addonId Addon ID to filter (nil for all).
-- @param searchParts Search parts for filtering.
function SkillsListPanel:AddFilteredSkills(professionId, addonId, searchParts)
    local profession = PM_Professions[professionId];
    local skillsService = self:GetService("skills");
    local playerService = self:GetService("player");

    if (profession) then
        for skillId, skillEntry in pairs(profession) do
            local skillData = skillsService:GetSkillById(skillId);
            if (skillData and skillData.name ~= nil) then
                if (addonId == nil or self:MatchesAddon(skillData, addonId)) then
                    if (self:MatchesCategory(skillData, professionId)) then
                    if (skillEntry.players and playerService:HasVisiblePlayers(skillEntry.players)) then
                        local bucketListAmount = PM_BucketList[skillId];

                        if (#searchParts == 0) then
                            table.insert(self.skills, {
                                professionId = professionId,
                                skillId = skillId,
                                skill = skillData,
                                players = skillEntry.players,
                                bucketListAmount = bucketListAmount
                            });
                            if (bucketListAmount) then
                                self.bucketListSkillAmount = self.bucketListSkillAmount + 1;
                            end
                        else
                            local skillValid = true;
                            for i, part in ipairs(searchParts) do
                                if (string.len(part) > 0 and string.find(string.lower(skillData.name), part) == nil) then
                                    skillValid = false;
                                    break;
                                end
                            end

                            if (skillValid) then
                                table.insert(self.skills, {
                                    professionId = professionId,
                                    skillId = skillId,
                                    skill = skillData,
                                    players = skillEntry.players,
                                    bucketListAmount = bucketListAmount
                                });
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
    end
end

--- Add specialization entries as skill rows (for "All Specializations" mode).
-- @param searchParts Search parts for filtering.
function SkillsListPanel:AddSpecializationSkills(searchParts)
    local localeService = self:GetService("locale");
    local playerService = self:GetService("player");
    local professionNamesService = self:GetService("profession-names");
    local specializationSpells = self:GetModel("specialization-spells");

    local professionOrder = professionNamesService:GetProfessionIdsToShow();

    for _, professionId in ipairs(professionOrder) do
        local specs = specializationSpells[professionId];
        if (specs) then
            local professionSpecs = {};
            for _, spec in ipairs(specs) do
                local specName = localeService:Get("Spec" .. spec.spellId);

                local players = {};
                for characterName, characterSpecs in pairs(PM_Specializations) do
                    if (characterSpecs[professionId] == spec.spellId) then
                        if (playerService:IsVisiblePlayer(characterName)) then
                            table.insert(players, characterName);
                        end
                    end
                end

                local matchesSearch = true;
                if (#searchParts > 0) then
                    for _, part in ipairs(searchParts) do
                        if (string.len(part) > 0 and string.find(string.lower(specName), part) == nil) then
                            matchesSearch = false;
                            break;
                        end
                    end
                end

                if (matchesSearch) then
                    table.insert(professionSpecs, {
                        professionId = professionId,
                        skillId = "spec_" .. spec.spellId,
                        skill = {
                            name = specName,
                            icon = spec.icon or 136240,
                            players = players,
                        },
                        isSpecialization = true,
                    });
                end
            end

            if (#professionSpecs > 0) then
                table.insert(self.skills, {
                    professionId = professionId,
                    isGroupHeader = true,
                    groupName = professionNamesService:GetProfessionName(professionId),
                });
                for _, specEntry in ipairs(professionSpecs) do
                    table.insert(self.skills, specEntry);
                end
            end
        end
    end
end

--- Refresh specialization rows above the item list.
function SkillsListPanel:RefreshSpecializationRows()
    if (not self.specArea or self.professionsView.addon.isVanilla) then return; end

    -- hide all existing spec rows
    for _, row in ipairs(self.specRowPool) do
        row:Hide();
    end

    local professionId = self.professionId;

    -- hide specs for "all professions" (0) and "all specializations" (-1)
    if (not professionId or professionId == 0 or professionId == -1) then
        self.specArea:Hide();
        self:UpdateItemAreaPosition(0);
        return;
    end

    -- get specialization spells for this profession
    local specializationSpells = self:GetModel("specialization-spells");
    local specs = specializationSpells[professionId];
    if (not specs or #specs == 0) then
        self.specArea:Hide();
        self:UpdateItemAreaPosition(0);
        return;
    end

    -- build specialization display data
    local localeService = self:GetService("locale");
    local playerService = self:GetService("player");
    local specRows = {};

    for _, spec in ipairs(specs) do
        local players = {};
        for characterName, characterSpecs in pairs(PM_Specializations) do
            if (characterSpecs[professionId] == spec.spellId) then
                if (playerService:IsVisiblePlayer(characterName)) then
                    table.insert(players, characterName);
                end
            end
        end
        local specName = localeService:Get("Spec" .. spec.spellId);
        table.insert(specRows, {
            name = specName,
            players = players,
            spellId = spec.spellId,
            icon = spec.icon or 136240,
        });
    end

    -- show spec area
    local rowHeight = 20;
    local headerHeight = 16;
    local totalHeight = headerHeight + (#specRows * rowHeight) + 4;
    self.specArea:SetHeight(totalHeight);
    self.specArea:Show();

    -- ensure enough row frames
    while (#self.specRowPool < #specRows) do
        local poolIndex = #self.specRowPool + 1;
        local row = CreateFrame("Button", nil, self.specArea, BackdropTemplateMixin and "BackdropTemplate");
        row:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]]
        });

        local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        itemText:SetPoint("TOPLEFT", 6, -3);
        row.itemText = itemText;

        local playerText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        playerText:SetPoint("TOPLEFT", 276, -4);
        playerText:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -4);
        playerText:SetJustifyH("LEFT");
        playerText:SetJustifyV("TOP");
        playerText:SetTextColor(1, 1, 1);
        row.playerText = playerText;

        -- hover effects
        row:SetScript("OnEnter", function()
            row:SetBackdropColor(0.2, 0.2, 0.2);
            GameTooltip:SetOwner(row, "ANCHOR_LEFT");
            GameTooltip:ClearLines();
            if (row.specData) then
                GameTooltip:SetText(row.specData.name);
                local playerNames = self:GetService("player"):CombinePlayerNames(row.specData.players, 5);
                GameTooltip:AddLine("|cffffffff" .. self:GetService("locale"):Get("SkillViewPlayers") .. ": " .. table.concat(playerNames, ", "));
            end
            GameTooltip:Show();
        end);
        row:SetScript("OnLeave", function()
            if (row.bgColor) then
                row:SetBackdropColor(row.bgColor, row.bgColor, row.bgColor, 0.5);
            end
            GameTooltip:Hide();
        end);

        -- click to open spec view
        row:SetScript("OnMouseDown", function(_, button)
            if (button == "LeftButton" and row.specData) then
                self.professionsView:ShowSpecView(row.specData);
            end
        end);

        self.specRowPool[poolIndex] = row;
    end

    -- populate rows
    for i, specData in ipairs(specRows) do
        local row = self.specRowPool[i];
        local top = headerHeight + (i - 1) * rowHeight;
        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", self.specArea, "TOPLEFT", 5, -top);
        row:SetPoint("RIGHT", self.specArea, "RIGHT", -28, 0);
        row:SetHeight(rowHeight);

        local backgroundColor = (i % 2 == 0) and 0.12 or 0.06;
        row.bgColor = backgroundColor;
        row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

        row.specData = specData;
        row.itemText:SetText("|T" .. specData.icon .. ":16|t " .. specData.name);

        if (self.hidePlayerColumn) then
            row.playerText:Hide();
        else
            row.playerText:Show();
            row.playerText:SetText(table.concat(playerService:CombinePlayerNames(specData.players, 12), ", "));
        end

        row:Show();
    end

    -- update item area position
    self:UpdateItemAreaPosition(totalHeight);
end

--- Update the item area position based on specialization area height.
-- @param specHeight Height of the specialization area.
function SkillsListPanel:UpdateItemAreaPosition(specHeight)
    if (not self.skillText) then return; end
    local offset = specHeight > 0 and (specHeight + 4) or 0;
    local skillTextTop = self.skillTextDefaultTop - offset;
    local playerHeaderTop = self.playerHeaderDefaultTop - offset;
    local scrollFrameTop = self.scrollFrameDefaultTop - offset;

    self.skillText:ClearAllPoints();
    self.skillText:SetPoint("TOPLEFT", 18, skillTextTop);

    self.playerHeaderText:ClearAllPoints();
    self.playerHeaderText:SetPoint("TOPLEFT", 292, playerHeaderTop);

    self.bucketListIcon:ClearAllPoints();
    self.bucketListIcon:SetPoint("TOPLEFT", self.frame, "TOPRIGHT", -56, skillTextTop - 2 + 4);

    self.scrollFrame:ClearAllPoints();
    self.scrollFrame:SetPoint("TOPLEFT", 10, scrollFrameTop);
    self.scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12);

    if (self.scrollChild and self.scrollFrame) then
        self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
    end
end

--- Refresh rows.
function SkillsListPanel:RefreshRows()
    -- get visible range based on actual scroll frame height
    local visibleRowCount = math.ceil((self.scrollFrame:GetHeight() or 400) / 20) + 6;
    local startIndex = math.max(math.floor(self.scrollTop / 20) - 3, 1);
    local endIndex = math.min(startIndex + visibleRowCount, #self.skills);
    local visibleCount = endIndex - startIndex + 1;

    -- ensure pool has enough frames
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
        playerText:SetPoint("TOPLEFT", 276, -4);
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
            self:GetService("tooltip"):ShowTooltip(GameTooltip, row.professionId, row.skillId, row.skill, row.players);
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
                if (row.isSpecialization) then
                    self.professionsView:ShowSpecView({
                        name = row.skill.name,
                        players = row.skill.players,
                        icon = row.skill.icon,
                        professionId = row.professionId,
                    });
                else
                    self.professionsView:ShowSkillView(row);
                end
            end
        end);

        self.rowPool[poolIndex] = row;
    end

    -- hide all pooled frames first
    for _, row in ipairs(self.rowPool) do
        row:Hide();
    end

    -- hide all group header labels
    for _, label in ipairs(self.groupHeaderPool) do
        label:Hide();
    end
    local groupHeaderIndex = 0;

    -- bind pool frames to visible data
    local poolUsed = 0;
    for i = 0, visibleCount - 1 do
        local rowIndex = startIndex + i;
        local skillData = self.skills[rowIndex];

        -- calculate top position
        local top = (rowIndex - 1) * 20;
        if (self.bucketListSkillAmount > 0 and skillData.bucketListAmount) then
            top = top + 20;
        elseif(self.bucketListSkillAmount > 0 and not skillData.bucketListAmount) then
            top = top + 40;
        end

        -- check if this is a group header
        if (skillData.isGroupHeader) then
            groupHeaderIndex = groupHeaderIndex + 1;
            if (not self.groupHeaderPool[groupHeaderIndex]) then
                local label = self.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                label:SetFont("Fonts\\FRIZQT__.TTF", 10);
                self.groupHeaderPool[groupHeaderIndex] = label;
            end
            local label = self.groupHeaderPool[groupHeaderIndex];
            label:ClearAllPoints();
            label:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 4, -(top + 6));
            label:SetText(skillData.groupName);
            label:Show();
        else
            poolUsed = poolUsed + 1;
            local row = self.rowPool[poolUsed];
            if (not row) then break; end

            local professionId = skillData.professionId;
            local skillId = skillData.skillId;
            local skill = skillData.skill;
            local bucketListAmount = skillData.bucketListAmount;

            -- set background color by data index
            self:GetService("ui"):SetRowColor(row, rowIndex);

            row:ClearAllPoints();
            row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -top);
            row:SetPoint("BOTTOMRIGHT", self.scrollChild, "TOPRIGHT", -28, -(top + 20));

            -- set item text
            local itemName = skill.itemColor and ("|c" .. skill.itemColor .. skill.name) or skill.name;
            local skillInfo = self:GetService("skills"):GetSkillById(skillId);
            local itemAmount = skillInfo and skillInfo.itemAmount;
            if (itemAmount and itemAmount > 1) then
                itemName = itemName .. "|r x" .. itemAmount;
            end
            row.itemText:SetText("|T" .. skill.icon .. ":16|t " .. itemName);

            -- set player text (use pre-computed cache from AddSkills)
            if (self.hidePlayerColumn) then
                row.playerText:Hide();
            else
                row.playerText:Show();
                row.playerText:SetText(skillData.playerNamesText or "");
            end

            -- set bucket list text
            row.bucketListText:SetText(bucketListAmount);

            -- store data on row
            row.professionId = professionId;
            row.skill = skill;
            row.skillId = skillId;
            row.players = skillData.players or (skill and skill.players);
            row.isSpecialization = skillData.isSpecialization;

            -- show
            row:Show();
        end
    end
end
