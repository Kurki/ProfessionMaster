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
PurgeService = {};
PurgeService.__index = PurgeService;

--- Initialize service.
function PurgeService:Initialize()
end

--- Purge data.
function PurgeService:Purge(context)
    -- get chat service
    local chatService = addon:GetService("chat");

    -- check if all data should be purged
    if (context == 'all') then
        -- purge all data
        Professions = {};
        OwnProfessions = {};
        SyncTimes = {};
        Settings = {};
        Logs = {};
        CharacterSets = {};
        BucketList = {};
        Frames = {};
        CharacterSettings = {}; 
        addon:CheckSettings();

        -- send message
        chatService:Write("AllDataPurged");
        return;
    end

    -- check if own data should be purged
    local playerService = addon:GetService('player');
    if (context == 'own') then
        self:PurgeCharacter(playerService.current);
        Frames = {};
        CharacterSettings = {}; 
        return;
    end

    -- purge by player name
    self:PurgeCharacter(playerService:GetLongName(context));
end

--- Purge character.
function PurgeService:PurgeCharacter(characterName) 
    -- get lower charatcer name
    local lowerCharacterName = string.lower(characterName);

    -- remove from own professions
    for ownProfessionCharacter, _ in pairs(OwnProfessions) do   
        if (string.lower(ownProfessionCharacter) == lowerCharacterName) then
            OwnProfessions[ownProfessionCharacter] = nil;
            break;
        end
    end

    -- check all professions
    for _, profession in pairs(Professions) do     
        -- check all skills
        for _, skill in pairs(profession) do     
            -- check all players
            for playerIndex, playerName in ipairs(skill.players) do
                if (string.lower(playerName) == lowerCharacterName) then
                    table.remove(skill.players, playerIndex);
                    break;
                end
            end
        end  
    end  

    -- reset all sync times
    SyncTimes = {};

    -- reset storage id to recieve data again
    Settings.storageId = nil;

    -- check settings
    addon:CheckSettings();

    -- send message
    addon:GetService("chat"):Write("CharacterPurged", characterName);
end

-- register service
addon:RegisterService(PurgeService, "purge");
