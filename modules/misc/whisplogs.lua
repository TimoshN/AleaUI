local addonName, E = ...

local C = E:Module("WhisperLogs")
local db = {}

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeSize = 1,
}
local copy_w, copy_h = 500, 300

local timeOut = 60 * 60 * 24 *30

local mover = CreateFrame("Frame", "AleaUIChatHistoryWhisperMover", E.UIParent)
mover:SetSize(copy_w, 20)
mover:SetPoint("CENTER", 0, 20)
mover:EnableMouse(true)
mover:SetMovable(true)
mover:RegisterForDrag("LeftButton")
mover:SetScript("OnDragStart", mover.StartMoving)
mover:SetScript("OnDragStop", mover.StopMovingOrSizing)
mover:Hide()
mover:SetBackdrop(backdrop)
mover:SetBackdropColor(0.1,0.1,0.1,0.9)
mover:SetBackdropBorderColor(0 , 0 , 0 , 1)

mover.Owner = mover:CreateFontString()
mover.Owner:SetPoint('LEFT', mover, 'LEFT')
mover.Owner:SetFont(E.media.default_font2, E.media.default_font_size2, 'OUTLINE')

local copyframe = CreateFrame("Frame", "AleaUIChatHistoryWhisperFrame", E.UIParent)
copyframe:SetPoint("TOPRIGHT", mover, "BOTTOMRIGHT", 0, -3)
copyframe:SetSize(copy_w, copy_h)
copyframe:SetFrameLevel(10)

--table.insert(UISpecialFrames, "AleaUIChatHistoryWhisperFrame")
--table.insert(UISpecialFrames, "AleaUIChatHistoryWhisperMover")
--[==[
copyframe.Scroll = CreateFrame("ScrollFrame", "AleaUIChatLogsScrollFrame", copyframe, "UIPanelScrollFrameTemplate")
copyframe.Scroll:SetFrameLevel(copyframe:GetFrameLevel() - 1)
copyframe.Scroll:SetSize(copy_w, copy_h)
copyframe.Scroll:SetPoint("TOPRIGHT", copyframe, "TOPRIGHT", 0, 0)

copyframe.editBox = CreateFrame("EditBox", nil, copyframe)
copyframe.editBox:SetPoint('TOPLEFT', copyframe.Scroll, "TOPLEFT", 11, 1)
copyframe.editBox:SetFontObject(GameFontWhite)
copyframe.editBox:SetHyperlinksEnabled(true)
copyframe.editBox:SetScript('OnHyperlinkClick', function(self, link, text, button)
	SetItemRef(link, text, button, self);
end)
copyframe.editBox:SetFrameLevel(E.UIParent:GetFrameLevel())

copyframe.Scroll:SetScrollChild(copyframe.editBox)
copyframe.Scroll:SetHorizontalScroll(-5)
copyframe.Scroll:SetVerticalScroll(0)
copyframe.Scroll:EnableMouse(true)

copyframe.editBox:SetSize(copy_w, copy_h)


copyframe.editBox:SetFont("Fonts\\ARIALN.TTF", 12)
--copyframe.editBox:SetFrameLevel(copyframe.Scroll:GetFrameLevel() + 1)
copyframe.editBox:SetAutoFocus(false)
copyframe.editBox:SetMultiLine(true)
copyframe.editBox:SetScript("OnEscapePressed", function(self)
	self:ClearFocus()
end)
]==]

