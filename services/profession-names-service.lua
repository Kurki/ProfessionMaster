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
ProfessionNamesService = {};
ProfessionNamesService.__index = ProfessionNamesService;

--- Initialize service.
function ProfessionNamesService:Initialize()
    -- get profession names
    local professionNames = addon:GetModel("profession-names")[GetLocale()];
    if (not professionNames) then
        addon:GetService("chat"):Write("LanguageNotSupported");
        return;
    end

    -- store profession names and ids
    self.professionNames = professionNames;
    self.professionIds = tInvert(professionNames);
end

--- Get profession ids to show.
-- @return List of ids.
function ProfessionNamesService:GetProfessionIdsToShow()
    return {
        333,
        755,
        171,
        197,
        165,
        164,
        202,
        773,
        185
    };
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
    return addon:GetModel("profession-icons")[professionId];
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
    if (enchantPrefixEnd == 0) then
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
    return "|cffffd000|Henchant:" .. skillId .. "|h[" .. self:GetProfessionName(professionId) .. ": " .. itemName .. "]|h|r";
end

--- Get item color by item link.
-- @param itemLink Link of item to get color for.
-- @return Color of the given item link.
function ProfessionNamesService:GetItemColor(itemLink)
    return string.sub(itemLink, 3, 10);
end

-- register service
addon:RegisterService(ProfessionNamesService, "profession-names");