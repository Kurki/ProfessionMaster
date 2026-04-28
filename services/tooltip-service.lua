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

    -- skip skills without a profession (e.g. poisons)
    if (not professionId) then
        return;
    end

    -- get player names from PM_Professions
    local professionsService = self:GetService("professions");
    local players = professionsService:GetSkillPlayers(professionId, skillId);
    local playerNames = self:GetService("player"):CombinePlayerNames(players, 5);

    -- get profession icon
    local professionNamesService = self:GetService("profession-names");
    local professionIcon = professionNamesService:GetProfessionIcon(professionId);

    -- get icon and name of profession
    tooltip:AddLine("|n|T" .. professionIcon .. ":12|t  |cffDA8CFF[PM] " .. table.concat(playerNames, ", "));
end

--- Fill tooltip.
function TooltipService:ShowTooltip(tooltip, professionId, skillId, skillMeta, players)
    -- check skill link
    if (skillMeta.skillLink) then
        tooltip:SetHyperlink(skillMeta.skillLink);
        return;
    end
    
    -- check item link
    if (skillMeta.itemLink) then
        tooltip:SetHyperlink(skillMeta.itemLink);
        return;
    end

    -- clear tooltip
    tooltip:ClearLines();
    tooltip:SetText(self:GetService("profession-names"):GetProfessionName(professionId) .. ": " .. skillMeta.name);

    -- add reagents
    self:GetTooltipReagents(skillId, function(reagents)
        -- check reagents
        if (reagents) then
            tooltip:AddLine("|cffffffff" .. SPELL_REAGENTS .. reagents);
        end

        -- add players
        local playerNames = self:GetService("player"):CombinePlayerNames(players, 5);
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

    -- count reagents
    local reagentCount = 0;
    if skillInfo.reagents then 
        for _ in pairs(skillInfo.reagents) do
            reagentCount = reagentCount + 1;
        end

        -- iterate skill reagents
        local result = {};
        for reagentItemId, reagentAmount in pairs(skillInfo.reagents) do
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
    else
        callback(nil);
    end
end

--- Show a custom recipe source tooltip on the given owner frame.
-- @param owner Frame to anchor the tooltip to.
-- @param recipe Table with name, itemColor, vendors, drops, worldDrop, quest.
function TooltipService:ShowRecipeSourceTooltip(owner, recipe)
    if (not recipe or not recipe.name) then return; end

    local localeService = self:GetService("locale");

    GameTooltip:SetOwner(owner, "ANCHOR_TOPRIGHT");
    GameTooltip:ClearLines();

    -- title line in recipe color
    local r, g, b = self:HexToRgb(recipe.itemColor or "FF1EFF00");
    GameTooltip:AddLine(recipe.name, r, g, b, true);

    -- vendors
    if (recipe.vendors and #recipe.vendors > 0) then
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine("|cffffd100" .. localeService:Get("SkillViewSoldBy") .. "|r");
        for _, vendor in ipairs(recipe.vendors) do
            local vendorName = vendor[1] or "?";
            local locationText = self:GetMapName(vendor[2]);
            if (locationText) then
                GameTooltip:AddLine("|cffffffff" .. vendorName .. " - " .. locationText .. "|r");
            else
                GameTooltip:AddLine("|cffffffff" .. vendorName .. "|r");
            end
        end
    end

    -- drops
    if (recipe.drops and #recipe.drops > 0) then
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine("|cffffd100" .. localeService:Get("SkillViewDroppedBy") .. "|r");
        for _, drop in ipairs(recipe.drops) do
            local dropName = drop[1] or "?";
            local locationText = self:GetMapName(drop[2]);
            if (locationText) then
                GameTooltip:AddLine("|cffffffff" .. dropName .. " - " .. locationText .. "|r");
            else
                GameTooltip:AddLine("|cffffffff" .. dropName .. "|r");
            end
        end
    end

    -- world drop
    if (recipe.worldDrop) then
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine("|cffffd100" .. localeService:Get("SkillViewWorldDrop") .. "|r");
    end

    -- quest
    if (recipe.quest) then
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine("|cffffd100" .. localeService:Get("SkillViewQuest") .. "|r");
    end

    GameTooltip:Show();
end

--- Convert an 8-character hex color (AARRGGBB) to normalized r, g, b values.
function TooltipService:HexToRgb(hex)
    if (not hex or #hex < 6) then return 1, 1, 1; end
    local offset = (#hex == 8) and 3 or 1;
    local r = tonumber(hex:sub(offset, offset + 1), 16) / 255;
    local g = tonumber(hex:sub(offset + 2, offset + 3), 16) / 255;
    local b = tonumber(hex:sub(offset + 4, offset + 5), 16) / 255;
    return r, g, b;
end

--- Get a map name by map ID, or nil if unknown.
function TooltipService:GetMapName(mapId)
    if (type(mapId) ~= "number") then return nil; end
    local mapInfo = C_Map.GetMapInfo(mapId);
    return mapInfo and mapInfo.name or nil;
end
