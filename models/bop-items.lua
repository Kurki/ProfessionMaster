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

-- define items
local BopItems = {
    32581, 32587, 32575, 28438, 32570, 32478, 28442, 10725, 13503, 28439, 30037, 
    32579, 22462, 28437, 32583, 28441, 32585, 22461, 32473, 32494, 28429, 21871, 
    32461, 28440, 21870, 21848, 16207, 29525, 30039, 21869, 24128, 28428, 28485, 
    28430, 21875, 32474, 22463, 34358, 33131, 29522, 29515, 21846, 9149, 30033, 
    35750, 21847, 21873, 21874, 28435, 32573, 29519, 34364, 28433, 35702, 29523, 
    29527, 30031, 29526, 33133, 34353, 30035, 28432, 29524, 34369, 32475, 33134, 
    6339, 29521, 28427, 30043, 29516, 30041, 28484, 34847, 33135, 32472, 29517, 
    24125, 32476, 28425, 24126, 35749, 32479, 28431, 34354, 34377, 28483, 28436, 
    34360, 11145, 28434, 28426, 34356, 33143, 29520, 34359, 32495, 34375, 34357, 
    10542, 11130, 23829, 33140, 32480, 6218, 23828, 35181, 35700, 11826, 30045, 
    34365, 34373, 23839, 33144, 21756, 25881, 10645, 23838, 35751, 7054, 25883, 
    30086, 21748, 29975, 24124, 35183, 29974, 30074, 34355, 11811, 29973, 29971, 
    35184, 35703, 21758, 30077, 35185, 35748, 30088, 34371, 24127, 30071, 35694, 
    10727, 14154, 30072, 34379, 30093, 29970, 10543, 11825, 21791, 25882, 30089, 
    35182, 21784, 29964, 23565, 35693, 30087, 14153, 14152, 21769, 10545, 23564,
    21789, 10587, 30073, 30076, 25498, 21763, 21777, 25880, 11604, 12782, 23563, 
    30070, 30069, 21760, 12773
};

-- register model
addon:RegisterModel(BopItems, "bop-items");