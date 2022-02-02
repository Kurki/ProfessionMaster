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

-- define model
LocalesModel = {};
LocalesModel.__index = LocalesModel;

-- Create model.
function LocalesModel:Create()
    return {
        -- define en locale
        ["en"] = {
            -- general
            ["AddonLoaded"] = "Version " .. addon.version .. " loaded. Use /pm to shouw professions.",
            ["VersionOutdated"] = "Your version is outdated. The latest version can be downloaded from https://www.curseforge.com/wow/addons/profession-master.",
            ["LanguageNotSupported"] = "Unfortunately, the language of your client is not supported by ProfessionMaster.",
            ["You"] = "You",

            -- provession view
            ["ProfessionsViewTitle"] = "Professtion Master - Overview",
            ["ProfessionsViewProfession"] = "Profession",
            ["ProfessionsViewAllProfessions"] = "All Professions",
            ["ProfessionsViewSearch"] = "Search",
            ["ProfessionsViewItem"] = "Item",
            ["ProfessionsViewEnchantment"] = "Enchantment",
            ["ProfessionsViewPlayers"] = "Players",
            ["ProfessionsViewToFavorites"] = "Add to Favorites",
            ["ProfessionsViewToShoppingList"] = "Add to Shopping List",
            ["ProfessionsViewCancel"] = "Cancel"
        },
        -- define de locale
        ["de"] = {
            -- general
            ["AddonLoaded"] = "Version " .. addon.version .. " geladen. Benutze /pm um Berufe anzuzeigen.",
            ["VersionOutdated"] = "Deine Version ist veraltet. Die neueste Version kann unter https://www.curseforge.com/wow/addons/profession-master heruntergeladen werden.",
            ["LanguageNotSupported"] = "Leider wird die Sprache deines Clients nicht von ProfessionMaster unterstützt.",
            ["You"] = "Du",

            -- provession view
            ["ProfessionsViewTitle"] = "Professtion Master - Übersicht",
            ["ProfessionsViewProfession"] = "Beruf",
            ["ProfessionsViewAllProfessions"] = "Alle Berufe",
            ["ProfessionsViewSearch"] = "Suchen",
            ["ProfessionsViewItem"] = "Gegenstand",
            ["ProfessionsViewEnchantment"] = "Verzauberung",
            ["ProfessionsViewPlayers"] = "Spieler",
            ["ProfessionsViewToFavorites"] = "Zu Favoriten hinzufügen",
            ["ProfessionsViewToShoppingList"] = "Zu Einkaufsliste hinzufügen",
            ["ProfessionsViewCancel"] = "Abbrechen"
        }
    };
end

-- register model
addon:RegisterModel(LocalesModel, "locales");
