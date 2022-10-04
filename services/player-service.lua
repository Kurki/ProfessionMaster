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
PlayerService = {};
PlayerService.__index = PlayerService;

-- get realm name
local realmName = string.gsub(GetRealmName(), "%s+", "");

--- Initialize service.
function PlayerService:Initialize()
    -- get player name
    self.current = self:GetLongName(GetUnitName("player"));
end

--- Refresh guildmates.
function PlayerService:RefreshGuildmates()
    -- set all guildmates offline
    if (not Guildmates) then Guildmates = {}; end
    for _, guildmate in pairs(Guildmates) do
        guildmate.online = false;
    end

    -- iterate all members
    for guildIndex = 1, GetNumGuildMembers() do
        -- get player info
        local playerName, _, _, _, _, _, _, _, online = GetGuildRosterInfo(guildIndex);

        -- check player name
        if (playerName) then
            -- check if not in guild mates
            if (not Guildmates[playerName]) then
                Guildmates[playerName] = {};
            end

            -- set online/offline
            Guildmates[playerName].online = online;
        end
    end
end

--- Get player short name.
function PlayerService:GetShortName(name)
    -- split by "-"
    local parts = addon:GetService("message"):SplitString(name, "-");

    -- check if realm is same realm
    if (#parts > 1 and parts[2] == realmName) then
        -- only return player name
        return parts[1];
    end

    -- different realm, return full name
    return name;
end

--- Check is if is same realm
function PlayerService:IsSameRealm(name)
    -- split by "-"
    local parts = addon:GetService("message"):SplitString(name, "-");

    -- check if realm is same realm
    return #parts > 1 and parts[2] == realmName;
end

--- Check name and add realm if not set.
function PlayerService:GetLongName(name)
    -- check if name is null
    if (name == nil) then
        return nil;
    end

    -- check if realm already included
    if (string.find(name, "-") == nil) then
        name = name .. "-" .. realmName;
    end
    return name;
end

--- Check if given player is current player.
function PlayerService:IsCurrentPlayer(name)
    return self.current == self:GetLongName(name);
end

--- Format palyer names.
function PlayerService:CombinePlayerNames(playerNames, maxAmount)
    -- prepare values
    local localeService = addon:GetService("locale");
    local containsCurrentPlayer = false;
    local ownPlayerNames = {};
    local onlinePlayers = {};
    local offlinePlayers = {};

    -- iterate all player names
    for _, playerName in ipairs(playerNames) do
        -- check realm
        if (self:IsSameRealm(playerName)) then
            -- get short player name
            local shortPlayerName = self:GetShortName(playerName);

            -- check if is current player
            if (self:IsCurrentPlayer(playerName)) then
                -- set is current player
                containsCurrentPlayer = true;

                -- reset other player names, not required
                ownPlayerNames = {};
            -- check if is owm player
            elseif (OwnProfessions[playerName]) then
                -- add to own players if current player is not added
                if (not containsCurrentPlayer) then
                    table.insert(ownPlayerNames, shortPlayerName);
                end
            else
                -- check if is online
                local guildPlayer = Guildmates[playerName];
                if (guildPlayer and guildPlayer.online) then
                    -- set online player
                    onlinePlayers[shortPlayerName] = {};
                else
                    -- find character set
                    local addToOffline = true;
                    local characterSet = self:FindCharacterSet(playerName);
                    if (characterSet) then
                        -- check if twink online
                        local twinkNamesOnline = {};
                        for _, twinkName in ipairs(characterSet) do
                            local twinkGuildPlayer = Guildmates[twinkName];
                            if (twinkGuildPlayer and twinkGuildPlayer.online) then
                                table.insert(twinkNamesOnline, twinkName);
                            end
                        end

                        -- check if twinks online
                        if (#twinkNamesOnline > 0) then
                            -- do not add to offline
                            addToOffline = false;

                            -- check if at least one twinks has profession
                            local twinksHaveProfession = false;
                            for _, playerName in ipairs(playerNames) do
                                for _, twinkNameOnline in pairs(twinkNamesOnline) do
                                    if (playerName == twinkNameOnline) then
                                        twinksHaveProfession = true;
                                        break;
                                    end
                                end
                                if (twinksHaveProfession) then
                                    break;
                                end
                            end

                            -- check if must be added as a twink
                            if (not twinksHaveProfession) then
                                for _, twinkNameOnline in pairs(twinkNamesOnline) do
                                    -- add short online twink name to online players if not already added
                                    local shortTwinkNameOnline = self:GetShortName(twinkNameOnline);
                                    if (not onlinePlayers[shortTwinkNameOnline]) then
                                        onlinePlayers[shortTwinkNameOnline] = {};
                                    end

                                    -- check if is in guild
                                    if (Guildmates[playerName]) then
                                        table.insert(onlinePlayers[shortTwinkNameOnline], shortPlayerName);
                                    else
                                        table.insert(onlinePlayers[shortTwinkNameOnline], "alt");
                                    end
                                end
                            end
                        end
                    end

                    -- check if is offline
                    if (addToOffline) then
                        if (Guildmates[playerName]) then
                            -- add to offline players
                            table.insert(offlinePlayers, shortPlayerName);
                        elseif (characterSet) then
                            local guildTwinkName = nil;
                            local characterSetExists = false;
                            for _, twinkName in ipairs(characterSet) do
                                local shortTwinkName = self:GetShortName(twinkName);
                                if (self:ListContains(offlinePlayers, shortTwinkName)) then
                                    characterSetExists = true;
                                    break;
                                end
                                
                                -- get guild twink name
                                if (Guildmates[twinkName] and not guildTwinkName) then  
                                    guildTwinkName = shortTwinkName;
                                end
                            end

                            -- check if guild twink name found and not added already
                            if (not characterSetExists and guildTwinkName) then
                                table.insert(offlinePlayers, guildTwinkName);
                            end
                        end
                    end
                end
            end
        end
    end

    -- prepare result
    local result = {};

    -- add yourself
    if (containsCurrentPlayer) then
        table.insert(result, "|cff00ee00" .. localeService:Get("You"));
    elseif (#ownPlayerNames > 0) then
        table.sort(ownPlayerNames, function(a, b)
            return a < b;
        end);
        table.insert(result, "|cff00ee00" .. localeService:Get("You") .. " (" .. table.concat(ownPlayerNames, ", ") .. ")");
    end

    -- add online players
    table.sort(onlinePlayers, function(a, b)
        return a < b;
    end);
    for onlinePlayerName, onlinePlayerTwinks in pairs(onlinePlayers) do
        if (maxAmount and #result >= maxAmount) then
            table.insert(result, "...");
            break;
        end
        if (#onlinePlayerTwinks == 1) then
            table.insert(result, "|cffffffff" .. onlinePlayerName .. " (" .. onlinePlayerTwinks[1] .. ")");
        elseif (#onlinePlayerTwinks > 1) then
            table.insert(result, "|cffffffff" .. onlinePlayerName .. " (Twink)");
        else
            table.insert(result, "|cffffffff" .. onlinePlayerName);
        end
    end

    -- check maximum amount
    if (not maxAmount or #result < maxAmount) then
        -- add offline players
        table.sort(offlinePlayers, function(a, b)
            return a < b;
        end);
        for _, offlinePlayer in ipairs(offlinePlayers) do
            if (maxAmount and #result >= maxAmount) then
                table.insert(result, "...");
                break;
            end
            table.insert(result, "|cff999999" .. offlinePlayer);
        end
    end

    -- players combined
    return result;
end

--- Cehck if list contains the given value
function PlayerService:ListContains(list, value)
    for _, entryValue in ipairs(list) do
        if (entryValue == value) then
            return true;
        end
    end
    return false;
end

--- Find character set by character name.
function PlayerService:FindCharacterSet(characterName)
    -- iterate all existing character sets
    for _, characterSet in ipairs(CharacterSets) do
        -- iterate players in character set
        for _, existingCharacterName in ipairs(characterSet) do
            if (characterName == existingCharacterName) then
                return characterSet;
            end
        end
    end
    return nil;
end

-- register service
addon:RegisterService(PlayerService, "player");