--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create service
local UiService = _G.professionMaster:CreateService("ui");

-- current z index
local currentZIndex = 1000;

--- Initialize service.
function UiService:Initialize()
    -- init database
    if (PM_Frames == nil) then
        PM_Frames = {}
    end
end

-- create frame
function UiService:CreateView(name, width, height, title, showShortcut, resizable)
    -- create view
    local view = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
    view:SetFrameStrata("HIGH");
    view:SetWidth(width);
    view:SetHeight(height);
    view.positionName = name;
    view.defaultWidth = width;
    view.defaultHeight = height;
    view:SetFrameLevel(currentZIndex);
    view:SetBackdrop({
        bgFile = [[Interface/Buttons/WHITE8X8]],
        edgeFile = [[Interface/Buttons/WHITE8X8]],
        edgeSize = 1
    });
    view:SetBackdropColor(0, 0, 0, 0.8);
    view:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
    currentZIndex = currentZIndex + 20;

    -- check elv ui
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        view:SetScale(ElvUI[1].global.general.UIScale);
    elseif (view:GetScale() > 0.9) then
        view:SetScale(0.9);
    end

    -- add title
    local titleLabel = view:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft");
    titleLabel:SetPoint("TOPLEFT", 16, -14);
    local titleText = title or "";
    if (showShortcut ~= false) then
        titleText = self.addon.shortcut .. titleText;
    end
    titleLabel:SetText(titleText);
    view.titleLabel = titleLabel;

    -- set moveable
    view:SetMovable(true);
    view:EnableMouse(true);
    view:SetClampedToScreen(true);
    view:RegisterForDrag("LeftButton");

    -- restore position and size
    self:RestorePosition(view);
    self:RestoreSize(view, width, height);

    -- validate that view is visible on screen
    self:ValidateOnScreen(view);

    -- set up resizable behavior
    if (resizable) then
        self:SetupResizable(view);
    end

    -- set drag handlers (only start drag if not on edge)
    local service = self;
    view:SetScript("OnDragStart", function()
        if (not view.amResizing) then
            view:StartMoving();
        end
    end);
    view:SetScript("OnDragStop", function()
        view:StopMovingOrSizing();
        service:StorePosition(view);
    end);

    return view;
end

