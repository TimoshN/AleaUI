local Skins = AleaUI:Module("Skins")
local _G = _G
local L = AleaUI.L

local varName = 'bossbanner'
AleaUI.default_settings.skins[varName] = true

AleaUI:OnInit(function()	
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	BossBanner:UnregisterAllEvents()
	
	UIParent:UnregisterEvent("CHALLENGE_MODE_COMPLETED");
	
	AleaUI:OnAddonLoad('Blizzard_ChallengesUI', function()	
		ChallengeModeCompleteBanner:UnregisterEvent("CHALLENGE_MODE_COMPLETED");		
	end)
	
--	if LevelUpDisplay then
	--	LevelUpDisplay:UnregisterEvent("CHALLENGE_MODE_NEW_RECORD");
		
	--	local old_LevelUpDisplay_PlayScenario = LevelUpDisplay_PlayScenario
	--	LevelUpDisplay_PlayScenario = function(...)	end
	
		LevelUpDisplay:SetParent(AleaUI.hidenframe)
		--[==[
	else
		hooksecurefunc('LevelUpDisplay_OnLoad', function(self)
			self:UnregisterEvent("CHALLENGE_MODE_NEW_RECORD");
			
			local old_LevelUpDisplay_PlayScenario = LevelUpDisplay_PlayScenario
			LevelUpDisplay_PlayScenario = function(...)end
		end)
	end
	]==]
	hooksecurefunc('BossBanner_OnEvent', function(self)
		-- BossBanner working again
		self:Hide()
		self:UnregisterAllEvents()
	end)
	
	hooksecurefunc('BossBanner_OnLoad', function(self)
		-- BossBanner working again
		self:Hide()
		self:UnregisterAllEvents()
	end)
	
	local ResetLootList, OnUpdateHandler, ShowBossDefeat, AddLootToShow, UpdateLootInfo
		
	local lastFromMaxItem = -1
	local baseFrameSize = 35

	local function AnimInNotShown_OnUpdate(self, elapsed)
	
		self.elapsed = self.elapsed + elapsed
		
		local alpha = 0
		
		if self.elapsed > 0.2 then
			alpha = (self.elapsed-0.2)/0.6
		end
		
		if alpha >= 1 then
			self:SetAlpha(1)
			self:SetScript('OnUpdate', nil)
		else
			self:SetAlpha(alpha)
		end
	end
	
	local function AnimIfNotShown(self)
	
	--	print('T', 'AnimIfNotShown', self:IsShown(), self:GetAlpha(), self.elapsed, self:GetScript('OnUpdate'))
		if self:IsShown() then
			self.elapsed = 0
			self:SetAlpha(1)
			self:SetScript('OnUpdate', nil)
		else
			if not self:GetScript('OnUpdate') then
				self.elapsed = 0
				self:Show()
				self:SetAlpha(0)
				self:SetScript('OnUpdate', AnimInNotShown_OnUpdate)
			end
		end
	end
	
	local bossKillFrame = CreateFrame('Frame', nil, AleaUI.UIParent)
	bossKillFrame:SetSize(100, 20)
	bossKillFrame:SetPoint('CENTER', 0, 300)
	bossKillFrame:Hide()
	--[==[
	bossKillFrame.bg = bossKillFrame:CreateTexture()
	bossKillFrame.bg:SetAllPoints()
	bossKillFrame.bg:SetColorTexture(0.6, 0.6, 0.6, 0.6)
	]==]
	bossKillFrame.artWork = CreateFrame('Frame', nil, bossKillFrame, BackdropTemplateMixin and 'BackdropTemplate')
	bossKillFrame.artWork:SetPoint('TOP', bossKillFrame, 'TOP', 0, 0)
	bossKillFrame.artWork:SetSize(270, 300)
	bossKillFrame.artWork:SetBackdrop({
		bgFile = [[Interface\Buttons\WHITE8x8]], 
		edgeFile = 'Interface\\AddOns\\AleaUI\\media\\glow', 
		tile = false, tileSize = 0, edgeSize = 4, 
		insets = { left = 4, right = 4, top = 4, bottom = 4}
	})
	bossKillFrame.artWork:SetBackdropColor(0, 0, 0, 0)
	bossKillFrame.artWork:SetBackdropBorderColor(0, 0, 0, 0)
	
	bossKillFrame.artWork.name = bossKillFrame.artWork:CreateFontString()
	bossKillFrame.artWork.name:SetFont(Skins.default_font, 16, 'OUTLINE')
	bossKillFrame.artWork.name:SetShadowOffset(1, -1)
	bossKillFrame.artWork.name:SetShadowColor(0,0,0)
	bossKillFrame.artWork.name:SetPoint('TOP', bossKillFrame.artWork, 'TOP', 0, -2)
	bossKillFrame.artWork.name:SetText('Boss Title')
	
	bossKillFrame.artWork.defeated = bossKillFrame.artWork:CreateFontString()
	bossKillFrame.artWork.defeated:SetFont(Skins.default_font, 10, 'OUTLINE')
	bossKillFrame.artWork.defeated:SetShadowOffset(1, -1)
	bossKillFrame.artWork.defeated:SetShadowColor(0,0,0)
	bossKillFrame.artWork.defeated:SetPoint('TOP', bossKillFrame.artWork.name, 'BOTTOM', 0, -2)
	bossKillFrame.artWork.defeated:SetText(L['Defeated'])
	
	bossKillFrame.artWork.close = CreateFrame("Button", nil, bossKillFrame.artWork, 'UIPanelCloseButton')
	bossKillFrame.artWork.close:SetFrameLevel(bossKillFrame.artWork:GetFrameLevel()+1)
	bossKillFrame.artWork.close:SetSize(32, 32)	
	bossKillFrame.artWork.close:SetPoint("TOPRIGHT", bossKillFrame.artWork, "TOPRIGHT", 3, 3)	

	bossKillFrame.artWork.close:SetScript("OnClick", function()
		bossKillFrame.artWork:Hide()
		ResetLootList()
	end)
	bossKillFrame.artWork.setHeight = baseFrameSize
	bossKillFrame.artWork.setHeightStart = -1
	bossKillFrame.artWork.curHeight = baseFrameSize
	bossKillFrame.artWork.ChangeHeight = function(self, numFrames)	
	
		if numFrames > 5 then
			numFrames = 5
		end
		
		self.curHeight = bossKillFrame.artWork:GetHeight()
		self.setHeight = baseFrameSize + numFrames*50
		self.setHeightStart = GetTime()
		
	--	print('Set to', numFrames)
	end
	bossKillFrame.artWork:EnableMouse(true)
	bossKillFrame.artWork.tempFrom = 1
	bossKillFrame.artWork:SetScript("OnMouseWheel", function(self, delta)
		
		self.tempFrom = self.tempFrom - delta

		if self.tempFrom < 1 then
			self.tempFrom = 1
		end
		
		local numHistory = min(#bossKillFrame.playerList, 20)
		
		local minFrom = numHistory - 4
		
		if minFrom < 1 then
			minFrom = 1
		end
		
		if self.tempFrom > minFrom then
			self.tempFrom = minFrom
		end
		
		UpdateLootInfo(self.tempFrom, true)
		self.sliderIndicator:SetPosition(self.tempFrom, numHistory)
	end)
	
	bossKillFrame.artWork.sliderIndicator = bossKillFrame.artWork:CreateTexture(nil, 'OVERLAY')
	bossKillFrame.artWork.sliderIndicator:SetSize(2, 100)
	bossKillFrame.artWork.sliderIndicator:SetColorTexture(0.5,0.5,0.5,1)
	bossKillFrame.artWork.sliderIndicator:SetPoint('TOPRIGHT', bossKillFrame.artWork, 'TOPRIGHT', -2, -1)
	bossKillFrame.artWork.sliderIndicator.SetPosition = function(self, from, maxV)		
		if maxV <= 5 or lastFromMaxItem < 5 then
			self:Hide()		
		else
			self:Show()
			local total = 5*(50)
			self:SetHeight(5/maxV*total)
			self:SetPoint("TOPRIGHT", bossKillFrame.artWork, "TOPRIGHT", -2, -25-(from-1)/maxV*total)
		end
	end
	
	local function SetAtlasTexture(obj, name)
		local filename, width, height, left, right, top, bottom, tilesHoriz, tilesVert = GetAtlasInfo(name)
		
		obj:SetTexture(filename)
		obj:SetSize(width, height)
		obj:SetTexCoord(left, right, top, bottom)
	end
	
	bossKillFrame.artWork.BgBanner_Top = bossKillFrame.artWork:CreateTexture(nil, 'BORDER')
	bossKillFrame.artWork.BgBanner_Top:SetBlendMode('BLEND')
	bossKillFrame.artWork.BgBanner_Top:SetPoint('TOP', bossKillFrame.artWork, 'TOP', 0, 44)
	bossKillFrame.artWork.BgBanner_Top:SetAlpha(0.7)
	SetAtlasTexture(bossKillFrame.artWork.BgBanner_Top, "BossBanner-BgBanner-Top")
	
	bossKillFrame.artWork.BgBanner_Bottom = bossKillFrame.artWork:CreateTexture(nil, 'BORDER')
	bossKillFrame.artWork.BgBanner_Bottom:SetBlendMode('BLEND')
	bossKillFrame.artWork.BgBanner_Bottom:SetPoint('BOTTOM', bossKillFrame.artWork, 'BOTTOM', 0, -84)
	bossKillFrame.artWork.BgBanner_Bottom:SetAlpha(0.7)
	SetAtlasTexture(bossKillFrame.artWork.BgBanner_Bottom, "BossBanner-BgBanner-Top")
	
	bossKillFrame.artWork.BannerMiddle = bossKillFrame.artWork:CreateTexture(nil, 'BACKGROUND')
	bossKillFrame.artWork.BannerMiddle:SetBlendMode('BLEND')
	bossKillFrame.artWork.BannerMiddle:SetPoint('TOPLEFT', bossKillFrame.artWork.BgBanner_Top, 0, -34)
	bossKillFrame.artWork.BannerMiddle:SetPoint('BOTTOMRIGHT', bossKillFrame.artWork.BgBanner_Bottom, 0, 75)
	bossKillFrame.artWork.BannerMiddle:SetAlpha(0.8)
	SetAtlasTexture(bossKillFrame.artWork.BannerMiddle, "BossBanner-BgBanner-Mid")
	
	bossKillFrame.minTime = 4
	bossKillFrame.lootList = {}
	bossKillFrame.playerList = {}
	
	bossKillFrame.slots = {}
	
	for i=1, 5 do
		local f = CreateFrame('Frame', nil, bossKillFrame.artWork)
		f:SetSize(160, 40)
		
	--	f.bg = f:CreateTexture()
	--	f.bg:SetAllPoints()
	--	f.bg:SetColorTexture(0.6, 0, 0, 0.6)
	
		f.artWork = CreateFrame('Frame', nil, f)	
		--[==[
		f.artWork:SetPoint('TOP', f, 'TOP', 0, -2)
		f.artWork:SetSize(160, 44)
		f.artWork:SetBackdrop({
			bgFile = [[Interface\Buttons\WHITE8x8]], 
			edgeFile = 'Interface\\AddOns\\AleaUI\\media\\glow', 
			tile = false, tileSize = 0, edgeSize = 4, 
			insets = { left = 4, right = 4, top = 4, bottom = 4}
		})
		f.artWork:SetBackdropColor(0.3, 0.3, 0.3, 0.7)
		f.artWork:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.7)
		]==]
		
		f.ItemBg = f:CreateTexture(nil, 'BACKGROUND')
		f.ItemBg:SetBlendMode('BLEND')
		f.ItemBg:SetPoint('TOP', f, 'TOP', 0, -2)
	--	f.ItemBg:SetPoint('BOTTOMRIGHT', bossKillFrame.artWork.BgBanner_Bottom, 0, 75)
		SetAtlasTexture(f.ItemBg, "LootBanner-ItemBg")
		f.ItemBg:SetSize(160, 44)
		f.ItemBg:SetAlpha(1)
	
		f:SetPoint('TOP', bossKillFrame.artWork, 'TOP', 0, 15-50*i)
		
		f.name = f.artWork:CreateFontString()
		f.name:SetFont(Skins.default_font, 12, 'OUTLINE')
		f.name:SetDrawLayer('OVERLAY')
		f.name:SetShadowOffset(1, -1)
		f.name:SetShadowColor(0,0,0)
		f.name:SetPoint('TOP', f, 'TOP', 0, -2)
		f.name:SetText('Player'..i)
		
		f:Hide()
		
		f.AnimIfNotShown = AnimIfNotShown
		
		f.items = {}
		
		for a=1, 5 do
			local item = CreateFrame('Button', nil, f)
			item:SetSize(22, 22)
			item:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 7 +(30*(a-1)), 3)
			item:EnableMouse(true)
			item:SetFrameLevel(f:GetFrameLevel()+1)
			
			item.bg = item:CreateTexture()
			item.bg:SetPoint('TOPLEFT', item, 'TOPLEFT', -1, 1)
			item.bg:SetPoint('BOTTOMRIGHT', item, 'BOTTOMRIGHT', 1, -1)
			item.bg:SetDrawLayer('BACKGROUND', 0)
			item.bg:SetColorTexture(0, 0, 0, 1)
			
			item.icon = item:CreateTexture()
			item.icon:SetDrawLayer('OVERLAY', 0)
			item.icon:SetAllPoints()
			item.icon:SetColorTexture(0.6, 0.6, 0, 0.6)
			item.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			
			item.ilvl = item:CreateFontString()
			item.ilvl:SetFont(Skins.default_font, 12, 'OUTLINE')
			item.ilvl:SetDrawLayer('OVERLAY')
			item.ilvl:SetShadowOffset(1, -1)
			item.ilvl:SetShadowColor(0,0,0)
			item.ilvl:SetPoint('BOTTOMLEFT', item, 'BOTTOMLEFT', 0, 0)
			item.ilvl:SetText('iLvL')
		
			item.RelicBorder = item:CreateTexture()
			item.RelicBorder:SetDrawLayer('OVERLAY', 3)
			item.RelicBorder:SetSize(22, 22)
			item.RelicBorder:SetPoint('CENTER', item.icon, 'CENTER', 0, 0)
			item.RelicBorder:SetTexCoord(0.04, 0.96, 0.04, 0.96)
			item.RelicBorder:SetTexture([[Interface\Artifacts\RelicIconFrame]]);
			item.RelicBorder:SetVertexColor(0.7, 0.7, 0.7, 1)
			
			item:SetScript("OnLeave", AleaUI.HideTip2)
			item:SetScript('OnEnter', AleaUI.SetItemTip)
			item:SetScript('OnEvent', AleaUI.SetItemTip)
			item:SetScript("OnClick", AleaUI.LootClick)	
	
			item.AnimIfNotShown = AnimIfNotShown
			
			f.items[a] = item
		end
		
		bossKillFrame.slots[i] = f
	end
	
	function ResetLootList()
		wipe(bossKillFrame.lootList)
		wipe(bossKillFrame.playerList)
	
		bossKillFrame.artWork.tempFrom = 1
		
		lastFromMaxItem = -1
		
		for i=1, #bossKillFrame.slots do
			bossKillFrame.slots[i]:Hide()
		end
		
	--	UpdateLootInfo(bossKillFrame.artWork.tempFrom)
	--	bossKillFrame.artWork.sliderIndicator:SetPosition(bossKillFrame.artWork.tempFrom, 0)

		bossKillFrame.artWork:Hide()
		bossKillFrame.artWork:SetHeight(baseFrameSize)
		bossKillFrame.step = 1
		bossKillFrame.elapsed = 0
		bossKillFrame:SetScript('OnUpdate', nil)
	end
	
	function ShowBossDefeat(name, skipUpdate)
		if name then
			bossKillFrame.artWork.name:SetText(name)
		end
		
		bossKillFrame.artWork.tempFrom = 1
		
		lastFromMaxItem = -1
		
		for i=1, #bossKillFrame.slots do
			bossKillFrame.slots[i]:Hide()
		end
		
		if not skipUpdate then
			UpdateLootInfo(bossKillFrame.artWork.tempFrom)
		end
		
		bossKillFrame.artWork.sliderIndicator:SetPosition(bossKillFrame.artWork.tempFrom, 0)
	
		bossKillFrame.minTime = 4
		bossKillFrame.artWork:Show()
		bossKillFrame.artWork:SetHeight(baseFrameSize)
		if not skipUpdate then
			bossKillFrame.step = 1
			bossKillFrame.elapsed = 0
		end
		bossKillFrame:SetScript('OnUpdate', OnUpdateHandler)
		bossKillFrame:Show()
	end

	function TEST_ShowBossDefeat()
		ResetLootList()
		ShowBossDefeat('TestBossName')
	end
	
	function AddLootToShow(player, class, item)
		local data
		
		if bossKillFrame:IsShown() and bossKillFrame.step == 3 then
			C_Timer.After(bossKillFrame.minTime+1-bossKillFrame.elapsed+0.3, function()
				AddLootToShow(player, class, item)
			end)
			
			return
		end
		
			
		for i=1, #bossKillFrame.playerList do
			if bossKillFrame.playerList[i].name == player then
				data = bossKillFrame.playerList[i]
				break
			end
		end
				
		if not data then
			bossKillFrame.playerList[#bossKillFrame.playerList+1] = { name = player, class = class, items = {} }
			
			data = bossKillFrame.playerList[#bossKillFrame.playerList]
		end
		
		if not bossKillFrame:IsShown() or bossKillFrame.step == 3 then
			bossKillFrame.step = 2
			bossKillFrame.elapsed = 1
			ShowBossDefeat( not bossKillFrame:IsShown() and LOOT or nil , true)
		end
		
		data.items[#data.items+1] = item
		
		if bossKillFrame.elapsed > 1 then
			bossKillFrame.elapsed = 1
		end
		bossKillFrame.artWork.sliderIndicator:SetPosition(bossKillFrame.artWork.tempFrom, #bossKillFrame.playerList)
	end
	
	function TEST_AddLootToShow(player, class, item)
		local name, link = GetItemInfo(item)

		AddLootToShow(player, class, link)
	end
	
	local function IsOverFrame()
		
		if InCombatLockdown() then
			return false
		end
		
		for i=1, #bossKillFrame.slots do			
			if bossKillFrame.slots[i]:IsVisible() and MouseIsOver(bossKillFrame.slots[i]) then
				return true
			end
			
			for a=1, #bossKillFrame.slots[i].items do
				if bossKillFrame.slots[i].items[a]:IsVisible() and MouseIsOver(bossKillFrame.slots[i].items[a]) then
					return true
				end
			end
		end
		
		return ( bossKillFrame:IsVisible() and MouseIsOver(bossKillFrame) ) or ( bossKillFrame.artWork:IsVisible() and MouseIsOver(bossKillFrame.artWork) )
	end
	
	function OnUpdateHandler(self, elapsed)
		self.elapsed = self.elapsed + elapsed

		
		if self.step == 1 then
			-- Show only boss name

			local alpha = 0
			
			if self.elapsed > 0.5 then 			
				alpha = ( self.elapsed - 0.5 )/0.5
			end
			
			if self.elapsed > 1 then
				self.step = 2
			end
			
			self.artWork:SetHeight(baseFrameSize)
			self.artWork:SetAlpha(alpha)
		elseif self.step == 2 then
			-- Update loot list

			
			local alpha = self.artWork:GetAlpha()
			
			if alpha < 1 then
				self.artWork:SetAlpha(alpha+(elapsed*3))
			else
				self.artWork:SetAlpha(1)
			end
			
			if IsOverFrame() and #bossKillFrame.playerList > 0 then
			--	print('Delay fade')
				
				self.elapsed = 3
			end
			
			if self.elapsed < self.minTime then
				UpdateLootInfo(bossKillFrame.artWork.tempFrom)
			else
				self.step = 3
			end
			
			if bossKillFrame.artWork.curHeight ~= bossKillFrame.artWork.setHeight then
			
			--	bossKillFrame.artWork.setHeight = baseFrameSize
			--	bossKillFrame.artWork.setHeightStart = 0
			--	bossKillFrame.artWork.curHeight = baseFrameSize
				
				local modif = ( GetTime()-bossKillFrame.artWork.setHeightStart )/0.3
				local height = ( bossKillFrame.artWork.setHeight - bossKillFrame.artWork.curHeight )*modif + bossKillFrame.artWork.curHeight
				
				if modif >= 1 then
					bossKillFrame.artWork.setHeight = height
					bossKillFrame.artWork.curHeight = height
					self.artWork:SetHeight(height)
					
					bossKillFrame.artWork.sliderIndicator:SetPosition(bossKillFrame.artWork.tempFrom, #bossKillFrame.playerList)
				else
					self.artWork:SetHeight(height)
				end
			end
		elseif self.step == 3 then
			-- Hide frame
		
			if IsOverFrame() then
				self.step = 2
				self.elapsed = 3
			end
			
			local alpha = 1
			
			if self.elapsed < self.minTime+1 then
				alpha = ( self.minTime+1 - self.elapsed )/1
			end
			
			self.artWork:SetAlpha(alpha)
			
			if self.elapsed >= self.minTime+1 then
				self:Hide()
				self.artWork:Hide()
				self:SetScript('OnUpdate', nil)
				self.step = 1
				self.elapsed = 0
				wipe(bossKillFrame.playerList)
			end
		end
	end
	
	local function QueueBossBannerItemItemLevel(obj, link)
		local itemLevel = GetDetailedItemLevelInfo(link)

		obj.ilvl:SetText((itemLevel and itemLevel > 1 ) and itemLevel or '')
	end
	
	local lastUpdate = -1
	
	function UpdateLootInfo(from, force)
	--	print('T', 'UpdateLootInfo', from, #ns.db.lootHistory)
		
		if lastUpdate > GetTime() and not force then
			return
		end
		
		if not force then
			lastUpdate = GetTime() + 0.7
		end

		local index = 0
		local maxNum = #bossKillFrame.playerList
		
		for i=1, #bossKillFrame.playerList do
			bossKillFrame.playerList[i].frame = nil
		end
		
		if maxNum > 0 then
			for i=from, from+4, 1 do		
				if bossKillFrame.playerList[i] then
					index = index + 1
		
					local name = bossKillFrame.playerList[i].name
					local items = bossKillFrame.playerList[i].items
					local class = bossKillFrame.playerList[i].class
					
					local classColorStr = ( class and RAID_CLASS_COLORS[class] ) and RAID_CLASS_COLORS[class].colorStr or 'ffffffff'
					
					bossKillFrame.slots[index].name:SetText('|c'..classColorStr..name..'|r')
					
					bossKillFrame.slots[index].bestRarity = -1
					
					for a=1, #items do
						local link = items[a]

						local _, _, _, _, textureInstant = GetItemInfoInstant(link);
						local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, _, _, _, _, _, _, classID, subclassID, bindType, expansion, itemSetID, isCraftReagent = GetItemInfo(link) 
						
						local color = ITEM_QUALITY_COLORS[itemRarity] or { r = 0.3, g = 0.3, b = 0.3 }
						
						if bossKillFrame.slots[index].items[a] then
						
							if bossKillFrame.slots[index].bestRarity < itemRarity then
								bossKillFrame.slots[index].bestRarity = itemRarity
							end
							
							bossKillFrame.slots[index].items[a]:Show()
							bossKillFrame.slots[index].items[a].icon:SetTexture(textureInstant)
							bossKillFrame.slots[index].items[a].link = itemLink
							
							if ( ( classID == 4  or classID == 2 ) and ( subclassID == 2 or subclassID == 1 or subclassID == 3 or subclassID == 4 or subclassID == 0 or subclassID == 10 or subclassID == 19 or subclassID == 7 or subclassID == 6 ) ) or IsArtifactRelicItem(link) then
							--	bossKillFrame.slots[index].items[a].ilvl:SetText(itemLevel)
								
								AleaUI.QueueForRun('bossKillFrame.slots['..index..'].items['..a..']-HandleText', QueueBossBannerItemItemLevel, bossKillFrame.slots[index].items[a], link)	
								
								bossKillFrame.slots[index].items[a].ilvl:SetTextColor(color.r, color.g, color.b)
							else
								bossKillFrame.slots[index].items[a].ilvl:SetText('') --classID..'-'..subclassID)
							end
							
							if link and IsArtifactRelicItem(link) then
								bossKillFrame.slots[index].items[a].RelicBorder:Show()
								bossKillFrame.slots[index].items[a].RelicBorder:SetVertexColor(color.r, color.g, color.b)
							else
								bossKillFrame.slots[index].items[a].RelicBorder:Hide()
							end
						end
						
						for b=a+1, #bossKillFrame.slots[index].items do
							bossKillFrame.slots[index].items[b]:Hide()
							bossKillFrame.slots[index].items[b].link = nil
						end
					end
					
					if lastFromMaxItem < index then
						lastFromMaxItem = index
						bossKillFrame.artWork:ChangeHeight(index)
						bossKillFrame.artWork.sliderIndicator:SetPosition(bossKillFrame.artWork.tempFrom, #bossKillFrame.playerList)
					--	break
					end
				
					bossKillFrame.playerList[i].frame = bossKillFrame.slots[index]
					
				--	local color = ITEM_QUALITY_COLORS[bossKillFrame.slots[index].bestRarity] or { r = 0.6, g = 0.6, b = 0.6 }
					
				--	print('T', bossKillFrame.slots[index].bestRarity, ITEM_QUALITY_COLORS[bossKillFrame.slots[index].bestRarity])
					
				--	bossKillFrame.slots[index].artWork:SetBackdropColor(color.r*0.5, color.g*0.5, color.b*0.5, ITEM_QUALITY_COLORS[bossKillFrame.slots[index].bestRarity] and 0.6 or 0.3)
				--	bossKillFrame.slots[index].artWork:SetBackdropBorderColor(color.r*0.5, color.g*0.5, color.b*0.5, ITEM_QUALITY_COLORS[bossKillFrame.slots[index].bestRarity] and 0.6)
					
				--	print('T', index, 'bossKillFrame.slots[index]:AnimIfNotShown()')
					
					bossKillFrame.slots[index]:AnimIfNotShown()
				end
			end
		end

		for i=index+1, #bossKillFrame.slots do
			bossKillFrame.slots[i]:Hide()
		end
	end
	
	local bossHandler = CreateFrame('Frame')
	bossHandler:RegisterEvent("BOSS_KILL")
--	bossHandler:RegisterEvent("ENCOUNTER_END")
	bossHandler:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
	bossHandler:SetScript('OnEvent', function(self, event, ...)
		if ( event == "BOSS_KILL" ) then
			local encounterID, name = ...;
			
			if bossKillFrame.encounterID ~= encounterID then
				ResetLootList()
			end
	
			bossKillFrame.killTime = GetTime() + 35
			bossKillFrame.encounterID = encounterID
			
			ShowBossDefeat(name)
		elseif ( event == 'ENCOUNTER_END' ) then
			local encounterID, name, difficultyID, raidSize, endStatus = ...;
			
			if endStatus == 1 then
				
				bossKillFrame.killTime = GetTime() + 35
				bossKillFrame.encounterID = encounterID
				
				ShowBossDefeat(name)
			end
		elseif ( event == "ENCOUNTER_LOOT_RECEIVED" ) then
			local encounterID, itemID, itemLink, quantity, playerName, className = ...;
			
		--	print('ENCOUNTER_LOOT_RECEIVED', itemID, itemLink, quantity, GetItemInfo(itemLink))
			
			if bossKillFrame.killTime and bossKillFrame.killTime < GetTime() then
		--		print('ClearBoossencounterID')
		--		bossKillFrame.encounterID = nil
			end
			
			local _, instanceType = GetInstanceInfo();
			
		--	print('ENCOUNTER_LOOT_RECEIVED', encounterID, bossKillFrame.encounterID, instanceType, itemLink)
			
			if ( encounterID == bossKillFrame.encounterID and ( instanceType == "party" or instanceType == "raid" ) ) then			
				if itemID == 140587 or IsArtifactPowerItem(itemID) then
				
				else
		--			print('ENCOUNTER_LOOT_RECEIVED-2', encounterID, bossKillFrame.encounterID, instanceType, itemLink)
					
					AddLootToShow(playerName, className, itemLink)
					
				end
			end
		elseif event == "CHALLENGE_MODE_COMPLETED" then		
			local mapID, level, time, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo();
			
			
		end
	end)
end)