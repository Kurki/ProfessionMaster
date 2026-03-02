--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local VersionService = _G.professionMaster:CreateService("version");

--- Initialize service.
function VersionService:Initialize()
    self.outdatedVersionNotified = false;

    -- cache own version parts (never changes at runtime)
    self.ownVersionParts = {};
    for part in string.gmatch(self.addon.version, "([^.]+)") do
        table.insert(self.ownVersionParts, tonumber(part));
    end
end

--- Check message.
function VersionService:CheckMessage(prefix, sender, message)
    -- check if version broadcast sent
    local versionBroadcastMessage = self:GetModel("version-broadcast-message");
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
    -- parse given version (own is cached)
    local i = 0;
    for part in string.gmatch(version, "([^.]+)") do
        i = i + 1;
        local given = tonumber(part);
        local own = self.ownVersionParts[i] or 0;
        if (given > own) then return true; end
        if (given < own) then return false; end
    end
    return false;
end

--- check if the given version is a lower version then the own.
-- @param version Sent version.
-- @return True, if own version is higher.
function VersionService:OwnIsHigher(version)
    -- parse given version (own is cached)
    local i = 0;
    for part in string.gmatch(version, "([^.]+)") do
        i = i + 1;
        local given = tonumber(part);
        local own = self.ownVersionParts[i] or 0;
        if (given < own) then return true; end
        if (given > own) then return false; end
    end
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
        self:GetService("chat"):Write("VersionOutdated"); 
        self.outdatedVersionNotified = true;
    elseif (self:OwnIsHigher(version)) then
        -- send own version to player
        self:GetService("message"):SendToPlayer(sender, self:GetModel("version-broadcast-message"):Create());
    end
end

