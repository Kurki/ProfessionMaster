--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create panel
local OwnSkillList = _G.professionMaster:CreateView("own-skill-list");

-- max skill levels per addon per profession
local MAX_SKILL_LEVELS = {
    -- default (most professions)
    default = { [1] = 300, [2] = 375, [3] = 450, [4] = 525, [5] = 600 },
};

--- Get max skill level for a profession and addon.
local function GetMaxSkillLevel(professionId, addonId)
    if (not addonId) then
        return 300;
    end
    local levels = MAX_SKILL_LEVELS[professionId] or MAX_SKILL_LEVELS.default;
    return levels[addonId] or 300;
end

--- Get the addon ID of the currently running game client.
function OwnSkillList:GetCurrentAddonId()
    local addon = self.professionsView.addon;
    if (addon.isMop) then return 5; end
    if (addon.isCata) then return 4; end
    if (addon.isWrath) then return 3; end
    if (addon.isBcc) then return 2; end
    return 1;
end

--- Create own skill list panel.
-- @param parentFrame The parent frame.
-- @param professionsView Reference to the parent professions view.
function OwnSkillList:Create(parentFrame, professionsView)
    self.professionsView = professionsView;
    self.rowPool = {};
    self.groupHeaderPool = {};
    self.skills = {};
    self.professionId = PM_CharacterSettings.lastOwnProfession or 0;
    self.addonId = PM_CharacterSettings.lastOwnAddon;
    self.categoryId = PM_CharacterSettings.lastOwnCategory;
    self.subcategoryId = PM_CharacterSettings.lastOwnSubcategory;
    self.scrollTop = 0;
    self.bucketListSkillAmount = 0;

    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");
    local addon = professionsView.addon;

    -- add frame
    local frame = CreateFrame("Frame", nil, parentFrame);
    frame:SetPoint("TOPLEFT", 0, 0);
    frame:SetPoint("BOTTOMRIGHT", 0, 0);
    self.frame = frame;

    -- add search box
    local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    searchLabel:SetPoint("TOPLEFT", 12, -12);
    searchLabel:SetText(localeService:Get("ProfessionsViewSearch"));
    self.searchLabel = searchLabel;

    local searchContainer = uiService:CreateEditBox(frame, 100);
    searchContainer:SetPoint("TOPLEFT", 12, -28);
    if (addon.isVanilla) then
        searchContainer:SetPoint("RIGHT", frame, "RIGHT", -199, 0);
    else
        searchContainer:SetPoint("RIGHT", frame, "RIGHT", -332, 0);
    end
    searchContainer:SetHeight(22);
    self.searchContainer = searchContainer;
    local searchBox = searchContainer.editBox;
    self.searchBox = searchBox;

    searchBox:SetScript("OnTextChanged", function()
        if (self.searchPending) then
            self.searchPending:Cancel();
        end
        self.searchPending = C_Timer.NewTimer(0.2, function()
            self.searchPending = nil;
            PM_CharacterSettings.lastOwnSearchText = self.searchBox:GetText();
            self:AddSkills();
        end);
    end);
    searchBox:SetScript("OnKeyDown", function(_, key)
        if (key == "ESCAPE") then
            professionsView:Hide();
        elseif (key == "ENTER") then
            ChatFrame_OpenChat("", nil, nil);
        end
    end);

    -- add profession dropdown
    local professionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    professionLabel:SetText(localeService:Get("ProfessionsViewProfession"));
    self.professionLabel = professionLabel;

    local professionSelection = uiService:CreateDropdown(frame, 160, {}, function(value)
        self.professionId = value;
        PM_CharacterSettings.lastOwnProfession = value;
        self:RefreshAddonItems();
        self:RefreshCategoryItems();
        self:SelectCategory(nil);
        self:RefreshProgressBar();
        self.searchBox:SetFocus();
        self:AddSkills();
    end);
    if (addon.isVanilla) then
        professionLabel:SetPoint("TOPLEFT", frame, "TOPRIGHT", -190, -12);
        professionSelection:SetPoint("TOPLEFT", frame, "TOPRIGHT", -192, -28);
    else
        professionLabel:SetPoint("TOPLEFT", frame, "TOPRIGHT", -323, -12);
        professionSelection:SetPoint("TOPLEFT", frame, "TOPRIGHT", -325, -28);
    end
    self.professionSelection = professionSelection;

    -- add addon dropdown
    if (not addon.isVanilla) then
        local addonLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        addonLabel:SetPoint("TOPLEFT", frame, "TOPRIGHT", -155, -12);
        addonLabel:SetText(localeService:Get("ProfessionsViewAddon"));
        self.addonLabel = addonLabel;

        local addonItems = self:BuildAddonItems();
        local addonSelection = uiService:CreateDropdown(frame, 130, addonItems, function(value)
            self:SelectAddon(value);
            self:RefreshProgressBar();
            self.searchBox:SetFocus();
            self:AddSkills();
        end);
        addonSelection:SetPoint("TOPLEFT", frame, "TOPRIGHT", -157, -28);
        self.addonSelection = addonSelection;

        -- set initial addon value
        if (self.addonId) then
            addonSelection:SetValue(self.addonId);
        end
    else
        self.addonId = 1;
    end

    -- add category filter dropdown
    local categoryLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    categoryLabel:SetPoint("TOPLEFT", 12, -58);
    categoryLabel:SetText(localeService:Get("ProfessionsViewCategory"));
    self.categoryLabel = categoryLabel;
    local categorySelection = uiService:CreateDropdown(frame, 150, {
        { value = nil, text = localeService:Get("ProfessionsViewCategoryAll") }
    }, function(value)
        self:SelectCategory(value);
        self:AddSkills();
    end);
    categorySelection:SetPoint("TOPLEFT", 12, -74);
    self.categorySelection = categorySelection;

    -- add subcategory filter dropdown
    local subcategoryLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    subcategoryLabel:SetPoint("TOPLEFT", 182, -58);
    subcategoryLabel:SetText(localeService:Get("ProfessionsViewSubcategory"));
    self.subcategoryLabel = subcategoryLabel;
    local subcategorySelection = uiService:CreateDropdown(frame, 150, {
        { value = nil, text = localeService:Get("ProfessionsViewSubcategoryAll") }
    }, function(value)
        self:SelectSubcategory(value);
        self:AddSkills();
    end);
    subcategorySelection:SetPoint("TOPLEFT", 182, -74);
    self.subcategorySelection = subcategorySelection;
    self.showSubcategory = false;
    subcategoryLabel:Hide();
    subcategorySelection:Hide();

    -- add progress bar
    local progressBarFrame = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate");
    progressBarFrame:SetPoint("TOPLEFT", 12, -102);
    progressBarFrame:SetPoint("RIGHT", frame, "RIGHT", -12, 0);
    progressBarFrame:SetHeight(24);
    progressBarFrame:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8x8]] });
    progressBarFrame:SetBackdropColor(0.15, 0.15, 0.15, 1);
    progressBarFrame:Hide();
    self.progressBarFrame = progressBarFrame;

    local progressBarFill = CreateFrame("Frame", nil, progressBarFrame, BackdropTemplateMixin and "BackdropTemplate");
    progressBarFill:SetPoint("TOPLEFT", 0, -2);
    progressBarFill:SetPoint("BOTTOMLEFT", 0, 2);
    progressBarFill:SetWidth(1);
    progressBarFill:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8x8]] });
    progressBarFill:SetBackdropColor(0.1, 0.7, 0.1, 1);
    self.progressBarFill = progressBarFill;

    local progressBarTextFrame = CreateFrame("Frame", nil, progressBarFrame);
    progressBarTextFrame:SetAllPoints(progressBarFrame);
    progressBarTextFrame:SetFrameLevel(progressBarFill:GetFrameLevel() + 2);
    local progressBarText = progressBarTextFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    progressBarText:SetPoint("CENTER", progressBarFrame, "CENTER", 0, 0);
    progressBarText:SetTextColor(1, 1, 1, 1);
    self.progressBarText = progressBarText;

    -- add skill header
    local skillText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    skillText:SetPoint("TOPLEFT", 12, -132);
    self.skillText = skillText;

    -- add difficulty header
    local difficultyText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    difficultyText:SetPoint("TOPLEFT", 286, -132);
    difficultyText:SetText(localeService:Get("ProfessionsViewDifficulty") or "Difficulty");
    self.difficultyText = difficultyText;

    -- add bucket list header label
    local bucketListText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    bucketListText:SetPoint("TOPLEFT", frame, "TOPRIGHT", -56, -132);
    bucketListText:SetText("");
    self.bucketListHeader = bucketListText;

    -- create scroll frame
    local scrollParent, scrollChild, scrollElement = uiService:CreateScrollFrame(frame);
    scrollParent:SetPoint("TOPLEFT", 6, -148);
    scrollParent:SetPoint("BOTTOMRIGHT", -8, 8);
    scrollChild:SetWidth(scrollParent:GetWidth());
    self.scrollFrame = scrollParent;
    self.scrollChild = scrollChild;
    self.scrollElement = scrollElement;

    scrollElement:SetScript("OnVerticalScroll", function(_, offset)
        self.scrollTop = offset;
        self:RefreshRows();
    end);

    scrollParent:SetScript("OnSizeChanged", function(_, width)
        scrollChild:SetWidth(width);
    end);

    -- add bucket list group text
    local bucketListGroupText = self.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    bucketListGroupText:SetPoint("TOPLEFT", 4, -6);
    bucketListGroupText:SetTextColor(1, 0.84, 0, 1);
    bucketListGroupText:SetText(localeService:Get("ProfessionsViewBucketList"));
    bucketListGroupText:Hide();
    self.bucketListGroupText = bucketListGroupText;

    -- add other group text
    local otherGroupText = self.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    otherGroupText:SetPoint("TOPLEFT", 4, -26);
    otherGroupText:SetTextColor(1, 0.84, 0, 1);
    otherGroupText:SetText(localeService:Get("ProfessionsViewNotOnBucketList"));
    otherGroupText:Hide();
    self.otherGroupText = otherGroupText;

    -- restore search text
    if (PM_CharacterSettings.lastOwnSearchText and PM_CharacterSettings.lastOwnSearchText ~= "") then
        self.searchBox:SetText(PM_CharacterSettings.lastOwnSearchText);
    end

    -- add empty state message (centered)
    local emptyContainer = CreateFrame("Frame", nil, frame);
    emptyContainer:SetPoint("CENTER", frame, "CENTER", 0, 0);
    emptyContainer:SetSize(400, 60);
    emptyContainer:Hide();
    self.emptyMessage = emptyContainer;

    local emptyTitle = emptyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    emptyTitle:SetPoint("TOP", emptyContainer, "TOP", 0, 0);
    emptyTitle:SetJustifyH("CENTER");
    emptyTitle:SetTextColor(0.7, 0.7, 0.7, 1);
    emptyTitle:SetText(localeService:Get("OwnNoProfessionsTitle"));

    local emptyDescription = emptyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    emptyDescription:SetPoint("TOP", emptyTitle, "BOTTOM", 0, -8);
    emptyDescription:SetJustifyH("CENTER");
    emptyDescription:SetTextColor(0.5, 0.5, 0.5, 1);
    emptyDescription:SetText(localeService:Get("OwnNoProfessionsDescription"));
