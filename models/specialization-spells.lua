--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create specialization spells model
-- maps profession SkillLine IDs to their possible specialization spell IDs
_G.professionMaster:CreateModel("specialization-spells", {
    -- Alchemy (171)
    [171] = {
        { spellId = 28675, icon = 134715 },
        { spellId = 28677, icon = 134876 },
        { spellId = 28672, icon = 134918 },
    },
    -- Blacksmithing (164)
    [164] = {
        { spellId = 9788, icon = 132739 },
        { spellId = 9787, icon = 135326 },
        { spellId = 17039, icon = 135351 },
        { spellId = 17040, icon = 133060 },
        { spellId = 17041, icon = 132396 },
    },
    -- Leatherworking (165)
    [165] = {
        { spellId = 10656, icon = 134305 },
        { spellId = 10658, icon = 135830 },
        { spellId = 10660, icon = 136069 },
    },
    -- Tailoring (197)
    [197] = {
        { spellId = 26797, icon = 135880 },
        { spellId = 26801, icon = 132888 },
        { spellId = 26798, icon = 132895 },
    },
    -- Engineering (202)
    [202] = {
        { spellId = 20219, icon = 132996 },
        { spellId = 20222, icon = 135826 },
    },
});
