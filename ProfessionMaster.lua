--[[

@author Esperanza - Everlook/EU-Alliance
@copyright ©2021 Profession Master Authors. All Rights Reserved.

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

-- define addon name
local addonName = "Profession Master";
local addonVersion = C_AddOns.GetAddOnMetadata("ProfessionMaster", "version");
local addonShortcut = "|cffDA8CFF[PM]|r ";

-- define addon
ProfessionMasterAddon = {};
ProfessionMasterAddon.__index = ProfessionMasterAddon;

-- prepare storage
if (not OwnProfessions) then OwnProfessions = {}; end
if (not Professions) then Professions = {}; end
if (not SyncTimes) then SyncTimes = {}; end
if (not Logs) then Logs = {}; end
if (not CharacterSets) then CharacterSets = {}; end
if (not BucketList) then BucketList = {}; end
if (not CharacterSettings) then CharacterSettings = {}; end
if (not Guildmates) then Guildmates = {}; end

--- Create new addon container.
function ProfessionMasterAddon:Create()
    -- get wow build
    local wowBuild = GetBuildInfo();

    -- create addon and add empty holders
    local addon = {
        name = addonName,
        version = addonVersion,
        shortcut = addonShortcut,
        debug = false,
        trace = false,
        frame = CreateFrame("Frame"),
        logLevel = 0,
        loaded = false,
        isVanilla = string.find(wowBuild, "1.") == 1,
        isBcc = string.find(wowBuild, "2.") == 1,
        isWrath = string.find(wowBuild, "3.") == 1,
        isCata = string.find(wowBuild, "4.") == 1,
        isMop = string.find(wowBuild, "5.") == 1,
    };
    setmetatable(addon, ProfessionMasterAddon);
    
    -- set at least addon indicators
    addon.isMopAtLeast = addon.isMop;
    addon.isCataAtLeast = addon.isCata or addon.isMopAtLeast;
    addon.isWrathAtLeast = addon.isWrath or addon.isCataAtLeast;
    addon.isBccAtLeast = addon.isBcc or addon.isWrathAtLeast;

    -- clear types
    addon.serviceTypes = {};
    addon.services = {};
    addon.viewTypes = {};
    addon.modelTypes = {};
    addon.eventHandlers = {};

    -- register events
    addon:RegisterEvents();
    return addon;
end

--- Create service.
-- @param name Name of service.
-- @return Service type definition.
function ProfessionMasterAddon:CreateService(name)
    local serviceType = {};
    serviceType.__index = serviceType;
    self.serviceTypes[name] = serviceType;
    return serviceType;
end

--- Check settings.
function ProfessionMasterAddon:CheckSettings()
    -- check settings
    if (not PMSettings) then 
        PMSettings = {}; 
    end
    if (not PMSettings.storageId) then
        PMSettings.storageId = self:GenerateString(12);
    end
    if (not PMSettings.minimapButton) then
        PMSettings.minimapButton = {
            hide = false
        };
    end
end

--- Create view.
-- @param name Name of view.
-- @return View type definition.
function ProfessionMasterAddon:CreateView(name)
    local viewType = {};
    viewType.__index = viewType;
    self.viewTypes[name] = viewType;
    return viewType;
end

--- Create model.
-- @param name Name of model.
-- @param initialData Optional initial data table for data-only models.
-- @return Model type definition.
function ProfessionMasterAddon:CreateModel(name, initialData)
    local modelType;
    if (initialData) then
        -- data model: store as-is, no injection
        modelType = initialData;
    else
        -- class model: inject helpers
        modelType = {
            addon = self,
            GetService = function(_self, serviceName)
                return self:GetService(serviceName);
            end,
            GetModel = function(_self, modelName)
                return self:GetModel(modelName);
            end,
        };
        modelType.__index = modelType;
    end
    self.modelTypes[name] = modelType;
    return modelType;
end

--- Get service.
-- @param name Name of service.
function ProfessionMasterAddon:GetService(name)
    -- check if service created
    if (self.services[name] == nil) then
        -- create service with injected helpers
        local service = {
            addon = self,
            GetService = function(_self, serviceName)
                return self:GetService(serviceName);
            end,
            GetModel = function(_self, modelName)
                return self:GetModel(modelName);
            end,
            HandleEvent = function(_self, eventName, callback)
                return self:HandleEvent(eventName, callback);
            end
        };
        setmetatable(service, self.serviceTypes[name]);
        self.services[name] = service;

        -- initialize service
        if (service.Initialize) then
            service:Initialize();
        end
    end

    -- get service
    return self.services[name];
end

--- Create new view instance.
-- @param name Name of view.
function ProfessionMasterAddon:NewView(name)
    -- get view type
    local viewType = self.viewTypes[name];

    -- create view with injected helpers
    local view = {
        addon = self,
        GetService = function(_self, serviceName)
            return self:GetService(serviceName);
        end,
        GetModel = function(_self, modelName)
            return self:GetModel(modelName);
        end
    };
    setmetatable(view, viewType);
    return view;
end

--- Get model.
-- @param name Name of model.
function ProfessionMasterAddon:GetModel(name)
    -- get model type
    return self.modelTypes[name];
end

--- Toggle debug flag.
function ProfessionMasterAddon:ToggleDebug()
    if (self.logLevel == 1) then
        self.logLevel = 0;
        self:GetService("chat"):WriteBare("Debug-Mode disabled.");
    elseif (self.logLevel == 0) then
        self.logLevel = 1;
        self:GetService("chat"):WriteBare("Debug-Mode enabled.");
    end
end

--- Toggle trace flag.
function ProfessionMasterAddon:ToggleTrace()
    if (self.logLevel == 2) then
        self.logLevel = 0;
        self:GetService("chat"):WriteBare("Trace-Mode disabled.");
    elseif (self.logLevel == 0) then
        self.logLevel = 2;
        self:GetService("chat"):WriteBare("Trace-Mode enabled.");
    end
end

--- Log debug message.
-- @param class Name of class to log within.
-- @param method Name of method to log within.
-- @param message Log message.
function ProfessionMasterAddon:LogDebug(class, method, message, ...)
    -- check if trace not enabled
    if (self.logLevel < 1) then
        return;
    end

    -- add to logs
    table.insert(Logs, date("%Y-%m-%dT%H-%M-%S") .. " " .. class .. ":" .. method .. " [Debug] " .. string.format(message, ...));

    -- print out trace
    print("[Debug] " .. class .. ":" .. method .. " - " .. string.format(message, ...));
end

--- Log trace message.
-- @param class Name of class to log within.
-- @param method Name of method to log within.
-- @param message Log message.
function ProfessionMasterAddon:LogTrace(class, method, message, ...)
    -- check if trace not enabled
    if (self.logLevel < 2) then
        return;
    end

    -- add to logs
    table.insert(Logs, date("%Y-%m-%dT%H-%M-%S") .. " " .. class .. ":" .. method .. " [Trace] " .. string.format(message, ...));

    -- print out trace
    print("[Trace] " .. class .. ":" .. method .. " - " .. string.format(message, ...));
end

--- Handle event.
-- @param name Event name.
-- @param callback Callback function, triggered on event.
function ProfessionMasterAddon:HandleEvent(name, callback)
    -- check if event not handled before
    if (self.eventHandlers[name] == nil) then
        -- create event handler array for the given event name
        self.eventHandlers[name] = {};

        -- watch event
        self.frame:RegisterEvent(name);
    end

    -- add callback to event handler
    table.insert(self.eventHandlers[name], callback);
end

--- Register addon events.
function ProfessionMasterAddon:RegisterEvents()
    -- handle on event
    self.frame:SetScript("OnEvent", function(_self, event, ...)
        -- dispatch to registered handlers
        if (self.eventHandlers[event]) then
            for _, handler in ipairs(self.eventHandlers[event]) do
                handler(...);
            end
        end
    end);

    -- handle addon loaded
    self:HandleEvent("ADDON_LOADED", function(addonName)
        if (addonName == "ProfessionMaster") then
            self:CheckSettings();
            self:GetService("commands");
        end
    end);

    -- handle chat message
    self:HandleEvent("CHAT_MSG_ADDON", function(prefix, message, channel, sender)
        self:GetService("message"):HandleMessage(prefix, message, sender);
    end);

    -- handle login
    self:HandleEvent("PLAYER_LOGIN", function()
        self.frame:UnregisterEvent("PLAYER_LOGIN");

        -- create professions view
        self.professionsView = self:NewView("professions");

        -- migrate data
        self:Migrate();

        -- create minimap icon
        self:GetService("ui"):CreateMinimapIcon();

        -- watch tooltip
        self:GetService("tooltip"):WatchTooltip();

        -- startup
        self:GetService("timer"):Wait("PlayerLogin", 5, function()
            -- show loaded message
            self:GetService("chat"):Write("AddonLoaded");

            -- broadcast version
            self:GetService("message"):SendToGuild(self:GetModel("version-broadcast-message"):Create());

            -- check welcome
            self:GetService("own-professions"):CheckWelcome();

            -- say hello to guild
            self:GetService("professions"):SayHelloToGuild();

            -- check missing reagents
            self:GetService("inventory"):CheckMissingReagents();
        end);
    end);

    -- handle trade skill update
    self:HandleEvent("TRADE_SKILL_UPDATE", function()
        self:GetService("own-professions"):GetProfessionData();
    end);

    -- handle craft update
    self:HandleEvent("CRAFT_UPDATE", function()
        self:GetService("own-professions"):GetProfessionData();
    end);

    -- handle guild roster update
    self:HandleEvent("GUILD_ROSTER_UPDATE", function()
        self:GetService("player"):RefreshGuildmates();
    end);

    -- handle combat enter
    self:HandleEvent("PLAYER_REGEN_DISABLED", function()
        self.inCombat = true;
        if (self.professionsView and self.professionsView.visible) then
            self.professionsView:Hide();
        end
    end);

    -- handle combat leave
    self:HandleEvent("PLAYER_REGEN_ENABLED", function()
        self.inCombat = nil;
    end);

    -- handle bag update (debounced)
    self:HandleEvent("BAG_UPDATE", function()
        -- immediately invalidate inventory cache
        self:GetService("inventory"):InvalidateInventory();

        -- debounce the actual reagent check
        if (not self.bagUpdatePending) then
            self.bagUpdatePending = true;
            C_Timer.After(0.2, function()
                self.bagUpdatePending = nil;
                self:GetService("inventory"):CheckMissingReagents();
            end);
        end
    end);
end

-- prepare charset
local idCharset = {};
for i = 48, 57 do
    table.insert(idCharset, string.char(i))
end
for i = 65, 90 do
    table.insert(idCharset, string.char(i))
end
for i = 97, 122 do
    table.insert(idCharset, string.char(i))
end

-- Generate random string.
function ProfessionMasterAddon:GenerateString(length)
    -- build id
    local id = {};
    for i = 1, length do
        table.insert(id, idCharset[math.random(1, #idCharset)]);
    end
    return table.concat(id, "");
end

-- Migrate data.
function ProfessionMasterAddon:Migrate()
    -- set store version
    PMSettings.storeVersion = 5;
end

-- create addon
_G.professionMaster = ProfessionMasterAddon:Create();