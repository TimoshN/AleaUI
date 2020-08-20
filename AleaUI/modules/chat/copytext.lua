local addOn, E = ...
local L = E.L

local chatframe = E:Module("ChatFrames")


local copy_w, copy_h = 500, 300
    
local backdrop = {
    bgFile = [[Interface\Buttons\WHITE8x8]], 
    edgeFile = [[Interface\Buttons\WHITE8x8]], 
    edgeSize = 1, 
}

local copyframe = CreateFrame("Frame", "AleaUIChatHistoryFrame", E.UIParent, BackdropTemplateMixin and 'BackdropTemplate')
copyframe:SetPoint("CENTER")
copyframe:SetSize(copy_w, copy_h)
copyframe:SetFrameLevel(15)

local f = CreateFrame("Frame", nil, copyframe)
f:SetPoint('CENTER', copyframe, 'CENTER', 0, 0)
f:SetSize(copy_w, copy_h)
f:SetFrameLevel(copyframe:GetFrameLevel() + 3)

--	tinsert(UISpecialFrames, "AleaUIChatHistoryFrame")

copyframe.Scroll = CreateFrame("ScrollFrame", "AleaUIChatScrollFrame", copyframe, "UIPanelScrollFrameTemplate")
copyframe.Scroll.ScrollBar:SetParent(f)

copyframe.Scroll.ScrollBar:SetScript('OnValueChanged', function(self, value)
    copyframe.Scroll:SetVerticalScroll(value);
end)

copyframe.Scroll:SetFrameLevel(copyframe:GetFrameLevel() + 1)
copyframe.Scroll:SetSize(copy_w, copy_h)
copyframe.Scroll:SetPoint("TOPRIGHT", copyframe, "TOPRIGHT", 0, -2)

copyframe.editBox = CreateFrame("EditBox", nil, E.UIParent)
copyframe.editBox:SetPoint('TOPLEFT', copyframe.Scroll, "TOPLEFT", 0, 0)
copyframe.editBox:SetPoint('TOPRIGHT', copyframe.Scroll, "TOPRIGHT", 0, 0)
copyframe.editBox:SetPoint("BOTTOM", copyframe, "BOTTOM", 0, 5)
copyframe.editBox:SetFontObject(GameFontWhite)
-- copyframe.editBox.__SetText = copyframe.editBox.SetText
-- copyframe.editBox.__Insert = copyframe.editBox.Insert

-- copyframe.editBox.SetText = function(self, text)
--     self:__SetText(string.sub(text, 1, 50) )

--     print('SetText:1', string.sub(text, 1, 50) )
--     print('SetText:2', self:GetText() )
-- end
-- copyframe.editBox.Insert = function(self, text)
--     self:__Insert(string.sub(text, 1, 50) )

--     print('Insert:1', string.sub(text, 1, 50) )
--     print('Insert:2', self:GetText() )
-- end

-- copyframe.editBox.bg = copyframe.editBox:CreateTexture()
-- copyframe.editBox.bg:SetColorTexture(1, 0, 0, 0.5)
-- copyframe.editBox.bg:SetAllPoints(copyframe.editBox)

copyframe.Scroll:SetScrollChild(copyframe.editBox)
copyframe.Scroll:SetHorizontalScroll(0)
copyframe.Scroll:SetVerticalScroll(0)
copyframe.Scroll:EnableMouse(true)	
copyframe.Scroll:SetClipsChildren(true)

copyframe.editBox:SetSize(copy_w, copy_h)
copyframe.editBox:SetFont(E.media.default_font2, 12);

copyframe.editBox:SetFrameLevel(copyframe.Scroll:GetFrameLevel() + 1)
copyframe.editBox:SetAutoFocus(false)
copyframe.editBox:SetMultiLine(true)
copyframe.editBox:SetCountInvisibleLetters(false)
copyframe.editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)
copyframe:Hide()
copyframe:SetBackdrop(backdrop)
copyframe:SetBackdropColor(0, 0, 0, 0.8) --цвет фона
copyframe:SetBackdropBorderColor(0 , 0 , 0 , 1) --цвет фона

copyframe.close = CreateFrame("Button", nil, copyframe.editBox)
copyframe.close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
copyframe.close:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
copyframe.close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
copyframe.close:SetSize(32, 32)
copyframe.close:SetPoint('TOPRIGHT', copyframe, 'TOPRIGHT', 0, 0)
copyframe.close:SetScript("OnClick", function(self) 
    copyframe:Hide();
    copyframe.editBox:SetText(''); 
    copyframe.editBox:ClearFocus()
end)


local function Sklonenie(a1, a2, a3, a4)
    --  print('a1:',a1, 'a2:', a2, 'a3:', a3, 'a4:', a4)
    if a1 == '1' then
       return a1..' '..a2
    elseif a1 == '2' or a1 == '3' or a1 == '4' then
       return a1..' '..a3
    else
       return a1..' '..a4
    end 
end

local function MessageIsProtected(message)
	return string.match(message, '[^|]-|K[vq]%d-[^|]-|k')
end

local function GetChatframeText()

    --print('GetChatframeText', SELECTED_CHAT_FRAME_ALEA)
    if SELECTED_CHAT_FRAME_ALEA then
        local msg = ""
        local start = 1
        local _max = SELECTED_CHAT_FRAME_ALEA:GetMaxLines()
        local _cur = SELECTED_CHAT_FRAME_ALEA:GetNumMessages()
        
        if _cur > _max then
            start = _cur - _max
        end
        
        --print('T', start, _cur)

        local showMe = false 

        for i=start, _cur do
            local msg2 = SELECTED_CHAT_FRAME_ALEA:GetMessageInfo(i)
            
            if ( not MessageIsProtected(msg2) ) then 

                showMe = true 

                msg2 = msg2:gsub('|c%x%x%x%x%x%x%x%x', '')
                msg2 = msg2:gsub('|r', '')
                --msg2 = msg2:gsub("|H.-|h(%[^.-%])|h", '%1') 
                msg2 = msg2:gsub("|H.-|h(%[.-%])|h", '%1')

                -- msg2 = msg2:gsub("|Hshareachieve:.-|h.-|t|h", '')
                -- msg2 = msg2:gsub("|H.-:.-|h([^:]+)|h", '%1')				
                msg2 = msg2:gsub("|T.-|t", '')
                msg2 = msg2:gsub(' |%d.-%d%((.-)%)', ' %1')
                msg2 = msg2:gsub('(%d) |4(.-):(.-):(.-);', Sklonenie)

                msg2 = msg2:gsub("|", '||')

                msg = msg .. msg2.."\n"
            end			
        end
        
        if ( showMe ) then 
            copyframe:Show()      
            copyframe.Scroll:SetVerticalScroll(0)
            copyframe.editBox:SetText(msg)
        end 
    end
end


local function addcopybutton(frame)	
    local bttn = CreateFrame("Button",nil, E.UIParent)
    bttn:SetWidth(18)
    bttn:SetHeight(18)
    bttn:SetScale(1)
    bttn:SetAlpha(0.3)
    bttn:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
    bttn:SetNormalTexture("Interface\\GossipFrame\\PetitionGossipIcon.blp")
    bttn:GetNormalTexture():SetTexCoord(unpack(E.media.texCoord))
    bttn:SetScript("OnClick", function(self) GetChatframeText() end)
    bttn:SetMovable(true)
    bttn:SetUserPlaced(true)
    bttn:EnableMouse(true)
    bttn:RegisterForDrag("LeftButton","RightButton")
    bttn:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")	
end

chatframe.CopyFrame = copyframe
chatframe.AddCopyButton = addcopybutton