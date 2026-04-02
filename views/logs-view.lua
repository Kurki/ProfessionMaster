--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create view
local LogsView = _G.professionMaster:CreateView("logs");

--- Show logs view.
function LogsView:Show()
    -- get services
    local uiService = self:GetService("ui");
    local logService = self:GetService("log");

    -- check if view created
    if (self.view == nil) then
        -- create view
        local view = uiService:CreateView("PmLogs", 600, 450, "Protokolle", true);
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

        -- add scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, view, "UIPanelScrollFrameTemplate");
        scrollFrame:SetPoint("TOPLEFT", 12, -36);
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 42);

        -- add edit box for selectable/copyable text
        local editBox = CreateFrame("EditBox", nil, scrollFrame);
        editBox:SetMultiLine(true);
        editBox:SetAutoFocus(false);
        editBox:SetFontObject(GameFontHighlightSmall);
        editBox:SetWidth(scrollFrame:GetWidth() - 10);
        editBox:SetScript("OnEscapePressed", function()
            editBox:ClearFocus();
        end);
        editBox:SetScript("OnTextChanged", function(_, userInput)
            if (userInput) then
                -- prevent user edits, restore original text
                editBox:SetText(self.logText or "");
                editBox:SetCursorPosition(0);
            end
        end);
        scrollFrame:SetScrollChild(editBox);
        self.editBox = editBox;

        -- create ok button
        local okButton = uiService:CreateFlatButton(view, "OK", function()
            self:Hide();
        end);
        okButton:SetWidth(100);
        okButton:SetHeight(22);
        okButton:SetPoint("BOTTOMRIGHT", -12, 8);
    end

    -- update log text
    self.logText = logService:GetLogText();
    self.editBox:SetText(self.logText);
    self.editBox:SetCursorPosition(0);

    -- show view
    self.view:Show();
    self.visible = true;
end

--- Hide view.
function LogsView:Hide()
    if (self.view) then
        self.view:Hide();
        self.visible = false;
    end
end

--- Toggle visibility.
function LogsView:ToggleVisibility()
    if (self.visible) then
        self:Hide();
    else
        self:Show();
    end
end
