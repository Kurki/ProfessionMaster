--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create panel
local GuildSpecializationsPanel = _G.professionMaster:CreateView("guild-specializations-panel");

--- Create guild specializations panel.
-- @param parentFrame The parent content frame.
-- @param professionsView Reference to the parent professions view.
function GuildSpecializationsPanel:Create(parentFrame, professionsView)
    self.professionsView = professionsView;
    self.rowPool = {};
    self.groupHeaderPool = {};
    self.skills = {};
    self.scrollTop = 0;
    self.hidePlayerColumn = false;

    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- create container frame
    local frame = CreateFrame("Frame", nil, parentFrame);
    frame:SetPoint("TOPLEFT", 5, -2);
    frame:SetPoint("BOTTOMRIGHT", -5, 2);
    frame:Hide();
    self.frame = frame;

    -- add column headers
    local specHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    specHeader:SetPoint("TOPLEFT", 12, -12);
    specHeader:SetText(localeService:Get("Specialization"));
    self.specHeader = specHeader;

    local playersHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    playersHeader:SetPoint("TOPLEFT", 266, -12);
    playersHeader:SetText(localeService:Get("ProfessionsViewPlayers"));
    self.playersHeader = playersHeader;

    -- create scroll frame
    local scrollParent, scrollChild, scrollElement = uiService:CreateScrollFrame(frame);
    scrollParent:SetPoint("TOPLEFT", 4, -28);
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
end

--- Show the panel.
function GuildSpecializationsPanel:Show()
    if (self.frame) then
        self.frame:Show();
        self:RefreshList();
    end
end

--- Hide the panel.
function GuildSpecializationsPanel:Hide()
    if (self.frame) then
        self.frame:Hide();
    end
end

--- Refresh data.
function GuildSpecializationsPanel:Refresh()
    self:RefreshList();
end

