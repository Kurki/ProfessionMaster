--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

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
