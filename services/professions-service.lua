--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create service
local ProfessionsService = _G.professionMaster:CreateService("professions");

--- Initialize service.
function ProfessionsService:Initialize()
    -- initialize skills service (handles PM_Skills rebuild if needed)
    local skillsService = self:GetService("skills");

    -- clean professions data if skill cache was just rebuilt
    if (skillsService.cacheRebuilt) then
        self:CleanProfessionsData();
    end

    -- session-level tracking for guild broadcasts
    self.lastGuildBroadcast = 0;
    self.relayedPlayers = {};
end

--- Strip legacy metadata fields from PM_Professions, keeping only players and itemId.
function ProfessionsService:CleanProfessionsData()
    if (not PM_Professions) then
        return;
    end
    for professionId, profession in pairs(PM_Professions) do
        for skillId, skill in pairs(profession) do
            -- keep only players array and itemId (needed for skill cache rebuild)
            local players = skill.players;
            local itemId = skill.itemId;
            if (players) then
                profession[skillId] = { players = players, itemId = itemId };
            else
                profession[skillId] = { players = {}, itemId = itemId };
            end
        end
    end
end

--- Check message.
function ProfessionsService:CheckMessage(prefix, sender, message)
    -- check if is hello message
    local HelloMessage = self:GetModel("hello-message");
    if (prefix == HelloMessage.prefix) then
        -- broadcast own data to guild (debounced: skip if already broadcast in last 30s)
        local now = time();
        if (now - self.lastGuildBroadcast >= 30) then
            self.lastGuildBroadcast = now;

            -- broadcast own skills + alts + character sets + specializations to guild
            self:GetService("own-professions"):BroadcastOwnProfessionsToGuild();

            -- relay offline players' skills after a delay (partitioned across online players)
            C_Timer.After(math.random(20, 50) / 10, function()
                self:RelayOfflinePlayers();
            end);
        end
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

        -- aggregate received skill counts for summary logging
        local key = ppMessage.playerName .. ":" .. ppMessage.professionId;
        if (not self.pendingSkillCounts) then
            self.pendingSkillCounts = {};
        end
        if (not self.pendingSkillCounts[key]) then
            self.pendingSkillCounts[key] = { playerName = ppMessage.playerName, professionId = ppMessage.professionId, count = 0 };
        end
        self.pendingSkillCounts[key].count = self.pendingSkillCounts[key].count + #ppMessage.skills;

        -- flush aggregated log after a short delay
        if (not self.pendingSkillLogTimer) then
            self.pendingSkillLogTimer = C_Timer.NewTimer(1, function()
                for _, entry in pairs(self.pendingSkillCounts) do
                    self.addon:Log("ProfessionsService", "CheckMessage", "Received %d skills for profession %s from %s", entry.count, tostring(entry.professionId), entry.playerName);
                end
                self.pendingSkillCounts = {};
                self.pendingSkillLogTimer = nil;
            end);
        end

        -- store player skills
        self:StorePlayerSkills(ppMessage.playerName, ppMessage.professionId, ppMessage.skills);

        -- add sync time
        PM_SyncTimes[ppMessage.storageId] = time();
        return;
    end

    -- check if is player specializations message
    local PlayerSpecializationsMessage = self:GetModel("player-specializations-message");
    if (prefix == PlayerSpecializationsMessage.prefix) then
        -- parse and store specializations
        local psMessage = PlayerSpecializationsMessage:Parse(message);
        PM_Specializations[psMessage.playerName] = psMessage.specializations;
        return;
    end
end

--- Say hello to guild.
function ProfessionsService:SayHelloToGuild()
    -- send hello message to guild
    self:GetService("message"):SendToGuild(self:GetModel("hello-message"):Create(PM_Settings.storageId));
end

--- Get last sync date of storage.
-- @param storageId Sorage id of player to get last sync date for.
-- @return Date of last sync or 0 if not synced yet.
function ProfessionsService:GetLastSyncDate(storageId)
    -- get sync time
    local syncTime = PM_SyncTimes[storageId];
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
        if (not PM_PlayerFactions[characterNames[i]]) then
            PM_PlayerFactions[characterNames[i]] = playerService.faction;
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
    table.insert(PM_CharacterSets, characterNames);
