--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local SkillsService = _G.professionMaster:CreateService("skills");

-- skill cache version (bump when static skill data or cache structure changes)
local SKILL_CACHE_VERSION = 14;

--- Initialize service.
function SkillsService:Initialize()
    -- check if skill cache needs rebuilding
    self.cacheRebuilt = (not PM_Settings.skillCacheVersion) or (PM_Settings.skillCacheVersion < SKILL_CACHE_VERSION) or (not PM_Skills) or (not next(PM_Skills));

    if (self.cacheRebuilt) then
        -- notify player
        local chatService = self:GetService("chat");
        chatService:Write("SkillCacheUpdating");

        -- reset and rebuild skill cache from scratch
        PM_Skills = {};
        self:BuildCache();
        PM_Settings.skillCacheVersion = SKILL_CACHE_VERSION;

        -- count cached skills and notify player
        local skillCount = 0;
        for _ in pairs(PM_Skills) do
            skillCount = skillCount + 1;
        end
        chatService:Write("SkillCacheUpdated", skillCount);
    end

    -- allSkills always references PM_Skills
    self.allSkills = PM_Skills;

    -- build reverse index
    self.allItems = {};
    self.allRecipes = {};
    for skillId, skillData in pairs(self.allSkills) do
        local itemId = skillData.itemId;
        if (itemId and itemId ~= 0) then
            self.allItems[itemId] = skillId;
        end
        if (skillData.recipes) then
            for _, recipe in ipairs(skillData.recipes) do
                if (recipe.itemId) then
                    self.allRecipes[recipe.itemId] = skillId;
                end
            end
        end
    end

    -- free source model data to allow garbage collection
    self:FreeSkillModels();
end

