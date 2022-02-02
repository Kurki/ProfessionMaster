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
LocaleService = {};
LocaleService.__index = LocaleService;

--- Initialize service.
function LocaleService:Initialize()
    -- get current locale name and all locales
    local localeName = string.sub(GetLocale(), 1, 2);
    local locales = addon:GetModel("locales"):Create();

    -- fund locale
    for k, v in pairs(locales) do
        if (k == localeName) then
            -- store current locale
            self.current = v;
            return;
        end
    end

    -- use enUS locale
    self.current = locales["en"];
end

-- Get value.
function LocaleService:Get(name, ...)
    return string.format(self.current[name], ...);
end

-- Get bare value.
function LocaleService:GetBare(name)
    return self.current[name];
end

-- register service
addon:RegisterService(LocaleService, "locale");
