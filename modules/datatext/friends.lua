local E = AleaUI
local DT = E:Module('DataText')
local L = E.L

if ( E.isClassic ) then 
	return 
end

-- create a popup
local BNGetNumFriendToons = BNGetNumFriendToons or BNGetNumFriendGameAccounts
local BNGetFriendToonInfo = BNGetFriendToonInfo or BNGetFriendGameAccountInfo
local BNGetToonInfo = BNGetToonInfo or BNGetGameAccountInfo

if not DT.PopupDialogs then DT.PopupDialogs = {} end
DT.PopupDialogs.SET_BN_BROADCAST = {
	text = BN_BROADCAST_TOOLTIP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
	OnShow = function(self) self.editBox:SetText(select(4, BNGetInfo()) ) self.editBox:SetFocus() end,
	OnHide = ChatEdit_FocusActiveWindow,
	EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	preferredIndex = 3
}

-- localized references for global functions (about 50% faster)
local join 			= string.join
local find			= string.find
local format		= string.format
local sort			= table.sort

local menuFrame = CreateFrame("Frame", "FriendDatatextRightClickMenu", E.UIParent, (Lib_EasyMenu and 'Lib_UIDropDownMenuTemplate' or "UIDropDownMenuTemplate") )
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true,notCheckable=true},
	{ text = INVITE, hasArrow = true,notCheckable=true, },
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true,notCheckable=true, },
	{ text = PLAYER_STATUS, hasArrow = true, notCheckable=true,
		menuList = {
			{ text = "|cff2BC226"..AVAILABLE.."|r", notCheckable=true, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffE7E716"..DND.."|r", notCheckable=true, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffFF0000"..AFK.."|r", notCheckable=true, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end },
		},
	},
	{ text = BN_BROADCAST_TOOLTIP, notCheckable=true, func = function() DT:StaticPopup_Show("SET_BN_BROADCAST") end },
}

local function inviteClick(self, name)
	menuFrame:Hide()
	
	if true then return end
	
	if type(name) ~= 'number' then
		InviteUnit(name)
	else
		BNInviteFriend(name);
	end
end

local function whisperClick(self, name, battleNet)
	menuFrame:Hide() 
	
	if battleNet then
		ChatFrame_SendSmartTell(name)
	else
		SetItemRef( "player:"..name, ("|Hplayer:%1$s|h[%1$s]|h"):format(name), "LeftButton" )		 
	end
end

local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s"
local worldOfWarcraftString = WORLD_OF_WARCRAFT
local battleNetString = BATTLENET_OPTIONS_LABEL
local wowString, scString, d3String, wtcgString, appString, overwatchString = BNET_CLIENT_WOW, BNET_CLIENT_SC2, BNET_CLIENT_D3, BNET_CLIENT_WTCG, BNET_CLIENT_APP, BNET_CLIENT_OVERWATCH
local hotsString = BNET_CLIENT_HEROES
local totalOnlineString = join("", FRIENDS_LIST_ONLINE, ": %s/%s")
local tthead, ttsubh, ttoff = {r=0.4, g=0.78, b=1}, {r=0.75, g=0.9, b=1}, {r=.3,g=1,b=.3}
local activezone, inactivezone = {r=0.3, g=1.0, b=0.3}, {r=0.65, g=0.65, b=0.65}
local displayString = ''
local statusTable = { "|cffFFFFFF[|r|cffFF0000"..'AFK'.."|r|cffFFFFFF]|r", "|cffFFFFFF[|r|cffFF0000"..'DND'.."|r|cffFFFFFF]|r", "" }
local groupedTable = { "|cffaaaaaa*|r", "" } 
local friendTable, BNTable, BNTableWoW, BNTableD3, BNTableSC, BNTableWTCG, BNTableApp, BNTableHero, BNTableOverwatch = {}, {}, {}, {}, {}, {}, {}, {}, {}
local tableList = {[wowString] = BNTableWoW, [d3String] = BNTableD3, [scString] = BNTableSC, [wtcgString] = BNTableWTCG, [hotsString] = BNTableHero, [overwatchString] = BNTableOverwatch, [appString] = BNTableApp }
local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS,"\124Hplayer:%%s\124h%[%%s%]\124h",""), gsub(ERR_FRIEND_OFFLINE_S,"%%s","")
local dataValid = false
local lastPanel

local function BuildFriendTable(total)
	wipe(friendTable)
	local name, level, class, area, connected, status, note
	for i = 1, total do
		name, level, class, area, connected, status, note = GetFriendInfo(i)

		if status == "<"..AFK..">" then
			status = "|cffFFFFFF[|r|cffFF0000"..'AFK'.."|r|cffFFFFFF]|r"
		elseif status == "<"..DND..">" then
			status = "|cffFFFFFF[|r|cffFF0000"..'DND'.."|r|cffFFFFFF]|r"
		end
		
		if connected then 
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
			for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
			friendTable[i] = { name, level, class, area, connected, status, note }
		end
	end
	sort(friendTable, function(a, b)
		if a[1] and b[1] then
			return a[1] < b[1]
		end
	end)
end

