--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create model
local MyCharactersMessage = _G.professionMaster:CreateModel("my-characters-message");
MyCharactersMessage.prefix = "MyCharacters";

--- Create message model.
function MyCharactersMessage:Create(characterNames)
    local message = {
        characterNames = characterNames
    };
    setmetatable(message, MyCharactersMessage);
    return message;
end

--- Parse message from string.
function MyCharactersMessage:Parse(value)
    local messageService = self:GetService("message");
    local values = messageService:SplitString(value, ":");
    local message = {
        characterNames = messageService:SplitString(values[1], ",");
    };
    setmetatable(message, MyCharactersMessage);
    return message;
end

--- Convert message to string.
function MyCharactersMessage:ToString()
    return table.concat(self.characterNames, ",");  
end