--- Build PM_Skills cache from source data files and existing PM_Professions entries.
function SkillsService:BuildCache()
    local professionNamesService = self:GetService("profession-names");
    local bopItems = self:GetModel("bop-items");

    -- load from source data files into temporary table
    local sourceSkills = {};
    self:MergeSourceSkills(sourceSkills, 1, self:GetModel('vanilla-skills'));

    if (self.addon.isBccAtLeast) then
        self:MergeSourceSkills(sourceSkills, 2, self:GetModel('bcc-skills'));
    end

    if (self.addon.isWrathAtLeast) then
        self:MergeSourceSkills(sourceSkills, 3, self:GetModel('wrath-skills'));
    end

    if (self.addon.isCataAtLeast) then
        self:MergeSourceSkills(sourceSkills, 4, self:GetModel('cata-skills'));
    end

    if (self.addon.isMopAtLeast) then
        self:MergeSourceSkills(sourceSkills, 5, self:GetModel('mop-skills'));
    end

    -- merge per-expansion recipe source models (later expansions override earlier)
    local mergedRecipeSources = {};
    self:MergeRecipeSources(mergedRecipeSources, self:GetModel('recipe-sources-vanilla'));

    if (self.addon.isBccAtLeast) then
        self:MergeRecipeSources(mergedRecipeSources, self:GetModel('recipe-sources-bcc'));
    end

    if (self.addon.isWrathAtLeast) then
        self:MergeRecipeSources(mergedRecipeSources, self:GetModel('recipe-sources-wrath'));
    end

    if (self.addon.isCataAtLeast) then
        self:MergeRecipeSources(mergedRecipeSources, self:GetModel('recipe-sources-cata'));
    end

    if (self.addon.isMopAtLeast) then
        self:MergeRecipeSources(mergedRecipeSources, self:GetModel('recipe-sources-mop'));
    end

    self.recipeSources = mergedRecipeSources;

    -- merge per-expansion NPC name lookup models
    local mergedNpcNames = {};
    self:MergeRecipeSources(mergedNpcNames, self:GetModel('npc-names-vanilla'));

    if (self.addon.isBccAtLeast) then
        self:MergeRecipeSources(mergedNpcNames, self:GetModel('npc-names-bcc'));
    end

    if (self.addon.isWrathAtLeast) then
        self:MergeRecipeSources(mergedNpcNames, self:GetModel('npc-names-wrath'));
    end

    if (self.addon.isCataAtLeast) then
        self:MergeRecipeSources(mergedNpcNames, self:GetModel('npc-names-cata'));
    end

    if (self.addon.isMopAtLeast) then
        self:MergeRecipeSources(mergedNpcNames, self:GetModel('npc-names-mop'));
    end

    self.npcNames = mergedNpcNames;

    -- merge per-expansion zone name lookup models
    local mergedZoneNames = {};
    self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-vanilla'));

    if (self.addon.isBccAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-bcc'));
    end

    if (self.addon.isWrathAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-wrath'));
    end

    if (self.addon.isCataAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-cata'));
    end

    if (self.addon.isMopAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-mop'));
    end

    self.zoneNames = mergedZoneNames;

    -- merge per-expansion zone name lookup models
    local mergedZoneNames = {};
    self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-vanilla'));

    if (self.addon.isBccAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-bcc'));
    end

    if (self.addon.isWrathAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-wrath'));
    end

    if (self.addon.isCataAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-cata'));
    end

    if (self.addon.isMopAtLeast) then
        self:MergeRecipeSources(mergedZoneNames, self:GetModel('zone-names-mop'));
    end

    self.zoneNames = mergedZoneNames;

    -- build PM_Skills from source data
    for skillId, skillInfo in pairs(sourceSkills) do
        self:LoadSkillIntoCache(skillId, skillInfo.itemId, skillInfo.professionId, professionNamesService, bopItems);

        -- store recipe data in PM_Skills for future cache-based loading
        local entry = PM_Skills[skillId];
        if (entry) then
            entry.reagents = skillInfo.reagents;
            entry.itemAmount = skillInfo.itemAmount;
            entry.addon = skillInfo.addon;
            entry.addonIds = skillInfo.addonIds;
            entry.difficulty = skillInfo.difficulty;
            if (skillInfo.recipeItemIds and #skillInfo.recipeItemIds > 0) then
                entry.recipes = {};
                for _, recipeItemId in ipairs(skillInfo.recipeItemIds) do
                    local recipe = self:LoadRecipeItemData(recipeItemId, professionNamesService);
                    self:LoadRecipeSourceData(recipe, recipeItemId);
                    table.insert(entry.recipes, recipe);
                end
            end
        end
    end

    -- also build from existing PM_Professions entries (for skills not in source data)
    if (PM_Professions) then
        for professionId, profession in pairs(PM_Professions) do
            for skillId, skill in pairs(profession) do
                if (not PM_Skills[skillId]) then
                    local itemId = skill.itemId or 0;
                    self:LoadSkillIntoCache(skillId, itemId, professionId, professionNamesService, bopItems);
                end
            end
        end
    end
end

--- Merge recipe source data from a per-expansion model into the target table.
--- Later expansions override earlier entries for the same item.
function SkillsService:MergeRecipeSources(targetTable, expansionSources)
    if (not expansionSources) then return; end
    for recipeItemId, sourceData in pairs(expansionSources) do
        targetTable[recipeItemId] = sourceData;
    end
end

--- Merge source skill data from an addon into the target table.
function SkillsService:MergeSourceSkills(targetTable, addonNumber, addonData)
    for skillId, skillData in pairs(addonData) do
        -- normalize recipe item IDs to array
        local newRecipeItemIds = {};
        if (type(skillData.r) == "number") then
            newRecipeItemIds = {skillData.r};
        elseif (type(skillData.r) == "table") then
            newRecipeItemIds = skillData.r;
        end

        local skill = {
            itemId = skillData.itemId,
            itemAmount = skillData.itemAmount,
            reagents = skillData.reagents,
            professionId = skillData.p,
            difficulty = skillData.d,
            recipeItemIds = newRecipeItemIds
        };

        if (targetTable[skillId]) then
            skill.addon = targetTable[skillId].addon;
            skill.addonIds = targetTable[skillId].addonIds or {targetTable[skillId].addon};
            -- accumulate recipe IDs from previous expansions
            local previousRecipeItemIds = targetTable[skillId].recipeItemIds or {};
            skill.recipeItemIds = previousRecipeItemIds;

            -- check for new recipe IDs not seen in earlier expansions
            local hasNewRecipe = false;
            for _, newId in ipairs(newRecipeItemIds) do
                local found = false;
                for _, existingId in ipairs(skill.recipeItemIds) do
                    if (existingId == newId) then
                        found = true;
                        break;
                    end
                end
                if (not found) then
                    hasNewRecipe = true;
                    table.insert(skill.recipeItemIds, newId);
                end
            end

            -- if new recipes appeared in this expansion, mark it as relevant
            if (hasNewRecipe) then
                table.insert(skill.addonIds, addonNumber);
            end
        else
            skill.addon = addonNumber;
            skill.addonIds = {addonNumber};
        end

        targetTable[skillId] = skill;
    end
end

--- Load a single skill into PM_Skills cache.
function SkillsService:LoadSkillIntoCache(skillId, itemId, professionId, professionNamesService, bopItems)
    -- check if already cached
    if (PM_Skills[skillId]) then
        return;
    end

    -- create cache entry
    local entry = {
        name = nil,
        skillLink = nil,
        itemId = itemId or 0,
        itemLink = nil,
        itemColor = nil,
        icon = nil,
        bop = false,
        professionId = professionId,
        classId = nil,
        subclassId = nil,
        equipLoc = nil
    };
    PM_Skills[skillId] = entry;

    -- handle enchantment spells (profession 333) without an item result
    if (professionId == 333 and (not itemId or itemId == 0)) then
        local spellName, _, spellIcon = GetSpellInfo(skillId);
        if (spellName) then
            entry.name = spellName;
            entry.icon = spellIcon;
            entry.itemColor = "FF71D5FF";
            entry.equipLoc = self:GetEnchantEquipLoc(spellName);
            entry.enchantCategory = self:GetEnchantCategory(spellName);
            if (self.addon.isVanilla) then
                entry.skillLink = "|cFF71D5FF|Henchant:" .. skillId .. "|h[" .. spellName .. "]|h|r";
            else
                entry.skillLink = GetSpellLink(skillId);
            end
        end
        return;
    end

    -- handle item-based skills
    if (itemId and itemId ~= 0 and type(itemId) == "number") then
        -- check bop
        entry.bop = bopItems[itemId] or false;

        -- load item data asynchronously
        if (C_Item.DoesItemExistByID(itemId)) then
            local item = Item:CreateFromItemID(itemId);
            if (not item:IsItemEmpty()) then
                pcall(function()
                    item:ContinueOnItemLoad(function()
                        local itemName = item:GetItemName();
                        local itemLink = item:GetItemLink();
                        entry.itemLink = itemLink;
                        entry.itemColor = professionNamesService:GetItemColor(itemLink);
                        entry.icon = item:GetItemIcon();
                        if (not entry.name) then
                            entry.name = itemName;
                        end
                        if (not entry.skillLink and professionId) then
                            entry.skillLink = professionNamesService:GetSkillLink(professionId, skillId, itemName);
                        end

                        -- store item classification for filtering
                        local _, _, _, itemEquipLoc, _, classID, subclassID = GetItemInfoInstant(itemId);
                        entry.classId = classID;
                        entry.subclassId = subclassID;
                        entry.equipLoc = itemEquipLoc or nil;
                    end);
                end);
            end
        end
    end
end

--- Load recipe item data (name, link, color) into a cache entry.
--- Load recipe item data and return a recipe table.
function SkillsService:LoadRecipeItemData(recipeItemId, professionNamesService)
    local recipe = {
        itemId = recipeItemId,
        name = nil,
        itemLink = nil,
        itemColor = nil
    };

    if (C_Item.DoesItemExistByID(recipeItemId)) then
        local item = Item:CreateFromItemID(recipeItemId);
        if (not item:IsItemEmpty()) then
            pcall(function()
                item:ContinueOnItemLoad(function()
                    recipe.name = item:GetItemName();
                    recipe.itemLink = item:GetItemLink();
                    recipe.itemColor = professionNamesService:GetItemColor(item:GetItemLink());
                end);
            end);
        end
    end

    return recipe;
end

--- Load recipe source data into a recipe table.
--- Format: {vendors = {{name, zone, side}}, drops = {{name, zone}}, worldDrop = bool, quest = bool}
function SkillsService:LoadRecipeSourceData(recipe, recipeItemId)
    if (not self.recipeSources or not recipe) then return; end

    local sourceData = self.recipeSources[recipeItemId];
    if (not sourceData) then return; end

    recipe.vendors = sourceData.vendors;
    recipe.drops = sourceData.drops;
    recipe.worldDrop = sourceData.worldDrop;
    recipe.quest = sourceData.quest;
end

--- Determine equip location for an enchantment based on spell name patterns.
function SkillsService:GetEnchantEquipLoc(spellName)
    if (not spellName) then return nil; end
    local name = string.lower(spellName);

    if (string.find(name, "bracer") or string.find(name, "wrist")) then return "INVTYPE_WRIST"; end
    if (string.find(name, "chest") or string.find(name, "torso")) then return "INVTYPE_CHEST"; end
    if (string.find(name, "cloak") or string.find(name, "back")) then return "INVTYPE_CLOAK"; end
    if (string.find(name, "boots") or string.find(name, "feet") or string.find(name, "speed")) then return "INVTYPE_FEET"; end
    if (string.find(name, "gloves") or string.find(name, "hands") or string.find(name, "glove")) then return "INVTYPE_HAND"; end
    if (string.find(name, "shield")) then return "INVTYPE_SHIELD"; end
    if (string.find(name, "2h weapon") or string.find(name, "two%-hand")) then return "INVTYPE_2HWEAPON"; end
    if (string.find(name, "weapon") or string.find(name, "striking") or string.find(name, "fiery") or string.find(name, "lifestealing") or string.find(name, "crusader") or string.find(name, "mongoose") or string.find(name, "berserking") or string.find(name, "executioner") or string.find(name, "blade")) then return "INVTYPE_WEAPON"; end
    if (string.find(name, "head") or string.find(name, "helm")) then return "INVTYPE_HEAD"; end
    if (string.find(name, "shoulder")) then return "INVTYPE_SHOULDER"; end
    if (string.find(name, "legs") or string.find(name, "leg")) then return "INVTYPE_LEGS"; end
    if (string.find(name, "ring")) then return "INVTYPE_FINGER"; end

    return nil;
end

--- Extract enchantment category from spell name (text before first " - ").
-- e.g. "Enchant Weapon - Fiery Weapon" -> "Enchant Weapon"
function SkillsService:GetEnchantCategory(spellName)
    if (not spellName) then return nil; end
    local dashPos = string.find(spellName, " %- ", 1, false);
    if (dashPos) then
        return string.sub(spellName, 1, dashPos - 1);
    end
    return spellName;
end

--- Ensure a skill exists in the cache, creating it if necessary.
function SkillsService:EnsureSkillCached(skillId, itemId, professionId)
    if (self.allSkills[skillId]) then
        return;
    end

    local professionNamesService = self:GetService("profession-names");
    local bopItems = self:GetModel("bop-items");
    self:LoadSkillIntoCache(skillId, itemId or 0, professionId, professionNamesService, bopItems);

    -- update reverse index
    local entry = self.allSkills[skillId];
    if (entry and entry.itemId and entry.itemId ~= 0) then
        self.allItems[entry.itemId] = skillId;
    end
end

--- Get skill by id.
function SkillsService:GetSkillById(skillId)
   return self.allSkills[skillId];
end

--- Get skill id by item id.
function SkillsService:GetSkillIdByItemId(itemId)
   return self.allItems[itemId];
end

--- Get skill id by recipe item id.
function SkillsService:GetSkillIdByRecipeItemId(recipeItemId)
   return self.allRecipes[recipeItemId];
end

--- Free skill model data references so Lua garbage collector can reclaim source file tables.
function SkillsService:FreeSkillModels()
    local modelTypes = self.addon.modelTypes;
    modelTypes["vanilla-skills"] = nil;
    modelTypes["bcc-skills"] = nil;
    modelTypes["wrath-skills"] = nil;
    modelTypes["cata-skills"] = nil;
    modelTypes["mop-skills"] = nil;
    modelTypes["recipe-sources-vanilla"] = nil;
    modelTypes["recipe-sources-bcc"] = nil;
    modelTypes["recipe-sources-wrath"] = nil;
    modelTypes["recipe-sources-cata"] = nil;
    modelTypes["recipe-sources-mop"] = nil;
    modelTypes["npc-names-vanilla"] = nil;
    modelTypes["npc-names-bcc"] = nil;
    modelTypes["npc-names-wrath"] = nil;
    modelTypes["npc-names-cata"] = nil;
    modelTypes["npc-names-mop"] = nil;
    modelTypes["zone-names-vanilla"] = nil;
    modelTypes["zone-names-bcc"] = nil;
    modelTypes["zone-names-wrath"] = nil;
    modelTypes["zone-names-cata"] = nil;
    modelTypes["zone-names-mop"] = nil;
    self.recipeSources = nil;
end