--- Set up resizable behavior on a view frame.
-- @param view The frame to make resizable.
function UiService:SetupResizable(view)
    local service = self;
    view:SetResizable(true);
    view:SetResizeBounds(view.defaultWidth * 0.67, view.defaultHeight * 0.6);

    local edgeSize = 6;
    local resizeDirection = nil;
    view.amResizing = false;

    -- create edge overlay textures for per-side coloring
    local edgeThickness = 1;
    local edgeTop = view:CreateTexture(nil, "OVERLAY");
    edgeTop:SetColorTexture(0.5, 0.5, 0.5, 0.5);
    edgeTop:SetPoint("TOPLEFT", 0, 0);
    edgeTop:SetPoint("TOPRIGHT", 0, 0);
    edgeTop:SetHeight(edgeThickness);

    local edgeBottom = view:CreateTexture(nil, "OVERLAY");
    edgeBottom:SetColorTexture(0.5, 0.5, 0.5, 0.5);
    edgeBottom:SetPoint("BOTTOMLEFT", 0, 0);
    edgeBottom:SetPoint("BOTTOMRIGHT", 0, 0);
    edgeBottom:SetHeight(edgeThickness);

    local edgeLeft = view:CreateTexture(nil, "OVERLAY");
    edgeLeft:SetColorTexture(0.5, 0.5, 0.5, 0.5);
    edgeLeft:SetPoint("TOPLEFT", 0, 0);
    edgeLeft:SetPoint("BOTTOMLEFT", 0, 0);
    edgeLeft:SetWidth(edgeThickness);

    local edgeRight = view:CreateTexture(nil, "OVERLAY");
    edgeRight:SetColorTexture(0.5, 0.5, 0.5, 0.5);
    edgeRight:SetPoint("TOPRIGHT", 0, 0);
    edgeRight:SetPoint("BOTTOMRIGHT", 0, 0);
    edgeRight:SetWidth(edgeThickness);

    -- map resize directions to active edges
    local directionEdges = {
        TOP         = { top = true },
        BOTTOM      = { bottom = true },
        LEFT        = { left = true },
        RIGHT       = { right = true },
        TOPLEFT     = { top = true, left = true },
        TOPRIGHT    = { top = true, right = true },
        BOTTOMLEFT  = { bottom = true, left = true },
        BOTTOMRIGHT = { bottom = true, right = true },
    };

    local function UpdateEdgeColors(direction)
        if (not direction) then
            -- default: all gray
            edgeTop:SetColorTexture(0.5, 0.5, 0.5, 0.5);
            edgeBottom:SetColorTexture(0.5, 0.5, 0.5, 0.5);
            edgeLeft:SetColorTexture(0.5, 0.5, 0.5, 0.5);
            edgeRight:SetColorTexture(0.5, 0.5, 0.5, 0.5);
            return;
        end
        local active = directionEdges[direction] or {};
        -- active edges golden, others white
        if (active.top) then edgeTop:SetColorTexture(1, 0.82, 0, 1); else edgeTop:SetColorTexture(1, 1, 1, 1); end
        if (active.bottom) then edgeBottom:SetColorTexture(1, 0.82, 0, 1); else edgeBottom:SetColorTexture(1, 1, 1, 1); end
        if (active.left) then edgeLeft:SetColorTexture(1, 0.82, 0, 1); else edgeLeft:SetColorTexture(1, 1, 1, 1); end
        if (active.right) then edgeRight:SetColorTexture(1, 0.82, 0, 1); else edgeRight:SetColorTexture(1, 1, 1, 1); end
    end

    local function GetResizeDirection()
        -- only detect edges when mouse is over the frame
        if (not view:IsMouseOver()) then return nil; end

        local x, y = GetCursorPosition();
        local scale = view:GetEffectiveScale();
        x, y = x / scale, y / scale;
        local left = view:GetLeft();
        local right = view:GetRight();
        local top = view:GetTop();
        local bottom = view:GetBottom();
        if (not left) then return nil; end

        local atLeft = (x - left) < edgeSize;
        local atRight = (right - x) < edgeSize;
        local atTop = (top - y) < edgeSize;
        local atBottom = (y - bottom) < edgeSize;

        if (atTop and atLeft) then return "TOPLEFT"; end
        if (atTop and atRight) then return "TOPRIGHT"; end
        if (atBottom and atLeft) then return "BOTTOMLEFT"; end
        if (atBottom and atRight) then return "BOTTOMRIGHT"; end
        if (atTop) then return "TOP"; end
        if (atBottom) then return "BOTTOM"; end
        if (atLeft) then return "LEFT"; end
        if (atRight) then return "RIGHT"; end
        return nil;
    end

    view:HookScript("OnUpdate", function()
        if (resizeDirection) then return; end
        local dir = GetResizeDirection();
        UpdateEdgeColors(dir);
    end);

    view:HookScript("OnMouseDown", function(_, button)
        if (button == "LeftButton") then
            local dir = GetResizeDirection();
            if (dir) then
                resizeDirection = dir;
                view.amResizing = true;
                view:StopMovingOrSizing();
                view:StartSizing(dir);
                UpdateEdgeColors(dir);
            end
        end
    end);

    view:HookScript("OnMouseUp", function(_, button)
        if (resizeDirection) then
            view:StopMovingOrSizing();
            resizeDirection = nil;
            view.amResizing = false;
            local dir = GetResizeDirection();
            UpdateEdgeColors(dir);
            service:StorePosition(view);
            service:StoreSize(view);
        end
    end);

    view:HookScript("OnLeave", function()
        if (not resizeDirection) then
            UpdateEdgeColors(nil);
        end
    end);
