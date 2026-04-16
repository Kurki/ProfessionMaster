--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local SettingsView = _G.professionMaster:CreateView("settings");

--- Initialize the settings panel in Interface Options.
function SettingsView:Initialize()
    -- get locale service
    local localeService = self:GetService("locale");

    -- create options panel
    local panel = CreateFrame("Frame");
    panel.name = "Profession Master";

    -- add title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    title:SetPoint("TOPLEFT", 16, -16);
    title:SetText("Profession Master");

    -- add respond to !who checkbox
    local respondToWhoCheckbox = CreateFrame("CheckButton", "PmSettingsRespondToWho", panel, "InterfaceOptionsCheckButtonTemplate");
    respondToWhoCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16);
    respondToWhoCheckbox.Text:SetText(localeService:Get("SettingsRespondToWho"));
    respondToWhoCheckbox.Text:SetPoint("LEFT", respondToWhoCheckbox, "RIGHT", 4, 0);
    respondToWhoCheckbox:SetChecked(PM_Settings.respondToWho);
    respondToWhoCheckbox:SetScript("OnClick", function(self)
        PM_Settings.respondToWho = self:GetChecked();
    end);

    -- add send non-guild characters checkbox
    local sendNonGuildCheckbox = CreateFrame("CheckButton", "PmSettingsSendNonGuildCharacters", panel, "InterfaceOptionsCheckButtonTemplate");
    sendNonGuildCheckbox:SetPoint("TOPLEFT", respondToWhoCheckbox, "BOTTOMLEFT", 0, -8);
    sendNonGuildCheckbox.Text:SetText(localeService:Get("SettingsSendNonGuildCharacters"));
    sendNonGuildCheckbox.Text:SetPoint("LEFT", sendNonGuildCheckbox, "RIGHT", 4, 0);
    sendNonGuildCheckbox:SetChecked(PM_Settings.sendNonGuildCharacters);
    sendNonGuildCheckbox:SetScript("OnClick", function(self)
        PM_Settings.sendNonGuildCharacters = self:GetChecked();
    end);

    -- add purge all button
    local purgeAllButton = CreateFrame("Button", "PmSettingsPurgeAll", panel, "UIPanelButtonTemplate");
    purgeAllButton:SetPoint("TOPLEFT", sendNonGuildCheckbox, "BOTTOMLEFT", 0, -16);
    purgeAllButton:SetSize(180, 24);
    purgeAllButton:SetText(localeService:Get("SettingsPurgeAll"));
    purgeAllButton:SetScript("OnClick", function()
        self:GetService("purge"):Purge("all");
    end);

    -- register in interface options
    if (Settings and Settings.RegisterCanvasLayoutCategory) then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name);
        Settings.RegisterAddOnCategory(category);
        self.categoryId = category:GetID();
    elseif (InterfaceOptions_AddCategory) then
        InterfaceOptions_AddCategory(panel);
    end
end

--- Open the settings panel.
function SettingsView:Open()
    if (self.categoryId and Settings and Settings.OpenToCategory) then
        Settings.OpenToCategory(self.categoryId);
    elseif (InterfaceOptionsFrame_OpenToCategory) then
        InterfaceOptionsFrame_OpenToCategory("Profession Master");
        InterfaceOptionsFrame_OpenToCategory("Profession Master");
    end
end
