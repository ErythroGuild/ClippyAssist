local frame = CreateFrame("Frame", "ClippyFrame", UIParent)
frame:SetSize(124, 93)
frame:SetPoint("CENTER")
frame:SetFrameStrata("HIGH")

local texture = frame:CreateTexture("tex_anima", "OVERLAY")
frame.tex_anims = texture
texture:SetTexture("Interface/AddOns/ClippyAssist/rc/GetAttention.tga")
texture:SetAllPoints("ClippyFrame")
frame:SetScript("OnUpdate", function(self, elapsed)
	AnimateTexCoords(self.tex_anims, 1024, 512, 124, 93, 24, elapsed, 0.1)
end)

frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

frame:Show()
