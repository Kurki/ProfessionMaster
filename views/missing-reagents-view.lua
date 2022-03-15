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
MissingReagentsView = {};
MissingReagentsView.__index = MissingReagentsView;

--- Show missing view.
function MissingReagentsView:Show(missingReagents)
    -- get services
    local uiService = addon:GetService("ui");
    local localeService = addon:GetService("locale");
    local professionNamesService = addon:GetService("profession-names");

    -- check if view created
    if (self.view == nil) then
        -- clear rows
        self.reagentRows = {};

        -- create view
        local view = uiService:CreateView("PmMissingReagents", 210, 200, localeService:Get("MissingReagentsViewTitle"));
        view:EnableKeyboard();
        view:SetBackdropColor(0, 0, 0, 0);
        view:SetBackdropBorderColor(0.5, 0.5, 0.5, 0);
        self.view = view;

        -- add close button
        local closeButton = CreateFrame("Button", nil, view, "UIPanelCloseButton");
        closeButton:SetHeight(24);
        closeButton:SetWidth(24);
        closeButton:SetPoint("TOPRIGHT", -7, -8);
        closeButton:SetScript("OnClick", function()
            addon:GetService("inventory"):ToggleMissingReagents();
        end);
        closeButton:Hide();

        -- bind events
        local onEnter = function()
            view:SetBackdropColor(0, 0, 0, 0.2);
            view:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.1);
            closeButton:Show();
        end;
        local onLeave = function()
            view:SetBackdropColor(0, 0, 0, 0);
            view:SetBackdropBorderColor(0.5, 0.5, 0.5, 0);
            closeButton:Hide();
        end;

        view:SetScript("OnEnter", onEnter);
        view:SetScript("OnLeave", onLeave);
        closeButton:SetScript("OnEnter", onEnter);
        closeButton:SetScript("OnLeave", onLeave);
    end

    -- hide rows
    for _, row in ipairs(self.reagentRows) do
        row:Hide();
    end

    -- show reagents
    local reagentRowAmount = 0;
    for itemId, missingAmount in pairs(missingReagents) do
        reagentRowAmount = reagentRowAmount + 1;
        if (#self.reagentRows < reagentRowAmount) then
            -- create row frame
            local row = CreateFrame("Frame", nil, self.view, BackdropTemplateMixin and "BackdropTemplate");
            local top = 35 + ((reagentRowAmount - 1) * 16);
            row:SetPoint("TOPLEFT", self.view, "TOPLEFT", 16, -top);
            row:SetPoint("BOTTOMRIGHT", self.view, "TOPRIGHT", -16, -(top + 20));

            -- add amount text
            local amountText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            amountText:SetPoint("TOPRIGHT", 0, 0);
            amountText:SetJustifyH("RIGHT");
            amountText:SetTextColor(1, 1, 1);
            row.amountText = amountText;

            -- add item text
            local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("TOPLEFT", 0, 0);
            itemText:SetPoint("BOTTOMRIGHT", amountText, "BOTTOMLEFT", -8, 0);
            itemText:SetJustifyH("LEFT");
            itemText:SetJustifyV("TOP");
            row.itemText = itemText;

            -- add row
            table.insert(self.reagentRows, row);
        end

        -- get row
        local row = self.reagentRows[reagentRowAmount];
        row.itemId = itemId;
        row:Show();

        -- update amount
        row.amountText:SetText(missingAmount);

        -- get item
        local item = Item:CreateFromItemID(itemId);
        if (not item:IsItemEmpty()) then
            -- wait until loaded
            item:ContinueOnItemLoad(function()
                row.itemLink = item:GetItemLink();
                row.itemText:SetText("|c" .. professionNamesService:GetItemColor(row.itemLink) .. item:GetItemName());
            end);
        end
    end

    -- show view
    self.view:SetHeight(35 + reagentRowAmount * 16 + 10);
    self.view:Show();
    self.visible = true;
end

-- Hide view.
function MissingReagentsView:Hide()
    if (self.view) then
        self.view:Hide();
        self.visible = false;
    end
end

-- register view
addon:RegisterView(MissingReagentsView, "missing-reagents");