local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'friendsframe'
AleaUI.default_settings.skins[varName] = true

local function Skin_FriendsFrame()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	_G['FriendsFrame']:StripTextures()
	_G['FriendsFrameInset']:StripTextures()

	FriendsFrame.NineSlice:StripTextures()
	FriendsFrameInset.NineSlice:StripTextures()

--	_G['FriendsFrameFriendsScrollFrame']:StripTextures()

	Skins.ThemeBackdrop('FriendsFrame')	

	_G['FriendsFrameIcon']:SetAlpha(0)

	for i=1, 4 do
		Skins.ThemeTab('FriendsFrameTab'..i)	
	end

	for i=1, 4 do
		Skins.ThemeUpperTabs(_G["FriendsTabHeaderTab"..i])
	end
		
	-- IgnoreListFrameTop:Kill()
	-- IgnoreListFrameMiddle:Kill()
	-- IgnoreListFrameBottom:Kill()
	--	PendingListFrameTop:Kill()
	--	PendingListFrameMiddle:Kill()
	--	PendingListFrameBottom:Kill()

	for i=1, 3 do
		_G["WhoFrameColumnHeader"..i]:StripTextures(true)
	end
		
	Skins.ThemeButton('FriendsFrameAddFriendButton')
	Skins.ThemeButton('FriendsFrameSendMessageButton')
	Skins.ThemeButton('FriendsFrameIgnorePlayerButton')
	Skins.ThemeButton('FriendsFrameUnsquelchButton')

	Skins.ThemeScrollBar(IgnoreListFrameScrollFrame.scrollBar)
	Skins.ThemeScrollBar(QuickJoinScrollFrame.scrollBar)
	Skins.ThemeScrollBar(FriendsListFrameScrollFrame.scrollBar)

	Skins.ThemeButton(QuickJoinFrame.JoinQueueButton)
	
	WhoFrameListInset:StripTextures()
	--WhoFrameListInsetBg:Kill()

	Skins.ThemeScrollBar(WhoListScrollFrame.scrollBar)

	WhoFrameEditBoxInset:StripTextures()
		
	local border, parent = Skins.ThemeEditBox('WhoFrameEditBox')
	border:SetPoint('TOPLEFT', parent, 'TOPLEFT', -5, -3)
	border:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 23, 8)

	Skins.ThemeDropdown('WhoFrameDropDown')

	Skins.ThemeButton('WhoFrameWhoButton')	
	Skins.ThemeButton('WhoFrameAddFriendButton')
	Skins.ThemeButton('WhoFrameGroupInviteButton')

	WhoFrameWhoButton:ClearAllPoints()
	WhoFrameWhoButton:SetPoint('BOTTOMLEFT', WhoFrame, 'BOTTOMLEFT', 7, 4)
	WhoFrameWhoButton:SetWidth(WhoFrameWhoButton:GetWidth()-3)

	WhoFrameAddFriendButton:ClearAllPoints()
	WhoFrameAddFriendButton:SetPoint('LEFT', WhoFrameWhoButton, 'RIGHT', 3, 0)
	WhoFrameAddFriendButton:SetWidth(WhoFrameAddFriendButton:GetWidth()-7)

	WhoFrameGroupInviteButton:ClearAllPoints()
	WhoFrameGroupInviteButton:SetPoint('LEFT', WhoFrameAddFriendButton, 'RIGHT', 3, 0)
	WhoFrameGroupInviteButton:SetWidth(WhoFrameAddFriendButton:GetWidth()+8)

	--ChannelFrameRightInset:StripTextures()
	--ChannelFrameLeftInset:StripTextures()

	--Skins.ThemeScrollBar('ChannelRosterScrollFrameScrollBar')
	--Skins.ThemeButton('ChannelFrameNewButton')
	Skins.ThemeButton('RaidFrameRaidInfoButton')
	Skins.ThemeButton('RaidFrameConvertToRaidButton')

	RaidInfoFrame:StripTextures()
	Skins.ThemeBackdrop('RaidInfoFrame')
	Skins.ThemeScrollBar('RaidInfoScrollFrameScrollBar')
	RaidInfoFrameHeader:Hide()
	AleaUI:CreateBackdrop(RaidInfoFrame, RaidInfoFrameHeader, default_border_color, default_background_color, 'ARTWORK', 1)
	RaidInfoFrameHeaderText:SetFont(default_font, Skins.default_font_size, 'NONE')
	RaidInfoFrameHeader:SetSize(110, 35)
	RaidInfoFrameHeader:SetUIBackgroundDrawLayer('ARTWORK')
	RaidInfoFrameHeader:SetUIBorderDrawLayer('ARTWORK')
	Skins.ThemeButton('RaidInfoExtendButton')
	Skins.ThemeButton('RaidInfoCancelButton')


	RaidInfoInstanceLabel:StripTextures(true)
	RaidInfoIDLabel:StripTextures(true)
	
	--[==[
	for i=1, 15 do
		_G["ChannelButton"..i..'NormalTexture']:SetAlpha(0)
		_G["ChannelButton"..i..'NormalTexture'].SetAlpha = function()end
		
		_G["ChannelButton"..i..'Text']:SetFont(default_font, Skins.default_font_size, 'NONE')
	end
	]==]

	FriendsFrameBattlenetFrame.BroadcastButton:ClearAllPoints()
	FriendsFrameBattlenetFrame.BroadcastButton:SetSize(20, 20)
	FriendsFrameBattlenetFrame.BroadcastButton:SetPoint('RIGHT', FriendsFrameStatusDropDown, 'LEFT', 5, 3)
	FriendsFrameBattlenetFrame.BroadcastButton:GetNormalTexture():SetTexCoord(.28, .72, .28, .72)
	FriendsFrameBattlenetFrame.BroadcastButton:GetPushedTexture():SetTexCoord(.28, .72, .28, .72)
	FriendsFrameBattlenetFrame.BroadcastButton:GetHighlightTexture():SetTexCoord(.28, .72, .28, .72)
	Skins.ThemeButtonBackdrop(FriendsFrameBattlenetFrame.BroadcastButton)

	FriendsFrameBattlenetFrame.BroadcastFrame:StripTextures()
	Skins.ThemeBackdrop(FriendsFrameBattlenetFrame.BroadcastFrame)

	Skins.ThemeDropdown(FriendsFrameStatusDropDown)

