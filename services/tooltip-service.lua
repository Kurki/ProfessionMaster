--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]
-- create service
local TooltipService = _G.professionMaster:CreateService("tooltip");

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

    -- check for item link (use actual tooltip, not hardcoded GameTooltip)
    local _, itemLink = tooltip:GetItem();
    if (itemLink) then
        -- find skill by item link
        skillId, skill, professionId = self:GetService("professions"):FindSkillByItemLink(itemLink);
    end

    -- check for spell id (direct lookup, works for all professions including smelting)
    if (not skill) then
        local _, spellId = tooltip:GetSpell();
        if (spellId) then
            skillId, skill, professionId = self:GetService("professions"):FindSkillByIdOrItemId(spellId, nil);
        end
    end

    -- fallback: text-based lookup via tooltip lines
    if (not skill) then
        local tooltipName = tooltip:GetName();
        if (tooltipName) then
            local text1Obj = _G[tooltipName .. "TextLeft1"];
            local text1 = text1Obj and text1Obj:GetText();
            if (text1 and string.find(text1, ":")) then
                skillId, skill, professionId = self:GetService("professions"):FindSkillByName(text1);
            end
        end
    end

    -- check if skill found
    if (not skill) then
        return;
    end

    -- get player names
    local playerNames = self:GetService("player"):CombinePlayerNames(skill.players, 5);

    -- get profession icon
    local professionNamesService = self:GetService("profession-names");
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
    tooltip:SetText(self:GetService("profession-names"):GetProfessionName(professionId) .. ": " .. skill.name);

    -- add reagents
    self:GetTooltipReagents(skillId, function(reagents)
        -- check reagents
        if (reagents) then
            tooltip:AddLine("|cffffffff" .. SPELL_REAGENTS .. reagents);
        end

        -- add players
        local playerNames = self:GetService("player"):CombinePlayerNames(skill.players, 5);
        tooltip:AddLine("|cffffffff" .. self:GetService("locale"):Get("SkillViewPlayers") .. ": " .. table.concat(playerNames, ", "));
        tooltip:Show();
    end);
end

-- Get tooltip reagents.
function TooltipService:GetTooltipReagents(skillId, callback)
    -- get skills service
    local skillsService = self:GetService("skills");

    -- get skill reagents
    local skillInfo = skillsService:GetSkillById(skillId);
    if (not skillInfo) then
        callback(nil);
        return;
    end

    -- scan inventory
    local inventoryService = self:GetService("inventory");
    inventoryService:ScanInventory();

    -- count reaegnts
    local reagentCount = 0;
    if skillInfo.reaegnts then 
        for _ in pairs(skillInfo.reaegnts) do
            reagentCount = reagentCount + 1;
        end

        -- iterate skill reagents
        local result = {};
        for reagentItemId, reagentAmount in pairs(skillInfo.reaegnts) do
            -- check if item id known
            if (C_Item.DoesItemExistByID(reagentItemId)) then
                -- get item data
                local reagentItem = Item:CreateFromItemID(reagentItemId);
                if (not reagentItem:IsItemEmpty()) then
                    pcall(function()
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
                    end);
                end
            end
        end
    end
end
