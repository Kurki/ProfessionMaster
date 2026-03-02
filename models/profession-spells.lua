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

-- SkillLine ID -> base Spell ID mapping (used to get localized names via GetSpellInfo)
local ProfessionSpells = _G.professionMaster:CreateModel("profession-spells", {
    [164] = 2018,   -- Blacksmithing
    [165] = 2108,   -- Leatherworking
    [171] = 2259,   -- Alchemy
    [182] = 2366,   -- Herbalism
    [185] = 2550,   -- Cooking
    [186] = 2575,   -- Mining
    [197] = 3908,   -- Tailoring
    [202] = 4036,   -- Engineering
    [333] = 7411,   -- Enchanting
    [356] = 7620,   -- Fishing
    [393] = 8613,   -- Skinning
    [755] = 25229,  -- Jewelcrafting
    [773] = 45357,  -- Inscription
});
