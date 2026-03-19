--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create specialization spells model
-- maps profession SkillLine IDs to their possible specialization spell IDs
_G.professionMaster:CreateModel("specialization-spells", {
    -- Alchemy (171)
    [171] = {
        { spellId = 28675 },
        { spellId = 28677 },
        { spellId = 28672 },
    },
    -- Blacksmithing (164)
    [164] = {
        { spellId = 9788 },
        { spellId = 9787 },
        { spellId = 17039 },
        { spellId = 17040 },
        { spellId = 17041 },
    },
    -- Leatherworking (165)
    [165] = {
        { spellId = 10656 },
        { spellId = 10658 },
        { spellId = 10660 },
    },
    -- Tailoring (197)
    [197] = {
        { spellId = 26797 },
        { spellId = 26801 },
        { spellId = 26798 },
    },
    -- Engineering (202)
    [202] = {
        { spellId = 20219 },
        { spellId = 20222 },
    },
});