end

--- Get formatted profession text.
function OwnSkillList:GetProfessionText(professionId)
    if (professionId == 0) then
        return "|T133739:16|t " .. self:GetService("locale"):Get("ProfessionsViewAllProfessions");
    end
    local service = self:GetService("profession-names");
    return "|T" .. service:GetProfessionIcon(professionId) .. ":16|t  " .. service:GetProfessionName(professionId);
end

--- Get text of addon.
function OwnSkillList:GetAddonText(addonId)
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
    return nil;
end

--- Build addon dropdown items.
function OwnSkillList:BuildAddonItems()
    local addon = self.professionsView.addon;
    local localeService = self:GetService("locale");
    local items = {{ value = nil, text = "|T135749:16|t " .. localeService:Get("ProfessionsViewAllAddons") }};
    table.insert(items, { value = 1, text = self:GetAddonText(1) });
    if (addon.isBccAtLeast) then
        table.insert(items, { value = 2, text = self:GetAddonText(2) });
    end
    if (addon.isWrathAtLeast) then
        table.insert(items, { value = 3, text = self:GetAddonText(3) });
    end
    if (addon.isCataAtLeast) then
        table.insert(items, { value = 4, text = self:GetAddonText(4) });
    end
    if (addon.isMopAtLeast) then
        table.insert(items, { value = 5, text = self:GetAddonText(5) });
    end
    return items;