local function Sort(a, b)
	if a[2] and b[2] and a[3] and b[3] then
		if a[2] == b[2] then return a[3] < b[3] end
		return a[2] < b[2]
	end
end

local function BuildBNTable(total)
	wipe(BNTable)
	wipe(BNTableWoW)
	wipe(BNTableD3)
	wipe(BNTableSC)
	wipe(BNTableWTCG)
	wipe(BNTableHero)
	wipe(BNTableApp)
	wipe(BNTableOverwatch)

	local _, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText
	local hasFocus, realmName, realmID, faction, race, class, guild, zoneName, level, gameText

	for i = 1, total do
		bnetIDAccount, accountName, battleTag, _, characterName, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, noteText = BNGetFriendInfo(i)
		hasFocus, _, _, realmName, realmID, faction, race, class, guild, zoneName, level, gameText = BNGetGameAccountInfo(bnetIDGameAccount or bnetIDAccount);
		

		if isOnline then --16
			characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or "";
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
			for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
			
		--	print('T', i, i2, bnetIDAccount, numAccounts, battleTag, toonName, client)
			
			BNTable[i] = { bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
			
			
			if client == scString then						
				BNTableSC[#BNTableSC + 1] = { 
					bnetIDAccount, accountName, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
			elseif client == d3String then
				BNTableD3[#BNTableD3 + 1] = { 
					bnetIDAccount, accountName, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
			elseif client == wtcgString then
				BNTableWTCG[#BNTableWTCG + 1] = { 
					bnetIDAccount, accountName, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
			elseif client == appString then
				BNTableApp[#BNTableApp + 1] = { 
					bnetIDAccount, accountName, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
			elseif client == hotsString then
				BNTableHero[#BNTableHero + 1] = { 
					bnetIDAccount, accountName, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
			elseif client == overwatchString then
				BNTableOverwatch[#BNTableOverwatch + 1] = { 
					bnetIDAccount, accountName, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
			elseif client == wowString then
				BNTableWoW[#BNTableWoW + 1] = { 					
					bnetIDAccount, accountName, characterName, bnetIDGameAccount, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }	
			end	
		end
	end
	
	sort(BNTable, Sort)	
	sort(BNTableWoW, Sort)
	sort(BNTableSC, Sort)
	sort(BNTableD3, Sort)
	sort(BNTableWTCG, Sort)
	sort(BNTableHero, Sort)
	sort(BNTableApp, Sort)
end

local function OnEvent(self, event, ...)
	local _, onlineFriends = GetNumFriends()
	local _, numBNetOnline = BNGetNumFriends()

	-- special handler to detect friend coming online or going offline
	-- when this is the case, we invalidate our buffered table and update the 
	-- datatext information
	if event == "CHAT_MSG_SYSTEM" then
		local message = select(1, ...)
		if not (find(message, friendOnline) or find(message, friendOffline)) then return end
	end

	-- force update when showing tooltip
	dataValid = false

	self.text:SetFormattedText(displayString, FRIENDS, onlineFriends + numBNetOnline)
	lastPanel = self
end

local function Click(self, btn)
	DT.tooltip:Hide()

	if false and btn == "RightButton" then
		local menuCountWhispers = 0
		local menuCountInvites = 0
		local classc, levelc, info
		
		menuList[2].menuList = {}
		menuList[3].menuList = {}
		
		if #friendTable > 0 then
			for i = 1, #friendTable do
				info = friendTable[i]
				if (info[5]) then
					menuCountInvites = menuCountInvites + 1
					menuCountWhispers = menuCountWhispers + 1
		
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
					classc = classc or GetQuestDifficultyColor(info[2]);
		
					menuList[2].menuList[menuCountInvites] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1],notCheckable=true, func = inviteClick}
					menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],classc.r*255,classc.g*255,classc.b*255,info[1]), arg1 = info[1],notCheckable=true, func = whisperClick}
				end
			end
		end
		if #BNTableWoW > 0 then
			local realID, grouped
			for i = 1, #BNTableWoW do
				info = BNTableWoW[i]
				
				-- { presenceID, presenceName, characterName ,toonID, client, isOnline, isAFK, isDND, noteText, realmName, faction, race, class, zoneName, level, gameText }
				
			--	print('T', '6', info[6], '2', info[2], '6', info[5], '11', info[11], '13', info[13], '15', info[15], '3', info[3])
				
				if (info[6]) then
					realID = info[2]
					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID, arg2 = true, notCheckable=true, func = whisperClick}

					if UnitFactionGroup("player") == info[11] then
						classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[13]], GetQuestDifficultyColor(info[15])
						classc = classc or GetQuestDifficultyColor(info[15])

						if UnitInParty(info[3]) or UnitInRaid(info[3]) then grouped = 1 else grouped = 2 end
						menuCountInvites = menuCountInvites + 1
						
						menuList[2].menuList[menuCountInvites] = {
							text = format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[15],classc.r*255,classc.g*255,classc.b*255,info[3]),
							arg1 = info[1], 
							notCheckable=true, 
							func = inviteClick
						}
					end
				end
			end
		end

		E.EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)	
	else
		ToggleFriendsFrame()
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local numberOfFriends, onlineFriends = GetNumFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()
		
	local totalonline = onlineFriends + numBNetOnline
	
	-- no friends online, quick exit
	if totalonline == 0 then return end

	if not dataValid then
		-- only retrieve information for all on-line members when we actually view the tooltip
		if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
		if totalBNet > 0 then BuildBNTable(totalBNet) end
		dataValid = true
	end

	local totalfriends = numberOfFriends + totalBNet
	local zonec, classc, levelc, realmc, info
	local grouped
	DT.tooltip:AddDoubleLine(L['Friend list'], format(totalOnlineString, totalonline, totalfriends),tthead.r,tthead.g,tthead.b,tthead.r,tthead.g,tthead.b)
	if onlineFriends > 0 then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(worldOfWarcraftString)
		for i = 1, #friendTable do
			info = friendTable[i]
			if info[5] then
				if GetRealZoneText() == info[4] then zonec = activezone else zonec = inactivezone end
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
				
				classc = classc or GetQuestDifficultyColor(info[2])
				
				if UnitInParty(info[1]) or UnitInRaid(info[1]) then grouped = 1 else grouped = 2 end
				DT.tooltip:AddDoubleLine(format(levelNameClassString,levelc.r*255,levelc.g*255,levelc.b*255,info[2],info[1],groupedTable[grouped]," "..info[6]),info[4],classc.r,classc.g,classc.b,zonec.r,zonec.g,zonec.b)
			end
		end
	end

	if numBNetOnline > 0 then
		local status = 0
		for client, BNTable in pairs(tableList) do
			if #BNTable > 0 then
				DT.tooltip:AddLine(' ')
				
				if client == BNET_CLIENT_OVERWATCH then
					DT.tooltip:AddLine('|T'..BNet_GetClientTexture(BNET_CLIENT_OVERWATCH)..':14|tOverwatch')
				else
					DT.tooltip:AddLine(battleNetString..' ('..client..')')
				end
				
				
				for i = 1, #BNTable do
					info = BNTable[i]
					
			--		print('T', i, info[3], info[5], info[6])
					local grouped
					if info[6] then
						if info[5] == wowString then
							
							if (info[7] == true) then status = 1 elseif (info[8] == true) then status = 2 else status = 3 end
							
							classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[13]]
							if info[15] ~= '' then
								levelc = GetQuestDifficultyColor(info[15])
							end
							
							levelc = levelc or RAID_CLASS_COLORS["PRIEST"]
							classc = classc or RAID_CLASS_COLORS["PRIEST"]
							
							if UnitInParty(info[4]) or UnitInRaid(info[4]) then grouped = 1 else grouped = 2 end
							DT.tooltip:AddDoubleLine(format(levelNameString,levelc.r*255,levelc.g*255,levelc.b*255,info[15],classc.r*255,classc.g*255,classc.b*255,info[3],groupedTable[grouped], 255, 0, 0, statusTable[status]),info[2],238,238,238,238,238,238)
							if IsShiftKeyDown() then
								if GetRealZoneText() == info[14] then zonec = activezone else zonec = inactivezone end
								if GetRealmName() == info[10] then realmc = activezone else realmc = inactivezone end
								DT.tooltip:AddDoubleLine(info[14], info[10], zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
							end
						else
						--	print('T', info[1], info[2], info[3], info[4], info[5], info[6], info[7], info[8], info[9])
						--	DT.tooltip:AddDoubleLine(info[3], info[2], .9, .9, .9, .9, .9, .9)
							if info[5] == hotsString then
								DT.tooltip:AddDoubleLine(info[2], info[16], .9, .9, .9, .9, .9, .9)
							elseif info[5] == appString  then
								if info[7] then
									DT.tooltip:AddDoubleLine(info[2], '|cFFFFFF00AFK|r', .9, .9, .9, .9, .9, .9)
								elseif info[8] then
									DT.tooltip:AddDoubleLine(info[2], '|cFFFF0000DND|r', .9, .9, .9, .9, .9, .9)
								else
									DT.tooltip:AddDoubleLine(info[2], '|cFF00FF00'..L['Online']..'|r', .9, .9, .9, .9, .9, .9)
								end
							elseif ( info[5] == d3String ) or ( info[5] == scString ) or ( info[5] == wtcgString ) or (info[5] == overwatchString ) then
								DT.tooltip:AddDoubleLine(info[2], info[16], .9, .9, .9, .9, .9, .9)
							end
						end
					end
				end
			end
		end
	end	
	
	DT.tooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s: ", hex, "%d|r")
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

DT:RegisterDatatext('Friends', {
	'PLAYER_ENTERING_WORLD', 
--	"BN_FRIEND_ACCOUNT_ONLINE", 
--	"BN_FRIEND_ACCOUNT_OFFLINE", 
	"BN_FRIEND_INFO_CHANGED", 
--	"BN_FRIEND_TOON_ONLINE",
--	"BN_FRIEND_TOON_OFFLINE", 
--	"BN_TOON_NAME_UPDATED", 
	"FRIENDLIST_UPDATE", 
	"CHAT_MSG_SYSTEM"}, OnEvent, nil, Click, OnEnter)

