--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local MessageService = _G.professionMaster:CreateService("message");

--- Initialize service.
function MessageService:Initialize()
    -- handle addon messages
    self.messageVersion = 1;
    self.messagePrefix = "PmV" .. self.messageVersion;
    self.splitPatternCache = {};
    C_ChatInfo.RegisterAddonMessagePrefix(self.messagePrefix);
end

-- handle message
function MessageService:HandleMessage(prefix, message, sender)
    -- check if is addon prefix
    if (prefix ~= self.messagePrefix) then
        return;
    end

    self.addon:LogTrace("MessageService", "HandleMessage", "Got message from " .. sender .. ": " .. message);

    -- check if own player
    if (self:GetService("player"):IsCurrentPlayer(sender)) then
         return;
    end

    -- get prefix and content
    local messagePrefix = string.sub(message, 1, string.find(message, ":") - 1);
    local messageContent = string.sub(message, #messagePrefix + 2);

    -- check message
    self:GetService("professions"):CheckMessage(messagePrefix, sender, messageContent);
    self:GetService("version"):CheckMessage(messagePrefix, sender, messageContent);
end

--- Split string.
function MessageService:SplitString(value, separator)
    -- get or build cached pattern
    local pattern = self.splitPatternCache[separator];
    if (not pattern) then
        pattern = "([^" .. separator .. "]+)";
        self.splitPatternCache[separator] = pattern;
    end

    local result = {};
    local n = 0;
    for part in string.gmatch(value, pattern) do
        n = n + 1;
        result[n] = part;
    end
    return result;
end

--- Trim string.
function MessageService:TrimString(value)
    local match = string.match;
    return match(value, "^()%s*$") and "" or match(value, "^%s*(.*%S)");
end

--- Send message to group.
-- @param message Message to send.
-- @return True, if successfully sent. 
function MessageService:SendToGroup(message)
    -- build message string
    local messageString = message.prefix .. ":" .. message:ToString();

    -- send
    if (IsInRaid()) then
        return C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "RAID");
    elseif (IsInGroup()) then
        return C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "PARTY");
    else
        return C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "WHISPER", self:GetService("player").current);
    end
end

--- Send message to guild.
-- @param message Message to send.
-- @return True, if successfully sent. 
function MessageService:SendToGuild(message)
    -- check if player is in guild
    if (not IsInGuild()) then
        return;
    end

    -- build message string
    local messageString = message.prefix .. ":" .. message:ToString();
    self.addon:LogTrace("MessageService", "SendToGuild", "GUILD Message: " .. messageString);
    return C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "GUILD");
end

--- Send message to player.
-- @param player Name of player to send message to.
-- @param message Message to send.
-- @return True, if successfully sent. 
function MessageService:SendToPlayer(player, message)
    -- build message string
    local messageString = message.prefix .. ":" .. message:ToString();
    self.addon:LogTrace("MessageService", "SendToPlayer", "Player Message to " .. player .. ": " .. messageString);
    return C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "WHISPER", player);
end

--- Send message to players.
-- @param players List of player names to send message to.
-- @param message Message to send.
-- @return True, if successfully sent. 
function MessageService:SendToPlayers(players, message)
    -- build message string
    local messageString = message.prefix .. ":" .. message:ToString();

    -- send
    for i, player in ipairs(players) do
        C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "WHISPER", player);
    end
end
