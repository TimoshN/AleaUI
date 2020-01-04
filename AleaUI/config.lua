local addonName, E = ...
local L = E.L

local function SetupChat()
	FCF_ResetChatWindows()

	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	
	
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	ChatFrame3:Show()
	
	
	FCF_DockFrame(ChatFrame4)
	FCF_SetLocked(ChatFrame4, 1)
	ChatFrame4:Show()
	
	FCF_DockFrame(ChatFrame5)
	FCF_SetLocked(ChatFrame5, 1)
	ChatFrame5:Show()

	FCF_DockFrame(ChatFrame6)
	FCF_SetLocked(ChatFrame6, 1)
	ChatFrame6:Show()
	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]

		FCF_StopDragging(frame)

		FCF_SetChatWindowFontSize(nil, frame, 12)

		if i == 1 then FCF_SetWindowName(frame, GENERAL)
		elseif i == 2 then FCF_SetWindowName(frame, GUILD_EVENT_LOG)
		elseif i == 3 then FCF_SetWindowName(frame, GUILD)
		elseif i == 4 then FCF_SetWindowName(frame, CHANNELS)
		elseif i == 5 then FCF_SetWindowName(frame, WHISPER)
		elseif i == 6 then FCF_SetWindowName(frame, LOOT)
		end
	end
	
	
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)

	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM_NOMENU")
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "TARGETICONS")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER_INFORM")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER_PLAYER_OFFLINE")
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_BATTLE_INFO")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")

	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	
	ChatFrame_AddMessageGroup(ChatFrame3, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame3, "OFFICER")
	
	
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)

	
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)
	ChatFrame_AddMessageGroup(ChatFrame5, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame5, "BN_WHISPER")
	
	ChatFrame_RemoveAllMessageGroups(ChatFrame6)
	
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame6, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame6, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame6, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame6, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame6, "OPENING")
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_MISC_INFO")
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_GUILD_XP_GAIN")
	
	local channelID, channel
	local channelList = {
		E.L['CHAT_CHANNEL_GENERAL'], 
		E.L['CHAT_CHANNEL_TRADE'], 
		E.L['CHAT_CHANNEL_DEFENSE'], 
		E.L['CHAT_CHANNEL_LFG']	
	}

	for i=1, #channelList do
		local channel = channelList[i]

		ChatFrame_RemoveChannel(ChatFrame1, channel)
		ChatFrame_RemoveChannel(ChatFrame2, channel)
		ChatFrame_RemoveChannel(ChatFrame3, channel)
		ChatFrame_RemoveChannel(ChatFrame4, channel)
		ChatFrame_RemoveChannel(ChatFrame5, channel)
		ChatFrame_RemoveChannel(ChatFrame6, channel)
	
		ChatFrame_AddChannel(ChatFrame4, channel)
	end
	
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")
	
	--Adjust Chat Colors
	--General
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	--Trade
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	--Local Defense
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)
	
	E.db.chatPanel.disable_chatlog = true
	E:Module("ChatFrames"):UpdateCombatLogChatSettings()
end

E.SetupChat = SetupChat

function E:InstallAddon()
	
	local character = E.myname..' - '..E.myrealm
	
	if character and not self.db.applyChatSettings[character] then
		self.db.applyChatSettings[character] = true
		AleaUI_GUI.ShowPopUp(
		   'AleaUI', 
		   L["Apply chat settings. Current chat table will be |cFFFF0000DELETED|r and new will be created."], 
		   { name = YES, OnClick = function() 
				SetupChat()			
			end}, 
		   { name = NO, OnClick = function() 	   
				
		   end}		   
		)
	
	end
end

