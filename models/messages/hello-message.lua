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
local HelloMessage = _G.professionMaster:CreateModel("hello-message");
HelloMessage.prefix = "Hello";

--- Create message model.
function HelloMessage:Create(storageId)
    local message = {
        storageId = storageId
    };
    setmetatable(message, HelloMessage);
    return message;
end

--- Parse message from string.
function HelloMessage:Parse(value)
    local messageService = self:GetService("message");
    local values = messageService:SplitString(value, ":");
    local message = {
        storageId = values[1]
    };
    setmetatable(message, HelloMessage);
    return message;
end

--- Convert message to string.
function HelloMessage:ToString()
    return self.storageId;  
end
