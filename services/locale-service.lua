--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local LocaleService = _G.professionMaster:CreateService("locale");

--- Initialize service.
function LocaleService:Initialize()
    -- get current locale name and all locales
    local fullLocaleName = GetLocale();
    local shortLocaleName = string.sub(fullLocaleName, 1, 2);
    local locales = self:GetModel("locales"):Create();

    -- try full locale first (e.g. zhCN, zhTW), then short (e.g. en, de)
    if (locales[fullLocaleName]) then
        self.current = locales[fullLocaleName];
        return;
    end

    if (locales[shortLocaleName]) then
        self.current = locales[shortLocaleName];
        return;
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

