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
OwnProfessionsService = {};
OwnProfessionsService.__index = OwnProfessionsService;

--- Initialize service.
function OwnProfessionsService:Initialize()
end

--- Get own trade skill professions. Enchanting is not part of trade professions.
function OwnProfessionsService:GetTradeSkillProfessionData()
    -- check if is in combat
    if (addon.inCombat) then
        return;
    end

    -- get an check profession id
    local professionNamesService = addon:GetService("profession-names");
    local professionId = professionNamesService:GetProfessionId(GetTradeSkillLine());
    if (not professionId) then
        return;
    end

    -- get amount of trade skills
    local tradeSkillAmount = GetNumTradeSkills();

    -- prepare item ids
    local skills = {};

    -- get item skills
    local itemSkills = addon:GetModel("item-skills");

    -- iterate trade skills
    for tradeSkillIndex = 1, tradeSkillAmount do
        -- ger trade skill name and type
        local tradeSkillName, tradeSkillType = GetTradeSkillInfo(tradeSkillIndex);

        -- check name and type
        if (tradeSkillName and (tradeSkillType == "optimal" or tradeSkillType == "medium" or tradeSkillType == "easy" or tradeSkillType == "trivial")) then
            -- get trade skill item link and link
            local tradeSkillItemLink = GetTradeSkillItemLink(tradeSkillIndex);
            local tradeSkillItemId = GetItemInfoInstant(tradeSkillItemLink);

            -- get trade skill id
            if (tradeSkillItemId) then
                -- get trande skill id
                local tradeSkillId = itemSkills[tradeSkillItemId];
                if (not tradeSkillId) then
                    local tradeSkillLink = GetTradeSkillRecipeLink(tradeSkillIndex);
                    if (tradeSkillLink) then
                        tradeSkillId = professionNamesService:GetSkillId(tradeSkillLink);
                    end
                end 

                -- check skill id
                if (tradeSkillId) then
                    -- add skill
                    table.insert(skills, {
                        skillId = tradeSkillId,
                        itemId = tradeSkillItemId,
                        added = time()
                    });
                end
            end
        end
    end

    -- store own profession
    self:StoreAndSendOwnProfession(professionId, skills);
end

--- Get own enchanting skills.
function OwnProfessionsService:GetEnchantingProfessionData()
    -- check if is in combat
    if (addon.inCombat) then
        return;
    end

    -- get and check profession id
    local professionId = addon:GetService("profession-names"):GetProfessionId(GetCraftSkillLine(1));
    if (not professionId or professionId ~= 333) then
        return;
    end

    -- get amount of skills
    local recipeAmount = GetNumCrafts();

    -- prepare skills
    local skills = {};

    -- iterate skills
    for recipeIndex = 1, recipeAmount do
        -- ger recipe name and type
        local recipeName, _, recipeType = GetCraftInfo(recipeIndex);

        -- check name and type
        if (recipeName and (recipeType == "optimal" or recipeType == "medium" or recipeType == "easy" or recipeType == "trivial")) then
            -- get item id of recipe
            local _, _, _, _, _, _, recipeId = GetSpellInfo(recipeName);

            -- add item id
            table.insert(skills, {
                skillId = recipeId,
                itemId = 0,
                added = time()
            });
        end
    end

    -- store own profession
    self:StoreAndSendOwnProfession(professionId, skills);
end

--- Store profession.
-- @param professionId Id of profession to store.
-- @param skills List of skills of this profession to store.
-- @return Ne added item ids.
function OwnProfessionsService:StoreAndSendOwnProfession(professionId, skills)
    -- prepare new skills
    local newSkills = {};

    -- check player
    local playerName = addon:GetService("player").current;
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
    local professionsService = addon:GetService("professions");
    professionsService:StorePlayerSkills(addon:GetService("player").current, professionId, newSkills);

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
    local playerService = addon:GetService("player");
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
        addon:GetService("professions"):RequestProfessionsFromPlayer(playerName, playerStorageId, false);
    end
end

--- Send my characters.
-- @param playerName Name of player to send characters to.
function OwnProfessionsService:SendMyCharacters(playerName)
    -- prepare skills to send
    local messageCharacters = {};

    -- get services and model
    local messageService = addon:GetService("message");
    local playerService = addon:GetService("player");
    local MyCharactersMessage = addon:GetModel("my-characters-message");

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
    local messageService = addon:GetService("message");
    local PlayerProfessionsMessage = addon:GetModel("player-professions-message");

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
                messageService:SendToPlayer(playerName, PlayerProfessionsMessage:Create(professionId, Settings.storageId, ownPlayerName, messageSkills));
                messageSkills = {};
            end
        end
    end

    -- check if skills to send
    if (#messageSkills > 0) then
        -- send message
        messageService:SendToPlayer(playerName, PlayerProfessionsMessage:Create(professionId, Settings.storageId, ownPlayerName, messageSkills)); 
    end
end

--- Check welcome.
function OwnProfessionsService:CheckWelcome()
    -- check if welcome read
    if (CharacterSettings.welcomeRead) then
        return;
    end

    -- check if player professions read
    local playerName = addon:GetService("player").current;
    if (OwnProfessions[playerName]) then
        return;
    end

    -- show welcome view
    addon:CreateView("welcome"):Show();
end

-- register service
addon:RegisterService(OwnProfessionsService, "own-professions");