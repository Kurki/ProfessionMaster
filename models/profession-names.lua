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

-- define names
local ProfessionNames = {
    ["enUS"] = {
        [164] = "Blacksmithing",
        [165] = "Leatherworking",
        [171] = "Alchemy",
        [182] = "Herbalism",
        [185] = "Cooking",
        [186] = "Mining",
        [197] = "Tailoring",
        [202] = "Engineering",
        [333] = "Enchanting",
        [356] = "Fishing",
        [393] = "Skinning",
        [755] = "Jewelcrafting",
        [773] = "Inscription"
    },
    ["deDE"] = {
        [164] = "Schmiedekunst",
        [165] = "Lederverarbeitung",
        [171] = "Alchemie",
        [182] = "Kräuterkunde",
        [185] = "Kochkunst",
        [186] = "Bergbau",
        [197] = "Schneiderei",
        [202] = "Ingenieurskunst",
        [333] = "Verzauberkunst",
        [356] = "Angeln",
        [393] = "Kürschnerei",
        [755] = "Juwelenschleifen",
        [773] = "Inschriftenkunde",
    },
    ["frFR"] = {
        [164] = "Forge",
        [165] = "Travail du cuir",
        [171] = "Alchimie",
        [182] = "Herboristerie",
        [185] = "Cuisine",
        [186] = "Minage",
        [197] = "Couture",
        [202] = "Ingénierie",
        [333] = "Enchantement",
        [356] = "Pêche",
        [393] = "Dépeçage",
        [755] = "Joaillerie",
        [773] = "Calligraphie",
    },
    ["esMX"] = {
        [164] = "Herrería",
        [165] = "Peletería",
        [171] = "Alquimia",
        [182] = "Herboristería",
        [185] = "Cocina",
        [186] = "Minería",
        [197] = "Sastrería",
        [202] = "Ingeniería",
        [333] = "Encantamiento",
        [356] = "Pesca",
        [393] = "Desuello",
        [755] = "Joyería",
        [773] = "Inscripción",
    },
    ["esES"] = {
        [164] = "Herrería",
        [165] = "Peletería",
        [171] = "Alquimia",
        [182] = "Herboristería",
        [185] = "Cocina",
        [186] = "Minería",
        [197] = "Sastrería",
        [202] = "Ingeniería",
        [333] = "Encantamiento",
        [356] = "Pesca",
        [393] = "Desuello",
        [755] = "Joyería",
        [773] = "Inscripción",
    },
    ["ptBR"] = {
        [164] = "Ferraria",
        [165] = "Couraria",
        [171] = "Alquimia",
        [182] = "Herborismo",
        [185] = "Culinária",
        [186] = "Mineração",
        [197] = "Alfaiataria",
        [202] = "Engenharia",
        [333] = "Encantamento",
        [356] = "Pesca",
        [393] = "Esfolamento",
        [755] = "Joalheria",
        [773] = "Escrivania",
    },
    -- ["ruRU"] = {
    --     [164] = "Кузнечное дело",
    --     [165] = "Кожевничество",
    --     [171] = "Алхимия",
    --     [182] = "Травничество",
    --     [185] = "Кулинария",
    --     [186] = "Горное дело",
    --     [197] = "Портняжное дело",
    --     [202] = "Инженерное дело",
    --     [333] = "Наложение чар",
    --     [356] = "Рыбная ловля",
    --     [393] = "Снятие шкур",
    --     [755] = "Ювелирное дело",
    --     [773] = "Начертание",
    -- },
    ["zhCN"] = {
        [164] = "锻造",
        [165] = "制皮",
        [171] = "炼金术",
        [182] = "草药学",
        [185] = "烹饪",
        [186] = "采矿",
        [197] = "裁缝",
        [202] = "工程学",
        [333] = "附魔",
        [356] = "钓鱼",
        [393] = "剥皮",
        [755] = "珠宝加工",
        [773] = "铭文",
    },
    ["zhTW"] = {
        [164] = "鍛造",
        [165] = "製皮",
        [171] = "鍊金術",
        [182] = "草藥學",
        [185] = "烹飪",
        [186] = "採礦",
        [197] = "裁縫",
        [202] = "工程學",
        [333] = "附魔",
        [356] = "釣魚",
        [393] = "剝皮",
        [755] = "珠寶設計",
        [773] = "銘文學",
    },
    ["koKR"] = {
        [164] = "대장기술",
        [165] = "가죽세공",
        [171] = "연금술",
        [182] = "약초채집",
        [185] = "요리",
        [186] = "채광",
        [197] = "재봉술",
        [202] = "기계공학",
        [333] = "마법부여",
        [356] = "낚시",
        [393] = "무두질",
        [755] = "보석세공",
        [773] = "주문각인",
    }
};

-- register model
addon:RegisterModel(ProfessionNames, "profession-names");