--- Build and display the specialization list.
function GuildSpecializationsPanel:RefreshList()
    local localeService = self:GetService("locale");
    local playerService = self:GetService("player");
    local professionNamesService = self:GetService("profession-names");
    local specializationSpells = self:GetModel("specialization-spells");

    local professionOrder = professionNamesService:GetProfessionIdsToShow();
    self.skills = {};

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

                table.insert(professionSpecs, {
                    professionId = professionId,
                    spellId = spec.spellId,
                    name = specName,
                    icon = spec.icon or 136240,
                    players = players,
                });
            end

            if (#professionSpecs > 0) then
                table.insert(self.skills, {
                    isGroupHeader = true,
                    groupName = professionNamesService:GetProfessionName(professionId),
                });
                for _, specEntry in ipairs(professionSpecs) do
                    table.insert(self.skills, specEntry);
                end
            end
        end
    end

    -- update scroll child height
    local rowHeight = 20;
    local totalHeight = #self.skills * rowHeight;
    self.scrollChild:SetHeight(totalHeight);

    self:RefreshRows();
end

--- Refresh visible rows based on scroll position.
function GuildSpecializationsPanel:RefreshRows()
    if (not self.skills or #self.skills == 0) then
        -- hide all rows
        for _, row in ipairs(self.rowPool) do
            row:Hide();
        end
        for _, row in ipairs(self.groupHeaderPool) do
            row:Hide();
        end
        return;
    end

    local playerService = self:GetService("player");
    local rowHeight = 20;
    local visibleRowCount = math.ceil((self.scrollFrame:GetHeight() or 400) / rowHeight) + 4;
    local startIndex = math.max(math.floor(self.scrollTop / rowHeight) - 2, 1);
    local endIndex = math.min(startIndex + visibleRowCount, #self.skills);

    -- hide all rows first
    for _, row in ipairs(self.rowPool) do
        row:Hide();
    end
    for _, row in ipairs(self.groupHeaderPool) do
        row:Hide();
    end

    local rowPoolIndex = 0;
    local headerPoolIndex = 0;

    for i = startIndex, endIndex do
        local entry = self.skills[i];
        local yOffset = -(i - 1) * rowHeight;

        if (entry.isGroupHeader) then
            headerPoolIndex = headerPoolIndex + 1;
            local header = self.groupHeaderPool[headerPoolIndex];
            if (not header) then
                header = CreateFrame("Frame", nil, self.scrollChild);
                header:SetHeight(rowHeight);
                local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                headerText:SetPoint("LEFT", 6, 0);
                headerText:SetTextColor(1, 0.84, 0, 1);
                header.text = headerText;
                self.groupHeaderPool[headerPoolIndex] = header;
            end
            header:ClearAllPoints();
            header:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", -2, yOffset);
            header:SetPoint("RIGHT", self.scrollChild, "RIGHT", 0, 0);
            header.text:SetText(entry.groupName);
            header:Show();
        else
            rowPoolIndex = rowPoolIndex + 1;
            local row = self.rowPool[rowPoolIndex];
            if (not row) then
                row = CreateFrame("Button", nil, self.scrollChild, BackdropTemplateMixin and "BackdropTemplate");
                row:SetBackdrop({
                    bgFile = [[Interface\Buttons\WHITE8x8]]
                });
                row:SetHeight(rowHeight);

                local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                itemText:SetPoint("TOPLEFT", 4, -3);
                row.itemText = itemText;

                local playerText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                playerText:SetPoint("TOPLEFT", 256, -3);
                playerText:SetPoint("RIGHT", row, "RIGHT", -6, 0);
                playerText:SetJustifyH("LEFT");
                playerText:SetTextColor(1, 1, 1);
                row.playerText = playerText;

                row:SetScript("OnEnter", function()
                    row:SetBackdropColor(0.2, 0.2, 0.2);
                    GameTooltip:SetOwner(row, "ANCHOR_LEFT");
                    GameTooltip:ClearLines();
                    if (row.specData) then
                        GameTooltip:SetText(row.specData.name);
                        local playerNames = playerService:CombinePlayerNames(row.specData.players, 5);
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
                row:SetScript("OnMouseDown", function(_, button)
                    if (button == "LeftButton" and row.specData) then
                        self.professionsView:ShowSpecView(row.specData);
                    end
                end);

                self.rowPool[rowPoolIndex] = row;
            end

            row:ClearAllPoints();
            row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 3, yOffset);
            row:SetPoint("BOTTOMRIGHT", self.scrollChild, "TOPRIGHT", -28, yOffset - 20);

            local backgroundColor = (i % 2 == 0) and 0.12 or 0.06;
            row.bgColor = backgroundColor;
            row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

            row.specData = entry;
            row.itemText:SetText("|T" .. entry.icon .. ":16|t " .. entry.name);

            -- responsive: show count when narrow, names when wide
            if (self.hidePlayerColumn) then
                row.playerText:SetText(tostring(#entry.players));
            else
                row.playerText:SetText(table.concat(playerService:CombinePlayerNames(entry.players, 12), ", "));
            end
            row:Show();
        end
    end
end

--- Set right margin.
function GuildSpecializationsPanel:SetRightMargin(margin)
    if (self.frame) then
        self.frame:SetPoint("BOTTOMRIGHT", -margin, 0);
        self:UpdateResponsiveLayout();
    end
end

--- Handle resize.
function GuildSpecializationsPanel:OnSizeChanged()
    self:UpdateResponsiveLayout();
end

--- Update responsive layout based on frame width.
function GuildSpecializationsPanel:UpdateResponsiveLayout()
    if (not self.frame) then return; end
    if (self.scrollChild and self.scrollFrame) then
        self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
    end
    local frameWidth = self.frame:GetWidth();
    if (frameWidth < 500) then
        self.hidePlayerColumn = true;
    else
        self.hidePlayerColumn = false;
    end
    self:RefreshRows();
end
