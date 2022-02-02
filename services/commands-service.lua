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

-- handle command line 
local function CommandHandler(parameters)
    -- check if help should be shown
    if (string.len(parameters) <= 0) then
        addon:CreateView("professions"):Show();
    end

    -- check if data should be purged
    if (string.lower(parameters) == "purge") then
        Professions = {};
        OwnProfessions = {};
        Settings = {};
        SyncTimes = {};
        addon:CheckSettings();
    end

    -- check if history should be shown
    if (string.lower(parameters) == "debug") then
        addon:ToggleDebug();
    end

    -- check if history should be shown
    if (string.lower(parameters) == "trace") then
        addon:ToggleTrace();
    end
end

-- register handler
SLASH_ProfessionMaster1 = "/pm"
SlashCmdList["ProfessionMaster"] = CommandHandler;