end

--- Refresh addon dropdown items based on the selected profession.
function OwnSkillList:RefreshAddonItems()
    if (not self.addonSelection) then
        return;
    end
    local items = self:BuildAddonItems();
    self.addonSelection:SetItems(items);
    -- validate current addon is still in the list
    local valid = false;
    for _, item in ipairs(items) do
        if (item.value == self.addonId) then
            valid = true;
            break;
        end
    end
    if (not valid and #items > 0) then
        self.addonId = items[#items].value;
        PM_CharacterSettings.lastOwnAddon = self.addonId;
    end
    self.addonSelection:SetValue(self.addonId);
end

--- Select addon.
function OwnSkillList:SelectAddon(addonId)
    self.addonId = addonId;
    PM_CharacterSettings.lastOwnAddon = addonId;
    if (self.addonSelection) then
        self.addonSelection:SetValue(addonId);
    end
    self:RefreshCategoryItems();
    self:SelectCategory(nil);
end

--- Select category filter.
function OwnSkillList:SelectCategory(categoryId)
    self.categoryId = categoryId;
    self.subcategoryId = nil;
    PM_CharacterSettings.lastOwnCategory = categoryId;
    PM_CharacterSettings.lastOwnSubcategory = nil;
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
function OwnSkillList:SelectSubcategory(subcategoryId)
    self.subcategoryId = subcategoryId;
    PM_CharacterSettings.lastOwnSubcategory = subcategoryId;
    if (not self.subcategorySelection) then
        return;
    end
    self.subcategorySelection:SetValue(subcategoryId);
end

--- Get localized text for a main category id.
function OwnSkillList:GetCategoryText(categoryId)
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
        return GetItemClassInfo(classId) .. " - " .. GetItemSubClassInfo(classId, subclassId);
    elseif (classId) then
        return GetItemClassInfo(classId);
    end

    return categoryId;
end

--- Get localized text for a subcategory id.
function OwnSkillList:GetSubcategoryText(subcategoryId)
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

--- Check if a skill matches the given addon filter.
function OwnSkillList:MatchesAddon(skillData, addonId)
    if (skillData.addonIds) then
        return tContains(skillData.addonIds, addonId);
    end
    return addonId == skillData.addon;
end

--- Check if a skill matches the currently selected category and subcategory filters.
function OwnSkillList:MatchesCategory(skillData, professionId)
    if (not self.categoryId) then
        return true;
    end

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

--- Collect visible own skill data for populating dropdowns.
function OwnSkillList:CollectVisibleSkillData()
    local skillsService = self:GetService("skills");
    local playerService = self:GetService("player");
    local currentPlayer = playerService.current;
    local result = {};

    local ownProfessions = PM_OwnProfessions[currentPlayer];
    if (not ownProfessions) then
        return result;
    end

    local professionIds;
    if (self.professionId == 0) then
        professionIds = self:GetService("profession-names"):GetProfessionIdsToShow();
    elseif (self.professionId and self.professionId > 0) then
        professionIds = {self.professionId};
    else
        return result;
    end

    for _, professionId in ipairs(professionIds) do
        local ownSkills = ownProfessions[professionId];
        if (ownSkills) then
            for _, ownSkill in ipairs(ownSkills) do
                local skillData = skillsService:GetSkillById(ownSkill.skillId);
                if (skillData and skillData.name) then
                    if (self.addonId == nil or self:MatchesAddon(skillData, self.addonId)) then
                        table.insert(result, {professionId = professionId, skillData = skillData});
                    end
                end
            end
        end
    end

    return result;
end

--- Refresh category dropdown items based on visible skills.
function OwnSkillList:RefreshCategoryItems()
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
function OwnSkillList:RefreshSubcategoryItems()
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
function OwnSkillList:HasSubcategories()
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

--- Refresh progress bar with current skill level.
function OwnSkillList:RefreshProgressBar()
    local currentLevel = 0;
    local maxLevel = 300;

    -- only show if we have a stored level for this profession
    local hasStoredLevel = PM_CharacterSettings.professionLevels
        and self.professionId and self.professionId > 0
        and PM_CharacterSettings.professionLevels[self.professionId];

    if (not hasStoredLevel) then
        self.progressBarFrame:Hide();
        return;
    end

    currentLevel = PM_CharacterSettings.professionLevels[self.professionId];

    -- use the addon of the current game client, not the filter selection
    local currentAddonId = self:GetCurrentAddonId();
    if (currentAddonId) then
        maxLevel = GetMaxSkillLevel(self.professionId, currentAddonId);
    end

    -- clamp current level to max
    local displayLevel = math.min(currentLevel, maxLevel);
    local fillRatio = maxLevel > 0 and (displayLevel / maxLevel) or 0;
    local barWidth = self.progressBarFrame:GetWidth();
    local fillWidth = math.max(1, barWidth * fillRatio);

    self.progressBarFill:SetWidth(fillWidth);
    self.progressBarText:SetText(displayLevel .. " / " .. maxLevel);
    self.progressBarFrame:Show();
end

--- Handle resize.
function OwnSkillList:OnSizeChanged()
    if (self.scrollChild and self.scrollFrame) then
        self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
    end
    self:RefreshProgressBar();
end

--- Set right margin.
function OwnSkillList:SetRightMargin(margin)
    if (self.frame) then
        self.frame:SetPoint("BOTTOMRIGHT", -margin, 0);
        if (self.scrollChild and self.scrollFrame) then
            self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
        end
    end
end

--- Add and filter skills.
function OwnSkillList:AddSkills()
    local messageService = self:GetService("message");
    local localeService = self:GetService("locale");
    local skillsService = self:GetService("skills");
    local playerService = self:GetService("player");
    local currentPlayer = playerService.current;

    -- determine which professions the current player has from PM_OwnProfessions
    local allProfessionIds = self:GetService("profession-names"):GetProfessionIdsToShow();
    local ownProfessionIds = {};
    local ownProfessions = PM_OwnProfessions[currentPlayer];
    if (ownProfessions) then
        for _, professionId in ipairs(allProfessionIds) do
            if (ownProfessions[professionId]) then
                table.insert(ownProfessionIds, professionId);
            end
        end
    end

    -- show empty state if no own professions
    if (#ownProfessionIds == 0) then
        self.searchLabel:Hide();
        self.searchContainer:Hide();
        self.professionLabel:Hide();
        self.professionSelection:Hide();
        self.skillText:Hide();
        self.difficultyText:Hide();
        self.bucketListHeader:Hide();
        self.scrollFrame:Hide();
        self.progressBarFrame:Hide();
        self.categoryLabel:Hide();
        self.categorySelection:Hide();
        self.subcategoryLabel:Hide();
        self.subcategorySelection:Hide();
        if (self.addonLabel) then self.addonLabel:Hide(); end
        if (self.addonSelection) then self.addonSelection:Hide(); end
        self.emptyMessage:Show();
        return;
    end

    -- show controls
    self.searchLabel:Show();
    self.searchContainer:Show();
    self.professionLabel:Show();
    self.professionSelection:Show();
    self.skillText:Show();
    self.difficultyText:Show();
    self.scrollFrame:Show();
    self.categoryLabel:Show();
    self.categorySelection:Show();
    if (self.addonLabel) then self.addonLabel:Show(); end
    if (self.addonSelection) then self.addonSelection:Show(); end
    self.emptyMessage:Hide();

    -- show/hide subcategory based on previous state
    if (self.showSubcategory) then
        self.subcategoryLabel:Show();
        self.subcategorySelection:Show();
    else
        self.subcategoryLabel:Hide();
        self.subcategorySelection:Hide();
    end

    -- rebuild dropdown items with only own professions (no "all professions" option)
    local professionItems = {};
    for _, professionId in ipairs(ownProfessionIds) do
        table.insert(professionItems, { value = professionId, text = self:GetProfessionText(professionId) });
    end
    self.professionSelection:SetItems(professionItems);

    -- validate saved profession is still valid
    local validProfession = false;
    for _, item in ipairs(professionItems) do
        if (item.value == self.professionId) then
            validProfession = true;
            break;
        end
    end
    if (not validProfession) then
        self.professionId = ownProfessionIds[1] or 0;
    end
    self.professionSelection:SetValue(self.professionId);

    -- refresh progress bar
    self:RefreshProgressBar();

    -- set column header
    self.skillText:SetText(localeService:Get("ProfessionsViewItem"));

    -- get search parts
    local searchText = string.lower(messageService:TrimString(self.searchBox:GetText()));
    local searchParts = messageService:SplitString(string.gsub(searchText, "%-", "%%-"), " ");
    for i, part in ipairs(searchParts) do
        searchParts[i] = messageService:TrimString(searchParts[i]);
    end

    self.skills = {};
    self.bucketListSkillAmount = 0;

    local professionIds;
    if (self.professionId == 0) then
        professionIds = ownProfessionIds;
    else
        professionIds = { self.professionId };
    end

    -- get current skill level
    local currentSkillLevel = 0;
    if (PM_CharacterSettings.professionLevels and self.professionId > 0) then
        currentSkillLevel = PM_CharacterSettings.professionLevels[self.professionId] or 0;
    end

    for _, professionId in ipairs(professionIds) do
        local ownSkills = ownProfessions and ownProfessions[professionId];
        if (ownSkills) then
            for _, ownSkill in ipairs(ownSkills) do
                local skillId = ownSkill.skillId;
                local skillData = skillsService:GetSkillById(skillId);
                if (skillData and skillData.name ~= nil) then
                    -- apply addon filter
                    if (self.addonId and not self:MatchesAddon(skillData, self.addonId)) then
                        -- skip
                    -- apply category/subcategory filter
                    elseif (not self:MatchesCategory(skillData, professionId)) then
                        -- skip
                    else
                        local bucketListAmount = PM_BucketList[skillId];
                        local matchesSearch = true;

                        if (#searchParts > 0) then
                            for _, part in ipairs(searchParts) do
                                if (string.len(part) > 0 and string.find(string.lower(skillData.name), part) == nil) then
                                    matchesSearch = false;
                                    break;
                                end
                            end
                        end

                        if (matchesSearch) then
                            table.insert(self.skills, {
                                professionId = professionId,
                                skillId = skillId,
                                skill = skillData,
                                bucketListAmount = bucketListAmount,
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

    -- sort: bucket list items first, then by difficulty (d4, d3, d2, d1 descending), then alphabetical
    table.sort(self.skills, function(a, b)
        if (a.bucketListAmount and not b.bucketListAmount) then return true; end
        if (not a.bucketListAmount and b.bucketListAmount) then return false; end
        local ad = a.skill.difficulty;
        local bd = b.skill.difficulty;
        local ad4 = ad and ad[4] or 0;
        local bd4 = bd and bd[4] or 0;
        if (ad4 ~= bd4) then return ad4 > bd4; end
        local ad3 = ad and ad[3] or 0;
        local bd3 = bd and bd[3] or 0;
        if (ad3 ~= bd3) then return ad3 > bd3; end
        local ad2 = ad and ad[2] or 0;
        local bd2 = bd and bd[2] or 0;
        if (ad2 ~= bd2) then return ad2 > bd2; end
        local ad1 = ad and ad[1] or 0;
        local bd1 = bd and bd[1] or 0;
        if (ad1 ~= bd1) then return ad1 > bd1; end
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

    -- store for row rendering
    self.currentSkillLevel = currentSkillLevel;

    -- refresh rows
    self:RefreshRows();
end

--- Get difficulty color string for a skill.
function OwnSkillList:GetDifficultyText(skillData)
    if (not skillData.difficulty) then
        return nil;
    end

    local d1 = skillData.difficulty[1] or 0;
    local d2 = skillData.difficulty[2] or 0;
    local d3 = skillData.difficulty[3] or 0;
    local d4 = skillData.difficulty[4] or 0;
    local level = self.currentSkillLevel or 0;

    local values = {d1, d2, d3, d4};

    -- determine which difficulty is the active one (highest reached)
    -- d1=lowest (orange), d2=yellow, d3=green, d4=highest (grey)
    local activeIndex = nil;
    local activeColor = nil;

    if (level >= d4) then
        activeIndex = 4;
        activeColor = "|cff808080"; -- grey (trivial)
    elseif (level >= d3) then
        activeIndex = 3;
        activeColor = "|cff40c040"; -- green
    elseif (level >= d2) then
        activeIndex = 2;
        activeColor = "|cffffff00"; -- yellow
    elseif (level >= d1) then
        activeIndex = 1;
        activeColor = "|cffff8040"; -- orange
    else
        -- lowest threshold not reached: highlight d1 in red
        activeIndex = 1;
        activeColor = "|cffff4040"; -- red
    end

    local result = {};
    for i, value in ipairs(values) do
        if (value > 0) then
            if (i == activeIndex) then
                result[i] = activeColor .. value .. "|r";
            else
                result[i] = "|cff404040" .. value .. "|r";
            end
        else
            result[i] = "";
        end
    end

    return result;
end

--- Refresh visible rows.
function OwnSkillList:RefreshRows()
    if (not self.skills or #self.skills == 0) then
        for _, row in ipairs(self.rowPool) do
            row:Hide();
        end
        return;
    end

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
        itemText:SetPoint("TOPLEFT", 3, -3);
        row.itemText = itemText;

        -- add difficulty value labels (4 fixed-width columns)
        row.difficultyLabels = {};
        for di = 1, 4 do
            local diffLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            diffLabel:SetPoint("TOPLEFT", 276 + (di - 1) * 32, -3);
            diffLabel:SetWidth(28);
            diffLabel:SetJustifyH("RIGHT");
            row.difficultyLabels[di] = diffLabel;
        end

        -- add bucket list count
        local bucketText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        bucketText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -6, -3);
        bucketText:SetJustifyH("RIGHT");
        row.bucketText = bucketText;

        -- hover
        row:SetScript("OnEnter", function()
            row:SetBackdropColor(0.2, 0.2, 0.2);
            GameTooltip:SetOwner(row, "ANCHOR_LEFT");
            self:GetService("tooltip"):ShowTooltip(GameTooltip, row.professionId, row.skillId, row.skill, nil);
        end);
        row:SetScript("OnLeave", function()
            if (row.bgColor) then
                row:SetBackdropColor(row.bgColor, row.bgColor, row.bgColor, 0.5);
            end
            GameTooltip:Hide();
        end);

        -- click
        row:SetScript("OnMouseDown", function(_, button)
            if (button == "LeftButton") and IsShiftKeyDown() and ChatEdit_GetActiveWindow() then
                if (row.skill and row.skill.itemLink) then
                    ChatEdit_InsertLink(row.skill.itemLink);
                end
            elseif (button == "LeftButton") then
                self.professionsView:ShowSkillView(row);
            end
        end);

        self.rowPool[poolIndex] = row;
    end

    -- hide all pooled frames
    for _, row in ipairs(self.rowPool) do
        row:Hide();
    end

    -- render visible rows
    local poolUsed = 0;
    for i = 0, visibleCount - 1 do
        local rowIndex = startIndex + i;
        local skillData = self.skills[rowIndex];
        if (skillData) then
            poolUsed = poolUsed + 1;
            local row = self.rowPool[poolUsed];

            local top = (rowIndex - 1) * 20;
            if (self.bucketListSkillAmount > 0 and skillData.bucketListAmount) then
                top = top + 20;
            elseif (self.bucketListSkillAmount > 0 and not skillData.bucketListAmount) then
                top = top + 40;
            end

            row:ClearAllPoints();
            row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -top);
            row:SetPoint("RIGHT", self.scrollChild, "RIGHT", -28, 0);
            row:SetHeight(20);

            local backgroundColor = (rowIndex % 2 == 0) and 0.12 or 0.06;
            row.bgColor = backgroundColor;
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

            row.professionId = skillData.professionId;
            row.skillId = skillData.skillId;
            row.skill = skillData.skill;

            -- set item text with icon and item color
            local icon = skillData.skill.icon or 134400;
            local itemName = skillData.skill.itemColor and ("|c" .. skillData.skill.itemColor .. skillData.skill.name) or skillData.skill.name;
            local skillInfo = self:GetService("skills"):GetSkillById(skillData.skillId);
            local itemAmount = skillInfo and skillInfo.itemAmount;
            if (itemAmount and itemAmount > 1) then
                itemName = itemName .. "|r x" .. itemAmount;
            end
            row.itemText:SetText("|T" .. icon .. ":16|t  " .. itemName);

            -- set difficulty text
            local diffTexts = self:GetDifficultyText(skillData.skill);
            if (diffTexts) then
                for di = 1, 4 do
                    row.difficultyLabels[di]:SetText(diffTexts[di] or "");
                end
            else
                for di = 1, 4 do
                    row.difficultyLabels[di]:SetText("");
                end
            end

            -- set bucket list amount
            if (skillData.bucketListAmount) then
                row.bucketText:SetText("|cff00ff00" .. skillData.bucketListAmount .. "|r");
                row.bucketText:Show();
            else
                row.bucketText:SetText("");
                row.bucketText:Hide();
            end

            row:Show();
        end
    end
end
