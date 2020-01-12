local addonName, E = ...
E.L = AleaUI_GUI.GetLocale(addonName)

local L = E.L


-- Legion to BFA

if not ( IsAddonMessagePrefixRegistered ) then
	IsAddonMessagePrefixRegistered = C_ChatInfo.IsAddonMessagePrefixRegistered
end

if not ( RegisterAddonMessagePrefix ) then
	RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
end

if not ( SendAddonMessage ) then
	SendAddonMessage = C_ChatInfo.SendAddonMessage
end

local scaler = CreateFrame("Frame")
scaler:RegisterEvent("VARIABLES_LOADED")
scaler:RegisterEvent("UI_SCALE_CHANGED")
scaler:SetScript("OnEvent", function(self, event)
	if not InCombatLockdown() then
	
		local screenwidth, screenheight = GetPhysicalScreenSize();
		
		local width = screenwidth
		local height = screenheight
		
		local scale = max(0.64, min(1.15, 768/height));
		
		
		UIParent:SetScale(scale)
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end)

local hidenframe = CreateFrame("Frame", "AleaUIHidenFrame")
hidenframe.unit = ""
hidenframe.buffsOnTop = false
hidenframe.auraRows = 0
hidenframe:Hide()

E.hidenframe = hidenframe

function E.noop()end

--/script DEFAULT_CHAT_FRAME:AddMessage( GetMouseFocus():GetName() );
--[==[
local coordx1 = 8
local coordx2 = 23
local coordy1 = 10
local coordy2 = 22

return '|TInterface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up:0:0:0:0:32:32:'..coordx1..':'..coordx2..':'..coordy1..':'..coordy2..'|t'
]==]

local function SetColorTexture(obj, r,g,b,a)
	if E.IsLegion then
		obj:SetColorTexture(r,g,b,a)
	else
		obj:SetTexture(r,g,b,a)
	end
end

local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 1
	yOffset = yOffset or 1
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end
	
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 1
	yOffset = yOffset or 1
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end
	
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

local function RePointVertival(obj, value)
	local a1, a2, a3, a4, a5 = obj:GetPoint()
	obj:SetPoint(a1, a2, a3, a4, a5+value)
end

local function RePointHorizontal(obj, value)
	local a1, a2, a3, a4, a5 = obj:GetPoint()
	obj:SetPoint(a1, a2, a3, a4+value, a5)
end

local function SetIgnoreFramePositionManager(obj, value)	
	if value then
		obj.ignoreFramePositionManager = true
		
		if obj.SetAttribute then
			obj:SetAttribute("ignoreFramePositionManager", true)
		end
	else
		obj.ignoreFramePositionManager = nil
		
		if obj.SetAttribute then
			obj:SetAttribute("ignoreFramePositionManager", false)
		end
	end
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.__hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetColorTexture(1, 1, 1, 0.3)
		hover:SetInside()
		button.__hover = hover
		button:SetHighlightTexture(hover)
	end

	if button.SetPushedTexture and not button.__pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		pushed:SetInside()
		button.__pushed = pushed
		button:SetPushedTexture(pushed)
	end

	if button.SetCheckedTexture and not button.__checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetColorTexture(1, 1, 1)
		checked:SetInside()
		checked:SetAlpha(0.3)
		button.__checked = checked
		button:SetCheckedTexture(checked)
	end

	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetInside()
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end
end

local function SetShownFalse(self, value)
	if value ~= false then
		self:SetShown(false)
	end
end

local function Kill(object, kill)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(hidenframe)
	elseif kill then
		object:SetParent(hidenframe)
	else
		object.Show = object.Hide
	end

	object:Hide()
end

local EnableMinimapMoving, DisableMinimapMoving
local onClick, onMouseUp, onMouseDown, onDragStart, onDragStop, updatePosition
local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {false, true, false, true},
	["SIDE-RIGHT"] = {true, false, true, false},
	["SIDE-TOP"] = {false, false, true, true},
	["SIDE-BOTTOM"] = {true, true, false, false},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}
local function GetRadius()	
	return GetMiniMapButtonsRad and GetMiniMapButtonsRad() or 80
end
	
function updatePosition(button)
	local angle = math.rad(button.settings and button.settings.minimapPos or button.minimapPos or 225)
	local x, y, q = math.cos(angle), math.sin(angle), 1
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]
	
	if quadTable[q] then
		x, y = x*GetRadius(), y*GetRadius()	
	else
		local diagRadius = math.sqrt(2*(GetRadius())^2)
		x = math.max(-GetRadius()	, math.min(x*diagRadius, GetRadius()	))
		y = math.max(-GetRadius()	, math.min(y*diagRadius, GetRadius()	))
	end

	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function onUpdate(me)
	local self = me.parent

	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	
	px, py = px /scale, py / scale
	if self.settings then
		self.settings.minimapPos = math.deg(math.atan2(py - my, px - mx)) % 360
	else
		self.minimapPos = math.deg(math.atan2(py - my, px - mx)) % 360
	end	
	updatePosition(self)
