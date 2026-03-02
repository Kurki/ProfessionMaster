--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local ChatService = _G.professionMaster:CreateService("chat");

-- Prevent double handling of the same message
ChatService.lastHandledMessage = nil;

--- Initialize service.
function ChatService:Initialize()
    -- check chat
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
    
    -- hook hyperlink tooltips on all chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i];
        if (chatFrame) then
            chatFrame:HookScript("OnHyperlinkEnter", function(_, link)
                local skillId = tonumber(link:match("^enchant:(%d+)"));
                if (not skillId or not Professions) then return; end
                for professionId, profession in pairs(Professions) do
                    if (profession[skillId]) then
                        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
                        self:GetService("tooltip"):ShowTooltip(GameTooltip, professionId, skillId, profession[skillId]);
                        return;
                    end
                end
            end);
            chatFrame:HookScript("OnHyperlinkLeave", function()
                GameTooltip:Hide();
            end);
        end
    end
end

--- Write message.
function ChatService:Write(locale, ...)
    self:WriteBare(self:GetService("locale"):Get(locale, ...));
end

--- Write bare message.
function ChatService:WriteBare(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffDA8CFF[PM]|cffffffff " .. message);
end

--- Parse !who argument to extract a skill id and/or item id.
-- Supports: item links, enchant/spell links, or plain numeric ids.
-- @return skillId, itemId (either or both may be nil)
function ChatService:ParseWhoArgument(argument)
    -- try to match an item link: |Hitem:12345:...|h[...]|h
    local itemId = tonumber(argument:match("|Hitem:(%d+)"));
    if (itemId) then
        -- resolve item id to skill id
        local skillId = self:GetService("skills"):GetSkillIdByItemId(itemId);
        return skillId, itemId;
    end

    -- try to match an enchant link: |Henchant:12345|h[...]|h
    local enchantId = tonumber(argument:match("|Henchant:(%d+)"));
    if (enchantId) then
        -- enchant id is the skill id
        local skillData = self:GetService("skills"):GetSkillById(enchantId);
        local resolvedItemId = skillData and skillData.itemId or nil;
        return enchantId, resolvedItemId;
    end

    -- try to match a spell link: |Hspell:12345|h[...]|h
    local spellId = tonumber(argument:match("|Hspell:(%d+)"));
    if (spellId) then
        local skillData = self:GetService("skills"):GetSkillById(spellId);
        local resolvedItemId = skillData and skillData.itemId or nil;
        return spellId, resolvedItemId;
    end

    -- try to match a PM link: [PM: name : 12345]
    local pmSkillId = tonumber(argument:match("%[PM:.*:%s*(%d+)%s*%]"));
    if (pmSkillId) then
        local skillData = self:GetService("skills"):GetSkillById(pmSkillId);
        local resolvedItemId = skillData and skillData.itemId or nil;
        return pmSkillId, resolvedItemId;
    end

    -- try plain numeric id
    local numericId = tonumber(argument:match("^%s*(%d+)%s*$"));
    if (numericId) then
        -- first check if it's a known skill id
        local skillData = self:GetService("skills"):GetSkillById(numericId);
        if (skillData) then
            return numericId, skillData.itemId;
        end

        -- otherwise check if it's an item id
        local skillId = self:GetService("skills"):GetSkillIdByItemId(numericId);
        if (skillId) then
            return skillId, numericId;
        end
    end

    return nil, nil;
end

--- Handle !who command.
-- @param player The player who sent the command.
-- @param argument Optional argument after !who (link or id).
-- @param isWhisper Whether the command was sent via whisper (not used currently, but could be for different response formatting or privacy).
function ChatService:HandleWhoCommand(player, argument, isWhisper)
    -- get own player name
    local playerService = self:GetService("player");
    local currentPlayer = playerService.current;

    -- do not respond to own messages
    if (playerService:GetLongName(player) == currentPlayer) then
        return;
    end

    -- check if argument is provided (item/skill query)
    if (argument and argument ~= "") then
        -- parse the argument
        local targetSkillId, targetItemId = self:ParseWhoArgument(argument);

        -- check if we could parse anything
        local localeService = self:GetService("locale");
        if (not targetSkillId and not targetItemId) then
            SendChatMessage("[PM] " .. localeService:Get("WhoCannotCraftResponse"), "WHISPER", nil, player);
            return;
        end

        -- find a crafter
        local professionsService = self:GetService("professions");
        local crafterName, isOwnPlayer = professionsService:FindCrafterForSkill(targetSkillId, targetItemId);
        if (isOwnPlayer) then
            SendChatMessage("[PM] " .. localeService:Get("WhoCraftResponse"), "WHISPER", nil, player);
        elseif(crafterName) then
            SendChatMessage("[PM] " .. playerService:GetShortName(crafterName) .. " " .. localeService:Get("WhoOtherCanCraftResponse"), "WHISPER", nil, player);
        elseif(isWhisper and isOwnPlayer) then
            SendChatMessage("[PM] " .. localeService:Get("WhoCannotCraftResponse"), "WHISPER", nil, player);
        end
    end
end

--- Check chat.
function ChatService:CheckChat(_, event, message, player, l, cs, t, flag, channelId, ...)
    -- check flag, event and channel
    if flag == "GM" or flag == "DEV" or (event == "CHAT_MSG_CHANNEL" and type(channelId) == "number" and channelId > 0) then
        return;
    end

    -- prevent double handling: use player+message as key
    local messageKey = tostring(player or "") .. "|" .. tostring(message or "");
    if (self.lastHandledMessage == messageKey) then
        return;
    end
    self.lastHandledMessage = messageKey;

    -- check if is whisper
    local isWhisper = (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER");

    -- check for !who command (only in guild, party and raid)
    if (message and (event == "CHAT_MSG_GUILD" 
        or event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER"
        or event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER"
        or isWhisper)) then
        -- match "!who" optionally followed by an argument (link, id, etc.)
        local whoMatch = message:match("^![Ww][Hh][Oo]%s*(.*)$");
        if (whoMatch ~= nil) then
            self:HandleWhoCommand(player, whoMatch, isWhisper);
        end
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

