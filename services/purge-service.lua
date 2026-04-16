--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local PurgeService = _G.professionMaster:CreateService("purge");

--- Initialize service.
function PurgeService:Initialize()
end

--- Purge data.
function PurgeService:Purge(context)
    -- get chat service
    local chatService = self:GetService("chat");

    -- check if all data should be purged
    if (context == 'all') then
        -- purge all data
        PM_Professions = {};
        PM_OwnProfessions = {};
        PM_SyncTimes = {};
        PM_Settings = {};
        PM_Logs = {};
        PM_CharacterSets = {};
        PM_BucketList = {};
        PM_Frames = {};
        PM_CharacterSettings = {}; 
        self.addon:CheckSettings();

        -- rebuild reverse index after purge
        self:GetService("professions"):RebuildItemIndex();

        -- refresh professions view
        if (self.addon.professionsView) then
            self.addon.professionsView:Refresh();
        end

        -- send message
        chatService:Write("AllDataPurged");
        return;
    end

    -- check if own data should be purged
    local playerService = self:GetService('player');
    if (context == 'own') then
        self:PurgeCharacter(playerService.current);
        PM_Frames = {};
        PM_CharacterSettings = {}; 
        return;
    end

    -- purge by player name
    self:PurgeCharacter(playerService:GetLongName(context));
end

--- Purge character.
function PurgeService:PurgeCharacter(characterName) 
    -- purge character data silently
    self:PurgeCharacterSilent(characterName);

    -- reset all sync times
    PM_SyncTimes = {};

    -- reset storage id to recieve data again
    PM_Settings.storageId = nil;

    -- check settings
    self.addon:CheckSettings();

    -- rebuild reverse index after purge
    self:GetService("professions"):RebuildItemIndex();

    -- refresh professions view
    if (self.addon.professionsView) then
        self.addon.professionsView:Refresh();
    end

    -- send message
    self:GetService("chat"):Write("CharacterPurged", characterName);
end

--- Purge character data without chat output or sync reset.
-- Used for batch purging.
function PurgeService:PurgeCharacterSilent(characterName)
    -- get lower character name
    local lowerCharacterName = string.lower(characterName);

    -- remove from own professions
    for ownProfessionCharacter, _ in pairs(PM_OwnProfessions) do   
        if (string.lower(ownProfessionCharacter) == lowerCharacterName) then
            PM_OwnProfessions[ownProfessionCharacter] = nil;
            break;
        end
    end

    -- check all professions
    for _, profession in pairs(PM_Professions) do     
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

    -- remove from guildmates
    for guildmateName, _ in pairs(PM_Guildmates) do
        if (string.lower(guildmateName) == lowerCharacterName) then
            PM_Guildmates[guildmateName] = nil;
            break;
        end
    end

    -- remove from specializations
    for specializationName, _ in pairs(PM_Specializations) do
        if (string.lower(specializationName) == lowerCharacterName) then
            PM_Specializations[specializationName] = nil;
            break;
        end
    end

    -- remove from player factions
    for factionName, _ in pairs(PM_PlayerFactions) do
        if (string.lower(factionName) == lowerCharacterName) then
            PM_PlayerFactions[factionName] = nil;
            break;
        end
    end
end

