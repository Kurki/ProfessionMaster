--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create view
local SpecView = _G.professionMaster:CreateView("spec-view");

--- Show spec view.
-- @param specData Specialization data table { name, players, spellId, icon, professionId }.
-- @param professionsView The parent professions view.
function SpecView:Show(specData, professionsView)
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- check if view created
    if (self.view == nil) then
        -- define player rows and scroll top
        self.playerScrollTop = 0;

        -- create view
        local view = uiService:CreateView("PmSpec", 240, 310, "");
        view:EnableKeyboard();
        self.view = view;

        -- add close button
        local closeButton = uiService:CreateFlatCloseButton(view, function()
            professionsView:HideSpecView();
        end);
        closeButton:SetHeight(22);
        closeButton:SetWidth(22);
        closeButton:SetPoint("TOPRIGHT", -12, -8);

        -- add players frame
        local playersFrame = CreateFrame("Frame", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        playersFrame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface/Buttons/WHITE8X8]],
            edgeSize = 1
        });
        playersFrame:SetBackdropColor(0, 0, 0, 0.5);
        playersFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
        playersFrame:SetPoint("TOPLEFT", 12, -36);
        playersFrame:SetPoint("BOTTOMRIGHT", -12, 42);
        self.playersFrame = playersFrame;

        -- add players label
        local playersLabel = playersFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        playersLabel:SetPoint("TOPLEFT", 13, -12);
        playersLabel:SetText(localeService:Get("SkillViewPlayers"));

        -- add players scroll frame
        local playerScrollFrame, playerScrollChild, playerScrollElement = uiService:CreateScrollFrame(playersFrame);
        playerScrollFrame:SetPoint("TOPLEFT", 7, -32);
        playerScrollFrame:SetPoint("BOTTOMRIGHT", -7, 5);
        playerScrollChild:SetWidth(playerScrollFrame:GetWidth());
        playerScrollElement:SetScript("OnVerticalScroll", function(_, top)
            self.playerScrollTop = top;
            self:RefreshPlayerRows();
        end);
        self.playerScrollFrame = playerScrollFrame;
        self.playerScrollChild = playerScrollChild;
        self.playerScrollElement = playerScrollElement;

        -- create ok button
        local okButton = uiService:CreateFlatButton(view, localeService:Get("SkillViewOk"), function()
            professionsView:HideSpecView();
        end);
        okButton:SetWidth(100);
        okButton:SetHeight(22);
        okButton:SetPoint("BOTTOMRIGHT", -12, 8);
    end

    -- update title
    self.view.titleLabel:SetText(self.addon.shortcut .. specData.name);

    -- set position
    self.view:ClearAllPoints();
    self.view:SetPoint("CENTER", professionsView.view, "CENTER", 0, 0);

    -- get player names
    self.playerNames = self:GetService("player"):CombinePlayerNames(specData.players);
    self.playerScrollChild:SetHeight(#self.playerNames * 20);
    self:RefreshPlayerRows();

    -- show view
    self.view:Show();
end

--- Refresh player rows (pooled).
function SpecView:RefreshPlayerRows()
    -- get visible range
    local startIndex = math.max(math.floor(self.playerScrollTop / 20) - 1, 1);
    local endIndex = math.min(startIndex + 25, #self.playerNames);
    local visibleCount = math.max(endIndex - startIndex + 1, 0);

    -- ensure pool has enough frames
    if (not self.playerRowPool) then
        self.playerRowPool = {};
    end
    while (#self.playerRowPool < visibleCount) do
        local poolIndex = #self.playerRowPool + 1;
        local row = CreateFrame("Button", nil, self.playerScrollChild, BackdropTemplateMixin and "BackdropTemplate");
        row:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]]
        });

        -- add name text
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        nameText:SetPoint("TOPLEFT", 6, -4);
        nameText:SetPoint("BOTTOMRIGHT", -6, -3);
        nameText:SetJustifyH("LEFT");
        nameText:SetJustifyV("TOP");
        row.nameText = nameText;

        self.playerRowPool[poolIndex] = row;
    end

    -- hide all pooled frames
    for _, row in ipairs(self.playerRowPool) do
        row:Hide();
    end

    -- bind pool frames to visible data
    for i = 0, visibleCount - 1 do
        local rowIndex = startIndex + i;
        local row = self.playerRowPool[i + 1];

        -- set background color by data index
        local backgroundColor;
        if (rowIndex % 2 == 0) then
            backgroundColor = 0.1;
        else
            backgroundColor = 0.15;
        end
        row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);

        -- position
        local top = (rowIndex - 1) * 20;
        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", self.playerScrollChild, "TOPLEFT", 0, -top);
        row:SetPoint("BOTTOMRIGHT", self.playerScrollChild, "TOPRIGHT", -28, -(top + 20));

        -- set text and show
        row.nameText:SetText(self.playerNames[rowIndex]);
        row:Show();
    end
end

--- Hide the spec view.
function SpecView:Hide()
    if (self.view) then
        self.view:Hide();
    end
end
