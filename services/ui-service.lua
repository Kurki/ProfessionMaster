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

-- define service
UiService = {};
UiService.__index = UiService;

-- current z index
local currentZIndex = 1000;

--- Initialize service.
function UiService:Initialize()
    -- init database
    if (Frames == nil) then
        Frames = {}
    end
end

-- create frame
function UiService:CreateView(name, width, height, title)
    -- create view
    local view = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
    view:SetFrameStrata("HIGH");
    view:SetWidth(width);
    view:SetHeight(height);
    view.positionName = name;
    view:SetFrameLevel(currentZIndex);
    view:SetBackdrop({
        bgFile = [[Interface/AddOns/nAuras/Media/BackgroundFlat]],
        edgeFile = [[Interface/Buttons/WHITE8X8]],
        edgeSize = 1
    });
    view:SetBackdropColor(0, 0, 0, 0.8);
    view:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
    currentZIndex = currentZIndex + 20;

    -- check elv ui
    if IsAddOnLoaded("ElvUI") then
        view:SetScale(ElvUI[1].global.general.UIScale);
    elseif (view:GetScale() > 0.9) then
        view:SetScale(0.9);
    end

    -- add title
    local titleLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft");
    titleLabel:SetPoint("TOPLEFT", 16, -14);
    titleLabel:SetText(addon.shortcut .. (title or ""));
    view.titleLabel = titleLabel;

    -- set moveable
    view:SetMovable(true);
    view:EnableMouse(true);
    view:SetClampedToScreen(true);
    view:RegisterForDrag("LeftButton");
    view:SetScript("OnDragStart", view.StartMoving);
    view:SetScript("OnDragStop", function()
        -- stop moving and store position
        view:StopMovingOrSizing();
        self:StorePosition(view);
    end);
    self:RestorePosition(view);
    return view;
end

--- Create normal button.
-- @param container  Container of button.
-- @param text Text of button.
-- @param onClick Callback function, triggered on button click.
function UiService:CreateButton(container, text, onClick)
    -- create button
    local button = CreateFrame("Button", nil, container, "UIPanelButtonTemplate");

    -- set text
    button:SetText(text);
    button:SetNormalFontObject("GameFontNormal");

    -- handle on click event
    button:SetScript("OnClick", onClick);
    return button;
end

--- Create icon button.
-- @param container Container of button.
-- @param iconName Icon of button.
-- @param tooltip tooltip of button.
-- @param onClick Callback function, triggered on button click.
-- @param size Size of button. If nil, 20 will be used.
function UiService:CreateIconButton(container, iconName, tooltipTitle, tooltipText, onClick, size)
    -- get size
    if (size == nil) then
        size = 20
    end

    -- create button
    local button = CreateFrame("Button", nil, container);
    button:SetWidth(size);
    button:SetHeight(size);
    button.tooltipTitle = tooltipTitle;
    button.tooltipText = tooltipText;

    -- add icon
    local icon = button:CreateTexture(nil, "BACKGROUND");
    icon:SetPoint("TOPLEFT", 0, 0);
    icon:SetPoint("BOTTOMRIGHT", 0, 0);
    icon:SetTexture("Interface/Icons/" .. iconName);

    -- add button glow
    local buttonGlow = button:CreateTexture(nil, "ARTWORK");
    buttonGlow:SetPoint("TOPLEFT", -12.5, 12.5);
    buttonGlow:SetWidth(size + 25);
    buttonGlow:SetHeight(size + 25);
    buttonGlow:SetTexture("Interface/Buttons/CheckButtonGlow");
    buttonGlow:Hide();

    -- bind bid button mouse events
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT");
        GameTooltip:AddLine(button.tooltipTitle);
        GameTooltip:AddLine(button.tooltipText, 1, 1, 1, true);
        GameTooltip:Show();
        buttonGlow:Show();
    end);
    button:SetScript("OnLeave", function()
        GameTooltip:Hide();
        buttonGlow:Hide();
    end);

    -- handle on click event
    button:SetScript("OnClick", onClick);
    return button;
end

-- create scroll frame
function UiService:CreateScrollFrame(container)
    -- create scroll frame and child
    local frameId = addon:GenerateString(10);
    local parentFrame = CreateFrame("Frame", "ScrollParentFrame" .. frameId, container, BackdropTemplateMixin and "BackdropTemplate");
    local scrollFrame = CreateFrame("ScrollFrame", "ScrollFrame" .. frameId, parentFrame, "UIPanelScrollFrameTemplate");
    local scrollChild = CreateFrame("Frame");
    parentFrame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]]
    });
    parentFrame:SetBackdropColor(0, 0, 0, 0.5);

    -- get scroll object
    local scrollBarName = scrollFrame:GetName()
    local scrollBar = _G[scrollBarName .. "ScrollBar"];
    local scrollUpButton = _G[scrollBarName .. "ScrollBarScrollUpButton"];
    local scrollDownButton = _G[scrollBarName .. "ScrollBarScrollDownButton"];

    -- re-arrange scroll bar
    scrollUpButton:ClearAllPoints();
    scrollUpButton:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -2, 0);
    scrollDownButton:ClearAllPoints();
    scrollDownButton:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -2, 0);
    scrollBar:ClearAllPoints();
    scrollBar:SetPoint("TOP", scrollUpButton, "BOTTOM", -1, 0);
    scrollBar:SetPoint("BOTTOM", scrollDownButton, "TOP", -1, 0);

    -- add scroll child to scroll frame
    scrollFrame:SetScrollChild(scrollChild);
    scrollFrame:SetPoint("TOPLEFT", parentFrame, 5, -5);
    scrollFrame:SetPoint("BOTTOMRIGHT", parentFrame, 0, 5);
    return parentFrame, scrollChild, scrollFrame;
