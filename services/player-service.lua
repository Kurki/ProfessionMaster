--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local PlayerService = _G.professionMaster:CreateService("player");

--- Initialize service.
function PlayerService:Initialize()
    -- get realm name and name cache
    self.realmName = string.gsub(GetRealmName(), "%s+", "");
    self.nameCache = {};

    -- get player name
    self.current = self:GetLongName(GetUnitName("player"));

    -- store current player faction (H = Horde, A = Alliance)
    local factionGroup = UnitFactionGroup("player");
    self.faction = (factionGroup == "Horde") and "H" or "A";
    PlayerFactions[self.current] = self.faction;
end

--- Parse a player name into short name and realm check (cached).
function PlayerService:ParsePlayerName(name)
    local cached = self.nameCache[name];
    if (cached) then
        return cached;
    end

    local dashPos = string.find(name, "-", 1, true);
    local result;
    if (dashPos) then
        local realm = string.sub(name, dashPos + 1);
        local short = string.sub(name, 1, dashPos - 1);
        local isSameRealm = (realm == self.realmName);
        result = {
            short = isSameRealm and short or name,
            sameRealm = isSameRealm
        };
    else
        result = {
            short = name,
            sameRealm = false
        };
    end

    self.nameCache[name] = result;
    return result;
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
    return self:ParsePlayerName(name).short;
end

--- Check is if is same realm
function PlayerService:IsSameRealm(name)
    return self:ParsePlayerName(name).sameRealm;
end

--- Check if player belongs to the same faction.
-- Players without a stored faction (legacy data) are treated as neutral.
function PlayerService:IsSameFaction(name)
    local storedFaction = PlayerFactions[name];
    -- nil = neutral (backward compatible), otherwise must match
    return storedFaction == nil or storedFaction == self.faction;
end

--- Check name and add realm if not set.
function PlayerService:GetLongName(name)
    -- check if name is null
    if (name == nil) then
        return nil;
    end

    -- check if realm already included
    if (string.find(name, "-") == nil) then
        name = name .. "-" .. self.realmName;
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
    local localeService = self:GetService("locale");
    local containsCurrentPlayer = false;
    local ownPlayerNames = {};
    local onlinePlayers = {};
    local offlinePlayers = {};

    -- iterate all player names
    for _, playerName in ipairs(playerNames) do
        -- check realm and faction
        if ((self:IsSameRealm(playerName) or Guildmates[playerName]) and self:IsSameFaction(playerName)) then
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
            table.insert(result, "|cffffffff" .. onlinePlayerName .. " (alt)");
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
