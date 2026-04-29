--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local PurgeView = _G.professionMaster:CreateView("purge");

--- Collect all players grouped by character set.
-- Returns two sorted lists: staleEntries (not in guild) and otherEntries (in guild / own).
-- @return staleEntries, otherEntries
function PurgeView:CollectPlayers()
    local playerService = self:GetService("player");

    -- collect all unique player names from profession data
    local allPlayers = {};
    for _, profession in pairs(PM_Professions) do
        for _, skill in pairs(profession) do
            if (skill.players) then
                for _, playerName in ipairs(skill.players) do
                    allPlayers[playerName] = true;
                end
            end
        end
    end

    -- also collect from own professions
    for characterName, _ in pairs(PM_OwnProfessions) do
        allPlayers[characterName] = true;
    end

    -- group players by character set
    local visited = {};
    local staleEntries = {};
    local otherEntries = {};

    for playerName, _ in pairs(allPlayers) do
        if (not visited[playerName]) then
            -- skip players from other realms or factions
            if (not playerService:IsSameRealm(playerName) or not playerService:IsSameFaction(playerName)) then
                visited[playerName] = true;
            else
                -- find character set
                local characterSet = playerService:FindCharacterSet(playerName);
                local groupMembers;

                if (characterSet) then
                    groupMembers = {};
                    for _, characterName in ipairs(characterSet) do
                        if (allPlayers[characterName]) then
                            table.insert(groupMembers, characterName);
                        end
                        visited[characterName] = true;
                    end
                else
                    groupMembers = { playerName };
                    visited[playerName] = true;
                end

                -- check if own character
                local isOwnCharacter = false;
                for _, characterName in ipairs(groupMembers) do
                    if (playerService:IsCurrentPlayer(characterName) or PM_OwnProfessions[characterName]) then
                        isOwnCharacter = true;
                        break;
                    end
                end

                if (#groupMembers > 0) then
                    -- check if ANY character in the group is still in the guild
                    local anyInGuild = false;
                    for _, characterName in ipairs(groupMembers) do
                        if (playerService:IsGuildmate(characterName)) then
                            anyInGuild = true;
                            break;
                        end
                    end
                    if (not anyInGuild and characterSet) then
                        for _, characterName in ipairs(characterSet) do
                            if (playerService:IsGuildmate(characterName)) then
                                anyInGuild = true;
                                break;
                            end
                        end
                    end

                    -- build display text
                    local knownNames = {};
                    local altCount = 0;
                    local displaySet = characterSet or groupMembers;
                    for _, characterName in ipairs(displaySet) do
                        if (allPlayers[characterName]) then
                            table.insert(knownNames, playerService:GetShortName(characterName));
                        else
                            altCount = altCount + 1;
                        end
                    end
                    table.sort(knownNames, function(a, b) return a < b; end);

                    local displayText = table.concat(knownNames, ", ");
                    if (altCount > 0) then
                        displayText = displayText .. " +" .. altCount .. " alts";
                    end

                    local entry = {
                        characters = groupMembers,
                        characterSet = characterSet,
                        displayText = displayText,
                        isOwnCharacter = isOwnCharacter
                    };

                    if (not isOwnCharacter and not anyInGuild) then
                        entry.checked = true;
                        table.insert(staleEntries, entry);
                    elseif (not isOwnCharacter) then
                        entry.checked = false;
                        table.insert(otherEntries, entry);
                    end
                end
            end
        end -- realm/faction filter
    end

    -- sort alphabetically within each group
    table.sort(staleEntries, function(a, b) return a.displayText < b.displayText; end);
    table.sort(otherEntries, function(a, b) return a.displayText < b.displayText; end);

    return staleEntries, otherEntries;
end

--- Build a flat display list with headers, entries and empty placeholders.
-- @return displayRows: list of { type, entry?, text? }
function PurgeView:BuildDisplayRows(staleEntries, otherEntries)
    local localeService = self:GetService("locale");
    local displayRows = {};

    -- section 1: not in guild
    table.insert(displayRows, { type = "header", text = localeService:Get("PurgeHeaderNotInGuild") });
    if (#staleEntries == 0) then
        table.insert(displayRows, { type = "empty", text = localeService:Get("PurgeNoPlayersFound") });
    else
        for _, entry in ipairs(staleEntries) do
            table.insert(displayRows, { type = "entry", entry = entry });
        end
    end

    -- section 2: other players
    table.insert(displayRows, { type = "header", text = localeService:Get("PurgeHeaderOtherPlayers") });
    if (#otherEntries == 0) then
        table.insert(displayRows, { type = "empty", text = localeService:Get("PurgeNoPlayersFound") });
    else
        for _, entry in ipairs(otherEntries) do
            table.insert(displayRows, { type = "entry", entry = entry });
        end
    end

    return displayRows;
end

--- Show purge view.
function PurgeView:Show()
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- collect all players and build display rows
    local staleEntries, otherEntries = self:CollectPlayers();
    self.staleEntries = staleEntries;
    self.otherEntries = otherEntries;
    self.displayRows = self:BuildDisplayRows(staleEntries, otherEntries);

    -- check if view created
    if (self.view == nil) then
        -- create view
        local view = uiService:CreateView("PmPurge", 400, 420, localeService:Get("PurgeViewTitle"));
        view:EnableKeyboard();
        view:SetScript("OnKeyDown", function(_, key)
            if (key == "ESCAPE") then
                self:Hide();
            end
        end);
        self.view = view;

        -- add close button
        local closeButton = uiService:CreateFlatCloseButton(view, function()
            self:Hide();
        end);
        closeButton:SetHeight(22);
        closeButton:SetWidth(22);
        closeButton:SetPoint("TOPRIGHT", -12, -8);

        -- add players frame
        local playersFrame = uiService:CreatePanel(view);
        playersFrame:SetPoint("TOPLEFT", 12, -36);
        playersFrame:SetPoint("BOTTOMRIGHT", -12, 42);
        self.playersFrame = playersFrame;

        -- add scroll frame
        local playerScrollFrame, playerScrollChild, playerScrollElement = uiService:CreateScrollFrame(playersFrame);
        playerScrollFrame:SetPoint("TOPLEFT", 5, -5);
        playerScrollFrame:SetPoint("BOTTOMRIGHT", -5, 5);
        playerScrollChild:SetWidth(playerScrollFrame:GetWidth());
        playerScrollElement:SetScript("OnVerticalScroll", function(_, top)
            self.playerScrollTop = top;
            self:RefreshRows();
        end);
        self.playerScrollFrame = playerScrollFrame;
        self.playerScrollChild = playerScrollChild;
        self.playerScrollElement = playerScrollElement;
        self.playerScrollTop = 0;

        -- create purge button
        local purgeButton = uiService:CreateFlatButton(view, "", function()
            self:PurgeSelected();
        end);
        purgeButton:SetWidth(220);
        purgeButton:SetHeight(22);
        purgeButton:SetPoint("BOTTOMRIGHT", -12, 8);
        self.purgeButton = purgeButton;
    end

    -- update scroll content height
    self.playerScrollChild:SetHeight(#self.displayRows * 24);
    self.playerScrollTop = 0;

    -- refresh
    self:UpdatePurgeButtonText();
    self:RefreshRows();

    -- show view
    self.view:Show();
    self.visible = true;
end

--- Update purge button text with selected count.
function PurgeView:UpdatePurgeButtonText()
    local localeService = self:GetService("locale");
    local selectedCount = 0;
    for _, entry in ipairs(self.staleEntries) do
        if (entry.checked) then
            selectedCount = selectedCount + 1;
        end
    end
    for _, entry in ipairs(self.otherEntries) do
        if (entry.checked) then
            selectedCount = selectedCount + 1;
        end
    end
    self.purgeButton:SetText(localeService:Get("PurgeButtonText", selectedCount));
end

--- Refresh visible rows (pooled).
function PurgeView:RefreshRows()
    local rowHeight = 24;

    -- get visible range
    local startIndex = math.max(math.floor(self.playerScrollTop / rowHeight) - 1, 1);
    local endIndex = math.min(startIndex + 25, #self.displayRows);
    local visibleCount = math.max(endIndex - startIndex + 1, 0);

    -- ensure pool has enough frames
    if (not self.rowPool) then
        self.rowPool = {};
    end
    while (#self.rowPool < visibleCount) do
        local poolIndex = #self.rowPool + 1;
        local row = CreateFrame("Button", nil, self.playerScrollChild, BackdropTemplateMixin and "BackdropTemplate");
        row:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]]
        });
        row:SetHeight(rowHeight);

        -- add checkbox
        local checkbox = CreateFrame("CheckButton", "PmPurgeCheck" .. self.addon:GenerateString(8), row, "UICheckButtonTemplate");
        checkbox:SetWidth(20);
        checkbox:SetHeight(20);
        checkbox:SetPoint("LEFT", 4, 0);
        checkbox:SetScript("OnClick", function()
            local displayRow = row.displayRow;
            if (displayRow and displayRow.entry) then
                displayRow.entry.checked = checkbox:GetChecked();
                self:UpdatePurgeButtonText();
            end
        end);
        row.checkbox = checkbox;

        -- add name text
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        nameText:SetPoint("LEFT", checkbox, "RIGHT", 4, 0);
        nameText:SetPoint("RIGHT", row, "RIGHT", -6, 0);
        nameText:SetJustifyH("LEFT");
        nameText:SetJustifyV("MIDDLE");
        row.nameText = nameText;

        -- add header/label text (full width, no checkbox)
        local headerText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        headerText:SetPoint("LEFT", 8, 0);
        headerText:SetPoint("RIGHT", row, "RIGHT", -6, 0);
        headerText:SetJustifyH("LEFT");
        headerText:SetJustifyV("MIDDLE");
        row.headerText = headerText;

        self.rowPool[poolIndex] = row;
    end

    -- hide all pooled frames
    for _, row in ipairs(self.rowPool) do
        row:Hide();
    end

    -- bind pool frames to visible data
    for i = 0, visibleCount - 1 do
        local rowIndex = startIndex + i;
        local displayRow = self.displayRows[rowIndex];
        local row = self.rowPool[i + 1];

        -- clear background
        row:SetBackdropColor(0, 0, 0, 0);

        -- position
        local top = (rowIndex - 1) * rowHeight;
        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", self.playerScrollChild, "TOPLEFT", 0, -top);
        row:SetPoint("RIGHT", self.playerScrollChild, "RIGHT", -28, 0);

        row.displayRow = displayRow;

        if (displayRow.type == "header") then
            -- header row: golden text, no checkbox
            row.checkbox:Hide();
            row.nameText:Hide();
            row.headerText:SetText(displayRow.text);
            row.headerText:SetTextColor(1, 0.82, 0);
            row.headerText:Show();
        elseif (displayRow.type == "empty") then
            -- empty placeholder: gray text, no checkbox
            row.checkbox:Hide();
            row.nameText:Hide();
            row.headerText:SetText(displayRow.text);
            row.headerText:SetTextColor(0.5, 0.5, 0.5);
            row.headerText:Show();
        else
            -- entry row: checkbox + name
            row.headerText:Hide();
            row.checkbox:Show();
            row.nameText:Show();

            local entry = displayRow.entry;
            row.checkbox:SetChecked(entry.checked);
            row.checkbox:SetEnabled(true);
            row.nameText:SetTextColor(1, 1, 1);
            row.nameText:SetText(entry.displayText);
        end

        row:Show();
    end
end

--- Purge all selected entries.
function PurgeView:PurgeSelected()
    local purgeService = self:GetService("purge");
    local purgedCount = 0;

    local allEntries = {};
    for _, entry in ipairs(self.staleEntries) do
        table.insert(allEntries, entry);
    end
    for _, entry in ipairs(self.otherEntries) do
        table.insert(allEntries, entry);
    end

    for _, entry in ipairs(allEntries) do
        if (entry.checked) then
            -- purge all characters in the group
            for _, characterName in ipairs(entry.characters) do
                purgeService:PurgeCharacterSilent(characterName);
            end

            -- also purge characters from the full character set
            if (entry.characterSet) then
                for _, characterName in ipairs(entry.characterSet) do
                    purgeService:PurgeCharacterSilent(characterName);
                end
            end

            purgedCount = purgedCount + 1;
        end
    end

    -- log purge
    if (purgedCount > 0) then
        self.addon:Log("PurgeView", "PurgeSelected", "Purged %d player groups", purgedCount);

        -- reset sync times so data can be received again
        PM_SyncTimes = {};

        -- rebuild reverse index after purge
        self:GetService("professions"):RebuildItemIndex();
    end

    -- hide and notify
    self:Hide();
    self:GetService("chat"):WriteBare(self:GetService("locale"):Get("PurgeDone", purgedCount));

    -- refresh professions view if open
    local professionsView = self.addon.professionsView;
    if (professionsView and professionsView.visible) then
        professionsView:RefreshActiveTab();
    end
end

--- Hide view.
function PurgeView:Hide()
    if (self.view) then
        self.view:Hide();
        self.visible = false;
    end
end
