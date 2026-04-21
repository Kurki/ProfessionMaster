--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local OwnProfessionsService = _G.professionMaster:CreateService("own-professions");

--- Initialize service.
function OwnProfessionsService:Initialize()
end

--- Detect own specializations for the current player.
-- Checks IsSpellKnown for all known specialization spells (TBC+).
function OwnProfessionsService:DetectSpecializations()
    -- only available from TBC onwards
    if (self.addon.isVanilla) then
        return;
    end

    -- get player name
    local playerName = self:GetService("player").current;

    -- get specialization spells model
    local specializationSpells = self:GetModel("specialization-spells");

    -- prepare specializations for this player
    local specializations = {};

    -- iterate all professions that have specializations
    for professionId, specs in pairs(specializationSpells) do
        for _, spec in ipairs(specs) do
            if (IsSpellKnown(spec.spellId)) then
                specializations[professionId] = spec.spellId;
                self.addon:Log("OwnProfessionsService", "DetectSpecializations", "Detected specialization %s for profession %s", tostring(spec.spellId), tostring(professionId));
                break;
            end
        end
    end

    -- store in saved variable
    PM_Specializations[playerName] = specializations;
end

--- Get own specializations for a character.
-- @param playerName Name of the character.
-- @return Table mapping professionId to spellId, or empty table.
function OwnProfessionsService:GetSpecializations(playerName)
    return PM_Specializations[playerName] or {};
end

--- Get own profession data.
function OwnProfessionsService:GetProfessionData()
    -- check if is in combat
    if (self.addon.inCombat) then
        return;
    end

    -- check if is link
    local professionIsLink, professionPlayerName = IsTradeSkillLinked();
    if (professionIsLink) then
        -- get long name
        professionPlayerName = self:GetService("player"):GetLongName(professionPlayerName);

        -- check if is guild mate
        if (not self:GetService("player"):IsGuildmate(professionPlayerName)) then
            return;
        end
    end

    -- get trade skill profession data
    self:GetTradeSkillProfessionData(professionIsLink, professionPlayerName);

    -- get craft skill profession data
    self:GetCraftSkillProfessionData(professionIsLink, professionPlayerName);
end

--- Get own trade skill profession data. 
function OwnProfessionsService:GetTradeSkillProfessionData(professionIsLink, professionPlayerName)
    -- get and check profession id
    local professionNamesService = self:GetService("profession-names");
    local professionId = professionNamesService:GetProfessionId(GetTradeSkillLine());
    if (not professionId) then
        return;
    end

    -- get amount of trade skills
    local tradeSkillAmount = GetNumTradeSkills();

    -- prepare item ids
    local skillsService = self:GetService("skills");
    local skills = {};

    -- iterate trade skills
    for tradeSkillIndex = 1, tradeSkillAmount do
        -- get trade skill name and type
        local tradeSkillName, tradeSkillType = GetTradeSkillInfo(tradeSkillIndex);

        -- check name and type
        if (tradeSkillName and (tradeSkillType == "optimal" or tradeSkillType == "medium" or tradeSkillType == "easy" or tradeSkillType == "trivial")) then
            -- get link and item id
            local tradeSkillLink = GetTradeSkillItemLink(tradeSkillIndex);
            if (tradeSkillLink) then
                local tradeSkillId = tonumber(tradeSkillLink:match("enchant:(%d+)"));
                local tradeSkillItemId = tonumber(tradeSkillLink:match("item:(%d+)"));
                if (tradeSkillItemId and (not tradeSkillId)) then
                    tradeSkillId = skillsService:GetSkillIdByItemId(tradeSkillItemId);
                end

                -- get trande skill id
                if (not tradeSkillId) then
                    local tradeSkillLink = GetTradeSkillRecipeLink(tradeSkillIndex);
                    if (tradeSkillLink) then
                        tradeSkillId = professionNamesService:GetSkillId(tradeSkillLink);
                    end
                end 

                -- check trade skill id
                if (tradeSkillId) then
                    -- add skill
                    table.insert(skills, {
                        skillId = tradeSkillId,
                        itemId = tradeSkillItemId or 0,
                        added = time()
                    });
                end
            end
        end
    end

    -- chck if is link
    if (professionIsLink) then
        -- add to player professions
        self:GetService("professions"):StorePlayerSkills(professionPlayerName, professionId, skills);
    else
        -- store own profession
        self:StoreAndSendOwnProfession(professionId, skills);
    end
