--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local PM_LogService = _G.professionMaster:CreateService("log");

--- Initialize service.
function PM_LogService:Initialize()
    -- purge entries older than 7 days
    self:PurgeOldEntries();
end

--- Log a message.
-- @param ... The values to log.
function PM_LogService:AddEntry(...)
    local parts = {};
    for index = 1, select("#", ...) do
        local value = select(index, ...);
        table.insert(parts, tostring(value));
    end

    local message = table.concat(parts, " ");
    local dayKey = date("%Y-%m-%d");

    -- ensure day array exists
    if (not PM_Logs[dayKey]) then
        PM_Logs[dayKey] = {};
    end

    table.insert(PM_Logs[dayKey], date("%H:%M:%S") .. " " .. message);
end

--- Purge log entries older than 7 days.
function PM_LogService:PurgeOldEntries()
    local cutoff = time() - 7 * 24 * 60 * 60;
    for dayKey, _ in pairs(PM_Logs) do
        -- parse day key
        local year, month, day = dayKey:match("^(%d+)-(%d+)-(%d+)$");
        if (year) then
            local entryTime = time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) });
            if (entryTime < cutoff) then
                PM_Logs[dayKey] = nil;
            end
        else
            -- legacy flat entry, remove
            PM_Logs[dayKey] = nil;
        end
    end
end

--- Get all log entries as a single string, newest day first.
-- @return string All log entries formatted for display.
function PM_LogService:GetLogText()
    -- collect and sort day keys (newest first)
    local dayKeys = {};
    for dayKey, _ in pairs(PM_Logs) do
        table.insert(dayKeys, dayKey);
    end
    table.sort(dayKeys, function(a, b) return a > b; end);

    -- build text
    local lines = {};
    for _, dayKey in ipairs(dayKeys) do
        table.insert(lines, "--- " .. dayKey .. " ---");
        for _, entry in ipairs(PM_Logs[dayKey]) do
            table.insert(lines, entry);
        end
        table.insert(lines, "");
    end

    if (#lines == 0) then
        return "No log entries.";
    end

    return table.concat(lines, "\n");
end