local function CreateCoreButton(parent)
	local f = CreateFrame("Frame", nil, parent)
	f:SetPoint('CENTER', parent, 'CENTER', 0, 0)
	f:SetSize(500, 300)
	f:SetFrameLevel(parent:GetFrameLevel() + 3)
	f.Scroll = CreateFrame("ScrollFrame", 'AleaUIChatLogsScrollFrame', f, "UIPanelScrollFrameTemplate")
	f.Scroll:SetFrameLevel(f:GetFrameLevel() - 1)
	f.Scroll.ScrollBar:SetParent(f)
	f.Scroll.ScrollBar:SetScript('OnValueChanged', function(self, value)
		f.Scroll:SetVerticalScroll(value);
	end)
	
	f.editBox = CreateFrame("EditBox", nil, f) 
	f.editBox:SetFontObject(ChatFontWhite)
	f.editBox:SetFrameLevel(f:GetFrameLevel()-1)
	f.editBox:SetAutoFocus(false)
	f.editBox:SetWidth(500)
	f.editBox:SetHeight(300)	
	f.editBox:SetMultiLine(true)
	f.editBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	
	f.Scroll:SetScrollChild(f.editBox)
	f.Scroll:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -2)
	f.Scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -2)
	f.Scroll:SetPoint("BOTTOM", f, "BOTTOM", 0, 2)
	f.Scroll:SetClipsChildren(true)
	
	f.editBox:SetPoint('TOPLEFT', f.Scroll, "TOPLEFT", 11, 0)
	f.editBox:SetPoint('TOPRIGHT', f.Scroll, "TOPRIGHT", 0, 0)
	f.editBox:SetPoint("BOTTOM", f, "BOTTOM", 0, 2)
	f.editBox:SetHyperlinksEnabled(true)
	f.editBox:SetScript('OnHyperlinkClick', function(self, link, text, button)
		SetItemRef(link, text, button, self);
	end)
	--f.editBox:SetIgnoreParentScale(true);
	f.editBox:SetFont(E.media.default_font2, 12)
	
	f.Scroll:SetSize(500, 300)
	f.Scroll:SetHorizontalScroll(-5)
	f.Scroll:SetVerticalScroll(0)
	f.Scroll:EnableMouse(true)
	
	f.editBox:Show()
	f.Scroll:Show()
	f:Show()
	
	copyframe.f = f
end
CreateCoreButton(copyframe)


local whisperList
local list

copyframe:Hide()
copyframe:SetBackdrop(backdrop)
copyframe:SetBackdropColor(0, 0, 0, 0.8)
copyframe:SetBackdropBorderColor(0 , 0 , 0 , 1)

copyframe.close = CreateFrame("Button", nil, copyframe)
copyframe.close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
copyframe.close:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
copyframe.close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
copyframe.close:SetSize(32, 32)
copyframe.close:SetPoint('TOPRIGHT', copyframe, 'TOPRIGHT', 30, 30)
copyframe.close:SetScript("OnClick", function(self) 
	mover:Hide();
	copyframe:Hide();
	copyframe.f.editBox:SetText(""); 
	mover.Owner:SetText(''); 
	copyframe.f.editBox:ClearFocus()
	
	whisperList.numPage = nil
	
	whisperList.expanded = false;
	
	whisperList:ToggleFrame(false)
	
	for i=1, #list do
		list[i]:Hide()
	end
end)

list = {}