end

--- Get own craft skill profession data. 
function OwnProfessionsService:GetCraftSkillProfessionData(professionIsLink, professionPlayerName)
    -- get and check profession id
    local professionNamesService = self:GetService("profession-names");
    local professionId = professionNamesService:GetProfessionId(GetCraftDisplaySkillLine());
    if (not professionId) then
        return;
    end

    -- get amount of craft skills
    local craftSkillAmount = GetNumCrafts();

    -- prepare item ids
    local skillsService = self:GetService("skills");
    local skills = {};

    -- iterate craft skills
    for craftSkillIndex = 1, craftSkillAmount do
        -- get craft skill name and type
        local craftSkillName, _, craftSkillType = GetCraftInfo(craftSkillIndex);

        -- check name and type
        if (craftSkillName and (craftSkillType == "optimal" or craftSkillType == "medium" or craftSkillType == "easy" or craftSkillType == "trivial")) then
            -- get link, id and item id from enchant
            local craftSkillLink = GetCraftItemLink(craftSkillIndex);
            if (craftSkillLink) then
                local craftSkillId = tonumber(craftSkillLink:match("enchant:(%d+)"));
                local craftSkillItemId = tonumber(craftSkillLink:match("item:(%d+)"));
                local craftSkill = skillsService:GetSkillById(craftSkillId);
                if (craftSkill and (not craftSkillItemId)) then
                    craftSkillItemId = craftSkill["itemId"];
                end

                -- check trade skill id
                if (craftSkillId) then
                    -- add skill
                    table.insert(skills, {
                        skillId = craftSkillId,
                        itemId = craftSkillItemId or 0,
                        added = time()
                    });
                end
            end
        end
    end

    -- chck if is link
    if (professionIsLink) then
        -- add to player professions
        self:GetService("professions"):StorePlayerSkills(professionPlayerName, professionId, skills);
    else
        -- store own profession
        self:StoreAndSendOwnProfession(professionId, skills);
    end
end

