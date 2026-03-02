--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create service
local ProfessionsService = _G.professionMaster:CreateService("professions");

--- Initialize service.
function ProfessionsService:Initialize()
    -- build reverse index from existing saved data
    self:RebuildItemIndex();
end

--- Rebuild the itemId -> {skillId, professionId} reverse index from Professions.
-- Call once at init or after data migration.
function ProfessionsService:RebuildItemIndex()
    self.itemIndex = {};
    if (not Professions) then
        return;
    end
    for professionId, profession in pairs(Professions) do
        for skillId, skill in pairs(profession) do
            if (skill.itemId and skill.itemId ~= 0) then
                self.itemIndex[skill.itemId] = {
                    skillId = skillId,
                    professionId = professionId
                };
            end
        end
    end
end

--- Check message.
function ProfessionsService:CheckMessage(prefix, sender, message)
    -- check if is hello message
    local HelloMessage = self:GetModel("hello-message");
    if (prefix == HelloMessage.prefix) then
        -- request professions from player
        local helloMessage = HelloMessage:Parse(message);
        self:RequestProfessionsFromPlayer(sender, helloMessage.storageId, true);
        return;
    end

    -- check if is request profession message
    local RequestProfessionsMessage = self:GetModel("request-professions-message");
    if (prefix == RequestProfessionsMessage.prefix) then
        -- send all own professions to sender
        local rpMessage = RequestProfessionsMessage:Parse(message);
        self:GetService("own-professions"):SendOwnProfessionsToPlayer(sender, rpMessage.storageId, rpMessage.lastSyncDate, rpMessage.sendBack);
        return;
    end

    -- check if is my characters message
    local MyCharactersMessage = self:GetModel("my-characters-message");
    if (prefix == MyCharactersMessage.prefix) then
        -- store charater set
        local mcMessage = MyCharactersMessage:Parse(message);
        self:StoreCharacterSet(mcMessage.characterNames)
        return;
    end

    -- check if is player profession message
    local PlayerProfessionsMessage = self:GetModel("player-professions-message");
    if (prefix == PlayerProfessionsMessage.prefix) then
        -- parse message
        local ppMessage = PlayerProfessionsMessage:Parse(message);

        -- store player skills
        self:StorePlayerSkills(ppMessage.playerName, ppMessage.professionId, ppMessage.skills);

        -- add sync time
        SyncTimes[ppMessage.storageId] = time();
        return;
    end
end

--- Say hello to guild.
function ProfessionsService:SayHelloToGuild()
    -- send hello message to guild
    self:GetService("message"):SendToGuild(self:GetModel("hello-message"):Create(PMSettings.storageId));
end

--- Request profession from other player.
function ProfessionsService:RequestProfessionsFromPlayer(playerName, playerStorageId, sendBack)
    -- get last sync
    local lastSyncDate = self:GetLastSyncDate(playerStorageId);

    -- send request professions message to player
    self:GetService("message"):SendToPlayer(playerName, self:GetModel("request-professions-message"):Create(PMSettings.storageId, lastSyncDate, sendBack));
end

--- Get last sync date of storage.
-- @param storageId Sorage id of player to get last sync date for.
-- @return Date of last sync or 0 if not synced yet.
function ProfessionsService:GetLastSyncDate(storageId)
    -- get sync time
    local syncTime = SyncTimes[storageId];
    if (not syncTime) then
        return 0;
    end

    -- get sync time
    return syncTime;
end