--	FriendsFrameBattlenetFrameScrollFrame:StripTextures()


	-- Skins.ThemeBackdrop(FriendsFrameBattlenetFrameScrollFrame)
	-- Skins.ThemeButton(FriendsFrameBattlenetFrameScrollFrame.UpdateButton)
	-- Skins.ThemeButton(FriendsFrameBattlenetFrameScrollFrame.CancelButton)

	Skins.SetAllFontString(FriendsFrameBattlenetFrame.BroadcastFrame, default_font,Skins.default_font_size, 'NONE')

	Skins.ThemeCheckBox(RaidFrameAllAssistCheckButton)

	RaidFrameRaidDescription:SetFont(default_font, Skins.default_font_size, 'NONE')
	
	
--	FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton
	local pendingButton = FriendsListFrameScrollFrame.PendingInvitesHeaderButton

	local function ClearCustomButton(frame)
		frame.TopLeft:Hide()
		frame.TopRight:Hide()
		if frame.BG then
			frame.BG:Hide()
		end
		frame.TopRight:Hide()
		frame.BottomLeft:Hide()
		frame.TopMiddle:Hide()
		frame.MiddleLeft:Hide()
		frame.MiddleRight:Hide()
		frame.BottomMiddle:Hide()
		frame.MiddleMiddle:Hide()
		frame.BottomRight:Hide()
		
		local texture = frame:CreateTexture()
		texture:SetDrawLayer('ARTWORK', -1)
		texture:SetTexture([[Interface\Buttons\WHITE8x8]])
		texture:SetVertexColor(1,1,1,0.3)

		frame:SetHighlightTexture(texture)
		
		Skins.SetAllFontString(frame, default_font, Skins.default_font_size, 'NONE')
	
		local framePointer = CreateFrame('Frame',nil, frame)
		framePointer:SetPoint('TOPLEFT', frame, 'TOPLEFT', 2, -2)
		framePointer:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
		
		texture:SetAllPoints(framePointer)
		
		AleaUI:CreateBackdrop(pendingButton, framePointer, default_border_color, default_background_color)
	end
	
	ClearCustomButton(pendingButton)
	
		
--	AleaUI:CreateBackdrop(FriendsFrameInset, nil, {0,0,0,1}, {0.2,0.2,0.2,0.4})
					
					
	local lastNumMaxChilds = -1
	
	local function ThemePendingButtons()
		if lastNumMaxChilds ~= FriendsListFrameScrollFrameScrollChild:GetNumChildren() then
			lastNumMaxChilds = FriendsListFrameScrollFrameScrollChild:GetNumChildren()

			for k,v in pairs({FriendsListFrameScrollFrameScrollChild:GetChildren()}) do
			   if v.AcceptButton and v.DeclineButton and not v.skinned then
					v.skinned = true
					
					ClearCustomButton(v.AcceptButton)
					ClearCustomButton(v.DeclineButton)
			   end
			end
		end
	end
	
	hooksecurefunc('FriendsList_Update', ThemePendingButtons)
	hooksecurefunc('FriendsFrame_OnEvent', ThemePendingButtons)	
	FriendsListFrame:HookScript('OnShow', ThemePendingButtons)
	
	
	AleaUI:CreateBackdrop(FriendsFrameBattlenetFrame, nil, {0,0,0,1}, {0.2,0.2,1, 0}, 'OVERLAY', 1)
	
	local battlenettexture = Skins.GetTextureObject(FriendsFrameBattlenetFrame, [[Interface\FriendsFrame\battlenet-friends-main]])
