--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create model
local PlayerSpecializationsMessage = _G.professionMaster:CreateModel("player-specializations-message");
PlayerSpecializationsMessage.prefix = "PlayerSpecs";

--- Create message model.
-- @param playerName Name of the character.
-- @param specializations Table mapping professionId to spellId.
function PlayerSpecializationsMessage:Create(playerName, specializations)
    local message = {
        playerName = playerName,
        specializations = specializations
    };
    setmetatable(message, PlayerSpecializationsMessage);
    return message;
end

--- Parse message from string.
function PlayerSpecializationsMessage:Parse(value)
    local messageService = self:GetService("message");
    local values = messageService:SplitString(value, ":");
    local message = {
        playerName = values[1],
        specializations = {}
    };

    -- parse specialization pairs (professionId.spellId,professionId.spellId,...)
    if (values[2] and values[2] ~= "") then
        local pairs = messageService:SplitString(values[2], ",");
        for pairIndex = 1, #pairs do
            local parts = messageService:SplitString(pairs[pairIndex], ".");
            local professionId = tonumber(parts[1]);
            local spellId = tonumber(parts[2]);
            if (professionId and spellId) then
                message.specializations[professionId] = spellId;
            end
        end
    end

    setmetatable(message, PlayerSpecializationsMessage);
    return message;
end

--- Convert message to string.
function PlayerSpecializationsMessage:ToString()
    local specValues = {};
    for professionId, spellId in pairs(self.specializations) do
        table.insert(specValues, professionId .. "." .. spellId);
    end

    return table.concat({
        self.playerName,
        table.concat(specValues, ",")
    }, ":");
end
