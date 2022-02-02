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
TooltipService = {};
TooltipService.__index = TooltipService;

--- Initialize service.
function TooltipService:Initialize()
    self.watching = false;
    self.currentText = nil;
    self.currentTextLine = nil;
    self.tooltips = { 
        GameTooltip, 
        ItemRefTooltip, 
        ShoppingTooltip1, 
        ShoppingTooltip2, 
        ShoppingTooltip3 
    };
end

-- Watch tooltip.
function TooltipService:WatchTooltip()
    -- check if already watching
    if (self.watching) then
        return;
    end

    -- set watching
    self.watching = true;

    -- hook tooltips
    for _, tooltip in ipairs(self.tooltips) do 
        -- hook set item
        tooltip:HookScript("OnTooltipSetItem", function (_self)
            if _self["ProfessionMaster"] then 
                return;
            end
            _self["ProfessionMaster"] = true;
            self:CheckTooltip(_self);
        end)   

        -- hook set spell
        tooltip:HookScript("OnTooltipSetSpell", function (_self)
            if _self["ProfessionMaster"] then 
                return; 
            end
            _self["ProfessionMaster"] = true;
            self:CheckTooltip(_self);
        end)

        -- hook tooltip cleared
        tooltip:HookScript("OnTooltipCleared", function (_self)
            _self["ProfessionMaster"] = nil;
        end)
    end
end

-- Check tooltip.
function TooltipService:CheckTooltip(tooltip)
    -- prepare skill 
    local skill, professionId = nil;

    -- check for item link
    local _, itemLink = GameTooltip:GetItem();
    if (itemLink) then
        -- find skill by item link
        skill, professionId = addon:GetService("professions"):FindSkillByItemLink(itemLink);
    end

    -- check if skill not found yet
    if (not skill) then
        -- check if small text is reagents
        local title = GameTooltipTextLeft1:GetText();
        local smallText = GameTooltipTextLeft2:GetText();
        if (title and smallText and string.find(smallText, SPELL_REAGENTS) == 1) then
            -- find skill by name
            skill, professionId = addon:GetService("professions"):FindSkillByName(title);
        end
    end

    -- check if skill found
    if (not skill) then
        return;
    end

    -- get player names
    local playerNames = addon:GetService("player"):CombinePlayerNames(skill.players, ", ", 5);

    -- get icon and name of profession
    local professionNamesService = addon:GetService("profession-names");
    tooltip:AddLine("|n|T" .. professionNamesService:GetProfessionIcon(professionId) .. ":12|t  |cffDA8CFF[PM] " .. playerNames);
end

-- register service
addon:RegisterService(TooltipService, "tooltip");