--	battlenettexture:SetAlpha(0)
	local texCoordAdd = 0.01
	battlenettexture:SetTexCoord(0.00390625+texCoordAdd, 0.74609375-texCoordAdd, 0.00195313+texCoordAdd, 0.05859375-texCoordAdd)
	--<TexCoords left="0.00390625" right="0.74609375" top="0.00195313" bottom="0.05859375"/>
	
	
	local function ClassColorCode(class)
		for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			if class == v then
				class = k
			end
		end

		if Locale ~= 'enUS' then
			for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
				if class == v then
					class = k
				end
			end
		end

		local color = class and RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }

		return format('|cFF%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
	end
	
	local ClientColor = {
		S1 = 'C495DD',
		S2 = 'C495DD',
		D3 = 'C41F3B',
		Pro = 'FFFFFF',
		WTCG = 'FFB100',
		Hero = '00CCFF',
		App = '82C5FF',
		BSAp = '82C5FF',
	}


	local function BasicUpdateFriends(button)
		local nameText, nameColor, infoText, broadcastText, _, Cooperate
		
		if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
			local info = C_FriendList.GetFriendInfo(button.id);
			--local name, level, class, area, connected, status = C_FriendList.GetFriendInfo(button.id)

			broadcastText = nil
			if info.connected then
			--	button.status:SetTexture(StatusIcons[self.db.StatusIconPack][(status == CHAT_FLAG_DND and 'DND' or status == CHAT_FLAG_AFK and 'AFK' or 'Online')])
				nameText = format('%s%s - %s', ClassColorCode(info.class), info.name, info.class, info.level)
				nameColor = FRIENDS_WOW_NAME_COLOR
				Cooperate = true
			else
			--	button.status:SetTexture(StatusIcons[self.db.StatusIconPack].Offline)
				nameText = name
				nameColor = FRIENDS_GRAY_COLOR
			end
			infoText = info.area
		elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET and BNConnected() then
			local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfoByID(button.id)
			local realmName, realmID, faction, race, class, zoneName, level, gameText
			broadcastText = messageText
			local characterName = toonName
			if presenceName then
				nameText = presenceName
				if isOnline and not characterName and battleTag then
					characterName = battleTag
				end
			else
				nameText = UNKNOWN
			end

			if characterName then
				_, _, _, realmName, realmID, faction, race, class, _, zoneName, level, gameText = BNGetGameAccountInfo(toonID)
				if client == BNET_CLIENT_WOW then
					if (level == nil or tonumber(level) == nil) then level = 0 end
					local classcolor = ClassColorCode(class)
					local diff = level ~= 0 and format('|cFF%02x%02x%02x', GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or '|cFFFFFFFF'
					local factionText = ( faction == "Horde" and "|cFFFF0000"..FACTION_HORDE.."|r" or "|cFF008eff"..FACTION_ALLIANCE.."|r" )
					nameText = format('%s |cFFFFFFFF(|r%s%s|r - %s%s|r - %s|cFFFFFFFF)|r', nameText, classcolor, characterName, diff, level, factionText)
					Cooperate = CanCooperateWithGameAccount(toonID)
				else
					nameText = format('|cFF%s%s|r', ClientColor[client] or 'FFFFFF', nameText)
				end
			end

			if isOnline then
			--	button.status:SetTexture(StatusIcons[self.db.StatusIconPack][(status == CHAT_FLAG_DND and 'DND' or status == CHAT_FLAG_AFK and 'AFK' or 'Online')])
				if client == BNET_CLIENT_WOW then
					if not zoneName or zoneName == '' then
						infoText = UNKNOWN
					else
						if realmName == GetRealmName() then
							infoText = zoneName
						else
							infoText = format('%s - %s', zoneName, realmName)
						end
					end
			--		button.gameIcon:SetTexture(GameIcons[self.db.GameIconPack][faction])
				else
					infoText = gameText
			--		button.gameIcon:SetTexture(GameIcons[self.db.GameIconPack][client])
				end
				nameColor = FRIENDS_BNET_NAME_COLOR
			else
			--	button.status:SetTexture(StatusIcons[self.db.StatusIconPack].Offline)
				nameColor = FRIENDS_GRAY_COLOR
				infoText = lastOnline == 0 and FRIENDS_LIST_OFFLINE or format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline))
			end
		end

		if button.summonButton:IsShown() then
			button.gameIcon:SetPoint('TOPRIGHT', -50, -2)
		else
			button.gameIcon:SetPoint('TOPRIGHT', -21, -2)
		end
		button.gameIcon:Show()

		if nameText then
			button.name:SetText(nameText)
			button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
			button.info:SetText(infoText)
			button.info:SetTextColor(.49, .52, .54)
			if Cooperate then
				button.info:SetTextColor(1, .96, .45)
			end
		--	button.name:SetFont(PA.LSM:Fetch('font', self.db.NameFont), self.db.NameFontSize, self.db.NameFontFlag)
		--	button.info:SetFont(PA.LSM:Fetch('font', self.db.InfoFont), self.db.InfoFontSize, self.db.InfoFontFlag)
			
			button.info:SetPoint('TOPRIGHT', button.name, 'BOTTOMRIGHT', 0, 0)
		end
	end
	
	--hooksecurefunc('FriendsFrame_UpdateFriendButton', BasicUpdateFriends)
end

AleaUI:OnInit2(Skin_FriendsFrame)