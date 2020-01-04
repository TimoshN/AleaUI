local E = AleaUI
local DT = E:Module('DataText')
local UF = E:Module("UnitFrames")
local L = E.L

-- localized references for global functions (about 50% faster)
local join 			= string.join
local format		= string.format
local find			= string.find
local gsub			= string.gsub
local sort			= table.sort
local ceil			= math.ceil
local split 		= string.split

local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local groupedTable = { "|cffaaaaaa*|r", "" } 
local displayString = ""
local noGuildString = ""
local guildInfoString = "%s [%d]"
local guildInfoString2 = join("", GUILD, ": %d/%d")
local guildMotDString = "%s |cffaaaaaa- |cffffffff%s"
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
local levelNameStatusString = "|cff%02x%02x%02x%d|r %s%s %s"
local nameRankString = "%s |cff999999-|cffffffff %s"
local guildXpCurrentString = gsub(join("", E.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b), GUILD_EXPERIENCE_CURRENT), ": ", ":|r |cffffffff", 1)
local guildXpDailyString = gsub(join("",  E.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b), GUILD_EXPERIENCE_DAILY), ": ", ":|r |cffffffff", 1)
local standingString = join("",  E.RGBToHex(ttsubh.r*255, ttsubh.g*255, ttsubh.b*255), "%s:|r |cFFFFFFFF%s/%s (%s%%)")
local moreMembersOnlineString = join("", "+ %d ", FRIENDS_LIST_ONLINE, "...")
local noteString = join("", "|cff999999   ", LABEL_NOTE, ":|r %s")
local officerNoteString = join("", "|cff999999   ", GUILD_RANK1_DESC, ":|r %s")
local guildTable, guildXP, guildMotD = {}, {}, ""
local MOBILE_BUSY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t";
local MOBILE_AWAY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t";
local lastPanel

local function SortGuildTable(shift)
	sort(guildTable, function(a, b)
		if a and b then
			if shift then
				return a[10] < b[10]
			else
				return a[1] < b[1]
			end
		end
	end)
end

local chatframetexture = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
local onlinestatusstring = "|cffFFFFFF[|r|cffFF0000%s|r|cffFFFFFF]|r"
local onlinestatus = {
	[0] = function () return '' end,
	[1] = function () return format(onlinestatusstring, 'AFK') end,
	[2] = function () return format(onlinestatusstring, 'DND') end,
}
local mobilestatus = {
	[0] = function () return chatframetexture end,
	[1] = function () return MOBILE_AWAY_ICON end,
	[2] = function () return MOBILE_BUSY_ICON end,
}

local function BuildGuildTable()
	wipe(guildTable)
	local statusInfo
	local _, name, rank, level, zone, note, officernote, connected, memberstatus, class, isMobile, rankIndex
	
	local totalMembers = GetNumGuildMembers()
	for i = 1, totalMembers do
		name, rank, rankIndex, level, _, zone, note, officernote, connected, memberstatus, class, _, _, isMobile = GetGuildRosterInfo(i)

		statusInfo = isMobile and mobilestatus[memberstatus]() or onlinestatus[memberstatus]()
		zone = (isMobile and not connected) and REMOTE_CHAT or zone

		if connected or isMobile then 
			guildTable[#guildTable + 1] = { name, rank, level, zone, note, officernote, connected, statusInfo, class, rankIndex, isMobile }
		end
	end
end

local function UpdateGuildXP()
	local currentXP, remainingXP = 0, 0 --UnitGetGuildXP("player")
	local nextLevelXP = currentXP + remainingXP
	local percentTotal
	if currentXP > 0 and nextLevelXP > 0  then
		percentTotal = ceil((currentXP / nextLevelXP) * 100)
	else 
		percentTotal = 0
	end
	
	guildXP[0] = { currentXP, nextLevelXP, percentTotal }
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local FRIEND_ONLINE = select(2, split(" ", ERR_FRIEND_ONLINE_SS, 2))
local resendRequest = false
local eventHandlers = {
	['CHAT_MSG_SYSTEM'] = function(self, arg1)
		if(FRIEND_ONLINE ~= nil and arg1 and arg1:find(FRIEND_ONLINE)) then
			resendRequest = true
		end
	end,
	-- when we enter the world and guildframe is not available then
	-- load guild frame, update guild message and guild xp	
	["PLAYER_ENTERING_WORLD"] = function (self, arg1)
	
		if not GuildFrame and IsInGuild() then 
			LoadAddOn("Blizzard_GuildUI")
			UpdateGuildXP() 
			GuildRoster() 
		end
	end,
	-- Guild Roster updated, so rebuild the guild table
	["GUILD_ROSTER_UPDATE"] = function (self)
		if(resendRequest) then
			resendRequest = false;
			return GuildRoster()
		else
			BuildGuildTable()
			UpdateGuildMessage()
			if GetMouseFocus() == self then
				self:GetScript("OnEnter")(self, nil, true)
			end
		end
	end,
	-- our guild xp changed, recalculate it	
	["GUILD_XP_UPDATE"] = function (self, arg1)
		UpdateGuildXP()
	end,
	["PLAYER_GUILD_UPDATE"] = function (self, arg1)
		GuildRoster()
	end,
	-- our guild message of the day changed
	["GUILD_MOTD"] = function (self, arg1)
		guildMotD = arg1
	end,
}


local function OnEvent(self, event, ...)
	lastPanel = self
	
	if IsInGuild() then
		assert(eventHandlers[event], "Error on event ("..tostring(event)..")")
		eventHandlers[event](self, select(1, ...))

		self.text:SetFormattedText(displayString, #guildTable)
	else
		self.text:SetText(noGuildString)
	end	
end

local menuFrame = CreateFrame("Frame", "GuildDatatTextRightClickMenu",AleaUI.UIParent, (Lib_EasyMenu and 'Lib_UIDropDownMenuTemplate' or "UIDropDownMenuTemplate") )
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true, notCheckable=true},
	{ text = INVITE, hasArrow = true, notCheckable=true,},
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true,}
}