--- Store profession.
-- @param professionId Id of profession to store.
-- @param skills List of skills of this profession to store.
-- @return Ne added item ids.
function OwnProfessionsService:StoreAndSendOwnProfession(professionId, skills)
    -- prepare new skills
    local newSkills = {};

    -- check player
    local playerName = self:GetService("player").current;
    if (not PM_OwnProfessions[playerName]) then
        -- add player name
        PM_OwnProfessions[playerName] = {};
    end

    -- get player professions
    local playerProfessions = PM_OwnProfessions[playerName];

    -- check profession
    if (not playerProfessions[professionId]) then
        -- profession not set before, store all item ids
        playerProfessions[professionId] = skills;
        newSkills = skills;
        self.addon:Log("OwnProfessionsService", "StoreAndSendOwnProfession", "New profession %s for %s with %d skills", tostring(professionId), playerName, #skills);
    else
        -- get profession
        local profession = playerProfessions[professionId];

        -- iterate all skills
        for i, skill in ipairs(skills) do
            -- check if skill exists
            local skillExists = false;
            for j, existingSkill in ipairs(profession) do
                -- check if skill id matches
                if (existingSkill.skillId == skill.skillId) then
                    -- skill already exists
                    skillExists = true;
                    break;
                end
            end

            -- check if does not exists already
            if (not skillExists) then
                -- add item id
                table.insert(profession, skill);
                table.insert(newSkills, skill);
            end
        end
    end

    -- check if has new item ids
    if (#newSkills == 0) then
        return;
    end

    self.addon:Log("OwnProfessionsService", "StoreAndSendOwnProfession", "Sending %d new skills for profession %s", #newSkills, tostring(professionId));

    -- add to player professions
    local professionsService = self:GetService("professions");
    professionsService:StorePlayerSkills(self:GetService("player").current, professionId, newSkills);

    -- send hello message
    professionsService:SayHelloToGuild();
end

--- Broadcast all own professions (self + alts) to guild channel.
-- Used by the new GUILD-based sync protocol.
-- @param lastSyncDate Optional timestamp; only send skills added after this date.
function OwnProfessionsService:BroadcastOwnProfessionsToGuild(lastSyncDate)
    local playerService = self:GetService("player");
    local messageService = self:GetService("message");
    local PlayerProfessionsMessage = self:GetModel("player-professions-message");
    local MyCharactersMessage = self:GetModel("my-characters-message");
    local PlayerSpecializationsMessage = self:GetModel("player-specializations-message");

    local messageCharacters = {};

    -- iterate all own characters
    for characterName, professions in pairs(PM_OwnProfessions) do
        -- check if is same realm and same faction
        if (playerService:IsSameRealm(characterName) and playerService:IsSameFaction(characterName)) then
            -- check if character is in guild or setting allows non-guild characters
            if (PM_Settings.sendNonGuildCharacters or playerService:IsGuildmate(characterName)) then
                -- collect character name for character set message
                table.insert(messageCharacters, playerService:GetShortName(characterName));

                -- broadcast skills for each profession
                for professionId, skills in pairs(professions) do
                    self:BroadcastProfessionToGuild(professionId, skills, lastSyncDate, characterName);
                end

                -- broadcast specializations (TBC+)
                if (not self.addon.isVanilla) then
                    local specializations = PM_Specializations[characterName];
                    if (specializations) then
                        local hasSpecializations = false;
                        for _ in pairs(specializations) do
                            hasSpecializations = true;
                            break;
                        end
                        if (hasSpecializations) then
                            messageService:SendToGuild(PlayerSpecializationsMessage:Create(characterName, specializations));
                        end
                    end
                end
            end
        end
    end

    -- broadcast character set
    if (#messageCharacters > 0) then
        messageService:SendToGuild(MyCharactersMessage:Create(messageCharacters));
    end
end

--- Broadcast a single profession's skills to guild channel.
-- @param professionId Profession ID.
-- @param skills Skills array from PM_OwnProfessions.
-- @param lastSyncDate Optional timestamp filter.
-- @param characterName Character name who owns the skills.
function OwnProfessionsService:BroadcastProfessionToGuild(professionId, skills, lastSyncDate, characterName)
    local messageService = self:GetService("message");
    local PlayerProfessionsMessage = self:GetModel("player-professions-message");
    local messageSkills = {};

    for skillIndex = 1, #skills do
        local skill = skills[skillIndex];
        if ((not lastSyncDate) or skill.added > lastSyncDate) then
            table.insert(messageSkills, skill);
            if (#messageSkills == 8) then
                messageService:SendToGuild(PlayerProfessionsMessage:Create(professionId, PM_Settings.storageId, characterName, messageSkills));
                messageSkills = {};
            end
        end
    end

    if (#messageSkills > 0) then
        messageService:SendToGuild(PlayerProfessionsMessage:Create(professionId, PM_Settings.storageId, characterName, messageSkills));
    end
end

--- Check welcome.
function OwnProfessionsService:CheckWelcome()
    -- check if welcome read
    if (PM_CharacterSettings.welcomeRead) then
        return;
    end

    -- check if player professions read
    local playerName = self:GetService("player").current;
    if (PM_OwnProfessions[playerName]) then
        return;
    end

    -- show welcome view
    self.addon:NewView("welcome"):Show();
end