end

--- Store player skills.
function ProfessionsService:StorePlayerSkills(playerName, professionId, skills)
    -- tag player faction if not already known
    if (not PM_PlayerFactions[playerName]) then
        local playerService = self:GetService("player");
        PM_PlayerFactions[playerName] = playerService.faction;
    end

    -- check profession id
    if (not PM_Professions[professionId]) then
        PM_Professions[professionId] = {};
    end

    -- get profession
    local profession = PM_Professions[professionId];
    local skillsService = self:GetService("skills");

    -- check skills
    for i, skill in ipairs(skills) do
        -- ensure profession entry exists (players and itemId)
        if (not profession[skill.skillId]) then
            profession[skill.skillId] = { players = {}, itemId = skill.itemId };
        end

        -- ensure skill cache entry exists
        skillsService:EnsureSkillCached(skill.skillId, skill.itemId, professionId);

        -- get player names
        local playerNames = profession[skill.skillId].players;

        -- check if player exists
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

    -- debounced refresh of professions view
    if (self.refreshPending) then
        self.refreshPending:Cancel();
    end
    self.refreshPending = C_Timer.NewTimer(1, function()
        self.refreshPending = nil;
        if (self.addon.professionsView) then
            self.addon.professionsView:Refresh();
        end
    end);
end

