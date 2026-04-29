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
        self.skillView = self.addon:NewView("skill-view");
        self.specView = self.addon:NewView("spec-view");

        -- create view
        local view = uiService:CreateView("PmProfessions", 1000, 540, localeService:Get("ProfessionsViewTitle"), false, true);
        view:EnableKeyboard();
        view:SetScript("OnKeyDown", function(_, key)
            -- check escape
            if (key == "ESCAPE") then
                view:SetPropagateKeyboardInput(false);
                if (self.skillViewVisible) then
                    self:HideSkillView();
                elseif (self.specViewVisible) then
                    self:HideSpecView();
                else
                    self:Hide();
                end
            else
                view:SetPropagateKeyboardInput(true);
            end
        end)

        self.view = view;

        -- add close button
        local closeButton = uiService:CreateFlatCloseButton(view, function()
            self:Hide();
        end);
        closeButton:SetHeight(22);
        closeButton:SetWidth(22);
        closeButton:SetPoint("TOPRIGHT", -12, -8);
        uiService:BindTooltip(closeButton, localeService:Get("CloseTooltip"));

        -- add help button (question mark text left of close button)
        self.helpView = self.addon:NewView("help");
        local helpButton = uiService:CreateFlatSquareButton(view, "?", function()
            self.helpView:ToggleVisibility();
        end, 16);
        helpButton:SetPoint("RIGHT", closeButton, "LEFT", -8, 0);
        helpButton:SetNormalFontObject("GameFontHighlightSmall");
        helpButton:SetHighlightFontObject("GameFontHighlight");
        uiService:BindTooltip(helpButton, localeService:Get("HelpTooltip"));

        -- add purge button (broom icon left of help button)
        self.purgeView = self.addon:NewView("purge");
        local purgeButton = uiService:CreateFlatSquareButton(view, "D", function()
            self.purgeView:Show();
        end, 16);
        purgeButton:SetPoint("RIGHT", helpButton, "LEFT", -8, 0);
        uiService:BindTooltip(purgeButton, localeService:Get("PurgeViewTitle"));

        -- add footer
        local footerLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft");
        footerLabel:SetPoint("BOTTOMLEFT", 16, 10);
        footerLabel:SetText(localeService:Get("ProfessionsViewFooter"));

        -- create ok button
        local okButton = uiService:CreateFlatButton(view, localeService:Get("ProfessionsViewAnnounce"), function()
            SendChatMessage(localeService:Get("GuildAnnouncement"), "GUILD");
        end);
        okButton:SetWidth(200);
        okButton:SetHeight(22);
        okButton:SetPoint("BOTTOMRIGHT", -12, 6);

        -- add content frame
        local contentFrame = CreateFrame("Frame", nil, view, BackdropTemplateMixin and "BackdropTemplate");
        contentFrame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
        });
        contentFrame:SetBackdropColor(0, 0, 0, 0.5);
        contentFrame:SetPoint("TOPLEFT", 12, -60);
        contentFrame:SetPoint("BOTTOMRIGHT", -12, 30);

        local cBottom = contentFrame:CreateTexture(nil, "BORDER");
        cBottom:SetColorTexture(0.5, 0.5, 0.5, 0.5);
        cBottom:SetHeight(1);
        cBottom:SetPoint("BOTTOMLEFT", 0, 0);
        cBottom:SetPoint("BOTTOMRIGHT", 0, 0);

        local cLeft = contentFrame:CreateTexture(nil, "BORDER");
        cLeft:SetColorTexture(0.5, 0.5, 0.5, 0.5);
        cLeft:SetWidth(1);
        cLeft:SetPoint("TOPLEFT", 0, 0);
        cLeft:SetPoint("BOTTOMLEFT", 0, 0);

        local cRight = contentFrame:CreateTexture(nil, "BORDER");
        cRight:SetColorTexture(0.5, 0.5, 0.5, 0.5);
        cRight:SetWidth(1);
        cRight:SetPoint("TOPRIGHT", 0, 0);
        cRight:SetPoint("BOTTOMRIGHT", 0, 0);

        -- top border: two segments with gap for active tab
        local cTopLeft = contentFrame:CreateTexture(nil, "BORDER");
        cTopLeft:SetColorTexture(0.5, 0.5, 0.5, 0.5);
        cTopLeft:SetHeight(1);
        self.cTopLeft = cTopLeft;

        local cTopRight = contentFrame:CreateTexture(nil, "BORDER");
        cTopRight:SetColorTexture(0.5, 0.5, 0.5, 0.5);
        cTopRight:SetHeight(1);
        self.cTopRight = cTopRight;

        self.contentFrame = contentFrame;

        -- tab button creation (borders on left, right, top only)
        local function CreateTabButton(parent, text)
            local button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate");
            button:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]],
            });
            button:SetBackdropColor(0, 0, 0, 0);
            button:SetNormalFontObject("GameFontNormal");
            button:SetText(text);
            button:SetWidth(120);
            button:SetHeight(24);

            local left = button:CreateTexture(nil, "BORDER");
            left:SetColorTexture(0.5, 0.5, 0.5, 0.5);
            left:SetWidth(1);
            left:SetPoint("TOPLEFT", 0, 0);
            left:SetPoint("BOTTOMLEFT", 0, 0);

            local right = button:CreateTexture(nil, "BORDER");
            right:SetColorTexture(0.5, 0.5, 0.5, 0.5);
            right:SetWidth(1);
            right:SetPoint("TOPRIGHT", 0, 0);
            right:SetPoint("BOTTOMRIGHT", 0, 0);

            local top = button:CreateTexture(nil, "BORDER");
            top:SetColorTexture(0.5, 0.5, 0.5, 0.5);
            top:SetHeight(1);
            top:SetPoint("TOPLEFT", 0, 0);
            top:SetPoint("TOPRIGHT", 0, 0);

            return button;
        end

        -- determine which tabs to show
        local isInGuild = IsInGuild();
        local isVanilla = self.addon.isVanilla;

        -- create guild tab button
        local guildTabButton = CreateTabButton(view, localeService:Get("TabGuild"));
        guildTabButton:SetPoint("BOTTOMLEFT", contentFrame, "TOPLEFT", 6, -1);
        guildTabButton:SetScript("OnClick", function()
            self:SelectTab("guild");
        end);
        self.guildTabButton = guildTabButton;

        -- create specializations tab button
        local specTabButton = CreateTabButton(view, localeService:Get("TabSpecializations"));
        specTabButton:SetPoint("BOTTOMLEFT", guildTabButton, "BOTTOMRIGHT", 4, 0);
        specTabButton:SetScript("OnClick", function()
            self:SelectTab("specializations");
        end);
        self.specTabButton = specTabButton;

        -- create own tab button
        local ownTabButton = CreateTabButton(view, localeService:Get("TabOwn"));
        if (isInGuild and not isVanilla) then
            ownTabButton:SetPoint("BOTTOMLEFT", specTabButton, "BOTTOMRIGHT", 4, 0);
        elseif (isInGuild) then
            ownTabButton:SetPoint("BOTTOMLEFT", guildTabButton, "BOTTOMRIGHT", 4, 0);
        else
            ownTabButton:SetPoint("BOTTOMLEFT", contentFrame, "TOPLEFT", 6, -1);
        end
        ownTabButton:SetScript("OnClick", function()
            self:SelectTab("own");
        end);
        self.ownTabButton = ownTabButton;

        -- hide tabs based on guild/expansion
        if (not isInGuild) then
            guildTabButton:Hide();
            specTabButton:Hide();
        elseif (isVanilla) then
            specTabButton:Hide();
        end

        -- create guild professions panel
        self.guildProfessionsPanel = self.addon:NewView("guild-professions-panel");
        self.guildProfessionsPanel:Create(contentFrame, self);

        -- create guild specializations panel
        self.guildSpecializationsPanel = self.addon:NewView("guild-specializations-panel");
        self.guildSpecializationsPanel:Create(contentFrame, self);

        -- create own professions panel
        self.ownProfessionsPanel = self.addon:NewView("own-professions-panel");
        self.ownProfessionsPanel:Create(contentFrame, self);

        -- create bucket list panel (outside tabs, always on right side)
        self.bucketListPanel = self.addon:NewView("bucket-list-panel");
        self.bucketListPanel:Create(contentFrame, self);

        -- handle resize
        view:HookScript("OnSizeChanged", function()
            if (self.activeTab == "guild") then
                self.guildProfessionsPanel:OnSizeChanged();
            elseif (self.activeTab == "specializations") then
                self.guildSpecializationsPanel:OnSizeChanged();
            elseif (self.activeTab == "own") then
                self.ownProfessionsPanel:OnSizeChanged();
            end
            if (self.bucketListPanel) then
                self.bucketListPanel:OnSizeChanged();
            end
            if (self.resizePending) then
                self.resizePending:Cancel();
            end
            self.resizePending = C_Timer.NewTimer(0.05, function()
                self.resizePending = nil;
                if (self.activeTab == "guild") then
                    self.guildProfessionsPanel:RefreshRows();
                elseif (self.activeTab == "specializations") then
                    self.guildSpecializationsPanel:RefreshRows();
                elseif (self.activeTab == "own") then
                    self.ownProfessionsPanel:RefreshRows();
                end
            end);
        end);

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

        -- select initial tab
        if (isInGuild) then
            self:SelectTab("guild");
        else
            self:SelectTab("own");
        end
    end

    -- hide skill view
    self:HideSkillView(true);
    self:HideSpecView();

    -- refresh active tab
    self:RefreshActiveTab();

    -- show view
    self.view:Show();
    self.visible = true;
