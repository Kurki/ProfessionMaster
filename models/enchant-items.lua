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
local EnchantItems = {
    [32667] = 22463,
    [45765] = 22449,
    [32665] = 22462,
    [28028] = 22459,
    [28019] = 22522,
    [42615] = 22448,
    [28022] = 22449,
    [28027] = 22460,
    [28016] = 22521,
    [32664] = 22461,
    [25130] = 20748,
    [25129] = 20749,
    [42613] = 22448,
    [20051] = 16207,
    [25128] = 20750,
    [15596] = 11811,
    [25127] = 20747,
    [17181] = 12810,
    [17180] = 12655,
    [13702] = 11145,
    [25126] = 20746,
    [14810] = 11290,
    [14809] = 11289,
    [13628] = 11130,
    [25125] = 20745,
    [14807] = 11288,
    [7795] = 6339,
    [14293] = 11287,
    [7421] = 6218,
    [25124] = 20744
};

-- register model
addon:RegisterModel(EnchantItems, "enchant-items");