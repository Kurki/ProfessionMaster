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

-- define service
TimerService = {};
TimerService.__index = TimerService;

--- Initialize service.
function TimerService:Initialize()
    self.timers = {};
end

-- start timer
function TimerService:Start(name, seconds, callback)
    -- check if timer not exists
    if (self.timers[name] == nil) then
        local timer = CreateFrame("Frame");
        timer:SetScript("OnUpdate", function(_self, elapsed)
            timer.currentSecond = timer.currentSecond - elapsed;
            if (timer.currentSecond <= 0) then
                -- reset current second
                timer.currentSecond = timer.currentSecond + 1;

                -- reduce second and call callback
                timer.seconds = timer.seconds - 1;
                timer.callback(timer.seconds);

                -- check if 0 seconds reached
                if (timer.seconds == 0) then
                    -- stop timer
                    self:Stop(name);
                end
            end
        end);
        self.timers[name] = timer;
    end

    -- store / reset values
    self.timers[name].currentSecond = 1;
    self.timers[name].seconds = seconds;
    self.timers[name].callback = callback;

    -- call with initial seconds
    callback(seconds);
end

-- stop timer
function TimerService:Stop(name)
    -- check timer
    if (self.timers[name] == nil) then
        return;
    end

    -- remove script and stop frame
    self.timers[name]:SetScript("OnUpdate", nil);
    self.timers[name]:Hide();
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

-- register service
addon:RegisterService(TimerService, "timer");