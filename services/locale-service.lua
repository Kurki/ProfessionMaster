--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local LocaleService = _G.professionMaster:CreateService("locale");

--- Initialize service.
function LocaleService:Initialize()
    -- get current locale name and all locales
    local localeName = string.sub(GetLocale(), 1, 2);
    local locales = self:GetModel("locales"):Create();

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

