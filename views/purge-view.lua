--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local PurgeView = _G.professionMaster:CreateView("purge");

--- Collect all players grouped by character set.
-- Non-guild players are sorted to the top and checked by default.
-- @return List of entries: { characters, characterSet, displayText, checked, stale }
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
    local entries = {};

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

                -- skip own characters
                local isOwnCharacter = false;
                for _, characterName in ipairs(groupMembers) do
                    if (playerService:IsCurrentPlayer(characterName) or PM_OwnProfessions[characterName]) then
                        isOwnCharacter = true;
                        break;
                    end
                end

                if (not isOwnCharacter and #groupMembers > 0) then
                    -- check if ANY character in the group is still in the guild
                    local anyInGuild = false;
                    for _, characterName in ipairs(groupMembers) do
                        if (PM_Guildmates[characterName]) then
                            anyInGuild = true;
                            break;
                        end
                    end
                    if (not anyInGuild and characterSet) then
                        for _, characterName in ipairs(characterSet) do
                            if (PM_Guildmates[characterName]) then
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

                    table.insert(entries, {
                        characters = groupMembers,
                        characterSet = characterSet,
                        displayText = displayText,
                        stale = not anyInGuild,
                        checked = not anyInGuild
                    });
                end
            end
        end -- realm/faction filter
    end

    -- sort: stale (not in guild) first, then alphabetically within each group
    table.sort(entries, function(a, b)
        if (a.stale ~= b.stale) then
            return a.stale;
        end
        return a.displayText < b.displayText;
    end);

    return entries;
end

--- Show purge view.
function PurgeView:Show()
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- collect all players
    self.staleEntries = self:CollectPlayers();

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

        -- add description label
        local descriptionLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        descriptionLabel:SetPoint("TOPLEFT", 16, -36);
        descriptionLabel:SetPoint("RIGHT", -16, 0);
        descriptionLabel:SetJustifyH("LEFT");
        descriptionLabel:SetTextColor(0.7, 0.7, 0.7);
        descriptionLabel:SetText(localeService:Get("PurgeViewDescription"));
        self.descriptionLabel = descriptionLabel;

        -- add players frame
        local playersFrame = uiService:CreatePanel(view);
        playersFrame:SetPoint("TOPLEFT", 12, -54);
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
    self.playerScrollChild:SetHeight(#self.staleEntries * 24);
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
    self.purgeButton:SetText(localeService:Get("PurgeButtonText", selectedCount));
end

--- Refresh visible rows (pooled).
function PurgeView:RefreshRows()
    local rowHeight = 24;

    -- get visible range
    local startIndex = math.max(math.floor(self.playerScrollTop / rowHeight) - 1, 1);
    local endIndex = math.min(startIndex + 25, #self.staleEntries);
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
            local entryIndex = row.entryIndex;
            if (entryIndex and self.staleEntries[entryIndex]) then
                self.staleEntries[entryIndex].checked = checkbox:GetChecked();
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

        self.rowPool[poolIndex] = row;
    end

    -- hide all pooled frames
    for _, row in ipairs(self.rowPool) do
        row:Hide();
    end

    -- bind pool frames to visible data
    local uiService = self:GetService("ui");
    for i = 0, visibleCount - 1 do
        local rowIndex = startIndex + i;
        local entry = self.staleEntries[rowIndex];
        local row = self.rowPool[i + 1];

        -- set background color
        uiService:SetRowColor(row, rowIndex);

        -- position
        local top = (rowIndex - 1) * rowHeight;
        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", self.playerScrollChild, "TOPLEFT", 0, -top);
        row:SetPoint("RIGHT", self.playerScrollChild, "RIGHT", -28, 0);

        -- set data
        row.entryIndex = rowIndex;
        row.checkbox:SetChecked(entry.checked);
        if (entry.stale) then
            row.nameText:SetTextColor(1, 1, 1);
        else
            row.nameText:SetTextColor(0.5, 0.5, 0.5);
        end
        row.nameText:SetText(entry.displayText);
        row:Show();
    end
end

--- Purge all selected entries.
function PurgeView:PurgeSelected()
    local purgeService = self:GetService("purge");
    local purgedCount = 0;

    for _, entry in ipairs(self.staleEntries) do
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

        -- rebuild reverse index after purge
        self:GetService("professions"):RebuildItemIndex();
    end

    -- hide and notify
    self:Hide();
    self:GetService("chat"):WriteBare(self:GetService("locale"):Get("PurgeDone", purgedCount));
end

--- Hide view.
function PurgeView:Hide()
    if (self.view) then
        self.view:Hide();
        self.visible = false;
    end
end