local function inviteClick(self, playerName)
	menuFrame:Hide()
	InviteUnit(playerName)
end

local function whisperClick(self, playerName)
	menuFrame:Hide()
	SetItemRef( "player:"..playerName, ("|Hplayer:%1$s|h[%1$s]|h"):format(playerName), "LeftButton" )
end

local function ToggleGuildFrame()
	if IsInGuild() then
		if not GuildFrame then GuildFrame_LoadUI() end
		GuildFrame_Toggle()
	else
		if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end
		if LookingForGuildFrame then 
			LookingForGuildFrame_Toggle()
		end
	end
end

local function Click(self, btn)
	if btn == "RightButton" and IsInGuild() then
		DT.tooltip:Hide()

		local classc, levelc, grouped, info
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		for i = 1, #guildTable do
			info = guildTable[i]
			if info[7] and info[1] ~= AleaUI.myname then
				local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]], GetQuestDifficultyColor(info[3])
				if UnitInParty(info[1]) or UnitInRaid(info[1]) then
					grouped = "|cffaaaaaa*|r"
				elseif not info[11] then
					menuCountInvites = menuCountInvites + 1
					grouped = ""
					menuList[2].menuList[menuCountInvites] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], ""), arg1 = info[1],notCheckable=true, func = inviteClick}
				end
				menuCountWhispers = menuCountWhispers + 1
				if not grouped then grouped = "" end
				menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString, levelc.r*255,levelc.g*255,levelc.b*255, info[3], classc.r*255,classc.g*255,classc.b*255, info[1], grouped), arg1 = info[1],notCheckable=true, func = whisperClick}
			end
		end

		E.EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)	
	else
		ToggleGuildFrame()
	end
end

local function OnEnter(self, _, noUpdate)
	if not IsInGuild() then return end

	DT:SetupTooltip(self)
	
	local total, _, online = GetNumGuildMembers()
	if #guildTable == 0 then BuildGuildTable() end

	SortGuildTable(IsShiftKeyDown())

	local guildName, guildRank = GetGuildInfo('player')

	if guildName and guildRank then
		DT.tooltip:AddDoubleLine(format(guildInfoString, guildName), format(guildInfoString2, online, total),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
		DT.tooltip:AddLine(guildRank, unpack(tthead))
	end
	
	if guildMotD ~= "" then 
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1) 
	end
	
	local col =  AleaUI.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b)
	
	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	if standingID ~= 8 then -- Not Max Rep
		barMax = barMax - barMin
		barValue = barValue - barMin
		barMin = 0
		DT.tooltip:AddLine(format(standingString, COMBAT_FACTION_CHANGE, E:ShortValue(barValue), E:ShortValue(barMax), ceil((barValue / barMax) * 100)))
	end
	
	local zonec, classc, levelc, info, grouped
	local shown = 0
	
	DT.tooltip:AddLine(' ')
	for i = 1, #guildTable do
		-- if more then 30 guild members are online, we don't Show any more, but inform user there are more
		if 30 - shown <= 1 then
			if online - 30 > 1 then DT.tooltip:AddLine(format(moreMembersOnlineString, online - 30), ttsubh.r, ttsubh.g, ttsubh.b) end
			break
		end

		info = guildTable[i]
		if GetRealZoneText() == info[4] then zonec = activezone else zonec = inactivezone end
		classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[9]], GetQuestDifficultyColor(info[3])
		
		if (UnitInParty(info[1]) or UnitInRaid(info[1])) then grouped = 1 else grouped = 2 end

		if IsShiftKeyDown() then
			DT.tooltip:AddDoubleLine(format(nameRankString, info[1], info[2]), info[4], classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
			if info[5] ~= "" then DT.tooltip:AddLine(format(noteString, info[5]), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
			if info[6] ~= "" then DT.tooltip:AddLine(format(officerNoteString, info[6]), ttoff.r, ttoff.g, ttoff.b, 1) end
		else
			DT.tooltip:AddDoubleLine(format(levelNameStatusString, levelc.r*255, levelc.g*255, levelc.b*255, info[3], split("-", info[1]), groupedTable[grouped], info[8]), info[4], classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b)
		end
		shown = shown + 1
	end	
	
	DT.tooltip:Show()
	
	if not noUpdate then
		GuildRoster()
	end	
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", GUILD, ": ", hex, "%d|r")
	noGuildString = join("", hex, L['No Guild'])

end

ValueColorUpdate("|cFFFFFFFF")

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]

DT:RegisterDatatext('Guild', {'PLAYER_ENTERING_WORLD', 'CHAT_MSG_SYSTEM', "GUILD_ROSTER_UPDATE", "PLAYER_GUILD_UPDATE", "GUILD_MOTD"}, OnEvent, nil, Click, OnEnter)