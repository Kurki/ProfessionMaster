--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- define items as hash set for O(1) lookup
local BopItems = _G.professionMaster:CreateModel("bop-items", {
    [32581] = true, [32587] = true, [32575] = true, [28438] = true, [32570] = true, [32478] = true, [28442] = true, [10725] = true, [13503] = true, [28439] = true, [30037] = true, 
    [32579] = true, [22462] = true, [28437] = true, [32583] = true, [28441] = true, [32585] = true, [22461] = true, [32473] = true, [32494] = true, [28429] = true, [21871] = true, 
    [32461] = true, [28440] = true, [21870] = true, [21848] = true, [16207] = true, [29525] = true, [30039] = true, [21869] = true, [24128] = true, [28428] = true, [28485] = true, 
    [28430] = true, [21875] = true, [32474] = true, [22463] = true, [34358] = true, [33131] = true, [29522] = true, [29515] = true, [21846] = true, [9149] = true, [30033] = true, 
    [35750] = true, [21847] = true, [21873] = true, [21874] = true, [28435] = true, [32573] = true, [29519] = true, [34364] = true, [28433] = true, [35702] = true, [29523] = true, 
    [29527] = true, [30031] = true, [29526] = true, [33133] = true, [34353] = true, [30035] = true, [28432] = true, [29524] = true, [34369] = true, [32475] = true, [33134] = true, 
    [6339] = true, [29521] = true, [28427] = true, [30043] = true, [29516] = true, [30041] = true, [28484] = true, [34847] = true, [33135] = true, [32472] = true, [29517] = true, 
    [24125] = true, [32476] = true, [28425] = true, [24126] = true, [35749] = true, [32479] = true, [28431] = true, [34354] = true, [34377] = true, [28483] = true, [28436] = true, 
    [34360] = true, [11145] = true, [28434] = true, [28426] = true, [34356] = true, [33143] = true, [29520] = true, [34359] = true, [32495] = true, [34375] = true, [34357] = true, 
    [10542] = true, [11130] = true, [23829] = true, [33140] = true, [32480] = true, [6218] = true, [23828] = true, [35181] = true, [35700] = true, [11826] = true, [30045] = true, 
    [34365] = true, [34373] = true, [23839] = true, [33144] = true, [21756] = true, [25881] = true, [10645] = true, [23838] = true, [35751] = true, [7054] = true, [25883] = true, 
    [30086] = true, [21748] = true, [29975] = true, [24124] = true, [35183] = true, [29974] = true, [30074] = true, [34355] = true, [11811] = true, [29973] = true, [29971] = true, 
    [35184] = true, [35703] = true, [21758] = true, [30077] = true, [35185] = true, [35748] = true, [30088] = true, [34371] = true, [24127] = true, [30071] = true, [35694] = true, 
    [10727] = true, [14154] = true, [30072] = true, [34379] = true, [30093] = true, [29970] = true, [10543] = true, [11825] = true, [21791] = true, [25882] = true, [30089] = true, 
    [35182] = true, [21784] = true, [29964] = true, [23565] = true, [35693] = true, [30087] = true, [14153] = true, [14152] = true, [21769] = true, [10545] = true, [23564] = true,
    [21789] = true, [10587] = true, [30073] = true, [30076] = true, [25498] = true, [21763] = true, [21777] = true, [25880] = true, [11604] = true, [12782] = true, [23563] = true, 
    [30070] = true, [30069] = true, [21760] = true, [12773] = true
});