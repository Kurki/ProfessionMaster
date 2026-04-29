--[[

@author Kurki
@copyright ©2026 Profession Master. All Rights Reserved.

--]]

-- create panel
local OwnProfessionsPanel = _G.professionMaster:CreateView("own-professions-panel");

--- Create own professions panel.
-- @param parentFrame The parent content frame.
-- @param professionsView Reference to the parent professions view.
function OwnProfessionsPanel:Create(parentFrame, professionsView)
    self.professionsView = professionsView;

    -- create container frame
    local frame = CreateFrame("Frame", nil, parentFrame);
    frame:SetPoint("TOPLEFT", 5, -2);
    frame:SetPoint("BOTTOMRIGHT", -5, 2);
    frame:Hide();
    self.frame = frame;

    -- create own skill list
    self.ownSkillList = self.addon:NewView("own-skill-list");
    self.ownSkillList:Create(frame, professionsView);
end

--- Show the panel.
function OwnProfessionsPanel:Show()
    if (self.frame) then
        self.frame:Show();
        self.ownSkillList:AddSkills();
    end
end

--- Hide the panel.
function OwnProfessionsPanel:Hide()
    if (self.frame) then
        self.frame:Hide();
    end
end

--- Refresh data.
function OwnProfessionsPanel:Refresh()
    self.ownSkillList:AddSkills();
end

--- Refresh rows after resize.
function OwnProfessionsPanel:RefreshRows()
    self.ownSkillList:RefreshRows();
end

--- Handle resize.
function OwnProfessionsPanel:OnSizeChanged()
    self.ownSkillList:OnSizeChanged();
end

--- Set right margin on the skill list.
function OwnProfessionsPanel:SetRightMargin(margin)
    self.ownSkillList:SetRightMargin(margin);
end
