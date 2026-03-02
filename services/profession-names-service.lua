--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create service
local ProfessionNamesService = _G.professionMaster:CreateService("profession-names");

--- Initialize service.
function ProfessionNamesService:Initialize()
    self.professionSpells = self:GetModel("profession-spells");

    -- build profession names from game spell data (works in all locales and versions)
    self.professionNames = {};
    self.professionIds = {};

    for skillLineId, spellId in pairs(self.professionSpells) do
        -- GetSpellInfo works in Classic Era, BCC, Wrath, Cata, MoP for any valid spell ID
        local spellName = GetSpellInfo(spellId);
        if (spellName) then
            self.professionNames[skillLineId] = spellName;
            self.professionIds[spellName] = skillLineId;
        end
    end

    -- warn if nothing loaded at all
    if (not next(self.professionNames)) then
        self:GetService("chat"):Write("LanguageNotSupported");
    end
end

--- Get profession ids to show.
-- @return List of ids.
function ProfessionNamesService:GetProfessionIdsToShow()
    -- get classic profession ids
    local professionIds = {
        333,
        171,
        197,
        165,
        164,
        202,
        185,
        186
    };

    -- add non vanilla ids
    if (self.addon.isBccAtLeast) then
        table.insert(professionIds, 2, 755);
    end
    if (self.addon.isWrathAtLeast) then
        table.insert(professionIds, 773);
    end
    return professionIds;
end

--- Get profession name by profession id.
-- @param professionId Id of profession to get name for.
-- @return Name of the given profession id or NIL if unknown.
function ProfessionNamesService:GetProfessionName(professionId)
    -- check profession id
    if (not professionId) then
        return nil;
    end

    -- get profession name
    return self.professionNames[professionId];
end

--- Get profession icon by profession id.
-- @param professionId Id of profession to get icon for.
-- @return Icon of the given profession id or NIL if unknown.
function ProfessionNamesService:GetProfessionIcon(professionId)
    -- check profession id
    if (not professionId) then
        return nil;
    end

    -- get profession name
    return self:GetModel("profession-icons")[professionId];
end

--- Get profession id by profession name.
-- @param professionName Name of profession to get id for.
-- @return Id of the given profession name or NIL if unknown.
function ProfessionNamesService:GetProfessionId(professionName)
    -- check profession name
    if (not professionName or professionName == "UNKNOWN") then
        return nil;
    end

    -- get profession id
    return self.professionIds[professionName];
end

--- Get skill id by skill link.
-- @param skillLink Link of skill to get id for.
-- @return Id of the given skill link.
function ProfessionNamesService:GetSkillId(skillLink)
    -- find enchant prefix
    local _, enchantPrefixEnd = string.find(skillLink, "|Henchant:");
    if (enchantPrefixEnd == 0 or enchantPrefixEnd == nil) then
        return nil;
    end

    -- find enchant suffix
    local enchantSuffixBegin = string.find(skillLink, "|h", enchantPrefixEnd + 1);
    if (enchantSuffixBegin < enchantPrefixEnd) then
        return nil;
    end

    -- get skill id
    return tonumber(string.sub(skillLink, enchantPrefixEnd + 1, enchantSuffixBegin - 1));
end

--- Get skill link by skill id and name.
-- @param professionId Id of profession to get link for.
-- @param skillId Id of skill to get link for.
-- @param itemName Name of item to get link for.
-- @return Link of the given skill id.
function ProfessionNamesService:GetSkillLink(professionId, skillId, itemName)
    if (professionId == 333) then
        return "|cffffd000|Henchant:" .. skillId .. "|h[" .. self:GetProfessionName(professionId) .. ": " .. itemName .. "]|h|r";
    else
        return "|cffffd000|Hspell:" .. skillId .. "|h[" .. self:GetProfessionName(professionId) .. ": " .. itemName .. "]|h|r";
    end
end

--- Get item color by item link.
-- @param itemLink Link of item to get color for.
-- @return Color of the given item link.
function ProfessionNamesService:GetItemColor(itemLink)
    return string.sub(itemLink, 3, 10);
end
