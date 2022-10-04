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
ProfessionsService = {};
ProfessionsService.__index = ProfessionsService;

--- Initialize service.
function ProfessionsService:Initialize()
    -- convert
    self:Convert();
end

--- Check message.
function ProfessionsService:CheckMessage(prefix, sender, message)
    -- check if is hello message
    local HelloMessage = addon:GetModel("hello-message");
    if (prefix == HelloMessage.prefix) then
        -- request professions from player
        local helloMessage = HelloMessage:Parse(message);
        self:RequestProfessionsFromPlayer(sender, helloMessage.storageId, true);
        return;
    end

    -- check if is request profession message
    local RequestProfessionsMessage = addon:GetModel("request-professions-message");
    if (prefix == RequestProfessionsMessage.prefix) then
        -- send all own professions to sender
        local rpMessage = RequestProfessionsMessage:Parse(message);
        addon:GetService("own-professions"):SendOwnProfessionsToPlayer(sender, rpMessage.storageId, rpMessage.lastSyncDate, rpMessage.sendBack);
        return;
    end

    -- check if is my characters message
    local MyCharactersMessage = addon:GetModel("my-characters-message");
    if (prefix == MyCharactersMessage.prefix) then
        -- store charater set
        local mcMessage = MyCharactersMessage:Parse(message);
        self:StoreCharacterSet(mcMessage.characterNames)
        return;
    end

    -- check if is player profession message
    local PlayerProfessionsMessage = addon:GetModel("player-professions-message");
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
    addon:GetService("message"):SendToGuild(addon:GetModel("hello-message"):Create(Settings.storageId));
end

--- Request profession from other player.
function ProfessionsService:RequestProfessionsFromPlayer(playerName, playerStorageId, sendBack)
    -- get last sync
    local lastSyncDate = self:GetLastSyncDate(playerStorageId);

    -- send request professions message to player
    addon:GetService("message"):SendToPlayer(playerName, addon:GetModel("request-professions-message"):Create(Settings.storageId, lastSyncDate, sendBack));
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

    -- get long names
    local playerService = addon:GetService('player');
    for i = 1, #characterNames do
        characterNames[i] = playerService:GetLongName(characterNames[i]);
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
    -- check profession id
    if (not Professions[professionId]) then
        Professions[professionId] = {};
    end

    -- get profession
    local profession = Professions[professionId];
    local professionNamesService = addon:GetService("profession-names");
    local professionName = professionNamesService:GetProfessionName(professionId);
    local itemsToLoad = {};
    local skillItems = addon:GetModel("skill-items");
    local bopItems = addon:GetModel("bop-items");

    -- check skills
    for i, skill in ipairs(skills) do
        -- check item
        if (not profession[skill.skillId]) then
            -- get spell
            local spellName, _, spellIcon = GetSpellInfo(skill.skillId);

            -- get skill link
            local skillLink = GetSpellLink(skill.skillId);

            -- add item
            local skillEntry = {
                name = spellName,
                skillLink = skillLink,
                itemId = skill.itemId,
                itemLink = nil,
                itemColor = nil,
                icon = spellIcon,
                bop = false,
                players = {}
            };
            profession[skill.skillId] = skillEntry;

            -- use default enchaning color
            if (professionId == 333) then
                skillEntry.itemColor = "FF71D5FF";
            end

            -- check if item can be found by skill id
            if (skillEntry.itemId == 0) then
                skillEntry.itemId = skillItems[skill.skillId];
                if (not skillEntry.itemId) then
                    skillEntry.itemId = 0;
                end
            end

            -- check if skill has item
            if (skillEntry.itemId ~= 0) then
                -- check if bop
                for _, itemId in ipairs(bopItems) do
                    -- check if is bop
                    if (skillEntry.itemId == itemId) then
                        skillEntry.bop = true;
                        break;
                    end
                end

                -- get item data
                local item = Item:CreateFromItemID(skillEntry.itemId);
                if (not item:IsItemEmpty()) then
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
                        if (not skillEntry.skillLink and not addon.isEra) then
                            skillEntry.skillLink = professionNamesService:GetSkillLink(professionId, skill.skillId, itemName);
                        end
                    end);
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

    -- split link
    local itemLinkParts = addon:GetService("message"):SplitString(itemLink, ":");
    if (#itemLinkParts < 3 or (not itemLinkParts[2])) then
        return nil;
    end

    -- get item id
    local itemId = tonumber(itemLinkParts[2]);
    if ((not itemId) or itemId == 0) then
        return nil;
    end

    -- check all professions
    for professionId, profession in pairs(Professions) do     
        -- check skills professions
        for skillId, skill in pairs(profession) do     
            -- check item id
            if (skill.itemId and skill.itemId == itemId) then
                return skillId, skill, professionId;
            end
        end  
    end  
    return nil;
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
    local professionId = addon:GetService("profession-names"):GetProfessionId(professionName);
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
    -- local ConvertData = {
    -- }
    -- Convert = {};
    -- -- print("123")
    -- for skillId, skill in pairs(ConvertData) do
    --     if (skill[1]) then
    --         Convert[skillId] = skill[1];
    --     end
    -- end

    -- Convert = {};
    -- for skillId, skill in pairs(ConvertData) do
    --     Convert[skillId] = {}
    --     for i, reagentId in ipairs(skill[6]) do
    --         Convert[skillId][reagentId] = skill[7][i];
    --     end
    -- end
end

-- register service
addon:RegisterService(ProfessionsService, "professions");