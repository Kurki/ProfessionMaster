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

-- create model
local PlayerProfessionsMessage = _G.professionMaster:CreateModel("player-professions-message");
PlayerProfessionsMessage.prefix = "PlayerProfessions2";

--- Create message model.
function PlayerProfessionsMessage:Create(professionId, storageId, playerName, skills)
    -- store values
    local message = {
        professionId = professionId,
        storageId = storageId,
        playerName = playerName,
        skills = skills
    };

    -- message created
    setmetatable(message, PlayerProfessionsMessage);
    return message;
end

--- Parse message from string.
function PlayerProfessionsMessage:Parse(value)
    -- split values an prepare message
    local messageService = self:GetService("message");
    local values = messageService:SplitString(value, ":");
    local message = {
        professionId = tonumber(values[1]),
        storageId = values[2],
        playerName = values[3],
        skills = {}
    };

    -- get item ids
    local skills = messageService:SplitString(values[4], ",");
    for skillIndex = 1, #skills do
        local skillParts = messageService:SplitString(skills[skillIndex], ".");
        table.insert(message.skills, {
            skillId = tonumber(skillParts[1]),
            itemId = tonumber(skillParts[2])
        });
    end

    -- message parsed
    setmetatable(message, PlayerProfessionsMessage);
    return message;
end

--- Convert message to string.
function PlayerProfessionsMessage:ToString()
    -- combine skills to values
    local skillValues = {};
    for i, skill in ipairs(self.skills) do
        table.insert(skillValues, skill.skillId .. "." .. skill.itemId);
    end

    -- build message
    return table.concat({
        self.professionId,
        self.storageId,
        self.playerName,
        table.concat(skillValues, ",")
    }, ":");  
end

