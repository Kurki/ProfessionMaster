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
