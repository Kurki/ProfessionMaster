--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create panel
local OwnSkillList = _G.professionMaster:CreateView("own-skill-list");

--- Create own skill list panel.
-- @param parentFrame The parent frame.
-- @param professionsView Reference to the parent professions view.
function OwnSkillList:Create(parentFrame, professionsView)
    self.professionsView = professionsView;
    self.rowPool = {};
    self.groupHeaderPool = {};
    self.skills = {};
    self.professionId = 0;
    self.scrollTop = 0;
    self.bucketListSkillAmount = 0;

    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

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
    searchContainer:SetPoint("RIGHT", frame, "RIGHT", -199, 0);
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
    professionLabel:SetPoint("TOPLEFT", frame, "TOPRIGHT", -192, -12);
    professionLabel:SetText(localeService:Get("ProfessionsViewProfession"));
    self.professionLabel = professionLabel;

    local professionSelection = uiService:CreateDropdown(frame, 160, {}, function(value)
        self.professionId = value;
        self.searchBox:SetFocus();
        self:AddSkills();
    end);
    professionSelection:SetPoint("TOPLEFT", frame, "TOPRIGHT", -192, -28);
    self.professionSelection = professionSelection;

    -- add skill header
    local skillText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    skillText:SetPoint("TOPLEFT", 12, -60);
    self.skillText = skillText;

    -- add bucket list header label
    local bucketListText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    bucketListText:SetPoint("TOPLEFT", frame, "TOPRIGHT", -56, -60);
    bucketListText:SetText("");
    self.bucketListHeader = bucketListText;

    -- create scroll frame
    local scrollParent, scrollChild, scrollElement = uiService:CreateScrollFrame(frame);
    scrollParent:SetPoint("TOPLEFT", 6, -76);
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

--- Handle resize.
function OwnSkillList:OnSizeChanged()
    if (self.scrollChild and self.scrollFrame) then
        self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
    end
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

    -- determine which professions the current player has
    local allProfessionIds = self:GetService("profession-names"):GetProfessionIdsToShow();
    local ownProfessionIds = {};
    for _, professionId in ipairs(allProfessionIds) do
        local profession = PM_Professions[professionId];
        if (profession) then
            for _, skillEntry in pairs(profession) do
                if (skillEntry.players and skillEntry.players[currentPlayer]) then
                    table.insert(ownProfessionIds, professionId);
                    break;
                end
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
        self.bucketListHeader:Hide();
        self.scrollFrame:Hide();
        self.emptyMessage:Show();
        return;
    end

    -- show controls
    self.searchLabel:Show();
    self.searchContainer:Show();
    self.professionLabel:Show();
    self.professionSelection:Show();
    self.skillText:Show();
    self.scrollFrame:Show();
    self.emptyMessage:Hide();

    -- rebuild dropdown items with only own professions
    local professionItems = {{ value = 0, text = self:GetProfessionText(0) }};
    for _, professionId in ipairs(ownProfessionIds) do
        table.insert(professionItems, { value = professionId, text = self:GetProfessionText(professionId) });
    end
    self.professionSelection:SetItems(professionItems);

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

    for _, professionId in ipairs(professionIds) do
        local profession = PM_Professions[professionId];
        if (profession) then
            for skillId, skillEntry in pairs(profession) do
                -- only show skills the current player knows
                if (skillEntry.players and skillEntry.players[currentPlayer]) then
                    local skillData = skillsService:GetSkillById(skillId);
                    if (skillData and skillData.name ~= nil) then
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

    -- sort: bucket list items first, then alphabetical
    table.sort(self.skills, function(a, b)
        if (a.bucketListAmount and not b.bucketListAmount) then return true; end
        if (not a.bucketListAmount and b.bucketListAmount) then return false; end
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
        itemText:SetPoint("TOPLEFT", 6, -3);
        row.itemText = itemText;

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
            row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 5, -top);
            row:SetPoint("RIGHT", self.scrollChild, "RIGHT", -5, 0);
            row:SetHeight(20);

            local backgroundColor = (rowIndex % 2 == 0) and 0.12 or 0.06;
            row.bgColor = backgroundColor;
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

            row.professionId = skillData.professionId;
            row.skillId = skillData.skillId;
            row.skill = skillData.skill;

            -- set item text with icon
            local icon = skillData.skill.icon or 134400;
            row.itemText:SetText("|T" .. icon .. ":16|t " .. skillData.skill.name);

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
