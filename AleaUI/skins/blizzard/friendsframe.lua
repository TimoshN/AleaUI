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
	WhoFrameListInset.NineSlice:StripTextures()

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

	for i=1, 4 do
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

	WhoFrameEditBoxInset:Kill()
		
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
	RaidInfoFrame.Header:StripTextures()
	AleaUI:CreateBackdrop(RaidInfoFrame, RaidInfoFrame.Header, default_border_color, default_background_color, 'ARTWORK', 1)
	RaidInfoFrame.Header.Text:SetFont(default_font, Skins.default_font_size, 'NONE')
	RaidInfoFrame.Header:SetSize(110, 35)
	RaidInfoFrame.Header:SetUIBackgroundDrawLayer('ARTWORK')
	RaidInfoFrame.Header:SetUIBorderDrawLayer('ARTWORK')
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

		return format('FF%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
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


	local ClassicServerNameByID = {
		[4703] = 'Amnennar',
		[4715] = 'Anathema',
		[4716] = 'Arcanite Reaper',
		[4742] = 'Ashbringer',
		[4387] = 'Ashkandi',
		[4372] = 'Atiesh',
		[4669] = 'Arugal',
		[4441] = 'Auberdine',
		[4376] = 'Azuresong',
		[4728] = 'Benediction',
		[4398] = 'Bigglesworth',
		[4397] = 'Blaumeux',
		[4746] = 'Bloodfang',
		[4648] = 'Bloodsail Buccaneers',
		[4386] = 'Deviate Delight',
		[4751] = 'Dragonfang',
		[4756] = "Dragon's Call",
		[4755] = 'Dreadmist',
		[4731] = 'Earthfury',
		[4749] = 'Earthshaker',
		[4440] = 'Everlook',
		[4408] = 'Faerlina',
		[4396] = 'Fairbanks',
		[4739] = 'Felstriker',
		[4744] = 'Finkle',
		[4467] = 'Firemaw',
		[4706] = 'Flamelash',
		[4702] = 'Gandling',
		[4476] = 'Gehennas',
		[4465] = 'Golemagg',
		[4647] = 'Grobbulus',
		[4732] = 'Heartseeker',
		[4763] = 'Heartstriker',
		[4406] = 'Herod',
		[4678] = 'Hydraxian Waterlords',
		[4698] = 'Incendius',
		[4758] = 'Judgement',
		[4700] = 'Kirtonos',
		[4699] = 'Kromcrush',
		[4399] = 'Kurinnaxx',
		[4442] = 'Lakeshire',
		[4801] = 'Loatheb',
		[4463] = 'Lucifron',
		[4813] = 'Mandokir',
		[4384] = 'Mankrik',
		[4454] = 'Mirage Raceway',
		[4701] = 'Mograine',
		[4373] = 'Myzrael',
		[4456] = 'Nethergarde Keep',
		[4729] = 'Netherwind',
		[4741] = 'Noggenfogger',
		[4374] = 'Old Blanchy',
		[4385] = 'Pagle',
		[4466] = 'Patchwerk',
		[4453] = 'Pyrewood Village',
		[4695] = 'Rattlegore',
		[4455] = 'Razorfen',
		[4478] = 'Razorgore',
		[4667] = 'Remulos',
		[4475] = 'Shazzrah',
		[4410] = 'Skeram',
		[4743] = 'Skullflame',
		[4696] = 'Smolderweb',
		[4409] = 'Stalagg',
		[4705] = 'Stonespine',
		[4726] = 'Sulfuras',
		[4464] = 'Sulfuron',
		[4737] = "Sul'thraze",
		[4757] = 'Ten Storms',
		[4407] = 'Thalnos',
		[4714] = 'Thunderfury',
		[4745] = 'Transcendence',
		[4477] = 'Venoxis',
		[4388] = 'Westfall',
		[4395] = 'Whitemane',
		[4727] = 'Windseeker',
		[4670] = 'Yojamba',
		[4676] = 'Zandalar Tribe',
		[4452] = 'Хроми',
		[4704] = 'Змейталак',
		[4754] = 'Рок-Делар',
		[4766] = 'Вестник Рока',
		[4474] = 'Пламегор',
	}
	
	hooksecurefunc('FriendsFrame_UpdateFriendButton', function(button)
		local nameText, infoText
		local status = 'Offline'
		if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
			local info = C_FriendList.GetFriendInfoByIndex(button.id)
			if info.connected then
				local name, level, class = info.name, info.level, info.className
				local classcolor = ClassColorCode(class)
				status = info.dnd and 'DND' or info.afk and 'AFK' or 'Online'

				local diff = level ~= 0 and format('FF%02x%02x%02x', GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or 'FFFFFFFF'
				nameText = format('%s |cFFFFFFFF(|r%s - %s %s|cFFFFFFFF)|r', WrapTextInColorCode(name, classcolor), class, LEVEL, WrapTextInColorCode(level, diff))
					
				infoText = info.area
			else
				nameText = info.name
			end
		elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local info = C_BattleNet.GetFriendAccountInfo(button.id);
			if info then
				nameText = info.accountName
				infoText = info.gameAccountInfo.richPresence
				if info.gameAccountInfo.isOnline then
					local client = info.gameAccountInfo.clientProgram
					status = info.isDND and 'DND' or info.isAFK and 'AFK' or 'Online'
	
					if client == BNET_CLIENT_WOW then
						local level = info.gameAccountInfo.characterLevel
						local characterName = info.gameAccountInfo.characterName
						local classcolor = ClassColorCode(info.gameAccountInfo.className)
						if characterName then
							local diff = level ~= 0 and format('FF%02x%02x%02x', GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or 'FFFFFFFF'
							nameText = format('%s (%s - %s %s)', nameText, WrapTextInColorCode(characterName, classcolor), LEVEL, WrapTextInColorCode(level, diff))
						end
	
						if info.gameAccountInfo.wowProjectID == WOW_PROJECT_CLASSIC then
							infoText = format('%s - %s - %s', info.gameAccountInfo.areaName, ClassicServerNameByID[info.gameAccountInfo.realmID] or '', infoText)
						end
					end
	
					button.gameIcon:SetTexCoord(0, 1, 0, 1)
					button.gameIcon:SetDrawLayer('OVERLAY')
					button.gameIcon:SetAlpha(1)
				else
					local lastOnline = info.lastOnlineTime
					infoText = lastOnline == 0 and FRIENDS_LIST_OFFLINE or format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline))
				end
			end
		end
	
		if button.summonButton:IsShown() then
			button.gameIcon:SetPoint('TOPRIGHT', -50, -2)
		else
			button.gameIcon:SetPoint('TOPRIGHT', -21, -2)
		end
	
		if nameText then button.name:SetText(nameText) end
		if infoText then button.info:SetText(infoText) end
	
		if button.Favorite and button.Favorite:IsShown() then
			button.Favorite:ClearAllPoints()
			button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0);
		end
	end)
end

AleaUI:OnInit2(Skin_FriendsFrame)