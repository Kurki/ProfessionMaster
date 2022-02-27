--[[

@author Esperanza - Everlook/EU-Alliance
@copyright ©2022 The Profession Master Authors. All Rights Reserved.

Licensed under the GNU General Public License, Version 3.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.gnu.org/licenses/gpl-3.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]
local addon = _G.professionMaster;

-- define view
WelcomeView = {};
WelcomeView.__index = WelcomeView;

--- Show welcome view.
function WelcomeView:Show()
    -- get services
    local uiService = addon:GetService("ui");
    local localeService = addon:GetService("locale");
    local professionNamesService = addon:GetService("profession-names");

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

-- register view
addon:RegisterView(WelcomeView, "welcome");