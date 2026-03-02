--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local MissingReagentsView = _G.professionMaster:CreateView("missing-reagents");

--- Show missing view.
function MissingReagentsView:Show(missingReagents)
    -- get services
    local uiService = self:GetService("ui");
    local localeService = self:GetService("locale");
    local professionNamesService = self:GetService("profession-names");

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
            self:GetService("inventory"):ToggleMissingReagents();
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
            local row = CreateFrame("Button", nil, self.view, BackdropTemplateMixin and "BackdropTemplate");
            local top = 33 + ((reagentRowAmount - 1) * 16);
            row:SetPoint("TOPLEFT", self.view, "TOPLEFT", 10, -top);
            row:SetPoint("BOTTOMRIGHT", self.view, "TOPRIGHT", -10, -(top + 18));
            row:SetBackdrop({
                bgFile = [[Interface\Buttons\WHITE8x8]]
            });
            row:SetBackdropColor(0, 0, 0, 0);

            -- hover highlight
            row:SetScript("OnEnter", function()
                row:SetBackdropColor(0.3, 0.3, 0.3, 0.5);
            end);
            row:SetScript("OnLeave", function()
                row:SetBackdropColor(0, 0, 0, 0);
            end);

            -- shift+click to insert item link into chat
            row:SetScript("OnMouseDown", function(_, button)
                if (button == "LeftButton") and IsShiftKeyDown() and row.itemLink then
                    ChatEdit_InsertLink(row.itemLink);
                end
            end);

            -- add amount text
            local amountText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            amountText:SetPoint("RIGHT", -6, 0);
            amountText:SetJustifyH("RIGHT");
            amountText:SetTextColor(1, 1, 1);
            row.amountText = amountText;

            -- add item text
            local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            itemText:SetPoint("LEFT", 6, 0);
            itemText:SetPoint("RIGHT", amountText, "LEFT", -8, 0);
            itemText:SetJustifyH("LEFT");
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

        -- check if item id known
        if (C_Item.DoesItemExistByID(itemId)) then
            -- get item
            local item = Item:CreateFromItemID(itemId);
            if (not item:IsItemEmpty()) then
                pcall(function()
                    -- wait until loaded
                    item:ContinueOnItemLoad(function()
                        row.itemLink = item:GetItemLink();
                        row.itemText:SetText("|c" .. professionNamesService:GetItemColor(row.itemLink) .. item:GetItemName());
                    end);
                end);
            end
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