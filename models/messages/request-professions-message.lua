--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create model
local RequestProfessionsMessage = _G.professionMaster:CreateModel("request-professions-message");
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
    local values = self:GetService("message"):SplitString(value, ":");
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

