local addOn, E = ...
local L = E.L

local chatframe = E:Module("ChatFrames")


--[[ Start popup creation ]]--
local frame = CreateFrame("Frame", nil, E.UIParent)

frame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = [[Interface\Buttons\WHITE8x8]],
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom =0}
    })
frame:SetBackdropColor(0 , 0 , 0 , 0.7) --цвет фона
frame:SetBackdropBorderColor(0 , 0 , 0 , 1) --цвет фона

frame:SetSize(650, 40)
frame:SetPoint("CENTER", E.UIParent, "CENTER")
frame:SetFrameStrata("DIALOG")
frame:Hide()

local editBox = CreateFrame("EditBox", nil, frame)
editBox:SetFontObject(ChatFontNormal)
editBox:SetSize(610, 40)
editBox:SetPoint("LEFT", frame, "LEFT", 10, 0)
local hide = function(f) f:GetParent():Hide() end
editBox:SetScript("OnEscapePressed", hide)

local close_ = CreateFrame("Button", nil, frame)
close_:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
close_:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
close_:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
close_:SetSize(32, 32)
close_:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
close_:SetScript("OnClick", hide)
--[[ End popup creation ]]--

-- Avoiding StaticPopup taints by making our own popup, rather that adding to the StaticPopup list
function chatframe:Popup(text)
    editBox:SetText(text)
    editBox:HighlightText(0)
    editBox:GetParent():Show()
end