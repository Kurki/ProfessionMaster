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
                if (self.skillViewVisible) then
                    self:HideSkillView();
                elseif (self.specViewVisible) then
                    self:HideSpecView();
                else
                    self:Hide();
                end
            elseif (key == "ENTER") then
                ChatFrame_OpenChat("", nil, nil);
            end
        end)

        self.view = view;

        -- create skills list panel
        self.skillsListPanel = self.addon:NewView("skills-list-panel");
        self.skillsListPanel:Create(view, self);

        -- create bucket list panel
        self.bucketListPanel = self.addon:NewView("bucket-list-panel");
        self.bucketListPanel:Create(view, self);

        -- handle resize: update scroll child width and debounce expensive refresh
        view:HookScript("OnSizeChanged", function()
            self.skillsListPanel:OnSizeChanged();
            self.bucketListPanel:OnSizeChanged();
            if (self.resizePending) then
                self.resizePending:Cancel();
            end
            self.resizePending = C_Timer.NewTimer(0.05, function()
                self.resizePending = nil;
                self.skillsListPanel:RefreshRows();
                self.skillsListPanel:UpdateResponsiveLayout();
            end);
        end);

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
    self:HideSpecView();
    self:CheckBucketList();

    -- focus search
    self.skillsListPanel:FocusSearch();

    -- show view
    self.view:Show();
    self.visible = true;
end

--- Check bucket list.
function ProfessionsView:CheckBucketList()
    if (not self.view) then
        return;
    end

    local hasBucketList = self.bucketListPanel:HasItems();

    if (hasBucketList) then
        self.skillsListPanel:SetRightMargin(310);
        self.bucketListPanel:Show();
    else
        self.skillsListPanel:SetRightMargin(12);
        self.bucketListPanel:Hide();
    end
    self.skillsListPanel:UpdateResponsiveLayout();
    self.bucketListPanel:Refresh();
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

--- Hide skill view.
function ProfessionsView:HideSkillView(supressLoading)
    self.skillViewBackground:Hide();
    self.skillView:Hide();
    self.skillViewVisible = false;

    if (not supressLoading) then
        self.skillsListPanel:AddSkills();
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