end

--- Bind a simple tooltip to a frame.
-- Shows tooltip on enter, hides on leave. Uses HookScript so existing handlers are preserved.
-- @param frame The frame to bind the tooltip to.
-- @param text Tooltip text string.
-- @param anchorPoint Optional anchor point (default "ANCHOR_BOTTOM").
function UiService:BindTooltip(frame, text, anchorPoint)
    local anchor = anchorPoint or "ANCHOR_BOTTOM";
    frame:HookScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, anchor);
        GameTooltip:SetText(text);
        GameTooltip:Show();
    end);
    frame:HookScript("OnLeave", function()
        GameTooltip:Hide();
    end);
end

--- Create a frame with standard panel backdrop (dark background with gray border).
-- @param parent Parent frame.
-- @return Frame with backdrop configured.
function UiService:CreatePanel(parent)
    local frame = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate");
    frame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = [[Interface/Buttons/WHITE8X8]],
        edgeSize = 1
    });
    frame:SetBackdropColor(0, 0, 0, 0.5);
    frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
    return frame;
end

--- Apply alternating row background color.
-- @param row Row frame with backdrop.
-- @param rowIndex 1-based row index for alternation.
function UiService:SetRowColor(row, rowIndex)
    local backgroundColor = (rowIndex % 2 == 0) and 0.1 or 0.15;
    row.bgColor = backgroundColor;
    row:SetBackdropColor(backgroundColor, backgroundColor, backgroundColor, 0.5);
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

--- Create flat button.
-- @param container Container of button.
-- @param text Text of button.
-- @param onClick Callback function, triggered on button click.
function UiService:CreateFlatButton(container, text, onClick)
    local button = CreateFrame("Button", nil, container, BackdropTemplateMixin and "BackdropTemplate");
    button:SetBackdrop({
        bgFile = [[Interface/Buttons/WHITE8X8]],
        edgeFile = [[Interface/Buttons/WHITE8X8]],
        edgeSize = 1
    });
    button:SetBackdropColor(0.12, 0.12, 0.12, 0.95);
    button:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.45);
    button:SetText(text);
    button:SetNormalFontObject("GameFontNormal");
    button:SetHighlightFontObject("GameFontHighlight");

    button:SetScript("OnMouseDown", function(self)
        self:SetBackdropColor(0.08, 0.08, 0.08, 0.95);
        self:SetBackdropBorderColor(0.28, 0.28, 0.28, 0.4);
    end);
    button:SetScript("OnMouseUp", function(self)
        self:SetBackdropColor(0.12, 0.12, 0.12, 0.95);
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.45);
    end);
    button:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.62);
    end);
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.12, 0.12, 0.12, 0.95);
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.45);
    end);
    button:SetScript("OnClick", onClick);
    return button;
end

--- Create flat square button.
-- @param container Container of button.
-- @param text Text of button.
-- @param onClick Callback function, triggered on button click.
-- @param size Optional size of button. Default is 20.
function UiService:CreateFlatSquareButton(container, text, onClick, size)
    local button = self:CreateFlatButton(container, text, onClick);
    local buttonSize = size or 20;
    button:SetWidth(buttonSize);
    button:SetHeight(buttonSize);
    return button;
end

