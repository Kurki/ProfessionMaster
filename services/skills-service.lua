--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local SkillsService = _G.professionMaster:CreateService("skills");

--- Initialize service.
function SkillsService:Initialize()
    -- preapre all skills
    self.allSkills = {};
    self.allItems = {};

    -- add vanilla
    self:AddAddonSkills(1, self:GetModel('vanilla-skills'));

    -- add bcc
    if (self.addon.isBccAtLeast) then
        self:AddAddonSkills(2, self:GetModel('bcc-skills'));
    end

    -- add wrath
    if (self.addon.isWrathAtLeast) then
        self:AddAddonSkills(3, self:GetModel('wrath-skills'));
    end

    -- add cata
    if (self.addon.isCataAtLeast) then
        self:AddAddonSkills(4, self:GetModel('cata-skills'));
    end

    -- add mop
    if (self.addon.isMopAtLeast) then
        self:AddAddonSkills(5, self:GetModel('mop-skills'));
    end

    -- index skill by item id
    for skillId, skillData in pairs(self.allSkills) do
        local itemId = skillData["itemId"];
        if itemId then 
            self.allItems[itemId] = skillId; 
        end
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

--- Add addon skills to all skills.
function SkillsService:AddAddonSkills(addonNumber, addonData) 
    for addonSkillId, addonSkillData in pairs(addonData) do
        -- build skill
        local skill = {
            itemId = addonSkillData.itemId,
            reagents = addonSkillData.reagents
        };

        -- get addon
        if (self.allSkills[addonSkillId]) then
            skill.addon = self.allSkills[addonSkillId].addon;
        else
            skill.addon = addonNumber;
        end

        -- store skill
        self.allSkills[addonSkillId] = skill;
    end
end