--- Store character set.
function ProfessionsService:StoreCharacterSet(characterNames)
    -- check new names
    if (not characterNames or #characterNames == 0) then
        return;
    end

    -- get long names and tag faction (characters in set are same faction as us)
    local playerService = self:GetService('player');
    for i = 1, #characterNames do
        characterNames[i] = playerService:GetLongName(characterNames[i]);
        if (not PlayerFactions[characterNames[i]]) then
            PlayerFactions[characterNames[i]] = playerService.faction;
        end
    end

    -- find existing character set
    local existingCharatcerSet = nil;
    for _, newCharacterName in ipairs(characterNames) do
        existingCharatcerSet = playerService:FindCharacterSet(newCharacterName);
        if (existingCharatcerSet) then
            break;
        end
    end

    -- check if exising found
    if (existingCharatcerSet) then
        -- iterate new character names
        for _, newCharacterName in ipairs(characterNames) do
            -- iterate players in character set
            local characterExists = false;
            for _, existingCharacterName in ipairs(existingCharatcerSet) do
                if (newCharacterName == existingCharacterName) then
                    characterExists = true;
                    break;
                end
            end
            if (not characterExists) then
                table.insert(existingCharatcerSet, newCharacterName);
            end
        end
        return;
    end

    -- create new character set
    table.insert(CharacterSets, characterNames);
end

--- Store player skills.
function ProfessionsService:StorePlayerSkills(playerName, professionId, skills)
    -- tag player faction if not already known
    if (not PlayerFactions[playerName]) then
        local playerService = self:GetService("player");
        PlayerFactions[playerName] = playerService.faction;
    end

    -- check profession id
    if (not Professions[professionId]) then
        Professions[professionId] = {};
    end

    -- get profession
    local profession = Professions[professionId];
    local professionNamesService = self:GetService("profession-names");
    local professionName = professionNamesService:GetProfessionName(professionId);
    local itemsToLoad = {};
    local skillsService = self:GetService("skills");
    local bopItems = self:GetModel("bop-items");

    -- check skills
    for i, skill in ipairs(skills) do
        -- check item
        if (not profession[skill.skillId]) then
            -- prepare skill entry
            local skillEntry = nil;

            -- check if profession is enchantment
            if (professionId == 333) then
                -- get spell
                local spellName, _, spellIcon = GetSpellInfo(skill.skillId);

                -- get skill link
                local skillLink = GetSpellLink(skill.skillId);
                if (self.addon.isVanilla) then
                    skillLink = "|cFF71D5FF|Henchant:" .. skill.skillId .. "|h[" .. spellName .. "]|h|r";
                else
                    skillLink = GetSpellLink(skill.skillId);
                end

                -- add item
                skillEntry = {
                    name = spellName,
                    skillLink = skillLink,
                    itemId = skill.itemId,
                    itemLink = nil,
                    itemColor = "FF71D5FF",
                    icon = spellIcon,
                    bop = false,
                    players = {}
                };
                profession[skill.skillId] = skillEntry;
            else
                -- add item
                skillEntry = {
                    name = nil,
                    skillLink = nil,
                    itemId = skill.itemId,
                    itemLink = nil,
                    itemColor = nil,
                    icon = nil,
                    bop = false,
                    players = {}
                };
                profession[skill.skillId] = skillEntry;
            end

            -- check if item can be found by skill id
            if (skillEntry.itemId == 0) then
				local skillInfo = skillsService:GetSkillById(skill.skillId);
				if (skillInfo) then
					skillEntry.itemId = skillInfo.itemId;
				end
            end

            -- update reverse index
            if (skillEntry.itemId and skillEntry.itemId ~= 0) then
                if (not self.itemIndex) then self.itemIndex = {}; end
                self.itemIndex[skillEntry.itemId] = {
                    skillId = skill.skillId,
                    professionId = professionId
                };
            end

            -- check if skill has item
            if (skillEntry and skillEntry.itemId ~= 0 and skillEntry.itemId ~= nil and type(skillEntry.itemId) == "number") then
                -- check if bop (O(1) hash set lookup)
                skillEntry.bop = bopItems[skillEntry.itemId] or false;

                -- check if item id known
                if (C_Item.DoesItemExistByID(skillEntry.itemId)) then
                    -- get item data
                    local item = Item:CreateFromItemID(skillEntry.itemId);
                    if (not item:IsItemEmpty()) then
                        pcall(function()
                            -- wait until loaded
                            item:ContinueOnItemLoad(function()
                                -- set values
                                local itemName = item:GetItemName();
                                local itemLink = item:GetItemLink();
                                skillEntry.itemLink = itemLink;
                                skillEntry.itemColor = professionNamesService:GetItemColor(itemLink);
                                skillEntry.icon = item:GetItemIcon();
                                if (not skillEntry.name) then
                                    skillEntry.name = itemName;
                                end
                                if (not skillEntry.skillLink) then
                                    skillEntry.skillLink = professionNamesService:GetSkillLink(professionId, skill.skillId, itemName);
                                end
                            end);
                        end);
                    end
                end
            end
        end

        -- get player names
        local playerNames = profession[skill.skillId].players;

        -- check if player exists player
        local playerNameExists = false;
        for j, itemPlayerName in ipairs(playerNames) do
            if (itemPlayerName == playerName) then
                playerNameExists = true;
                break;
            end
        end

        -- add player name if not exist
        if (not playerNameExists) then
            table.insert(playerNames, playerName);
        end
    end
end

--- Find skill by item link.
function ProfessionsService:FindSkillByItemLink(itemLink)
    -- check profession storage
    if ((not Professions) or (not itemLink)) then
        return nil;
    end

    -- extract item id from link using pattern match (avoids SplitString allocation)
    local itemId = tonumber(itemLink:match("item:(%d+)"));
    if ((not itemId) or itemId == 0) then
        return nil;
    end

    -- use reverse index for O(1) lookup
    if (self.itemIndex) then
        local entry = self.itemIndex[itemId];
        if (entry) then
            local profession = Professions[entry.professionId];
            if (profession and profession[entry.skillId]) then
                return entry.skillId, profession[entry.skillId], entry.professionId;
            end
        end
    end
    return nil;
end

--- Find skill by skill id or item id.
-- @param targetSkillId Skill id to find (optional if item id provided).
-- @param targetItemId Item id to find (optional if skill id provided).
-- @return skillId, skillData, professionId or nil if not found
function ProfessionsService:FindSkillByIdOrItemId(targetSkillId, targetItemId)
    -- check values
    if ((not Professions) or ((not targetSkillId) and (not targetItemId))) then
        return nil;
    end

    -- try reverse index for item id (O(1))
    if (targetItemId and self.itemIndex) then
        local entry = self.itemIndex[targetItemId];
        if (entry) then
            local profession = Professions[entry.professionId];
            if (profession and profession[entry.skillId]) then
                return entry.skillId, profession[entry.skillId], entry.professionId;
            end
        end
    end

    -- try direct skill id lookup across professions (O(P) instead of O(P*S))
    if (targetSkillId) then
        for professionId, profession in pairs(Professions) do
            if (profession[targetSkillId]) then
                return targetSkillId, profession[targetSkillId], professionId;
            end
        end
    end
    return nil;
end

--- Check if any own character (current player or alts on same realm) can craft the given skill/item.
-- @return characterName that can craft it, or nil
function ProfessionsService:FindCrafterForSkill(targetSkillId, targetItemId)
    -- find skill by id or item id
    local _, skill, _ = self:FindSkillByIdOrItemId(targetSkillId, targetItemId);

    -- check if skill found
    if (not skill) then
        return nil;
    end

    -- find player who can craft the skill from guild
    local playerService = self:GetService("player");
    local guildMateOnline = false;
    local eligiblePlayers = {};
    for _, playerName in ipairs(skill.players) do
        -- check if is same realm and guild mate
        if (playerService:IsSameRealm(playerName) and Guildmates[playerName]) then
            -- cheeck if is online
            if (Guildmates[playerName].online) then
                guildMateOnline = true;
            end

            -- check if is own character
            if (OwnProfessions[playerName]) then
                return playerName, true;
            end
            -- add player to player list
            table.insert(eligiblePlayers, playerName);
        end
    end
    
    -- if there are any eligible players, return comma-separated string
    if (#eligiblePlayers > 0 and (not guildMateOnline)) then
        return table.concat(eligiblePlayers, ", "), false;
    end
end

--- Find skill by skill name.
function ProfessionsService:FindSkillByName(skillName)
    -- check profession storage
    if (not skillName) then
        return nil;
    end

    -- find separator
    local separatorPos = string.find(skillName, ":");
    if (not separatorPos or separatorPos < 2) then
        return nil;
    end

    -- get profession and skill name
    local professionName = string.sub(skillName, 1, separatorPos - 1);
    local skillName = string.sub(skillName, separatorPos + 1);

    -- find profession id by name
    local professionId = self:GetService("profession-names"):GetProfessionId(professionName);
    if (not professionId) then
        return nil;
    end

    -- check profession id
    if (not Professions[professionId]) then
        return nil;
    end

    -- get name
    local skillName = string.trim(skillName);

    -- check skills professions
    for skillId, skill in pairs(Professions[professionId]) do     
        -- check item id
        if (skill.name and skill.name == skillName) then
            return skillId, skill, professionId;
        end
    end  
end

--- Convert data.
function ProfessionsService:Convert()
    local convertData = self:GetModel('convert-data');
    Convert = {};
    --self:ConvertAddon(1, convertData.CLASSIC);
    Convert.Bcc = self:ConvertAddon("BCC", convertData.BCC, convertResult);
    Convert.Wrath = self:ConvertAddon("WRATH", convertData.WRATH, convertResult);
    Convert.Cata = self:ConvertAddon("CATA", convertData.CATA, convertResult);
    Convert.Mop = {};
end
function ProfessionsService:ConvertAddon(addonNumber, data, convertResult)
    print("Converting " .. addonNumber);
    local result = {};
    for skillId, skill in pairs(data) do
        local convertedSkill = {
            reagents = {},
            itemId = skill[1]
        }
        for i, reagentId in ipairs(skill[6]) do
            convertedSkill.reagents[reagentId] = skill[7][i];
        end
        result[skillId] = convertedSkill;
    end
    return result;
end
