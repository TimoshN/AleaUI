local addOn, E = ...
local L = E.L

local bubbles = E:Module("ChatBubbles")

local step = 0.08
local select = select
local pairs = pairs
local find = string.find
local strlower = string.lower

local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

local skinBubbles = function(frame)
    for i=1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        
        if region:GetObjectType() == "Texture" then
            region:SetAlpha(0)
        elseif region:GetObjectType() == "FontString" then
            region:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
            
            frame.text = region
        end
    end
    
    frame:SetBackdrop({
        bgFile = 'Interface\\Buttons\\WHITE8x8', 
        edgeFile ='Interface\\Buttons\\WHITE8x8', 
        tile = false, tileSize = 0, edgeSize = E.UIParent:GetScale(), 
        insets = { left = 0, right = 0, top = 0, bottom = 0}
    })	
    
    frame:SetBackdropColor(0,0,0,0.8)
    frame:SetBackdropBorderColor(frame.text:GetTextColor())
    
    frame:HookScript("OnShow", function(self)
        self:SetBackdropBorderColor(self.text:GetTextColor())
    end)
    
    frame.isSkinnedAleaUI = true
    frame.isBubble = true
    frame.isTransparentBubble = true
end

local function LoadChatBubbles()
    bubbles.elapsed = -2
    
    bubbles:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed < 0.1 then return end
        
        local t = C_ChatBubbles.GetAllChatBubbles()
        
        for i=1, #t do
            if not t[i].isSkinnedAleaUI then
                skinBubbles(t[i])
            end
        end
    end)
end

E:OnInit2(LoadChatBubbles)