end

--- Select tab.
-- @param tabName Tab name: "guild", "specializations", "own".
function ProfessionsView:SelectTab(tabName)
    self.activeTab = tabName;

    -- hide all tab content
    self.guildProfessionsPanel:Hide();
    self.guildSpecializationsPanel:Hide();
    self.ownProfessionsPanel:Hide();

    -- update tab button styles
    local activeHeight = 26;
    local inactiveHeight = 24;
    local tabs = {
        { button = self.guildTabButton, name = "guild" },
        { button = self.specTabButton, name = "specializations" },
        { button = self.ownTabButton, name = "own" },
    };

    for _, tab in ipairs(tabs) do
        if (tab.button) then
            local fontString = tab.button:GetFontString();
            if (tab.name == tabName) then
                tab.button:SetHeight(activeHeight);
                tab.button:SetBackdropColor(0, 0, 0, 0.5);
                fontString:SetTextColor(1, 0.84, 0, 1);
            else
                tab.button:SetHeight(inactiveHeight);
                tab.button:SetBackdropColor(0, 0, 0, 0);
                fontString:SetTextColor(1, 1, 1, 1);
            end
        end
    end

    -- update top border gap for active tab
    if (self.cTopLeft and self.cTopRight and self.contentFrame) then
        local activeButton = nil;
        for _, tab in ipairs(tabs) do
            if (tab.name == tabName and tab.button and tab.button:IsShown()) then
                activeButton = tab.button;
                break;
            end
        end

        self.cTopLeft:ClearAllPoints();
        self.cTopRight:ClearAllPoints();

        if (activeButton) then
            self.cTopLeft:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, 0);
            self.cTopLeft:SetPoint("TOPRIGHT", activeButton, "TOPLEFT", 0, -(activeButton:GetHeight() - 1));

            self.cTopRight:SetPoint("TOPLEFT", activeButton, "TOPRIGHT", 0, -(activeButton:GetHeight() - 1));
            self.cTopRight:SetPoint("TOPRIGHT", self.contentFrame, "TOPRIGHT", 0, 0);
        else
            self.cTopLeft:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, 0);
            self.cTopLeft:SetPoint("TOPRIGHT", self.contentFrame, "TOPRIGHT", 0, 0);
            self.cTopRight:SetPoint("TOPLEFT", self.contentFrame, "TOPRIGHT", 0, 0);
            self.cTopRight:SetPoint("TOPRIGHT", self.contentFrame, "TOPRIGHT", 0, 0);
        end
    end

    -- show selected tab content
    if (tabName == "guild") then
        self.guildProfessionsPanel:Show();
    elseif (tabName == "specializations") then
        self.guildSpecializationsPanel:Show();
    elseif (tabName == "own") then
        self.ownProfessionsPanel:Show();
    end

    -- update bucket list
    self:CheckBucketList();