end
	
function onDragStart(self)
	self:LockHighlight()
	self._onupdate:SetScript("OnUpdate", onUpdate)
	GameTooltip:Hide()
end

function onDragStop(self)
	self._onupdate:SetScript("OnUpdate", nil)
	self:UnlockHighlight()
end
	
function EnableMinimapMoving(obj, settings)
	if not AleaUI.db.Frames[settings] then
		AleaUI.db.Frames[settings] = {}
	end
	obj._onupdate = CreateFrame("Frame", nil, obj)
	obj._onupdate.parent = obj
	obj.minimapButtonFadeOut = true
	obj:RegisterForDrag("LeftButton")
	obj.settings = AleaUI.db.Frames[settings]
	obj:HookScript("OnDragStop", onDragStop)
	obj:HookScript("OnDragStart", onDragStart)
	obj:ClearAllPoints()
	
	updatePosition(obj)
end

function DisableMinimapMoving(obj)
	
	obj.settings = nil

	obj:SetScript("OnDragStart", nil)
	obj:SetScript("OnDragStop", nil)	
end

local function StripTextures(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region and region:GetObjectType() == "Texture" then
		
			if kill and type(kill) == 'boolean' then
				region:Kill()
			elseif region:GetDrawLayer() == kill then
				region:SetTexture(nil)
			elseif kill and type(kill) == 'string' and region:GetTexture() ~= kill then
				region:SetTexture(nil)
			else
				region:SetTexture(nil)
			end
		end
	end
end

local function StripTextures2(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if kill and region:GetTexture() == kill then
				region:SetTexture(nil)
			end
		end
	end
end

local function SetResize(object, width, height)
	local o1, o2 = object:GetSize()
	
	if height then
		object:SetSize(o1+width, o2+height)
	else
		object:SetSize(o1+width, o2+width)
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.Kill then mt.Kill = Kill end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.StripTextures2 then mt.StripTextures2 = StripTextures2 end
	if not object.RePointVertival then mt.RePointVertival = RePointVertival end
	if not object.RePointHorizontal then mt.RePointHorizontal = RePointHorizontal end
	if not object.SetIgnoreFramePositionManager then mt.SetIgnoreFramePositionManager = SetIgnoreFramePositionManager end
	if not object.SetResize then mt.SetResize = SetResize end
	if not object.EnableMinimapMoving then mt.EnableMinimapMoving = EnableMinimapMoving end
	if not object.DisableMinimapMoving then mt.DisableMinimapMoving = DisableMinimapMoving end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.SetColorTexture and object.SetTexture then mt.SetColorTexture = SetColorTexture end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do

	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end
	
	object = EnumerateFrames(object)
end

--Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the "Frame" widget
local scrollFrame = CreateFrame("ScrollFrame")
addapi(scrollFrame)

do
	local addon = ...
	local C = {}
	local addonChannel = "AleaUIVCH"
	local remindMeagain = true
	local name
	local string_match = string.match
	local format = format
	local SendAddonMessage = SendAddonMessage
	local tonumber = tonumber
	local sendmessagethottle = 20
	local versioncheck = 0

	if not IsAddonMessagePrefixRegistered(addonChannel) then
		RegisterAddonMessagePrefix(addonChannel)
	end

	function C:AddonMessage(msg, channel)
		if channel == "GUILD" and IsInGuild() then
			SendAddonMessage(addonChannel, msg, "GUILD")
		else
			local chatType = "PRINT"
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
				chatType = "INSTANCE_CHAT"
			elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
				chatType = "RAID"
			elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
				chatType = "PARTY"
			end
				
			if chatType == "PRINT" then
				
			else
				SendAddonMessage(addonChannel, msg, chatType)
			end
		end
	end

	local function constructVersion(ver)
		local d1, d2, d3 = strsplit(".", ver)
		
		d1 = d1 or "0"
		d2 = d2 or "0"
		d3 = d3 or "0"
		
		if #d2 == 1 then
		   d2 = "00"..d2
		end
		if #d2 == 2 then
		   d2 = "0"..d2
		end
		if #d3 == 1 then
		   d3 = "00"..d3
		end
		if #d3 == 2 then
		   d3 = "0"..d3
		end
		
		return tonumber(d1..d2..d3)
	end

	local events = CreateFrame("Frame")
	events:SetScript("OnEvent", function(self, event, ...)
		self[event](self, event, ...)
	end)

	function events:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
		if prefix ~= addonChannel then return end
		if sender == name then return end
		if not remindMeagain then return end	
		local version, source = strsplit(":", message)	
		if version and source then
			local cntrV = constructVersion(version)
			local cntrmV = constructVersion(C.myVersionT)
		
			if cntrV > cntrmV then
				remindMeagain = false
				print(addon..": New version".." "..version.." ".."availible on https://mods.curse.com/addons/wow/aleaui")
			end
		end
	end

	function events:SendAddonIndo()
		if GetTime() < versioncheck then return end
		versioncheck = GetTime() + sendmessagethottle
		C:AddonMessage(format("%s:%s", C.myVersionT, C.VersionSource))
	end

	function events:SendAddonIndo2()
		if GetTime() < versioncheck then return end
		versioncheck = GetTime() + sendmessagethottle
		C:AddonMessage(format("%s:%s", C.myVersionT, C.VersionSource) , "GUILD")
	end

	events.GROUP_ROSTER_UPDATE = events.SendAddonIndo
	events.PLAYER_ENTERING_WORLD = events.SendAddonIndo2
	events.PLAYER_ENTERING_BATTLEGROUND = events.SendAddonIndo
	events.GROUP_JOINED = events.SendAddonIndo
	events.RAID_INSTANCE_WELCOME = events.SendAddonIndo
	events.ZONE_CHANGED_NEW_AREA = events.SendAddonIndo

	events.GUILD_MOTD = events.SendAddonIndo2
	events.GUILD_NEWS_UPDATE = events.SendAddonIndo2
	events.GUILD_ROSTER_UPDATE = events.SendAddonIndo2


	events:RegisterEvent("PLAYER_LOGIN")

	function events:PLAYER_LOGIN()
		local version = GetAddOnMetadata(addon, "Version") or "0"
		local version_c = version:gsub("%.", "")
		
		name = UnitName("player").."-"..GetRealmName()

		C.myVersionT = version
		C.myVersion = tonumber(version_c) or 0
		C.VersionSource = GetAddOnMetadata(addon, "VersionType") or "main"

		events:RegisterEvent("CHAT_MSG_ADDON")
		events:RegisterEvent("GROUP_ROSTER_UPDATE")
		events:RegisterEvent("PLAYER_ENTERING_WORLD")
		events:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
		events:RegisterEvent("GROUP_JOINED")
		events:RegisterEvent("RAID_INSTANCE_WELCOME")
		events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		events:RegisterEvent("GUILD_MOTD")

		if (not E.isClassic) then 
			events:RegisterEvent("GUILD_NEWS_UPDATE")
		end
		events:RegisterEvent("GUILD_ROSTER_UPDATE")
		
		events:SendAddonIndo()
		events:SendAddonIndo2()
	end
end

do
	local LockedCVars = {}
	local IgnoredCVars = {}
	
	local CVarUpdate = nil
	
	local event = CreateFrame('Frame')
	event:RegisterEvent('PLAYER_REGEN_ENABLED')
	event:SetScript('OnEvent', function(event)
		if(CVarUpdate) then
			for cvarName, value in pairs(LockedCVars) do
				if (not IgnoredCVars[cvarName] and (GetCVar(cvarName) ~= value)) then
					SetCVar(cvarName, value)
				end			
			end
			CVarUpdate = nil
		end
	end)

	local function CVAR_UPDATE(cvarName, value)
		if(not IgnoredCVars[cvarName] and LockedCVars[cvarName] and LockedCVars[cvarName] ~= value) then
			if(InCombatLockdown()) then
				CVarUpdate = true
				return
			end
			
	--		print('LockCVar2', cvarName, LockedCVars[cvarName])
			SetCVar(cvarName, LockedCVars[cvarName])
		end
	end

	hooksecurefunc("SetCVar", CVAR_UPDATE)
	function E:LockCVar(cvarName, value, force)
	
	--	print('LockCVar1', cvarName, value)
		
		LockedCVars[cvarName] = value
		
		if(GetCVar(cvarName) ~= value) or force then
			SetCVar(cvarName, value)
		end
	end
	
	function E:IgnoreCVar(cvarName, ignore)
		ignore = not not ignore --cast to bool, just in case
		IgnoredCVars[cvarName] = ignore
	end
end


do
	local PADDING = 10
	local BUTTON_HEIGHT = 16
	local BUTTON_WIDTH = 135

	local function OnClick(btn)
		btn.func()

		btn:GetParent():Hide()
	end

	local function OnEnter(btn)
		btn.hoverTex:Show()
		btn:GetParent().elapsed = 0
	end

	local function OnLeave(btn)
		btn.hoverTex:Hide()
		btn:GetParent().elapsed = 0
	end

	function E:DropDown(list, frame, xOffset, yOffset)
		if not frame.buttons then
			frame.buttons = {}
			frame:SetFrameStrata("DIALOG")
			frame:SetClampedToScreen(true)
	--		tinsert(UISpecialFrames, frame:GetName())
			frame:Hide()
		end

		xOffset = xOffset or 0
		yOffset = yOffset or 0

		for i=1, #frame.buttons do
			frame.buttons[i]:Hide()
		end

		for i=1, #list do
			if not frame.buttons[i] then
				frame.buttons[i] = CreateFrame("Button", nil, frame)

				frame.buttons[i].hoverTex = frame.buttons[i]:CreateTexture(nil, 'OVERLAY')
				frame.buttons[i].hoverTex:SetAllPoints()
				frame.buttons[i].hoverTex:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
				frame.buttons[i].hoverTex:SetBlendMode("ADD")
				frame.buttons[i].hoverTex:Hide()

				frame.buttons[i].text = frame.buttons[i]:CreateFontString(nil, 'BORDER')
				frame.buttons[i].text:SetAllPoints()
				frame.buttons[i].text:SetFont(STANDARD_TEXT_FONT, 10, 'NONE') 
				frame.buttons[i].text:SetJustifyH("LEFT")

				frame.buttons[i]:SetScript("OnEnter", OnEnter)
				frame.buttons[i]:SetScript("OnLeave", OnLeave)
			end

			frame.buttons[i]:Show()
			frame.buttons[i]:SetHeight(BUTTON_HEIGHT)
			frame.buttons[i]:SetWidth(BUTTON_WIDTH)
			frame.buttons[i].text:SetText(list[i].text)
			frame.buttons[i].func = list[i].func
			frame.buttons[i]:SetScript("OnClick", OnClick)

			if i == 1 then
				frame.buttons[i]:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
			else
				frame.buttons[i]:SetPoint("TOPLEFT", frame.buttons[i-1], "BOTTOMLEFT")
			end
		end

		frame:SetHeight((#list * BUTTON_HEIGHT) + PADDING * 2)
		frame:SetWidth(BUTTON_WIDTH + PADDING * 2)

		local UIScale = UIParent:GetScale();
		local x, y = GetCursorPosition();
		x = x/UIScale
		y = y/UIScale
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x + xOffset, y + yOffset)
		frame:SetScript('OnUpdate', function(self, elapsed)
			frame.elapsed = ( frame.elapsed or 0 ) + elapsed
			if frame.elapsed < 3 then return end
			frame.elapsed = 0	
			ToggleFrame(self)
		end)
		frame:SetScript('OnShow', function(self)
			self.elapsed = 0
		end)
		frame:SetScript('OnHide', function(self)
			self.elapsed = 0
		end)
		
		ToggleFrame(frame)
	end
end

do
	local list = {}
	local list2 = {}
	local list3 = {}
	local list4 = {}
	
	local type = type
	local tinsert = table.insert

	local function trueFunction(...)
		print('[Error Trace]', ...)
		return true;
	end

	function E:OnInit(func)
		if not func then return end
		if type(func) == "function" then
			tinsert(list, func)
		elseif type(func) == "string" and E[func] then
			tinsert(list, E[func])
		end
	end
	function E:InitFrames()
		for i, func in ipairs(list) do		
			local status, ret, err = xpcall(func, trueFunction)

			-- print (status)
			-- print (ret)
			-- print (err)
		end		
		wipe(list)
	end
	
	
	function E:OnInit2(func)
		if not func then return end
		if type(func) == "function" then
			tinsert(list2, func)
		elseif type(func) == "string" and E[func] then
			tinsert(list2, E[func])
		end
	end	
	function E:InitFrames2()
		for i, func in ipairs(list2) do
			local status, ret, err = xpcall(func, trueFunction)

			--print (status)
			--print (ret)
			--print (err)
		end	
		wipe(list2)
	end
	
	
	function E:OnPostInit(func)
		if not func then return end
		if type(func) == "function" then
			tinsert(list3, func)
		elseif type(func) == "string" and E[func] then
			tinsert(list3, E[func])
		end
	end
	function E:InitFrames3()
		for i, func in ipairs(list3) do		
			local status, ret, err = xpcall(func, trueFunction)

			--print (status)
			--print (ret)
			--print (err)
		end		
		wipe(list3)
	end
	
	function E:OnPostInit2(func)
		if not func then return end
		if type(func) == "function" then
			tinsert(list4, func)
		elseif type(func) == "string" and E[func] then
			tinsert(list4, E[func])
		end
	end
	function E:InitFrames4()
		for i, func in ipairs(list4) do		
			local status, ret, err = xpcall(func, trueFunction)

			--print (status)
			--print (ret)
			--print (err)
		end		
		wipe(list4)
	end
end


do -- other non-english locales require this
	E.UnlocalizedClasses = {}
	for k,v in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do E.UnlocalizedClasses[v] = k end
	for k,v in pairs(_G.LOCALIZED_CLASS_NAMES_FEMALE) do E.UnlocalizedClasses[v] = k end

	function E:UnlocalizedClassName(className)
		return (className and className ~= '') and E.UnlocalizedClasses[className]
	end
end

do
	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
	local modules = {}
	
	function E:Module(name)
	
		if not modules[name] then
			modules[name] = CreateFrame("Frame", "AleaUI"..name.."Module")
			modules[name]:SetScript("OnEvent", function(self, event, ...)
				if not self[event] then 
					error('Unused event '..event) 
				end

				if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
					self[event](self, event, CombatLogGetCurrentEventInfo())
				else
					self[event](self, event, ...)
				end
			end)
			
			
			modules[name].Register = function(self, events)
				for k,v in pairs(events) do
					self:RegisterEvent(v)				
				end
			end
		end
		
		return modules[name]
	end
end

do	
	local list = {}
	local function OnAddonLoad(core, addon, func)
		if not list[addon] then list[addon] = {} end
		list[addon][#list[addon]+1] = func
	end
	
	local onaddonloaded = CreateFrame("Frame")
	onaddonloaded:RegisterEvent("ADDON_LOADED")
	onaddonloaded:SetScript("OnEvent", function(self, event, addon, ...)	
		if list[addon] then
			for i=1, #list[addon] do
				list[addon][i]()
			end
		end
	end)
	
	E.OnAddonLoad = OnAddonLoad
end

do
	local function HideTip2(frame) GameTooltip:Hide(); ResetCursor(); frame:UnregisterEvent('MODIFIER_STATE_CHANGED'); end
	local function SetItemTip(frame)
		if not frame.link then return end
		
		frame:RegisterEvent('MODIFIER_STATE_CHANGED')
		
		GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT")

		GameTooltip:SetHyperlink(frame.link)
	
		if IsShiftKeyDown() then 
			GameTooltip_ShowCompareItem() 
		end
		if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
	end
	local function LootClick(frame)
		if IsControlKeyDown() then DressUpItemLink(frame.link)
		elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
	end
	
	E.HideTip2 = HideTip2
	E.SetItemTip = SetItemTip
	E.LootClick = LootClick
end

do
	local GetItemInfo = GetItemInfo
	
		-- rarity 6
			-- classID 2  4, offhand
			
			
	function E:ItemIsArtifact(link)
		if link then
			local _, _, itemRarity, _, _, _, _, _, _, _, _, classID = GetItemInfo(link)
			return ( itemRarity == 6 ) --and ( classID == 2 or classID == 4 ) )
		end
		
		return false
	end
	
end

do

	-- Construct your saarch pattern based on the existing global string:
	local S_UPGRADE_LEVEL   = "^" .. gsub(ITEM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)")
	local ITEM_LEVEL_PATTERN =  '^'..ITEM_LEVEL:gsub('%%d', '(%%d+)')
	local ITEM_UPGRADE_TOOLTIP_FORMAT_PATTERN = '^'..ITEM_UPGRADE_TOOLTIP_FORMAT:gsub('%%d', '(%%d+)')

	-- Create the tooltip:
	local scantip = CreateFrame("GameTooltip", "AleaUIScanningTooltip", nil, "GameTooltipTemplate")
	scantip:SetOwner(UIParent, "ANCHOR_NONE")
	scantip:SetScript('OnTooltipAddMoney', function()end)
	scantip:SetScript('OnTooltipCleared', function()end)
	scantip:SetScript('OnHide', function()end)
	scantip:SetScript('OnTooltipSetDefaultAnchor',function()end)
	
	E.scantip = scantip
	
	-- Create a function for simplicity's sake:
	--local tempItemLinkItemLevel = {}
	
	local function GetItemUpgradeLevel(itemLink)
		local itemLevel = itemLink and GetDetailedItemLevelInfo(itemLink)
		
		return itemLevel
	end

	local function GetItemItemLevel( unit, id )
		scantip:ClearLines()
		scantip:SetInventoryItem( unit, id )
		
		local link = GetInventoryItemLink(unit, id)
		local itemLevel = link and GetDetailedItemLevelInfo(link)
		
		return itemLevel
	end
	
	function E.ScanTooltip(str, doNotClear)
	
		if not str then return end
		
		if not doNotClear then
			scantip:ClearLines()
		end
		
	--	print('T', 'CheckForContainTooltip', link)
		
		for i = 1, scantip:NumLines() do		
			local left = _G[scantip:GetName().."TextLeft"..i]:GetText()
			local right = _G[scantip:GetName().."TextRight"..i]:GetText()
			
			if left then
				local result = string.match(left, str)
				if result then
					
			--		print('T', 'CheckForContainTooltip', 'left', 'result', result, left)
					
					return result, left
				end
			end
			
			if right then
				local result = string.match(right, str)
				if result then
					
			--		print('T', 'CheckForContainTooltip', 'right', 'result', result, right)
					
					return result, right
				end
			end
		end
		
		return false
	end
	
	E.GetItemItemLevel = GetItemItemLevel
	E.GetItemUpgradeLevel = GetItemUpgradeLevel
end

do
	local queue = {}

	local tremove = table.remove
	
	local handler = CreateFrame("Frame")
	handler.elapsed = 0
	handler:Hide()
	handler:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		
		if self.elapsed < 0.005 then return end
		self.elapsed = 0
		
		local hide = true
		
		local numMax = math.max(3, #queue*0.1)
		
		for i=1, numMax do
			local d = queue[i]
			if d then
				if d.func and type(d.func) == 'string' then
					E[d.func](unpack(d.args))
					tremove(queue, i)
					hide = false
				elseif d.func and type(d.func) == 'function' then
					d.func(unpack(d.args))
					tremove(queue, i)
					hide = false
				end
			end
		end
		
	--	print(#queue)
		
		if hide then
			self:Hide()
		end
	end)
	
	function E.QueueForRun(tag, func, ...)	
		if tag then	
			local add = true
			
			for i=1, #queue do
				if queue[i].tag == tag then
					--print('Skip', tag)
					add = false
					break
				end
			end
			
			if add then
				queue[#queue+1] = { 
					tag = tag, 
					func = func, 
					args = { ... } 
				}
				
				handler:Show()
			end
		else
			queue[#queue+1] = { 
				tag = tag, 
				func = func, 
				args = { ... } 
			}
			handler:Show()
		end
	end
	
end

do
	-- Kui Nameplates fader	
	-- Frame fading functions
	-- (without the taint of UIFrameFade & the lag of AnimationGroups)
	
	local frameFadeFrame = CreateFrame('Frame')
	local FADEFRAMES = {}

	E.frameIsFading = function(frame)
		for index, value in pairs(FADEFRAMES) do
			if value == frame then
				return true
			end
		end
	end
	E.frameFadeRemoveFrame = function(frame)
		tDeleteItem(FADEFRAMES, frame)
	end
	E.frameFadeOnUpdate = function(self, elapsed)
		local frame, info
		for index, value in pairs(FADEFRAMES) do
			frame, info = value, value.fadeInfo

			if info.startDelay and info.startDelay > 0 then
				info.startDelay = info.startDelay - elapsed
			else
				info.fadeTimer = (info.fadeTimer and info.fadeTimer + elapsed) or 0

				if info.fadeTimer < info.timeToFade then
					-- perform animation in either direction
					if info.mode == 'IN' then
						frame:SetAlpha(
							(info.fadeTimer / info.timeToFade) *
							(info.endAlpha - info.startAlpha) +
							info.startAlpha
						)
					elseif info.mode == 'OUT' then
						frame:SetAlpha(
							((info.timeToFade - info.fadeTimer) / info.timeToFade) *
							(info.startAlpha - info.endAlpha) + info.endAlpha
						)
					end
				else
					-- animation has ended
					frame:SetAlpha(info.endAlpha)

					if info.fadeHoldTime and info.fadeHoldTime > 0 then
						info.fadeHoldTime = info.fadeHoldTime - elapsed
					else
						E.frameFadeRemoveFrame(frame)

						if info.finishedFunc then
							info.finishedFunc(frame)
							info.finishedFunc = nil
						end
					end
				end
			end
		end

		if #FADEFRAMES == 0 then
			self:SetScript('OnUpdate', nil)
		end
	end
	--[[
		info = {
			mode            = "IN" (nil) or "OUT",
			startAlpha      = alpha value to start at,
			endAlpha        = alpha value to end at,
			timeToFade      = duration of animation,
			startDelay      = seconds to wait before starting animation,
			fadeHoldTime    = seconds to wait after ending animation before calling finishedFunc,
			finishedFunc    = function to call after animation has ended,
		}

		If you plan to reuse `info`, it should be passed as a single table,
		NOT a reference, as the table will be directly edited.
	]]
	E.frameFade = function(frame, info)
		if not frame then return end
		if E.frameIsFading(frame) then
			-- cancel the current operation
			-- the code calling this should make sure not to interrupt a
			-- necessary finishedFunc. This will entirely skip it.
			E.frameFadeRemoveFrame(frame)
		end

		info        = info or {}
		info.mode   = info.mode or 'IN'

		if info.mode == 'IN' then
			info.startAlpha = info.startAlpha or 0
			info.endAlpha   = info.endAlpha or 1
		elseif info.mode == 'OUT' then
			info.startAlpha = info.startAlpha or 1
			info.endAlpha   = info.endAlpha or 0
		end

		frame:SetAlpha(info.startAlpha)
		frame.fadeInfo = info

		tinsert(FADEFRAMES, frame)
		frameFadeFrame:SetScript('OnUpdate', E.frameFadeOnUpdate)
	end
end

do
	local GetTalentInfo = GetTalentInfo
	local MAX_TALENT_TIERS = MAX_TALENT_TIERS
	local GetActiveSpecGroup = GetActiveSpecGroup
	
	local function IsTalentKnown(spellID)
		for i=1, MAX_TALENT_TIERS do
			for a=1, 3 do
				local talentID, name, texture, selected, availible, spellID_talent = GetTalentInfo(i, a, GetActiveSpecGroup())

				if selected then
					if spellID == spellID_talent then
						return true
					end
				end
			end
		end
		
		return false
	end

	E.IsTalentKnown = IsTalentKnown
end	

do

	
	function E:GetRelativePoint(parent)
		local ResolutionH = E.UIParent:GetRight()
		local ResolutionV = E.UIParent:GetTop()
		
		local HPoint = ResolutionH*0.5
		local VPoint = ResolutionV*0.5
		
		local p1, p2, p3, p4 = nil, nil, nil, nil
		local p5, p6 = 0, 0
		if ResolutionH - parent:GetRight() > HPoint then
			p2 = 'RIGHT'
			p4 = 'LEFT'
		else
			p2 = 'LEFT'
			p4 = 'RIGHT'
		end
		
		if ResolutionV - parent:GetTop() > VPoint then
			p1 = 'TOP'
			p3 = 'BOTTOM'
			p6 = 3
		else
			p1 = 'BOTTOM'
			p3 = 'TOP'
			p6 = -3
		end
		
		return	p1, p2, p3, p4, p5, p6
	end
end

--Return short value of a number
do
	local abs = abs
	local format = format
	
	function E:ShortValue(v)
		if E.db.numberPrefixStyle == "METRIC" then
			if abs(v) >= 1e9 then
				return format("%.1fG", v / 1e9)
			elseif abs(v) >= 1e6 then
				return format("%.1fM", v / 1e6)
			elseif abs(v) >= 1e3 then
				return format("%.1fk", v / 1e3)
			else
				return format("%d", v)
			end
		elseif E.db.numberPrefixStyle == "CHINESE" then
			if abs(v) >= 1e8 then
				return format("%.1fY", v / 1e8)
			elseif abs(v) >= 1e4 then
				return format("%.1fW", v / 1e4)
			else
				return format("%d", v)
			end
		else
			if abs(v) >= 1e9 then
				return format("%.1fB", v / 1e9)
			elseif abs(v) >= 1e6 then
				return format("%.1fM", v / 1e6)
			elseif abs(v) >= 1e3 then
				return format("%.1fK", v / 1e3)
			else
				return format("%d", v)
			end
		end
	end
end

do
	local day, hour, minute = 86400, 3600, 60
	
    local format = string.format
    local ceil = math.ceil
	local floor = math.floor
	local fmod = math.fmod
	
	local hf = L['HOUR_FORMAT_TIME']
	local df = L['DAY_FORMAT_TIME']
	local mf = L['MINUTE_FORMAT_TIME']
	local sf = L['SECONDS_FORMAT_TIME']
	
	local format_dd = '%d'..df
	
	local format_dh = '%d'..hf
	local format_dm = '%d'..mf
	local format_ds = '%d'..sf

	local format_fs0 = '%.0f'..sf
	local format_fs1 = '%.1f'..sf

	local format_full_dm = "%d:%0.2d"..mf
	
	local formats = {
		function(s)  -- 1d 1h, 2m, 119s, 29.9
			if s >= day then
				return (format_dd):format(ceil(s / day))
			elseif s >= hour then
				return (format_dh):format(ceil(s / hour))
			elseif s >= minute then
				return (format_dm):format(ceil(s / minute))
			elseif s >= 30 then
				return (format_ds):format(ceil(s))
			end
			return ("%.1f"):format(s)
		end,
		function(s) -- 1d 1h, 2m, 1:11m, 59s, 10s, 1s
			if s >= day then
				return (format_dd):format(ceil(s / day))
			elseif s >= hour then
				return (format_dh):format(ceil(s / hour))
			elseif s <= minute then
				return (format_fs0):format(ceil(s))
			else
				return (format_full_dm):format(s/minute, fmod(s, minute))
			end
		end,
		function(s) -- 1d 1h, 2m, 1:11m, 59.1s, 10.2s, 1.1s
			if s >= day then
				return (format_dd):format(ceil(s / day))
			elseif s >= hour then
				return (format_dh):format(ceil(s / hour))
			elseif s <= minute then
				return (format_fs1):format(s)
			else
				return (format_full_dm):format(s/minute, fmod(s, minute))
			end
		end,		
		function(s) -- 1d 1h, 2m, 1:11, 59, 10, 1
			if s >= day then
				return (format_dd):format(ceil(s / day))
			elseif s >= hour then
				return (format_dh):format(ceil(s / hour))
			elseif s <= minute then
				return ("%.0f"):format(ceil(s))
			else
				return ("%d:%0.2d"):format(s/minute, fmod(s, minute))
			end
		end,
		function(s) -- 1d 1h, 2m, 1:11, 59.1, 10.2, 1.1
			if s >= day then
				return (format_dd):format(ceil(s / day))
			elseif s >= hour then
				return (format_dh):format(ceil(s / hour))				
			elseif s > minute then
				return ("%d:%0.2d"):format(s/minute, fmod(s, minute))
			end

			return ("%.1f"):format(s)
		end,
		function(s)  -- 1d 1h, 1m, 40, 1
			if s >= day then
				return (format_dd):format(ceil(s / day))
			elseif s >= hour then
				return (format_dh):format(ceil(s / hour))
			elseif s >= minute then
				return (format_dm):format(ceil(s / minute))
			end
			return ("%d"):format(ceil(s))
		end,
		function(s)  -- 1d, 1h, 1:11, 0:01
			if s >= day then
				return (format_dd):format(ceil(s / day))
			elseif s >= hour then
				return (format_dh):format(ceil(s / hour))
			end
			return ("%d:%0.2d"):format(s/minute, fmod(s, minute))
		end,		
	}
	
	
	local RED = "|cFFFF0000"
	local YELLOW = '|cFFFFFF00'
	local CYAN = '|cFF00FFFF'
	
	E.TimeFormatList = {
		'1m, 29.9',
		'1:11m, 59s, 10s, 1s',
		'1:11m, 59.1s, 10.2s, 1.1s',
		'1:11, 59, 10, 1',
		'1:11, 59.1, 10.2, 1.1',
		'1m, 40, 1',
		'1:11, 0:01',
	}
	
	E.TimeFormatListBuffs = {
		[2] = E.TimeFormatList[2],
		[5] = E.TimeFormatList[5],
		[6] = E.TimeFormatList[6],
		[7] = E.TimeFormatList[7],
	}
	
    function E.FormatTime(t, s, colored)
		t = formats[t] and t or 1
		
		if colored then
			if s > 60 then
				return CYAN..formats[t](s)
			elseif s > 3 then
				return YELLOW..formats[t](s)
			else
				return RED..formats[t](s)
			end
		else
			return formats[t](s)
		end
    end

end

do
	E.PowerType = {}	
	E.PowerType.HealthCost = -2
	E.PowerType.None = -1
	E.PowerType.Mana = 0
	E.PowerType.Rage = 1
	E.PowerType.Focus = 2
	E.PowerType.Energy = 3
	E.PowerType.ComboPoints = 4
	E.PowerType.Runes = 5
	E.PowerType.RunicPower = 6
	E.PowerType.SoulShards = 7
	E.PowerType.LunarPower = 8
	E.PowerType.HolyPower = 9
	E.PowerType.Alternate = 10
	E.PowerType.Maelstrom = 11
	E.PowerType.Chi = 12
	E.PowerType.Insanity = 13
	E.PowerType.Obsolete = 14
	E.PowerType.Obsolete2 = 15
	E.PowerType.ArcaneCharges = 16
	E.PowerType.Fury = 17
	E.PowerType.Pain = 18
	E.PowerType.NumPowerTypes = 19
	
	--[==[
		PowerBarColor[0] = PowerBarColor["MANA"];
		PowerBarColor[1] = PowerBarColor["RAGE"];
		PowerBarColor[2] = PowerBarColor["FOCUS"];
		PowerBarColor[3] = PowerBarColor["ENERGY"];
		PowerBarColor[4] = PowerBarColor["CHI"];
		PowerBarColor[5] = PowerBarColor["RUNES"];
		PowerBarColor[6] = PowerBarColor["RUNIC_POWER"];
		PowerBarColor[7] = PowerBarColor["SOUL_SHARDS"];
		PowerBarColor[8] = PowerBarColor["LUNAR_POWER"];
		PowerBarColor[9] = PowerBarColor["HOLY_POWER"];
		PowerBarColor[11] = PowerBarColor["MAELSTROM"];
		PowerBarColor[13] = PowerBarColor["INSANITY"];
		PowerBarColor[17] = PowerBarColor["FURY"];
		PowerBarColor[18] = PowerBarColor["PAIN"];
	]==]
	
	E.PowerTypeString = {}
	E.PowerTypeString.Mana = 'MANA'
	E.PowerTypeString.Rage = 'RAGE'
	E.PowerTypeString.Focus = 'FOCUS'
	E.PowerTypeString.Energy = 'ENERGY'
	E.PowerTypeString.ComboPoints = 'COMBO_POINTS'
	E.PowerTypeString.Runes = 'RUNES'
	E.PowerTypeString.RunicPower = 'RUNIC_POWER'
	E.PowerTypeString.SoulShards = 'SOUL_SHARDS'
	E.PowerTypeString.LunarPower = 'LUNAR_POWER'
	E.PowerTypeString.HolyPower = 'HOLY_POWER'
	E.PowerTypeString.Maelstrom = 'MAELSTROM'
	E.PowerTypeString.Chi = 'CHI'
	E.PowerTypeString.Insanity = 'INSANITY'
	E.PowerTypeString.ArcaneCharges = 'ARCANE_CHARGES'
	E.PowerTypeString.Fury = 'FURY'
	E.PowerTypeString.Pain = 'PAIN'
end

do
	function E.EasyMenu(...)		
		if Lib_EasyMenu then
			Lib_EasyMenu(...)
		else
			EasyMenu(...)
		end
	end
end

do
	--[==[
	local guid, name = UnitGUID("target"), UnitName("target")
	local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
	print(name .. " is a " .. type);
	if type == "Creature" then
	 print(name .. "'s NPC id is " .. npc_id)
	elseif type == "Vignette" then
	 print(name .. " is a Vignette and should have its npc_id be zero (" .. npc_id .. ").")
	elseif type == "Player" then
	 print(name .. " is a player.")
	end
	]==]
	
	function E.GetNpcID(unit)
		local guid = UnitGUID(unit or '')
		
		if guid then
			local type, _, _, _, _, npc_id = strsplit("-",guid);			
			if type ~= 'Player' then
				return tonumber(npc_id)
			end
		end	
		
		return false
	end
end