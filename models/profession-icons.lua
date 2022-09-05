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

-- define icons
local ProfessionIcons = {
    [164] = 136241,
    [165] = 133611,
    [171] = 136240,
    [182] = 136065,
    [185] = 133971,
    [186] = 136248,
    [197] = 136249,
    [202] = 136243,
    [333] = 136244,
    [356] = 136245,
    [393] = 134366,
    [755] = 134071,
    [773] = 237171
};

-- register model
addon:RegisterModel(ProfessionIcons, "profession-icons");