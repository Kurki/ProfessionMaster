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
    respondToWhoCheckbox:SetChecked(PM_Settings.respondToWho);
    respondToWhoCheckbox:SetScript("OnClick", function(self)
        PM_Settings.respondToWho = self:GetChecked();
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
