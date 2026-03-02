--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create service
local CommandsService = _G.professionMaster:CreateService("commands");

--- Initialize service.
function CommandsService:Initialize()
    -- register slash command
    local service = self;
    SLASH_ProfessionMaster1 = "/pm";
    SlashCmdList["ProfessionMaster"] = function(parameters)
        service:HandleCommand(parameters);
    end;
end

--- Handle command line.
function CommandsService:HandleCommand(parameters)
    -- check if no parameters entered
    if (string.len(parameters) <= 0 and not self.addon.inCombat) then
        -- show / hide overview
        self.addon.professionsView:ToggleVisibility();
        return;
    end

    -- check if overview should be shown
    if (string.lower(parameters) == "overview" and not self.addon.inCombat) then
        -- show / hide overview
        self.addon.professionsView:ToggleVisibility();
        return;
    end

    -- check if help should be shown
    if (string.lower(parameters) == "help") then
        -- write help
        local chatService = self:GetService("chat");
        chatService:Write("CommandsTitle");
        chatService:Write("CommandsOverview");
        chatService:Write("CommandsReagents");
        if (PMSettings.minimapButton.hide) then
            chatService:Write("CommandsMinimap");
        end
        chatService:Write("CommandsPurge");
        return;
    end

    -- check if overview shoulkd be shown
    if (string.lower(parameters) == "test") then
        self:GetService("own-professions"):StoreAndSendOwnProfession(171, {
            {
                skillId = 17187,
                itemId = 12360,
                added = time()
            }
        });
        return;
    end

    -- check if overview shoulkd be shown
    if (string.lower(parameters) == "convert") then
        self:GetService("professions"):Convert();
        return;
    end

    -- check if overview shoulkd be shown
    if (string.lower(parameters) == "reagents") then
        self:GetService("inventory"):ToggleMissingReagents();
        return;
    end

    -- check if minimap should be toggeled
    if (string.lower(parameters) == "minimap") then
        LibStub("LibDBIcon-1.0"):Show("ProfessionMaster");
        PMSettings.minimapButton.hide = false;
        return;
    end

    -- check if purge information must be shown
    if (string.lower(parameters) == "purge") then
        local chatService = self:GetService("chat");
        chatService:Write("CommandsPurgeRow1");
        chatService:Write("CommandsPurgeRow2");
        chatService:Write("CommandsPurgeRow3");
        chatService:Write("CommandsPurgeRow4");
        return;
    end

    --check if data msut be purged
    if (string.find(parameters, "purge") == 1 and string.len(parameters) > 6) then
        self:GetService("purge"):Purge(string.sub(parameters, 7));
    end

    -- check if history should be shown
    if (string.lower(parameters) == "debug") then
        self.addon:ToggleDebug();
        return;
    end

    -- check if history should be shown
    if (string.lower(parameters) == "trace") then
        self.addon:ToggleTrace();
    end
end