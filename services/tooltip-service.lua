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
    local skillId, skill, professionId = nil;

    -- check for item link
    local _, itemLink = GameTooltip:GetItem();
    if (itemLink) then
        -- find skill by item link
        skillId, skill, professionId = addon:GetService("professions"):FindSkillByItemLink(itemLink);
    end

    -- check if skill not found yet
    if (not skill) then
        -- check if small text is reagents
        local text1 = GameTooltipTextLeft1:GetText();
        local text2 = GameTooltipTextLeft2:GetText();
        local text3 = GameTooltipTextLeft3:GetText();
        if (text1 and (text2 and string.find(text2, SPELL_REAGENTS) == 1 or text3 and string.find(text3, SPELL_REAGENTS) == 1)) then
            -- find skill by name
            skillId, skill, professionId = addon:GetService("professions"):FindSkillByName(text1);
        end
    end

    -- check if skill found
    if (not skill) then
        return;
    end

    -- get player names
    local playerNames = addon:GetService("player"):CombinePlayerNames(skill.players, 5);

    -- get profession icon
    local professionNamesService = addon:GetService("profession-names");
    local professionIcon = professionNamesService:GetProfessionIcon(professionId);

    -- get icon and name of profession
    tooltip:AddLine("|n|T" .. professionIcon .. ":12|t  |cffDA8CFF[PM] " .. table.concat(playerNames, ", "));
end

--- Fill tooltip.
function TooltipService:ShowTooltip(tooltip, professionId, skillId, skill)
    -- check skill link
    if (skill.skillLink) then
        tooltip:SetHyperlink(skill.skillLink);
        return;
    end
    
    -- check item link
    if (skill.itemLink) then
        tooltip:SetHyperlink(skill.itemLink);
        return;
    end

    -- clear tooltip
    tooltip:ClearLines();
    tooltip:SetText(addon:GetService("profession-names"):GetProfessionName(professionId) .. ": " .. skill.name);

    -- add reagents
    self:GetTooltipReagents(skillId, function(reagents)
        -- check reagents
        if (reagents) then
            tooltip:AddLine("|cffffffff" .. SPELL_REAGENTS .. reagents);
        end

        -- add players
        local playerNames = addon:GetService("player"):CombinePlayerNames(skill.players, 5);
        tooltip:AddLine("|cffffffff" .. addon:GetService("locale"):Get("SkillViewPlayers") .. ": " .. table.concat(playerNames, ", "));
        tooltip:Show();
    end);
end

-- Get tooltip reagents.
function TooltipService:GetTooltipReagents(skillId, callback)
    -- get skill reagents
    local skillInfo = addon:GetModel("all-skills")[skillId];
    if (not skillInfo) then
        callback(nil);
        return;
    end

    -- scan inventory
    local inventoryService = addon:GetService("inventory");
    inventoryService:ScanInventory();

    -- count reaegnts
    local reagentCount = 0;
    for _ in pairs(skillInfo.reaegnts) do
        reagentCount = reagentCount + 1;
    end

    -- iterate skill reagents
    local result = {};
    for reagentItemId, reagentAmount in pairs(skillInfo.reaegnts) do
        -- get item data
        local reagentItem = Item:CreateFromItemID(reagentItemId);
        if (not reagentItem:IsItemEmpty()) then
            -- wait until loaded
            reagentItem:ContinueOnItemLoad(function()
                -- prepare reagent text
                local reagentText = "";

                -- check if inventory amount is not high enough
                local lowStocks = (inventoryService.inventory[reagentItemId] or 0) < reagentAmount;
                if (lowStocks) then
                    reagentText = "|cFFFF0000";
                end

                -- add reagent name
                reagentText = reagentText .. reagentItem:GetItemName();

                -- add reagent amount
                if (reagentAmount > 1) then
                    reagentText = reagentText .. " (" .. reagentAmount .. ")";
                end

                -- reset color
                if (lowStocks) then
                    reagentText = reagentText .. "|r";
                end

                -- add regent text
                table.insert(result, reagentText);
                if (#result >= reagentCount) then
                    callback(table.concat(result, ", "));
                end
            end);
        end
    end
end

-- register service
addon:RegisterService(TooltipService, "tooltip");