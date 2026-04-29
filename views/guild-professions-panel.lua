--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create panel
local GuildProfessionsPanel = _G.professionMaster:CreateView("guild-professions-panel");

--- Create guild professions panel.
-- @param parentFrame The parent content frame.
-- @param professionsView Reference to the parent professions view.
function GuildProfessionsPanel:Create(parentFrame, professionsView)
    self.professionsView = professionsView;

    -- create container frame
    local frame = CreateFrame("Frame", nil, parentFrame);
    frame:SetPoint("TOPLEFT", 5, -2);
    frame:SetPoint("BOTTOMRIGHT", -5, 2);
    frame:Hide();
    self.frame = frame;

    -- create guild skill list
    self.guildSkillList = self.addon:NewView("guild-skill-list");
    self.guildSkillList:Create(frame, professionsView);
end

--- Show the panel.
function GuildProfessionsPanel:Show()
    if (self.frame) then
        self.frame:Show();
        self.guildSkillList:AddSkills();
    end
end

--- Hide the panel.
function GuildProfessionsPanel:Hide()
    if (self.frame) then
        self.frame:Hide();
    end
end

--- Refresh data.
function GuildProfessionsPanel:Refresh()
    self.guildSkillList:AddSkills();
end

--- Refresh rows after resize.
function GuildProfessionsPanel:RefreshRows()
    self.guildSkillList:RefreshRows();
    self.guildSkillList:UpdateResponsiveLayout();
end

--- Handle resize.
function GuildProfessionsPanel:OnSizeChanged()
    self.guildSkillList:OnSizeChanged();
end

--- Set right margin on the skill list.
function GuildProfessionsPanel:SetRightMargin(margin)
    self.guildSkillList:SetRightMargin(margin);
    self.guildSkillList:UpdateResponsiveLayout();
end