end

--- Refresh the active tab data.
function ProfessionsView:RefreshActiveTab()
    if (self.activeTab == "guild") then
        self.guildProfessionsPanel:Refresh();
    elseif (self.activeTab == "specializations") then
        self.guildSpecializationsPanel:Refresh();
    elseif (self.activeTab == "own") then
        self.ownProfessionsPanel:Refresh();
    end
end

--- Show skill view.
function ProfessionsView:ShowSkillView(row)
     self.skillViewBackground:Show();
     self.skillViewBackground:SetFrameLevel(2000);
     self.skillView:Show(row, self);
     self.skillView.view:SetFrameLevel(2001);
     self.skillViewVisible = true;
end

--- Hide skill view.
function ProfessionsView:HideSkillView(supressLoading)
    self.skillViewBackground:Hide();
    self.skillView:Hide();
    self.skillViewVisible = false;

    if (not supressLoading) then
        self:RefreshActiveTab();
    end
end

--- Show spec view.
function ProfessionsView:ShowSpecView(specData)
    self.skillViewBackground:Show();
    self.skillViewBackground:SetFrameLevel(2000);
    self.specView:Show(specData, self);
    self.specView.view:SetFrameLevel(2001);
    self.specViewVisible = true;
end

--- Hide spec view.
function ProfessionsView:HideSpecView()
    self.skillViewBackground:Hide();
    self.specView:Hide();
    self.specViewVisible = false;
end

--- Hide professions view.
function ProfessionsView:Hide()
    if (self.view) then
        self:HideSkillView();
        self.view:Hide();
    end
    self.visible = false;
end

--- Refresh data while view is open.
function ProfessionsView:Refresh()
    if (not self.visible) then
        return;
    end
    self:RefreshActiveTab();
end

--- Check bucket list visibility (delegate to guild professions panel).
function ProfessionsView:CheckBucketList()
    if (not self.bucketListPanel) then return; end

    local hasBucketList = self.bucketListPanel:HasItems();

    if (hasBucketList) then
        self.bucketListPanel:Show();
        self.bucketListPanel:Refresh();
        -- shrink active panel
        if (self.activeTab == "guild") then
            self.guildProfessionsPanel:SetRightMargin(300);
        elseif (self.activeTab == "specializations") then
            self.guildSpecializationsPanel:SetRightMargin(300);
        elseif (self.activeTab == "own") then
            self.ownProfessionsPanel:SetRightMargin(300);
        end
    else
        self.bucketListPanel:Hide();
        -- expand active panel
        if (self.activeTab == "guild") then
            self.guildProfessionsPanel:SetRightMargin(0);
        elseif (self.activeTab == "specializations") then
            self.guildSpecializationsPanel:SetRightMargin(0);
        elseif (self.activeTab == "own") then
            self.ownProfessionsPanel:SetRightMargin(0);
        end
    end
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
