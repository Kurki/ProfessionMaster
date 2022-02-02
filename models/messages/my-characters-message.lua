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

-- define message
MyCharactersMessage = {};
MyCharactersMessage.__index = MyCharactersMessage;
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
    local messageService = addon:GetService("message");
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

-- register model
addon:RegisterModel(MyCharactersMessage, "my-characters-message");
