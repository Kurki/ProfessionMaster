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
VersionBroadcastMessage = {};
VersionBroadcastMessage.__index = VersionBroadcastMessage;
VersionBroadcastMessage.prefix = "VersionBroadcast";

--- Create message model.
function VersionBroadcastMessage:Create()
    local message = {
        version = addon.version
    }
    setmetatable(message, VersionBroadcastMessage);
    return message;
end

--- Parse message from string.
function VersionBroadcastMessage:Parse(value)
    local values = addon:GetService("message"):SplitString(value, ":");
    local message = {
        version = values[1]
    }
    setmetatable(message, VersionBroadcastMessage);
    return message;
end

--- Convert message to string.
function VersionBroadcastMessage:ToString()
    return table.concat({
        self.version
    }, ":");
end

-- register model
addon:RegisterModel(VersionBroadcastMessage, "version-broadcast-message");