do	


	local function CurrentProfileName()	
		local name = UnitName("player")
		local realm = GetRealmName()
		local activespec = AleaUIDB.enableDualProfile and GetActiveSpecGroup() or 1		
		
		local owner = name..' - '..realm
		
		return AleaUIDB.profileKeys[owner][activespec]
	end
	
	local width, height = 500, 300
	
	local profileData = CreateFrame("Frame", nil, UIParent)
	profileData:SetPoint("CENTER")
	profileData:SetFrameStrata('HIGH')
	profileData:SetFrameLevel(50)
	profileData:SetSize(width, height)
	
	profileData.Scroll = CreateFrame("ScrollFrame", "AleaUIExportImportScrollFrame", profileData, "UIPanelScrollFrameTemplate")
	profileData.Scroll:SetFrameLevel(profileData:GetFrameLevel() + 1)
	profileData.Scroll:SetSize(width, height)
	profileData.Scroll:SetPoint("TOPRIGHT", profileData, "TOPRIGHT", -2, -2)
	profileData.Scroll:SetPoint("BOTTOMLEFT", profileData, "BOTTOMLEFT", 2, 2)
	profileData.Scroll:SetClipsChildren(true)
	
	profileData.Scroll.ScrollBar:SetParent(profileData)	
	profileData.Scroll.ScrollBar:SetScript('OnValueChanged', function(self, value)
		profileData.Scroll:SetVerticalScroll(value);
	end)
	
	profileData.editBox = CreateFrame("EditBox", nil, profileData)
	profileData.editBox:SetPoint('TOPLEFT', profileData.Scroll, "TOPLEFT", 2, 1)
	profileData.editBox:SetSize(width, height)
	
	profileData.Scroll:SetScrollChild(profileData.editBox)
	profileData.Scroll:SetHorizontalScroll(-5)
	profileData.Scroll:SetVerticalScroll(0)
	profileData.Scroll:EnableMouse(true)
	
	profileData.editBox:SetFont("Fonts\\ARIALN.TTF", 10, "NONE")
	profileData.editBox:SetFrameLevel(profileData:GetFrameLevel() + 1)
	profileData.editBox:SetAutoFocus(false)
	profileData.editBox:SetMultiLine(true)
	profileData.editBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	profileData:Hide()
	profileData:SetBackdrop({
			bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
			edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], --[=[Interface\ChatFrame\ChatFrameBackground]=]
			edgeSize = 1,
		})
	profileData:SetBackdropColor(0 , 0 , 0 , 0.7) --цвет фона
	profileData:SetBackdropBorderColor(1 , 1 , 1 , 1) --цвет фона
	
	profileData.button = CreateFrame("Button",nil,profileData)
	profileData.button:SetPoint('TOP', profileData, 'BOTTOM', 130, -10)
	profileData.button:SetWidth(100)
	profileData.button:SetHeight(20)
	
	profileData.button.fs = profileData.button:CreateFontString()
	profileData.button.fs:SetPoint("CENTER")
	profileData.button.fs:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	profileData.button.fs:SetText(L["Import"])
	
	profileData.button:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
	profileData.button:GetNormalTexture():SetVertexColor(0,0,0,1)
	profileData.button:SetScript("OnClick", function(self) profileData:Hide(); profileData.editBox:ClearFocus(); E:DeserializeImport() end)
	profileData.button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", insets = {top = -2, left = -2, bottom = -2, right = -2}})
	profileData.button:SetBackdropColor(0, 0, 0, 1)
	profileData.button:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	profileData.button:Show()
	
	
	profileData.button2 = CreateFrame("Button",nil,profileData)
	profileData.button2:SetPoint('TOP', profileData, 'BOTTOM', -130, -10)
	profileData.button2:SetWidth(100)
	profileData.button2:SetHeight(20)
	
	profileData.button2.fs = profileData.button2:CreateFontString()
	profileData.button2.fs:SetPoint("CENTER")
	profileData.button2.fs:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	profileData.button2.fs:SetText(L["Select All"])
	
	profileData.button2:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
	profileData.button2:GetNormalTexture():SetVertexColor(0,0,0,1)
	profileData.button2:SetScript("OnClick", function(self) profileData.editBox:HighlightText(0) end)
	profileData.button2:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", insets = {top = -2, left = -2, bottom = -2, right = -2}})
	profileData.button2:SetBackdropColor(0, 0, 0, 1)
	profileData.button2:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	profileData.button2:Show()
	
	profileData.button3 = CreateFrame("Button",nil,profileData)
	profileData.button3:SetPoint('TOP', profileData, 'BOTTOM', 0, -10)
	profileData.button3:SetWidth(100)
	profileData.button3:SetHeight(20)
	
	profileData.button3.fs = profileData.button3:CreateFontString()
	profileData.button3.fs:SetPoint("CENTER")
	profileData.button3.fs:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	profileData.button3.fs:SetText(CLOSE)
	
	profileData.button3:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
	profileData.button3:GetNormalTexture():SetVertexColor(0,0,0,1)
	profileData.button3:SetScript("OnClick", function(self) profileData:Hide(); profileData.editBox:ClearFocus(); AleaUI_GUI:Open(addonName) end)
	profileData.button3:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", insets = {top = -2, left = -2, bottom = -2, right = -2}})
	profileData.button3:SetBackdropColor(0, 0, 0, 1)
	profileData.button3:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	profileData.button3:Show()
	
	local settingToExport = {
		'cVars', 
		'battletext', 
		'raidFramesSettings', 
		'nameplates', 
		'Frames', 
		'actionbars', 
		'auradefault', 
		'buffframe', 
		'datatexts', 
		'unitframes', 
		'classBars', 
		'chatPanel', 
		'minimap', 
		'skins', 
		'skins_custom',
		'xpbar',
		'cooldown',
		'alerts',
		'objectFrame',
	}

	local auraList = {
		'anount_spelllist', 'spelllist', 'font', 'anchors', 'enable_aurawatcher', 'OnlyBossFights',
	}
	
	local auraWidget = {
		'fakeName', 'spellName', 'spellID', 'anchor', 
	}
	
	local function IsProfileImport(profile)
		local isProfile = false
		
		for i=1, #settingToExport do
			if profile[settingToExport[i]] then
				isProfile = true
			end
		end
		
		return isProfile
	end
	
	local function IsAuraList(profile)	
		local isProfile = false
		
		for i=1, #auraList do
			if profile[auraList[i]] then
				isProfile = true
			end
		end
		
		return isProfile
	end
	
	local function IsAuraData(profile)
		local isProfile = false
		
		if profile.indexAura then
			isProfile = true
		end
		
		return isProfile	
	end
	
	function E:ExportProfile()
		local profile = {}
		
		local profileFrom = AleaUIDB.profiles[CurrentProfileName()]
		
		print('AleaUI: Init Export profile -', CurrentProfileName())
		
		for i=1, #settingToExport do
			if profileFrom[settingToExport[i]] then
				profile[settingToExport[i]] = profileFrom[settingToExport[i]]
			end
		end

		if profile.raidFramesSettings then
			for name in pairs( profile.raidFramesSettings.Profiles ) do		
				profile.raidFramesSettings.Profiles.perCharSpec = {}
			end
		end
		
		profile.chatPanel.battleTagFilter = {}
		profile.chatPanel.nameFilter = {}
		
		--[==[
			fill profile with data
		]==]
		
		E:SerializeTable(profile)
	end

	function E:ExportAuraList()
		local profile = {}
		
		print('AleaUI: Init Export aura list')
		
		for i=1, #auraList do
			if AleaUI_AuraWidgets[auraList[i]] then
				profile[auraList[i]] = AleaUI_AuraWidgets[auraList[i]]
			end
		end
		
		profile['encounters'] = AleaUI_AuraWidgets['encounters']
		
		profile["ignoredSpells"] = {}
		profile["NeWignoredSpells"] = {}

		E:SerializeTable(profile)
	end
	
	function E:ExportAura(data, encounters)
		local profile = {}
		
		profile.indexAura = {}
		
		print('AleaUI: Init Export aura widget')
		
		for k,v in pairs(data) do	
			profile.indexAura[k] = v
		end

		profile.encounters = encounters
		
		E:SerializeTable(profile)
	end
	
	function E:ImportProfile()
	
		profileData.editBox:SetText("")
		profileData:Show()
		profileData.editBox:SetFocus()
		
		AleaUI_GUI:Close(addonName)
		
		profileData.button3:Show()
		profileData.button2:Hide()
		profileData.button:Show()
	end
	
	function E:SerializeTable(tabl)
		
		local data3 = E.Serializer:Serialize(tabl)
		local data1 = E.Serializer:encode(data3)
		
		wipe(tabl);
		data3 = nil
		
		profileData:Show()

		AleaUI_GUI:Close(addonName)
		
		profileData.editBox:SetText(data1)
		
		profileData.editBox:HighlightText(0)
		
		profileData.editBox:SetFocus()
		
		profileData.button3:Show()
		profileData.button2:Show()
		profileData.button:Hide()
	
		data1 = nil;
	end

	function E:DeserializeImport()

		local gentime = date("%H:%M:%S %a%b%d")
		
		local data3 = profileData.editBox:GetText()

		local data1, message = E.Serializer:decode(data3) -- libC:Decompress(data2)				
		if(not data1) then
			print("AleaUI: error decompressing: " .. message)
			return
		end			
		local done, final = E.Serializer:Deserialize(data1)			
		if (not done) then
			print("AleaUI: error deserializing " .. final)
			return
		end
		
		if final then		
			if IsProfileImport(final) then
				print('AleaUI: Imported to "Import - '..gentime)
				
				AleaUIDB.profiles["Import - "..gentime] = E.deepcopy(final)
			elseif IsAuraList(final) then
				print('AleaUI: Import aura list')
				
				AleaUI_AuraWidgets = E.deepcopy(final)
				
				E:UpdateAuraWidgetOptions()
			elseif IsAuraData(final) then
				print('AleaUI: Import aura data')
			
				table.insert(AleaUI_AuraWidgets.spelllist, final.indexAura) 
				
				AleaUI_AuraWidgets.encounters = final.encounters
			end
		end
		
		wipe(final)
	end
end