--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local TimerService = _G.professionMaster:CreateService("timer");

--- Initialize service.
function TimerService:Initialize()
    self.timers = {};
end

-- start timer
function TimerService:Start(name, seconds, callback)
    -- stop existing timer with same name
    self:Stop(name);

    -- create timer state
    local timer = {
        seconds = seconds,
        callback = callback
    };
    self.timers[name] = timer;

    -- call with initial seconds
    callback(seconds);

    -- create a 1-second ticker (event-driven, no per-frame overhead)
    timer.ticker = C_Timer.NewTicker(1, function()
        timer.seconds = timer.seconds - 1;
        timer.callback(timer.seconds);

        -- check if 0 seconds reached
        if (timer.seconds <= 0) then
            self:Stop(name);
        end
    end, seconds);
end

-- stop timer
function TimerService:Stop(name)
    -- check timer
    if (self.timers[name] == nil) then
        return;
    end

    -- cancel ticker
    if (self.timers[name].ticker) then
        self.timers[name].ticker:Cancel();
    end
    self.timers[name] = nil;
end

-- wait timer
function TimerService:Wait(name, seconds, callback)
    -- start timer
    self:Start(name, seconds, function(second)
        -- check if zero
        if (second == 0) then
            -- trigger callback
            callback();
        end
    end);
end
