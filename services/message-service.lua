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
MessageService = {};
MessageService.__index = MessageService;

--- Initialize service.
function MessageService:Initialize()
    -- handle addon messages
    self.messageVersion = 1;
    self.messagePrefix = "PmV" .. self.messageVersion;
    C_ChatInfo.RegisterAddonMessagePrefix(self.messagePrefix);
end

-- handle message
function MessageService:HandleMessage(prefix, message, sender)
    -- check if is addon prefix
    if (prefix ~= self.messagePrefix) then
        return;
    end

    addon:LogTrace("MessageService", "HandleMessage", "Got message from " .. sender .. ": " .. message);

    -- check if own player
    if (addon:GetService("player"):IsCurrentPlayer(sender)) then
         return;
    end

    -- get prefix and content
    local messagePrefix = string.sub(message, 1, string.find(message, ":") - 1);
    local messageContent = string.sub(message, #messagePrefix + 2);

    -- check message
    addon:GetService("professions"):CheckMessage(messagePrefix, sender, messageContent);
    addon:GetService("version"):CheckMessage(messagePrefix, sender, messageContent);
end

--- Split string.
function MessageService:SplitString(value, separator)
    local result = {};
    for part in string.gmatch(value, "([^" .. separator .. "]+)") do
        table.insert(result, part);
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
        return C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "WHISPER", addon:GetService("player").current);
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
    addon:LogTrace("MessageService", "SendToGuild", "GUILD Message: " .. messageString);
    return C_ChatInfo.SendAddonMessage(self.messagePrefix, messageString, "GUILD");
end

--- Send message to player.
-- @param player Name of player to send message to.
-- @param message Message to send.
-- @return True, if successfully sent. 
function MessageService:SendToPlayer(player, message)
    -- build message string
    local messageString = message.prefix .. ":" .. message:ToString();
    addon:LogTrace("MessageService", "SendToPlayer", "Player Message to " .. player .. ": " .. messageString);
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

-- register service
addon:RegisterService(MessageService, "message");