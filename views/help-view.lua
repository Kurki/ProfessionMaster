--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local HelpView = _G.professionMaster:CreateView("help");

--- Show help view.
function HelpView:Show()
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");

    -- check if view created
    if (self.view == nil) then
        -- create view
        local view = uiService:CreateView("PmHelp", 420, 200, localeService:Get("HelpViewTitle"));
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

        -- build help text
        local helpLines = {
            localeService:Get("CommandsTitle"),
            "",
            localeService:Get("CommandsOverview"),
            localeService:Get("CommandsReagents"),
            localeService:Get("CommandsMinimap"),
            localeService:Get("CommandsPurge")
        };
        local helpText = table.concat(helpLines, "\n");

        -- add description text
        local descriptionText = view:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        descriptionText:SetPoint("TOPLEFT", 16, -40);
        descriptionText:SetPoint("RIGHT", -16, 0);
        descriptionText:SetJustifyH("LEFT");
        descriptionText:SetJustifyV("TOP");
        descriptionText:SetTextColor(1, 1, 1);
        descriptionText:SetText(helpText);

        -- create ok button
        local okButton = uiService:CreateFlatButton(view, localeService:Get("SkillViewOk"), function()
            self:Hide();
        end);
        okButton:SetWidth(100);
        okButton:SetHeight(22);
        okButton:SetPoint("BOTTOMRIGHT", -12, 8);
    end

    -- show view
    self.view:Show();
    self.visible = true;
end

--- Hide view.
function HelpView:Hide()
    if (self.view) then
        self.view:Hide();
        self.visible = false;
    end
end

--- Toggle visibility.
function HelpView:ToggleVisibility()
    if (self.visible) then
        self:Hide();
    else
        self:Show();
    end
end