--- Create flat close button.
-- @param container Container of button.
-- @param onClick Callback function, triggered on button click.
function UiService:CreateFlatCloseButton(container, onClick)
    local button = self:CreateFlatSquareButton(container, "X", onClick, 18);
    button:SetNormalFontObject("GameFontHighlightSmall");
    button:SetHighlightFontObject("GameFontHighlight");
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
    local frameId = self.addon:GenerateString(10);
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
    local tabId = self.addon:GenerateString(10);

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
    local checkButton = CreateFrame("CheckButton", "CheckButton" .. self.addon:GenerateString(10),
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
    local from, _, to, x, y = frame:GetPoint();
    if (not PM_Frames[frame.positionName]) then
        PM_Frames[frame.positionName] = {};
    end
    PM_Frames[frame.positionName].from = from;
    PM_Frames[frame.positionName].to = to;
    PM_Frames[frame.positionName].x = x;
    PM_Frames[frame.positionName].y = y;
end

-- restore frame position
function UiService:RestorePosition(frame)
    frame:ClearAllPoints();
    local data = PM_Frames[frame.positionName];
    if (not data or not data.from) then
        frame:SetPoint("CENTER", 0, 0);
        return;
    end
    frame:SetPoint(data.from, nil, data.to, data.x, data.y);
end

-- store frame size
function UiService:StoreSize(frame)
    if (not PM_Frames[frame.positionName]) then
        PM_Frames[frame.positionName] = {};
    end
    PM_Frames[frame.positionName].width = frame:GetWidth();
    PM_Frames[frame.positionName].height = frame:GetHeight();
end

-- restore frame size
function UiService:RestoreSize(frame, defaultWidth, defaultHeight)
    local data = PM_Frames[frame.positionName];
    if (data and data.width and data.height) then
        -- enforce minimum size
        local minWidth = defaultWidth * 0.67;
        local minHeight = defaultHeight * 0.5;
        frame:SetWidth(math.max(data.width, minWidth));
        frame:SetHeight(math.max(data.height, minHeight));
    else
        frame:SetWidth(defaultWidth);
        frame:SetHeight(defaultHeight);
    end
end

-- validate that frame is visible on screen, reset to center if not
function UiService:ValidateOnScreen(frame)
    -- defer to next frame so layout is resolved
    C_Timer.After(0, function()
        local left = frame:GetLeft();
        local bottom = frame:GetBottom();
        local right = frame:GetRight();
        local top = frame:GetTop();
        if (not left or not bottom) then
            return;
        end

        local scale = frame:GetEffectiveScale();
        local screenWidth = GetScreenWidth();
        local screenHeight = GetScreenHeight();

        -- check if at least part of the frame is visible
        local visible = (right * scale > 0) and (left * scale < screenWidth) and (top * scale > 0) and (bottom * scale < screenHeight);
        if (not visible) then
            frame:ClearAllPoints();
            frame:SetPoint("CENTER", 0, 0);
        end
    end);
end

-- Create minimap icon.
function UiService:CreateMinimapIcon()
    local service = self;

    -- get lib
    local libDbIcon = LibStub("LibDBIcon-1.0");

    -- create / register data broker
	local dataObj = LibStub("LibDataBroker-1.1"):NewDataObject("ProfessionMaster", {
		type = "launcher",
        label = "Profession Master",
		icon = "Interface\\Icons\\Inv_misc_book_05",
		OnClick = function(_, button)
            if (button == "LeftButton") then
                if (IsShiftKeyDown()) then
                    service.addon.settingsView:Open();
                elseif (not service.addon.inCombat) then
                    service.addon.professionsView:ToggleVisibility();
                end
            elseif (button == "RightButton") then
                if (IsShiftKeyDown()) then
                    libDbIcon:Hide("ProfessionMaster");
                    PM_Settings.minimapButton.hide = true;
                else
                    service:GetService("inventory"):ToggleMissingReagents();
                end
            end
		end,
		OnTooltipShow = function(tooltip)
            local localeService = service:GetService("locale");
            tooltip:SetText(localeService:Get("MinimapButtonTitle"));
            tooltip:AddLine(" ");
            tooltip:AddLine(localeService:Get("MinimapButtonLeftClick"));
            tooltip:AddLine(localeService:Get("MinimapButtonShiftLeftClick"));
            tooltip:AddLine(localeService:Get("MinimapButtonRightClick"));
            tooltip:AddLine(localeService:Get("MinimapButtonShiftRightClick"));
		end,
	})

    -- show minimap button
	libDbIcon:Register("ProfessionMaster", dataObj, PM_Settings.minimapButton);
end

