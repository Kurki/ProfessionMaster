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
local addonVersion = "1.5.3";
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
        isEra = string.find(wowBuild, "1.") == 1
    };
    setmetatable(addon, ProfessionMasterAddon);
    
    -- clear types
    addon.serviceTypes = {};
    addon.services = {};
    addon.viewTypes = {};
    addon.modelTypes = {};

    -- check settings
    addon:CheckSettings();

    -- register events
    addon:RegisterEvents();
    return addon;
end

--- Register service.
-- @param ServiceType Service type definition.
-- @param name Name of service.
function ProfessionMasterAddon:RegisterService(ServiceType, name)
    -- add to service types
    self.serviceTypes[name] = ServiceType;
end

--- Check settings.
function ProfessionMasterAddon:CheckSettings()
    -- check settings
    if (not Settings) then 
        Settings = {}; 
    end
    if (not Settings.storageId) then
        Settings.storageId = self:GenerateString(12);
    end
end

--- Register view.
-- @param ViewType View type definition.
-- @param name Name of view.
function ProfessionMasterAddon:RegisterView(ViewType, name)
    -- add to view types
    self.viewTypes[name] = ViewType;
end

--- Register model.
-- @param ModelType Model type definition.
-- @param name Name of model.
function ProfessionMasterAddon:RegisterModel(ModelType, name)
    -- add to model types
    self.modelTypes[name] = ModelType;
end

--- Get service.
-- @param name Name of service.
function ProfessionMasterAddon:GetService(name)
    -- check if service created
    if (self.services[name] == nil) then
        -- create service
        local service = {};
        setmetatable(service, self.serviceTypes[name]);
        self.services[name] = service;

        -- initialize service
        service:Initialize();
    end

    -- get service
    return self.services[name];
end

--- Create view.
-- @param name Name of view.
function ProfessionMasterAddon:CreateView(name)
    -- get to view type
    local viewType = self.viewTypes[name];

    -- create view
    local view = {};
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
    --print("[Debug] " .. class .. ":" .. method .. " - " .. string.format(message, ...));
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
    -- print("[Trace] " .. class .. ":" .. method .. " - " .. string.format(message, ...));
end

--- Register addon events.
function ProfessionMasterAddon:RegisterEvents()
    -- check if russian
    if (GetLocale() == "ruRU") then
        print(addonShortcut .. "Авторы аддона оставляют за собой право не поддерживать игроков из стран, которые ведут себя мизантропически.");
    end

    -- register events
    self.frame:RegisterEvent("CHAT_MSG_ADDON");
    self.frame:RegisterEvent("PLAYER_LOGIN");
    self.frame:RegisterEvent("TRADE_SKILL_UPDATE");
    self.frame:RegisterEvent("CRAFT_UPDATE");
    self.frame:RegisterEvent("GUILD_ROSTER_UPDATE");
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED");
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED");
    self.frame:RegisterEvent("BAG_UPDATE");

    -- handle on event
    self.frame:SetScript("OnEvent", function(_self, event, prefix, message, channel, sender)
        -- handle chat messaage
        if (event == "CHAT_MSG_ADDON") then
            -- startup
            self:GetService("message"):HandleMessage(prefix, message, sender);

        -- handle login
        elseif (event == "PLAYER_LOGIN") then
            -- unregister event
            _self:UnregisterEvent("PLAYER_LOGIN")

            -- crete professions view
            self.professionsView = self:CreateView("professions");

            -- migrate data
            self:Migrate();

            -- create minimap icon
            self:GetService("ui"):CreateMinimapIcon();

            -- watch tooltip
            self:GetService("tooltip"):WatchTooltip();

            -- startup
            self:GetService("timer"):Wait("PlayerLogin", 10, function()
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

        -- handle trade skill update
        elseif (event == "TRADE_SKILL_UPDATE") then
            self:GetService("own-professions"):GetTradeSkillProfessionData();

        -- handle craft update
        elseif (event == "GUILD_ROSTER_UPDATE") then
            self:GetService("player"):RefreshGuildmates();

        -- handle combat enter
        elseif (event == "PLAYER_REGEN_DISABLED") then
            self.inCombat = true;
            if (self.professionsView.visible) then
                self.professionsView:Hide();
            end

        -- handle combat leave
        elseif (event == "PLAYER_REGEN_ENABLED") then
            self.inCombat = nil;

        -- handle bag update
        elseif (event == "BAG_UPDATE") then
            self:GetService("inventory"):CheckMissingReagents();
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
    -- check data version
    if (Settings.storeVersion and Settings.storeVersion < 3) then
        -- clear data
        Professions = {};
        OwnProfessions = {};
        SyncTimes = {};
        CharacterSettings = {}; 
        Settings = {};
        self:CheckSettings();
    end

    -- check data version
    if (Settings.storeVersion and Settings.storeVersion < 5) then
        -- check all professions
        for professionId, profession in pairs(Professions) do  
            -- prepare valid skills
            local validSkills = {};

            -- iterate skills
            for skillId, skill in pairs(profession) do     
                -- check skill
                if (skill.name ~= nil and skill.itemId ~= nil) then
                    validSkills[skillId] = skill;
                end
            end

            -- store valid skills
            Professions[professionId] = validSkills;
        end

        -- check own professions
        for characterName, professions in pairs(OwnProfessions) do
            -- iterate all professions
            for professionId, skills in pairs(professions) do
                -- prepare valid skills
                local validSkills = {};

                -- iterate all skills
                for skillIndex = 1, #skills do
                    -- get skill
                    local skill = skills[skillIndex];

                    -- check skill
                    if (skill.skillId ~= nil and skill.itemId ~= nil) then
                        table.insert(validSkills, skill);
                    end
                end

                -- store valid skills
                professions[professionId] = validSkills;
            end
        end
    end

    -- set store version
    Settings.storeVersion = 5;
end

-- create addon
_G.professionMaster = ProfessionMasterAddon:Create();