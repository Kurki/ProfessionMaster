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
RequestProfessionsMessage = {};
RequestProfessionsMessage.__index = RequestProfessionsMessage;
RequestProfessionsMessage.prefix = "RequestProfessions2";

--- Create message model.
function RequestProfessionsMessage:Create(storageId, lastSyncDate, sendBack)
    local message = {
        storageId = storageId,
        lastSyncDate = lastSyncDate,
        sendBack = sendBack
    };
    setmetatable(message, RequestProfessionsMessage);
    return message;
end

--- Parse message from string.
function RequestProfessionsMessage:Parse(value)
    local values = addon:GetService("message"):SplitString(value, ":");
    local message = {
        storageId = values[1],
        lastSyncDate = tonumber(values[2]),
        sendBack = (tonumber(values[3]) == 1)
    };
    setmetatable(message, RequestProfessionsMessage);
    return message;
end

--- Convert message to string.
function RequestProfessionsMessage:ToString()
    return table.concat({
        self.storageId,
        self.lastSyncDate,
        (self.sendBack and "1" or "0")
    }, ":");
end

-- register model
addon:RegisterModel(RequestProfessionsMessage, "request-professions-message");
