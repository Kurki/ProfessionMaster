--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create specialization spells model
-- maps profession SkillLine IDs to their possible specialization spell IDs
-- matchClassId/matchSubclassIds: item classification criteria to determine which skills benefit from a specialization
_G.professionMaster:CreateModel("specialization-spells", {
    -- Alchemy (171)
    [171] = {
        { spellId = 28675, icon = 134715, matchClassId = 0, matchSubclassIds = {2, 3} },       -- Elixir Master (Elixirs + Flasks)
        { spellId = 28677, icon = 134876, matchClassId = 0, matchSubclassIds = {1} },          -- Potion Master (Potions)
        { spellId = 28672, icon = 134918, matchClassId = 7 },                                   -- Transmutation Master (Trade Goods)
    },
    -- Blacksmithing (164)
    [164] = {
        { spellId = 9788, icon = 132739, matchClassId = 4 },                                    -- Armorsmith (Armor)
        { spellId = 9787, icon = 135326, matchClassId = 2 },                                    -- Weaponsmith (Weapons)
        { spellId = 17039, icon = 135351, matchClassId = 2, matchSubclassIds = {7, 15} },       -- Swordsmith (1H + 2H Swords)
        { spellId = 17040, icon = 133060, matchClassId = 2, matchSubclassIds = {0, 1} },        -- Axesmith (1H + 2H Axes)
        { spellId = 17041, icon = 132396, matchClassId = 2, matchSubclassIds = {4, 5} },        -- Macesmith (1H + 2H Maces)
    },
    -- Leatherworking (165)
    [165] = {
        { spellId = 10656, icon = 134305, matchClassId = 4, matchSubclassIds = {3} },           -- Dragonscale (Mail)
        { spellId = 10658, icon = 135830, matchClassId = 4, matchSubclassIds = {2} },           -- Elemental (Leather)
        { spellId = 10660, icon = 136069, matchClassId = 4, matchSubclassIds = {2} },           -- Tribal (Leather)
    },
    -- Tailoring (197)
    [197] = {
        { spellId = 26797, icon = 135880 },     -- Shadoweave
        { spellId = 26801, icon = 132888 },     -- Spellfire
        { spellId = 26798, icon = 132895 },     -- Mooncloth
    },
    -- Engineering (202)
    [202] = {
        { spellId = 20219, icon = 132996 },     -- Gnomish
        { spellId = 20222, icon = 135826 },     -- Goblin
    },
});
