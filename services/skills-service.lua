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
