--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create model
local VersionBroadcastMessage = _G.professionMaster:CreateModel("version-broadcast-message");
VersionBroadcastMessage.prefix = "VersionBroadcast";

--- Create message model.
function VersionBroadcastMessage:Create()
    local message = {
        version = self.addon.version
    }
    setmetatable(message, VersionBroadcastMessage);
    return message;
end

--- Parse message from string.
function VersionBroadcastMessage:Parse(value)
    local values = self:GetService("message"):SplitString(value, ":");
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

