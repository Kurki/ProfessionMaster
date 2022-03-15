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
ChatService = {};
ChatService.__index = ChatService;

--- Initialize service.
function ChatService:Initialize()
    -- check if is era server
    if (addon.isEra) then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", function(...) return self:CheckChat(...) end);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", function(...) return self:CheckChat(...) end);
    end
end

--- Write message.
function ChatService:Write(locale, ...)
    self:WriteBare(addon:GetService("locale"):Get(locale, ...));
end

--- Write bare message.
function ChatService:WriteBare(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffDA8CFF[PM]|cffffffff " .. message);
end

--- Check chat.
function ChatService:CheckChat(_, event, message, player, l, cs, t, flag, channelId, ...)
    -- check flag, event and channel
    if flag == "GM" or flag == "DEV" or (event == "CHAT_MSG_CHANNEL" and type(channelId) == "number" and channelId > 0) then
        return;
    end

    -- preapre values
    local newMessage = "";
    local currentMessage = message;
    local messageRead = false;

    -- read message
    repeat
        -- read skill name and id
        local startPos, endPos, skillName, skillId = currentMessage:find("%[PM: (.*) : (.*)%]");

        -- check if skill found
        if(skillName and skillId) then
            -- build new message
            newMessage = newMessage .. currentMessage:sub(1, startPos - 1);
            newMessage = newMessage .. "|cFF71D5FF|Henchant:" .. skillId .. "|h[" .. skillName .. "]|h|r"

            -- redefine current message
            currentMessage = currentMessage:sub(endPos + 1);
        else
            -- skill not found, message read
            messageRead = true;
        end
    until(messageRead)

    -- check new message
    if (newMessage ~= "") then
        -- add remaining message
        newMessage = newMessage .. currentMessage;

        -- return new message
        return false, newMessage, player, l, cs, t, flag, channelId, ...; 
    end
end

-- register service
addon:RegisterService(ChatService, "chat");
