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
VersionService = {};
VersionService.__index = VersionService;

--- Initialize service.
function VersionService:Initialize()
    self.outdatedVersionNotified = false;
end

--- Check message.
function VersionService:CheckMessage(prefix, sender, message)
    -- check if version broadcast sent
    local versionBroadcastMessage = addon:GetModel("version-broadcast-message");
    if (prefix == versionBroadcastMessage.prefix) then
        -- handle version broadcast
        self:CheckAndNotify(sender, versionBroadcastMessage:Parse(message).version, true);
        return;
    end
end

--- Check if the given version is a higher version then the own.
-- @param version Sent version.
-- @return True, if the own version is lower.
function VersionService:OwnIsLower(version)
    -- split versions
    local messageService = addon:GetService("message");
    local currentVersionParts = messageService:SplitString(addon.version, ".");
    local givenVersionParts = messageService:SplitString(version, ".");

    -- iterate version
    for i = 1, 3 do
        -- check if given version part is higher
        if (tonumber(givenVersionParts[i]) > tonumber(currentVersionParts[i])) then
            return true;
        end

        -- check if given version part is lower
        if (tonumber(givenVersionParts[i]) < tonumber(currentVersionParts[i])) then
            return false;
        end
    end

    -- same version
    return false;
end

--- check if the given version is a lower version then the own.
-- @param version Sent version.
-- @return True, if own version is higher.
function VersionService:OwnIsHigher(version)
    -- split versions
    local messageService = addon:GetService("message");
    local currentVersionParts = messageService:SplitString(addon.version, ".");
    local givenVersionParts = messageService:SplitString(version, ".");

    -- iterate version
    for i = 1, 3 do
        -- check if given version part is lower
        if (tonumber(givenVersionParts[i]) < tonumber(currentVersionParts[i])) then
            return true;
        end

        -- check if given version part is higher
        if (tonumber(givenVersionParts[i]) > tonumber(currentVersionParts[i])) then
            return false;
        end
    end

    -- same version
    return false;
end

--- Cehck the given version and handle version issues.
-- @param sender Sender of version.
-- @param version Sent version.
-- @param isBroadcast Indicates if version comes from broadcast.
function VersionService:CheckAndNotify(sender, version, isBroadcast)
    -- check if own version is lower
    if (self:OwnIsLower(version)) then
        -- check if comes from broadcast and outdated already notified
        if (isBroadcast and self.outdatedVersionNotified) then
            return;
        end

        -- notify user version outdated
        addon:GetService("chat"):Write("VersionOutdated"); 
        self.outdatedVersionNotified = true;
    elseif (self:OwnIsHigher(version)) then
        -- send own version to player
        addon:GetService("message"):SendToPlayer(sender, addon:GetModel("version-broadcast-message"):Create());
    end
end

-- register service
addon:RegisterService(VersionService, "version");
