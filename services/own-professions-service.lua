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

-- create service
local OwnProfessionsService = _G.professionMaster:CreateService("own-professions");

--- Initialize service.
function OwnProfessionsService:Initialize()
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
        if (not Guildmates or not Guildmates[professionPlayerName]) then
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
    if (not OwnProfessions[playerName]) then
        -- add player name
        OwnProfessions[playerName] = {};
    end

    -- get player professions
    local playerProfessions = OwnProfessions[playerName];

    -- check profession
    if (not playerProfessions[professionId]) then
        -- profession not set before, store all item ids
        playerProfessions[professionId] = skills;
        newSkills = skills;
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

    -- add to player professions
    local professionsService = self:GetService("professions");
    professionsService:StorePlayerSkills(self:GetService("player").current, professionId, newSkills);

    -- send hello message
    professionsService:SayHelloToGuild();
end

--- Send all own profession to player.
-- @param playerName Name of player to send professions to.
-- @param playerStorageId Storage id of player to send professions to.
-- @param lastSyncDate Date of last sync.
-- @param sendBack Indicates if can sync back.
function OwnProfessionsService:SendOwnProfessionsToPlayer(playerName, playerStorageId, lastSyncDate, sendBack)
    -- iterate all players
    local playerService = self:GetService("player");
    for characterName, professions in pairs(OwnProfessions) do
        -- check if is same realm and same guild
        if (playerService:IsSameRealm(characterName)) then
             -- iterate all professions
            for professionId, skills in pairs(professions) do
                self:SendOwnProfessionToPlayer(playerName, professionId, skills, lastSyncDate, characterName);
            end
        end
    end

    -- send my characters
    self:SendMyCharacters(playerName);

    -- check if should send back
    if (sendBack) then
        -- request professions from other player
        self:GetService("professions"):RequestProfessionsFromPlayer(playerName, playerStorageId, false);
    end
end

--- Send my characters.
-- @param playerName Name of player to send characters to.
function OwnProfessionsService:SendMyCharacters(playerName)
    -- prepare skills to send
    local messageCharacters = {};

    -- get services and model
    local messageService = self:GetService("message");
    local playerService = self:GetService("player");
    local MyCharactersMessage = self:GetModel("my-characters-message");

    -- iterate all characters
    for characterName, _ in pairs(OwnProfessions) do
        -- check if is same realm
        if (playerService:IsSameRealm(characterName)) then
            -- add short name to result
            table.insert(messageCharacters, playerService:GetShortName(characterName));
        end
    end

    -- check if charatcers to send
    if (#messageCharacters > 0) then
        -- send message
        messageService:SendToPlayer(playerName, MyCharactersMessage:Create(messageCharacters)); 
    end
end

--- Send own profession to player.
-- @param playerName Name of player to send profession to.
-- @param professionId Id of profession to send.
-- @param skills List of skills of this profession to send.
-- @param lastSyncDate Date of alst sync.
-- @param ownPlayerName Own player name to to send professions from.
function OwnProfessionsService:SendOwnProfessionToPlayer(playerName, professionId, skills, lastSyncDate, ownPlayerName)
    -- prepare skills to send
    local messageSkills = {};

    -- get service and model
    local messageService = self:GetService("message");
    local PlayerProfessionsMessage = self:GetModel("player-professions-message");

    -- iterate all skills
    for skillIndex = 1, #skills do
        -- get skill
        local skill = skills[skillIndex];

        -- check last sync date
        if ((not lastSyncDate) or skill.added > lastSyncDate) then
            -- add skill
            table.insert(messageSkills, skill);

            -- check if 8 skills added
            if (#messageSkills == 8) then
                -- send message
                messageService:SendToPlayer(playerName, PlayerProfessionsMessage:Create(professionId, PMSettings.storageId, ownPlayerName, messageSkills));
                messageSkills = {};
            end
        end
    end

    -- check if skills to send
    if (#messageSkills > 0) then
        -- send message
        messageService:SendToPlayer(playerName, PlayerProfessionsMessage:Create(professionId, PMSettings.storageId, ownPlayerName, messageSkills)); 
    end
end

--- Check welcome.
function OwnProfessionsService:CheckWelcome()
    -- check if welcome read
    if (CharacterSettings.welcomeRead) then
        return;
    end

    -- check if player professions read
    local playerName = self:GetService("player").current;
    if (OwnProfessions[playerName]) then
        return;
    end

    -- show welcome view
    self.addon:NewView("welcome"):Show();
end

