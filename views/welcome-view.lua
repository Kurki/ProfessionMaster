--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local WelcomeView = _G.professionMaster:CreateView("welcome");

--- Show welcome view.
function WelcomeView:Show()
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");
    local professionNamesService = self:GetService("profession-names");

    -- check if view created
    if (self.view == nil) then
        -- create view
        local view = uiService:CreateView("PmWelcome", 380, 200, localeService:Get("WelcomeTitle"));
        view:EnableKeyboard();
        self.view = view;

        -- add bucket list group text
        local descriptionText = view:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        descriptionText:SetPoint("TOPLEFT", 16, -40);
        descriptionText:SetPoint("BOTTOMRIGHT", -16, -42);
        descriptionText:SetJustifyH("LEFT");
        descriptionText:SetJustifyV("TOP");
        descriptionText:SetTextColor(1, 1, 1);
        descriptionText:SetText(localeService:Get("WelcomeDescription"));

        -- create ok button
        local okButton = uiService:CreateButton(view, localeService:Get("SkillViewOk"), function()
            CharacterSettings.welcomeRead = true;
            self:Hide();
        end);
        okButton:SetWidth(100);
        okButton:SetHeight(27);
        okButton:SetPoint("BOTTOMRIGHT", -10, 8);
    end

    -- show view
    self.view:Show();
    self.visible = true;
end

-- Hide view.
function WelcomeView:Hide()
    if (self.view) then
        self.view:Hide();
        self.visible = false;
    end
end