end

function UiService:CreateTab(container, caption)
    -- get tab id
    local tabId = addon:GenerateString(10);

    -- generate tab
    local tab = CreateFrame("Button", "Tab" .. tabId, container, "OptionsFrameTabButtonTemplate");
    tab:SetID(1);
    tab:SetText(caption);
    PanelTemplates_TabResize(tab, 0);
    return tab;
end

--- Create edit box.
function UiService:CreateEditBox(container, width)
    local editBoxCotnainer = CreateFrame("Frame", nil, container, BackdropTemplateMixin and "BackdropTemplate");
    editBoxCotnainer:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]]
    });
    editBoxCotnainer:SetBackdropColor(1, 1, 1, 0.2);
    editBoxCotnainer:SetWidth(width);
    editBoxCotnainer:SetHeight(20);
    local editBox = CreateFrame("EditBox", nil, editBoxCotnainer);
    editBox:SetFontObject("ChatFontNormal");
    editBox:SetPoint("TOPLEFT", 4, -2);
    editBox:SetPoint("BOTTOMRIGHT", -4, 2);
    editBox:SetAutoFocus(false);
    editBoxCotnainer.text = editBox;
    return editBoxCotnainer;
end

--- Create edit box.
function UiService:CreateNumberEditBox(container, width)
    -- create edit box
    local editBox = self:CreateEditBox(container, width);
    editBox.text:SetJustifyH("RIGHT");
    return editBox;
end

--- Create check button.
function UiService:CreateCheckButton(container, width, text, tooltip)
    local checkButton = CreateFrame("CheckButton", "CheckButton" .. addon:GenerateString(10),
                            container, "ChatConfigCheckButtonTemplate");
    checkButton.tooltip = tooltip;
    local checkButtonText = getglobal(checkButton:GetName() .. 'Text');
    checkButtonText:SetText(text);
    checkButtonText:SetWidth(width);
    checkButtonText:SetPoint("TOPLEFT", 28, -6);
    return checkButton;
end

-- store frame position
function UiService:StorePosition(frame)
    -- store position
    local from, _, to, x, y = frame:GetPoint();
    Frames[frame.positionName] = {
        from = from,
        to = to,
        x = x,
        y = y
    };
end

-- restore frame position
function UiService:RestorePosition(frame)
    -- clear all points
    frame:ClearAllPoints();

    -- get position
    local position = Frames[frame.positionName];

    -- check position
    if (position == nil) then
        frame:SetPoint("CENTER", 0, 0);
        return;
    end

    -- set stored point
    frame:SetPoint(position.from, nil, position.to, position.x, position.y);
end

-- Create minimap icon.
function UiService:CreateMinimapIcon()
    -- get lib
    local libDbIcon = LibStub("LibDBIcon-1.0");

    -- create / register data broker
	local dataObj = LibStub("LibDataBroker-1.1"):NewDataObject("ProfessionMaster", {
		type = "launcher",
        label = "Profession Master",
		icon = "Interface\\Icons\\Inv_misc_book_05",
		OnClick = function(_, button)
            if (button == "LeftButton" and not addon.inCombat) then
                addon.professionsView:ToggleVisibility();
            elseif (button == "RightButton") then
                if (IsShiftKeyDown()) then
                    libDbIcon:Hide("ProfessionMaster");
                    Settings.minimapButton.hide = true;
                else
                    addon:GetService("inventory"):ToggleMissingReagents();
                end
            end
		end,
		OnTooltipShow = function(tooltip)
            local localeService = addon:GetService("locale");
            tooltip:SetText(localeService:Get("MinimapButtonTitle"));
            tooltip:AddLine(" ");
            tooltip:AddLine(localeService:Get("MinimapButtonLeftClick"));
            tooltip:AddLine(localeService:Get("MinimapButtonRightClick"));
            tooltip:AddLine(localeService:Get("MinimapButtonShiftRightClick"));
		end,
	})

    -- show minimap button
	libDbIcon:Register("ProfessionMaster", dataObj, Settings.minimapButton);
end

-- register service
addon:RegisterService(UiService, "ui");
