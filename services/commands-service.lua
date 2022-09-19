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
    -- check if no parameters entered
    if (string.len(parameters) <= 0 and not addon.inCombat) then
        -- show / hide overview
        addon.professionsView:ToggleVisibility();
        return;
    end

    -- check if overview should be shown
    if (string.lower(parameters) == "overview" and not addon.inCombat) then
        -- show / hide overview
        addon.professionsView:ToggleVisibility();
        return;
    end

    -- check if help should be shown
    if (string.lower(parameters) == "help") then
        -- write help
        local chatService = addon:GetService("chat");
        chatService:Write("CommandsTitle");
        chatService:Write("CommandsOverview");
        chatService:Write("CommandsReagents");
        if (Settings.hideMinimapButton) then
            chatService:Write("CommandsMinimap");
        end
        chatService:Write("CommandsPurge");
        return;
    end

    -- check if overview shoulkd be shown
    if (string.lower(parameters) == "reagents") then
        addon:GetService("inventory"):ToggleMissingReagents();
        return;
    end


    -- check if minimap should be toggeled
    if (string.lower(parameters) == "minimap" and Settings.hideMinimapButton) then
        addon.minimapButton:Show();
        Settings.hideMinimapButton = nil;
        return;
    end

    -- check if purge information must be shown
    if (string.lower(parameters) == "purge") then
        local chatService = addon:GetService("chat");
        chatService:Write("CommandsPurgeRow1");
        chatService:Write("CommandsPurgeRow2");
        chatService:Write("CommandsPurgeRow3");
        chatService:Write("CommandsPurgeRow4");
        return;
    end

    --check if data msut be purged
    if (string.find(parameters, "purge") == 1 and string.len(parameters) > 6) then
        addon:GetService("purge"):Purge(string.sub(parameters, 7));
    end

    -- check if history should be shown
    if (string.lower(parameters) == "debug") then
        addon:ToggleDebug();
        return;
    end

    -- check if history should be shown
    if (string.lower(parameters) == "trace") then
        addon:ToggleTrace();
    end
end

-- register handler
SLASH_ProfessionMaster1 = "/pm"
SlashCmdList["ProfessionMaster"] = CommandHandler;