local function ShowButtonListFrom()
	local startFrom = ((whisperList.numPage-1) * #list) + 1

	for i=1, #list do
		list[i]:Hide()
		list[i]:SetAlpha(0)
	end
	
	local numButton = 1
	for i=startFrom, #whisperList.id do
		if list[numButton] then
			local dir = whisperList.id[i][1]
			list[numButton].unit = dir
			
			if db[dir].new then
				list[numButton].new:Show()
			else
				list[numButton].new:Hide()
			end
			
			if db[dir].types == "bnet" then
				local name = strsplit("#", dir)
				list[numButton].text:SetText(E.RGBToHex(23, 189, 222)..name.."|r")					
				list[numButton].icon:SetVertexColor(23/255, 189/255, 222/255, 1)
			elseif db[dir].types == 'whisper' and db[dir].class and RAID_CLASS_COLORS[db[dir].class] then
				local c = RAID_CLASS_COLORS[db[dir].class] 
				local name = strsplit("-", dir)
				list[numButton].text:SetText('|c'..c.colorStr..name.."|r")	
				list[numButton].icon:SetVertexColor(220/255, 166/255, 205/255, 1)
			else
				local name = strsplit("-", dir)
				list[numButton].text:SetText(E.RGBToHex(220, 166, 205)..name.."|r")
				list[numButton].icon:SetVertexColor(220/255, 166/255, 205/255, 1)
			end
			
			list[numButton]:Show()
			E.frameFade(list[numButton],{ timeToFade = 0.2, startDelay = numButton*0.01 })
			
			numButton = numButton + 1
		end
	end
	
	whisperList.pages:SetText(whisperList.numPage..'/'..whisperList.numPages)
end

local function UpdateHistoryButtons(self)
	self.expanded = not self.expanded

	self:ToggleFrame(false)
	
	for i=1, #list do
		list[i]:Hide()
	end

	if self.expanded then
	
		self:ToggleFrame(true)
		
		self.id = self.id or {}
		wipe(self.id)
	
		for k,v in pairs(db) do
			self.id[#self.id+1] = { k, v.timestamp }
		end
		
		table.sort(self.id, function(x, y)
			return x[2] > y[2]	
		end)
		
		local numPages = ceil(#self.id/#list)
	
		self.numPages = numPages
		self.numPage = self.numPage or 1
		
		if self.numPage > self.numPages then
			self.numPage = 1
		end

		ShowButtonListFrom()
	end
end

whisperList = CreateFrame("Frame", nil, copyframe)
whisperList:SetFrameLevel(copyframe:GetFrameLevel() + 5)
whisperList:SetSize(20, copy_h)
whisperList:SetPoint("TOPRIGHT", copyframe, "TOPLEFT", -5, 0)
whisperList:SetPoint("BOTTOMRIGHT", copyframe, "BOTTOMLEFT", -5, 0)
whisperList:SetBackdrop(backdrop)
whisperList:SetBackdropColor(0.1,0.1,0.1,0.9) --цвет фона
whisperList:SetBackdropBorderColor(0 , 0 , 0 , 1) --цвет фона
whisperList:SetScript('OnMouseUp', UpdateHistoryButtons)
whisperList:SetScript('OnMouseDown', function(self)end)

whisperList.stat = whisperList:CreateFontString()
whisperList.stat:SetPoint('LEFT', whisperList, 'LEFT')
whisperList.stat:SetFont(E.media.default_font, E.media.default_font_size+4, 'OUTLINE')
whisperList.stat:SetText('>\n>\n>\n>\n>\n>\n>\n>\n>\n>\n>\n>\n>')

whisperList.holdTexture = whisperList:CreateTexture()
whisperList.holdTexture:SetColorTexture(0,0,0, 0.7)
whisperList.holdTexture:SetAllPoints(copyframe)
whisperList.holdTexture:Hide()

whisperList.info = whisperList:CreateFontString()
whisperList.info:SetPoint('BOTTOMLEFT', copyframe, 'BOTTOMLEFT', 2, 2)
whisperList.info:SetFont(E.media.default_font2, E.media.default_font_size2, 'OUTLINE')
whisperList.info:SetText(E.L['Right mouse click to delete\nLeft mouse click to show'])
whisperList.info:Hide()
whisperList.info:SetTextColor(0.5, 0.5, 0.5)
whisperList.info:SetJustifyH('LEFT')

whisperList.next = CreateFrame("Button", nil, whisperList)
whisperList.next:SetSize(16, 16)
whisperList.next:EnableMouse(true)
whisperList.next:SetPoint("BOTTOMRIGHT", copyframe, "BOTTOMRIGHT", -45, 40)
whisperList.next:SetBackdrop(backdrop)
whisperList.next:SetBackdropColor(0.1,0.1,0.1,0.9) --цвет фона
whisperList.next:SetBackdropBorderColor(0.5 , 0.5 , 0.5 , 1) --цвет фона
whisperList.next:SetScript('OnClick', function(self)
	if whisperList.numPage then
		whisperList.numPage = whisperList.numPage + 1
		
		if whisperList.numPages < whisperList.numPage then		
			whisperList.numPage = whisperList.numPages
		end
		
		ShowButtonListFrom()
	end
end)
whisperList.next.stat = whisperList.next:CreateFontString()
whisperList.next.stat:SetPoint('LEFT', whisperList.next, 'LEFT')
whisperList.next.stat:SetFont(E.media.default_font, E.media.default_font_size+4, 'OUTLINE')
whisperList.next.stat:SetText('>')
whisperList.next:Hide()

whisperList.prev = CreateFrame("Button", nil, whisperList)
whisperList.prev:SetSize(16, 16)
whisperList.prev:EnableMouse(true)
whisperList.prev:SetPoint("BOTTOMRIGHT", copyframe, "BOTTOMRIGHT", -95, 40)
whisperList.prev:SetBackdrop(backdrop)
whisperList.prev:SetBackdropColor(0.1,0.1,0.1,0.9) --цвет фона
whisperList.prev:SetBackdropBorderColor(0.5 , 0.5 , 0.5 , 1) --цвет фона
whisperList.prev:SetScript('OnClick', function(self)
	if whisperList.numPage then
		whisperList.numPage = whisperList.numPage - 1
		
		if whisperList.numPage <= 0 then		
			whisperList.numPage = 1
		end
		
		ShowButtonListFrom()
	end
end)
whisperList.prev.stat = whisperList.prev:CreateFontString()
whisperList.prev.stat:SetPoint('LEFT', whisperList.prev, 'LEFT')
whisperList.prev.stat:SetFont(E.media.default_font, E.media.default_font_size+4, 'OUTLINE')
whisperList.prev.stat:SetText('<')
whisperList.prev:Hide()

whisperList.pages = whisperList:CreateFontString()
whisperList.pages:SetPoint("BOTTOMRIGHT", copyframe, "BOTTOMRIGHT", -62, 42)
whisperList.pages:SetFont(E.media.default_font2, E.media.default_font_size2, 'OUTLINE')
whisperList.pages:SetText('10/10')
whisperList.pages:Hide()
whisperList.pages:SetTextColor(0.5, 0.5, 0.5)
whisperList.pages:SetJustifyH('LEFT')

whisperList.ToggleFrame = function(self, toggle)
	if toggle then
		self.holdTexture:Show()
		self.stat:SetText('<\n<\n<\n<\n<\n<\n<\n<\n<\n<\n<\n<\n<')
		self.info:Show()
		
		whisperList.prev:Show()
		whisperList.next:Show()
		
		whisperList.pages:Show()
	else
		self.holdTexture:Hide()
		self.stat:SetText('>\n>\n>\n>\n>\n>\n>\n>\n>\n>\n>\n>\n>')
		self.info:Hide()
		
		whisperList.prev:Hide()
		whisperList.next:Hide()
		
		whisperList.pages:Hide()
	end
end

local function BuildTextString(unit)
	local text = ""
	local lastData = nil
	
	for i=#db[unit].datas-50, #db[unit].datas, 1 do
		if db[unit].datas[i] then
		
			local data = db[unit].datas[i]:sub(1, 8)
			local ttext = db[unit].datas[i]:sub(9)
			
			if lastData ~= data then
				text = text.."\n"..data.."\n"
				lastData = data
			end
			
			text = text..'  '..ttext.."\n"
		end
	end
	
	return text
end

local function UpdateScroll()
	copyframe.f.Scroll:SetVerticalScroll(copyframe.f.Scroll:GetVerticalScrollRange())
end

local function DeleteLog(self)
	AleaUI_GUI.ShowPopUp(
		   'AleaUI', 
			E.L['Do you really want to |cffff0000DELETE|r this history?.'], 
		   { name = YES, OnClick = function() 
				db[self.unit] = nil
				whisperList.expanded = false
				UpdateHistoryButtons(whisperList)
			end}, 
		   { name = NO, OnClick = function() 	   
				
		   end}		   
		)
end

local function ShowLog(self, button)

	if button == 'RightButton' then
		DeleteLog(self)
		return
	end
	
	whisperList.expanded = false

	whisperList:ToggleFrame(false)
	
	for i=1, #list do
		list[i]:Hide()
	end

	copyframe.f.editBox:SetText(BuildTextString(self.unit))			
	mover.Owner:SetText(self.unit)
	
	db[self.unit].new = nil
			
	if db[self.unit].types == 'bnet' then
		copyframe.f.editBox:SetTextColor(23/255, 189/255, 222/255)
		mover.Owner:SetTextColor(23/255, 189/255, 222/255)
	elseif db[self.unit].types == 'whisper' and db[self.unit].class and RAID_CLASS_COLORS[db[self.unit].class] then
		copyframe.f.editBox:SetTextColor(220/255, 166/255, 205/255)
		local c = RAID_CLASS_COLORS[db[self.unit].class]
		mover.Owner:SetTextColor(c.r, c.g, c.b)
	else
		copyframe.f.editBox:SetTextColor(220/255, 166/255, 205/255)
		mover.Owner:SetTextColor(220/255, 166/255, 205/255)
	end
	
	C_Timer.After(0.2, UpdateScroll)
	
end

local perRow = 4
local numRows = 12
local curNum = 0
local curRow = 1
local buttonW, buttonH = 120, 18

for i=1, perRow*numRows do

	curNum = curNum + 1
	
	if curNum > perRow then
		curNum = 1
		curRow = curRow + 1
	end
	
	list[i] = CreateFrame("BUTTON", nil, whisperList)
	list[i]:SetSize(buttonW, buttonH)
	list[i]:SetBackdrop(backdrop)
	list[i]:SetBackdropColor(0.2 , 0.2 , 0.2 , 0.8) --цвет фона
	list[i]:SetBackdropBorderColor(0.5 , 0.5 , 0.5 , 1) --цвет фона
	list[i]:RegisterForClicks('AnyUp')
	
	if curNum == 1 then
		list[i]:SetPoint("TOPLEFT", copyframe, "TOPLEFT", 8, -4 -( 20 * ( curRow - 1) ))
	else
		list[i]:SetPoint('LEFT', list[i-1], 'RIGHT', 2, 0)
	end
	
	list[i]:SetScript("OnEnter", function(self)
		list[i]:SetBackdropColor(0.5 , 0.5 , 0.2 , 0.8) --цвет фона
	end)
	list[i]:SetScript("OnLeave", function(self)
		list[i]:SetBackdropColor(0.2 , 0.2 , 0.2 , 0.8) --цвет фона
	end)
	
	list[i]:SetScript("OnClick", ShowLog)
	
	
	list[i].icon = list[i]:CreateTexture()
	list[i].icon:SetSize(buttonH, buttonH)
	list[i].icon:SetTexture('Interface\\ChatFrame\\UI-ChatWhisperIcon')
	list[i].icon:SetPoint('LEFT', list[i], 'LEFT', 0, 0)
	
	list[i].text = list[i]:CreateFontString()
	list[i].text:SetFontObject(GameFontWhite)
	list[i].text:SetPoint('LEFT', list[i].icon, 'RIGHT', 0, 0)
	list[i].text:SetPoint('RIGHT', list[i], 'RIGHT', 0, 0)
	list[i].text:SetJustifyH('LEFT')
	
	list[i].new = list[i]:CreateFontString()
	list[i].new:SetFontObject(GameFontWhite)
	list[i].new:SetPoint('RIGHT', list[i], 'RIGHT', 0, 0)
	list[i].new:SetJustifyH('RIGHT')
	list[i].new:SetText('New')
	list[i].new:Hide()
	
	list[i].text:SetFont(E.media.default_font2, E.media.default_font_size2)
	list[i]:Hide()
	
end

local bttn = CreateFrame("Button",nil, E.UIParent)
bttn:SetWidth(18)
bttn:SetHeight(18)
bttn:SetScale(1)
bttn:SetAlpha(0.3)
bttn:SetPoint('TOPRIGHT', ChatFrame1, 'TOPRIGHT', 0, -20)

bttn:SetNormalTexture(GetSpellTexture(80353))
bttn:GetNormalTexture():SetTexCoord(unpack(E.media.texCoord))
bttn:GetNormalTexture():SetDesaturated(true)
bttn:SetScript("OnClick", function(self) 
	if not copyframe:IsShown() then
		whisperList.numPage = nil	
		copyframe:Show() 
		mover:Show()
	end
end)

bttn:SetMovable(true)
bttn:SetUserPlaced(true)
bttn:EnableMouse(true)
bttn:RegisterForDrag("LeftButton","RightButton")
--	bttn:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", insets = {top = -2, left = -2, bottom = -2, right = -2}})
--	bttn:SetBackdropColor(0, 0, 0, 1)
bttn:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	
	
	
local function realStr(str)
	return gsub(str , "|", "||")
end
	
C:RegisterEvent("CHAT_MSG_BN_WHISPER") -- incoming
C:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM") -- outgoing
C:RegisterEvent("CHAT_MSG_WHISPER") -- incoming
C:RegisterEvent("CHAT_MSG_WHISPER_INFORM") -- outgoing
-- whisper 220, 166, 205
-- bnet 41, 134, 255

local whispto = " To me: "
local from = " Me: "

local blacklistWords = {
	['inv'] = true,
	['инв'] = true,
}

local string_match = string.match
function E.Erase(name)
	if not name then return name end
	local rname = string_match(name, "(.+)-") or name
	return rname
end

function C:CHAT_MSG_BN_WHISPER(event, message, sender, ...)
	if blacklistWords[message] then return end
	
	local senderID = select(11, ...)
	local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, broadcastTime, canSoR = BNGetFriendInfoByID(senderID)
	
--	print(event, realStr(sender), senderID, presenceID, realStr(presenceName), realStr(battleTag), isBattleTagPresence, realStr(toonName))
	
	if not db[battleTag] then 
		db[battleTag] = {} 
		db[battleTag].timestamp = 0
		db[battleTag].types = "bnet"
		db[battleTag].datas = {}
		db[battleTag].chars = {}
	end
	
	local battleShort = strsplit('#', battleTag)

	--  [Кемио] >>: авыва
	-- 7 >> [Кемио]: авыва

	db[battleTag].new = true
	db[battleTag].timestamp = time()
	db[battleTag].datas[#db[battleTag].datas+1] = date("%m/%d/%y %H:%M:%S").." || ["..battleShort..'] >>: '..message
end

function C:CHAT_MSG_BN_WHISPER_INFORM(event, message, target, ...)
	if blacklistWords[message] then return end
	
	local senderID = select(11, ...)
	local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, broadcastTime, canSoR = BNGetFriendInfoByID(senderID)
	
--	print(event, realStr(target), senderID, presenceID, realStr(presenceName), realStr(battleTag), isBattleTagPresence, realStr(toonName))
	
	if not db[battleTag] then 
		db[battleTag] = {} 
		db[battleTag].timestamp = 0
		db[battleTag].types = "bnet"
		db[battleTag].datas = {}
		db[battleTag].chars = {}
	end

	local battleShort = strsplit('#', battleTag)
	
	db[battleTag].new = nil
	db[battleTag].timestamp = time()
	db[battleTag].datas[#db[battleTag].datas+1] = date("%m/%d/%y %H:%M:%S").." || >> ["..battleShort..']: '..message
end

function C:CHAT_MSG_WHISPER(event, message, sender, ...)	
	if blacklistWords[message] then return end
	
	local guid = select(10, ...)
	local class, classFilename
	
	if guid and guid ~= '' then
		class, classFilename = GetPlayerInfoByGUID(guid)
	end

	local sender2, server = strsplit('-', sender)
	
	if db[sender2] and not db[sender] then
		db[sender] = db[sender2]
		db[sender2] = {}
		db[sender2] = nil
	end
	
	if not db[sender] then 
		db[sender] = {} 
		db[sender].timestamp = 0
		db[sender].types = "whisper"
		db[sender].datas = {}
	end
	
	if db[sender].btag == nil then
		db[sender].btag = C:GetBtagForCharacter(sender)
	end

	if db[sender].btag then
		-- Save as battle tag friend
		sender = db[sender].btag
		
		if not db[sender] then 
			db[sender] = {} 
			db[sender].timestamp = 0
			db[sender].types = "bnet"
			db[sender].datas = {}
			db[sender].chars = {}
		end
	end
	
	if classFilename then
		db[sender].class = classFilename
	end
	
	db[sender].new = true
	db[sender].timestamp = time()
	db[sender].datas[#db[sender].datas+1] = date("%m/%d/%y %H:%M:%S").." || ["..sender2..'] >>: '..message
end

function C:CHAT_MSG_WHISPER_INFORM(event, message, target, ...)
	if blacklistWords[message] then return end
	
	local guid = select(10, ...)
	local class, classFilename
	
	if guid and guid ~= '' then
		class, classFilename = GetPlayerInfoByGUID(guid)
	end
	
--	print('T', target)
	
	local target2 = strsplit('-', target)

	if db[target2] and not db[target] then
		db[target] = db[target2]
		db[target2] = {}
		db[target2] = nil
	end
	
	if not db[target] then 
		db[target] = {} 
		db[target].timestamp = 0
		db[target].types = "whisper"
		db[target].datas = {}
	end
	
	if db[target].btag == nil then
		db[target].btag = C:GetBtagForCharacter(target)
	end

	if db[target].btag then
		-- Save as battle tag friend
		target = db[target].btag
		
		if not db[target] then 
			db[target] = {} 
			db[target].timestamp = 0
			db[target].types = "bnet"
			db[target].datas = {}
			db[target].chars = {}
		end
	end
	
	if classFilename then
		db[target].class = classFilename
	end
	
	db[target].new = nil
	db[target].timestamp = time()
	db[target].datas[#db[target].datas+1] = date("%m/%d/%y %H:%M:%S").." || >> ["..target2..']: '..message
end

local function AddToHistory(target, data)

	if AleaUIDB["WhispersLogs"][target] then
	
		AleaUIDB["WhispersLogs"][target].timestamp = data.timestamp
		
		if data.class then
			AleaUIDB["WhispersLogs"][target].class = data.class
		end
		
		for i=1, #data.datas do
			AleaUIDB["WhispersLogs"][target].datas[#AleaUIDB["WhispersLogs"][target].datas+1] = data.datas[i]
		end
	else	
		AleaUIDB["WhispersLogs"][target] = data
	end
	
end

C:RegisterEvent("BN_FRIEND_INFO_CHANGED") -- outgoing
C:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")

function C:UpdateWhispersOwner()

	local _, num = BNGetNumFriends()

	for i=1, num do
		local bnetIDAccount, accountName, battleTag, _, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)
		local toon = BNGetNumFriendGameAccounts(i)
		
		for j=1, toon do
			local _, rName, rGame, realmName, realmID, faction, race, class = BNGetFriendGameAccountInfo(i, j)
			if rGame == "WoW" then
		--		print('T', rName, characterName, realmName:gsub(' ', ''), battleTag)
				
				if db[battleTag] and realmName and realmName ~= '' then
					local nameChars = rName..'-'..realmName:gsub(' ', '')
					
					db[battleTag].chars = db[battleTag].chars or {}

					db[battleTag].chars[nameChars] = true
				--	print('AleaUI:WhisperLog. Find new character', nameChars, 'for', battleTag)
					
					for k,v in pairs( db ) do
						if k == rName then
							
							if db[k] and not db[nameChars] then
								db[nameChars] = db[k]
								db[k] = {}
								db[k] = nil
				--				print('AleaUI:WhisperLog. Transfer log from', k, 'to', nameChars)
							end
							
							if db[nameChars] then
								db[nameChars].btag = battleTag
				--				print('AleaUI:WhisperLog. Update btag for', nameChars)
							end
							
							break
						elseif k == nameChars  then
							if db[nameChars] then
								db[nameChars].btag = battleTag
				--				print('AleaUI:WhisperLog. Update btag for', nameChars)
							end
							
							break
						end
					end
				end
			end
		end
	end
end

local throttle = true

C.BN_FRIEND_INFO_CHANGED = function()
	if throttle then
		throttle = false
		C_Timer.After(0.5, C.UpdateWhispersOwner)
	end
end
C.BN_FRIEND_LIST_SIZE_CHANGED = C.BN_FRIEND_INFO_CHANGED

function C:GetBtagForCharacter(name)

	local _, num = BNGetNumFriends()

	for i=1, num do
		local bnetIDAccount, accountName, battleTag, _, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)
		local toon = BNGetNumFriendGameAccounts(i)
		
		for j=1, toon do
			local _, rName, rGame, realmName, realmID, faction, race, class = BNGetFriendGameAccountInfo(i, j)
			if rGame == "WoW" then
				if realmName and realmName ~= '' then
					local nameChars = rName..'-'..realmName:gsub(' ', '')
				
					if rName == name or nameChars == name then
						return battleTag
					end
				end
			end
		end
	end
	
	return false
end

local function InitChatLogs()
	
	if not AleaUIDB then AleaUIDB = {} end
	if not AleaUIDB["WhispersLogs"] then AleaUIDB["WhispersLogs"] = {} end
	
	for target, data in pairs(db) do	
		AddToHistory(target, data)
	end
	
	db = AleaUIDB["WhispersLogs"]
	--[==[	
	local timestamp = time()	
	
	for dir, data in pairs(db) do
		
	--	print('T', tDate, ( timestamp - timespamp1 ) > timeOut)
		if data.types == "whisper" then
			if ( data.timestamp - timestamp ) > timeOut then	
				db[dir] = nil
			end
		end
	end
	]==]	
		
	C:BN_FRIEND_INFO_CHANGED()
end
	

E:OnInit(InitChatLogs)

--[[
	local totalBNet, numBNetOnline = BNGetNumFriends()
	
	local trimmedPlayer = Ambiguate(player, "none")
	local _, num = BNGetNumFriends()
      for i=1, num do
		local bnetIDAccount, accountName, battleTag, _, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)
        local toon = BNGetNumFriendGameAccounts(i)
        for j=1, toon do
          local _, rName, rGame = BNGetFriendGameAccountInfo(i, j)
          if rName == trimmedPlayer and rGame == "WoW" then
            return false, newMsg, player, l, cs, t, flag, channelId, ...; -- Player is a real id friend, allow it
          end
        end
      end
      return true -- Filter strangers
	  
]]