--- Relay offline players' skills to guild.
-- Partitions the work: each online player only relays a subset of offline players
-- based on a deterministic hash, so the load is distributed evenly.
function ProfessionsService:RelayOfflinePlayers()
    local playerService = self:GetService("player");
    local messageService = self:GetService("message");
    local PlayerProfessionsMessage = self:GetModel("player-professions-message");

    -- get relay slot for this player
    local myIndex, onlineCount = playerService:GetRelaySlot();
    if (onlineCount == 0) then
        return;
    end

    -- build reverse index: playerName → { professionId → { {skillId, itemId}, ... } }
    local offlinePlayers = {};
    for professionId, profession in pairs(PM_Professions) do
        for skillId, skillEntry in pairs(profession) do
            if (skillEntry.players) then
                for _, playerName in ipairs(skillEntry.players) do
                    -- only relay visible players who are offline and not ourselves
                    if (playerService:IsVisiblePlayer(playerName)
                        and not playerService:IsGuildmateOnline(playerName)
                        and not playerService:IsCurrentPlayer(playerName)
                        and not PM_OwnProfessions[playerName]
                        and not self.relayedPlayers[playerName]) then
                        -- check if this player's hash matches our relay slot
                        if (playerService:HashString(playerName) % onlineCount == myIndex) then
                            if (not offlinePlayers[playerName]) then
                                offlinePlayers[playerName] = {};
                            end
                            if (not offlinePlayers[playerName][professionId]) then
                                offlinePlayers[playerName][professionId] = {};
                            end
                            table.insert(offlinePlayers[playerName][professionId], {
                                skillId = skillId,
                                itemId = skillEntry.itemId or 0,
                            });
                        end
                    end
                end
            end
        end
    end

    -- send relayed skills to guild (batched)
    for playerName, professions in pairs(offlinePlayers) do
        self.relayedPlayers[playerName] = true;
        for professionId, skills in pairs(professions) do
            local messageSkills = {};
            for _, skill in ipairs(skills) do
                table.insert(messageSkills, skill);
                if (#messageSkills == 8) then
                    messageService:SendToGuild(PlayerProfessionsMessage:Create(professionId, PM_Settings.storageId, playerName, messageSkills));
                    messageSkills = {};
                end
            end
            if (#messageSkills > 0) then
                messageService:SendToGuild(PlayerProfessionsMessage:Create(professionId, PM_Settings.storageId, playerName, messageSkills));
            end
        end
    end
end

--- Find skill by item link.
-- @return skillId, skillData, professionId or nil
function ProfessionsService:FindSkillByItemLink(itemLink)
    -- check input
    if (not itemLink) then
        return nil;
    end

    -- extract item id from link using pattern match (avoids SplitString allocation)
    local itemId = tonumber(itemLink:match("item:(%d+)"));
    if ((not itemId) or itemId == 0) then
        return nil;
    end

    -- use skills service for O(1) lookup
    local skillsService = self:GetService("skills");
    local skillId = skillsService:GetSkillIdByItemId(itemId);
    if (skillId) then
        local skillData = skillsService:GetSkillById(skillId);
        if (skillData) then
            return skillId, skillData, skillData.professionId;
        end
    end

    -- check if item is a recipe
    local recipeSkillId = skillsService:GetSkillIdByRecipeItemId(itemId);
    if (recipeSkillId) then
        local skillData = skillsService:GetSkillById(recipeSkillId);
        if (skillData) then
            return recipeSkillId, skillData, skillData.professionId;
        end
    end

    return nil;
end

--- Find skill by skill id or item id.
-- @param targetSkillId Skill id to find (optional if item id provided).
-- @param targetItemId Item id to find (optional if skill id provided).
-- @return skillId, skillData, professionId or nil
function ProfessionsService:FindSkillByIdOrItemId(targetSkillId, targetItemId)
    -- check values
    if ((not targetSkillId) and (not targetItemId)) then
        return nil;
    end

    local skillsService = self:GetService("skills");

    -- try item id lookup (O(1))
    if (targetItemId) then
        local skillId = skillsService:GetSkillIdByItemId(targetItemId);
        if (skillId) then
            local skillData = skillsService:GetSkillById(skillId);
            if (skillData) then
                return skillId, skillData, skillData.professionId;
            end
        end
    end

    -- try direct skill id lookup
    if (targetSkillId) then
        local skillData = skillsService:GetSkillById(targetSkillId);
        if (skillData) then
            return targetSkillId, skillData, skillData.professionId;
        end
    end
    return nil;
end

--- Get player list for a skill.
-- @param professionId Profession ID.
-- @param skillId Skill ID.
-- @return players array or empty table
function ProfessionsService:GetSkillPlayers(professionId, skillId)
    if (PM_Professions and PM_Professions[professionId] and PM_Professions[professionId][skillId]) then
        return PM_Professions[professionId][skillId].players;
    end
    return {};
end

--- Check if any own character (current player or alts on same realm) can craft the given skill/item.
-- @return characterName that can craft it, or nil
function ProfessionsService:FindCrafterForSkill(targetSkillId, targetItemId)
    -- find skill by id or item id
    local skillId, skillMeta, professionId = self:FindSkillByIdOrItemId(targetSkillId, targetItemId);

    -- check if skill found
    if (not skillMeta) then
        return nil;
    end

    -- get players from PM_Professions
    local players = self:GetSkillPlayers(professionId, skillId);

    -- find player who can craft the skill from guild
    local playerService = self:GetService("player");
    local guildMateOnline = false;
    local eligiblePlayers = {};
    for _, playerName in ipairs(players) do
        -- check if is same realm and guild mate
        if (playerService:IsSameRealm(playerName) and playerService:IsGuildmate(playerName)) then
            -- check if is online
            local guildmate = playerService:GetGuildmate(playerName);
            if (guildmate and guildmate.online) then
                guildMateOnline = true;
            end

            -- check if is own character
            if (PM_OwnProfessions[playerName]) then
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
-- @return skillId, skillData, professionId or nil
function ProfessionsService:FindSkillByName(skillName)
    -- check input
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

    -- get name
    local skillName = string.trim(skillName);

    -- search skills for matching name and profession
    local skillsService = self:GetService("skills");
    for skillId, skillData in pairs(skillsService.allSkills) do
        if (skillData.professionId == professionId and skillData.name and skillData.name == skillName) then
            return skillId, skillData, professionId;
        end
    end
end

--- Convert data.
function ProfessionsService:Convert()
    local convertData = self:GetModel('convert-data');
    PM_Convert = {};
    --self:ConvertAddon(1, convertData.CLASSIC);
    PM_Convert.Bcc = self:ConvertAddon("BCC", convertData.BCC, convertResult);
    PM_Convert.Wrath = self:ConvertAddon("WRATH", convertData.WRATH, convertResult);
    PM_Convert.Cata = self:ConvertAddon("CATA", convertData.CATA, convertResult);
    PM_Convert.Mop = self:ConvertAddon("MOP", convertData.MOP, convertResult);
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
