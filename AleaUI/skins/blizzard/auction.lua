local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'auction'
E.default_settings.skins[varName] = true

E:OnAddonLoad('Blizzard_AuctionUI', function()
	
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	AuctionFrame:StripTextures()
	AuctionFrameBrowse:StripTextures()
	
	
	local temp = Skins.NewBackdrop(AuctionFrame)	
	temp:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 1)
	temp:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
	
	AuctionFrameTopLeft:Kill()
	AuctionFrameBotLeft:Kill()
	AuctionFrameTopRight:Kill()
	AuctionFrameBotRight:Kill()
	AuctionFrameTop:Kill()
	AuctionFrameBot:Kill()
	
	temp:SetPoint('TOPLEFT', AuctionFrameTopLeft, 5, -10)
	temp:SetPoint('TOPRIGHT', AuctionFrameTopRight, 0, -10)
	temp:SetPoint('BOTTOMRIGHT', AuctionFrameBotRight, 0, 75)
	temp:SetPoint('BOTTOMLEFT', AuctionFrameBotLeft, 0, 75)
	
	AuctionPortraitTexture:Kill()
	
	Skins.ThemeScrollBar('BrowseFilterScrollFrameScrollBar')
	Skins.ThemeScrollBar('BrowseScrollFrameScrollBar')

	BrowseQualitySort:StripTextures(true)
	BrowseLevelSort:StripTextures(true)
	BrowseDurationSort:StripTextures(true)
	BrowseHighBidderSort:StripTextures(true)
	BrowseQualitySort:StripTextures(true)
	BrowseCurrentBidSort:StripTextures(true)
	
	BidQualitySort:StripTextures(true)
	BidLevelSort:StripTextures(true)
	BidDurationSort:StripTextures(true)
	BidBuyoutSort:StripTextures(true)
	BidStatusSort:StripTextures(true)
	BidBidSort:StripTextures(true)
	
	AuctionsQualitySort:StripTextures(true)
	AuctionsDurationSort:StripTextures(true)
	AuctionsHighBidderSort:StripTextures(true)
	AuctionsBidSort:StripTextures(true)
	
	BrowseName:ClearAllPoints()
	BrowseName:SetPoint('TOPLEFT', AuctionFrame, 'TOPLEFT', 18, -53)
	BrowseName:SetWidth(200)
	
	for i=1, 3 do
		Skins.ThemeTab('AuctionFrameTab'..i)
	end
	
	Skins.ThemeIconButton(BrowsePrevPageButton, -5)
	BrowsePrevPageButton:SetSize(16, 16)
	
	Skins.ThemeIconButton(BrowseNextPageButton, -5)
	BrowseNextPageButton:SetSize(16, 16)
	
	Skins.ThemeCheckBox(ExactMatchCheckButton)
	Skins.ThemeCheckBox(IsUsableCheckButton)
	Skins.ThemeCheckBox(ShowOnPlayerCheckButton)
	
	local border = Skins.ThemeEditBox(BrowseName, true, 200, 20)
	border:SetPoint('TOPLEFT', BrowseName, 'TOPLEFT', -2, 2)
	border:SetSize(200, 20)
	
	local border = Skins.ThemeEditBox(BrowseMinLevel, nil, 25)	
	border:SetPoint('TOPLEFT', BrowseMinLevel, 'TOPLEFT', -2, 2)
	border:SetSize(25, 20)
	
	local border = Skins.ThemeEditBox(BrowseMaxLevel, nil, 25)
	border:SetPoint('TOPLEFT', BrowseMaxLevel, 'TOPLEFT', -2, 2)
	border:SetSize(25, 20)
	
	Skins.ThemeEditBox(BrowseBidPriceGold, true)
	Skins.ThemeEditBox(BrowseBidPriceSilver, nil, 40, 18)
	Skins.ThemeEditBox(BrowseBidPriceCopper, nil, 40, 18)
	
	Skins.ThemeEditBox(BidBidPriceGold, true)
	Skins.ThemeEditBox(BidBidPriceSilver, nil, 40, 18)
	Skins.ThemeEditBox(BidBidPriceCopper, nil, 40, 18)
	
	local temp1, f = Skins.ThemeDropdown('BrowseDropDown')
	temp1:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -3)
	temp1:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 108, 8)
	
	Skins.ThemeButton(BrowseSearchButton)
	Skins.ThemeButton(BrowseResetButton)
	Skins.ThemeButton(BrowseBidButton)
	Skins.ThemeButton(BrowseBuyoutButton)
	Skins.ThemeButton(BrowseCloseButton)
	
	Skins.ThemeButton(BidBidButton)
	Skins.ThemeButton(BidBuyoutButton)
	Skins.ThemeButton(BidCloseButton)
	
	local temp1, f = Skins.ThemeDropdown('PriceDropDown')
	local temp1, f = Skins.ThemeDropdown('DurationDropDown')

	Skins.ThemeEditBox(StartPriceGold, true)
	Skins.ThemeEditBox(StartPriceSilver, nil, 40, 18)
	Skins.ThemeEditBox(StartPriceCopper, nil, 40, 18)
	
	Skins.ThemeEditBox(BuyoutPriceGold, true)
	Skins.ThemeEditBox(BuyoutPriceSilver, nil, 40, 18)
	Skins.ThemeEditBox(BuyoutPriceCopper, nil, 40, 18)
	
	Skins.ThemeButton(AuctionsCreateAuctionButton)
	Skins.ThemeButton(AuctionsCancelAuctionButton)
	Skins.ThemeButton(AuctionsCloseButton)
	
	for i=1, NUM_FILTERS_TO_DISPLAY do
		local tab = _G["AuctionFilterButton"..i]
		
		_G["AuctionFilterButton"..i..'NormalTexture']:SetAlpha(0)
		_G["AuctionFilterButton"..i..'NormalTexture'].SetAlpha = function()end
	end
	
	
	for i=1, NUM_BROWSE_TO_DISPLAY do
		local button = _G["BrowseButton"..i]
		local btn = _G["BrowseButton"..i..'Item']
		local icon = _G["BrowseButton"..i..'ItemIconTexture']
		local border = btn.IconBorder
		local normal = _G["BrowseButton"..i..'ItemNormalTexture']
		local name = _G["BrowseButton"..i..'Name']
		
		E:CreateBackdrop(btn, icon, default_button_border, { 0, 0, 0, 0 })
		
		normal:SetTexture(nil)
		border:SetTexture(nil)
		border:SetAlpha(0)
		
		button:StripTextures()
		
		hooksecurefunc(border, 'SetVertexColor', function(self, r, g, b)
			icon:SetUIBackdropBorderColor(r, g, b, 1)
		end)
		hooksecurefunc(border, 'Hide', function(self, r, g, b)
			icon:SetUIBackdropBorderColor(0, 0, 0, 1)
		end)
			
		icon:SetTexCoord(unpack(E.media.texCoord))
		name:SetFont(default_font, Skins.default_font_size, 'NONE')

		if button then		
			button:GetHighlightTexture():SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
			button:GetHighlightTexture():ClearAllPoints()
			button:GetHighlightTexture():SetPoint("TOPLEFT", icon, "TOPRIGHT", 2, 0)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		end
	end
	
	local browseBackground = CreateFrame('Frame', nil, AuctionFrameBrowse)
	browseBackground:SetSize(170, 312)
	browseBackground:SetPoint('TOPLEFT', AuctionFrame, 'TOPLEFT', 20 , -100)
	local temp = Skins.NewBackdrop(browseBackground)	
	temp:SetBackdropColor(0, 0, 0, 0.2)
	temp:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
	
	
	local auctionSetBackground = CreateFrame('Frame', nil, AuctionFrameAuctions)
	auctionSetBackground:SetSize(190, 312)
	auctionSetBackground:SetPoint('TOPLEFT', AuctionFrame, 'TOPLEFT', 20 , -75)
	local temp = Skins.NewBackdrop(auctionSetBackground)	
	temp:SetBackdropColor(0, 0, 0, 0.2)
	temp:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
	
	
	AuctionsItemButton:StripTextures()
	Skins.ThemeButton(AuctionsItemButton)
	AuctionsItemButton.IconBorder:Kill()
	
	AuctionsItemButton:HookScript('OnEvent', function(self, event, ...)
		self.modborder:SetBackdropBorderColor(0, 0, 0, 1)
		if event == 'NEW_AUCTION_UPDATE' and self:GetNormalTexture() then
			local Quality = select(4, GetAuctionSellItemInfo())
			self:GetNormalTexture():SetTexCoord(unpack(E.media.texCoord))
			self:GetNormalTexture():SetInside()
			if Quality and Quality > 1 and BAG_ITEM_QUALITY_COLORS[Quality] then
				self.modborder:SetBackdropBorderColor(BAG_ITEM_QUALITY_COLORS[Quality].r, BAG_ITEM_QUALITY_COLORS[Quality].g, BAG_ITEM_QUALITY_COLORS[Quality].b)
			end
		end
	end)
	
	Skins.ThemeEditBox(AuctionsStackSizeEntry, nil, 40, 18)
	Skins.ThemeEditBox(AuctionsNumStacksEntry, nil, 40, 18)
	
	Skins.ThemeButton(AuctionsStackSizeMaxButton)
	Skins.ThemeButton(AuctionsNumStacksMaxButton)
	
	for i=1, NUM_AUCTIONS_TO_DISPLAY do
		local button = _G["AuctionsButton"..i]
		local btn = _G["AuctionsButton"..i..'Item']
		local icon = _G["AuctionsButton"..i..'ItemIconTexture']
		local border = btn.IconBorder
		local normal = _G["AuctionsButton"..i..'ItemNormalTexture']
		local name = _G["AuctionsButton"..i..'Name']
		
		E:CreateBackdrop(btn, icon, default_button_border, { 0, 0, 0, 0 })
		
		normal:SetTexture(nil)
		border:SetTexture(nil)
		border:SetAlpha(0)
		
		button:StripTextures()
		
		hooksecurefunc(border, 'SetVertexColor', function(self, r, g, b)
			icon:SetUIBackdropBorderColor(r, g, b, 1)
		end)
		hooksecurefunc(border, 'Hide', function(self, r, g, b)
			icon:SetUIBackdropBorderColor(0, 0, 0, 1)
		end)
			
		icon:SetTexCoord(unpack(E.media.texCoord))
		name:SetFont(default_font, Skins.default_font_size, 'NONE')
		
		if button then		
			button:GetHighlightTexture():SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
			button:GetHighlightTexture():ClearAllPoints()
			button:GetHighlightTexture():SetPoint("TOPLEFT", icon, "TOPRIGHT", 2, 0)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		end
	end
	
	for i=1, NUM_BIDS_TO_DISPLAY do
		local button = _G["BidButton"..i]
		local btn = _G["BidButton"..i..'Item']
		local icon = _G["BidButton"..i..'ItemIconTexture']
		local border = btn.IconBorder
		local normal = _G["BidButton"..i..'ItemNormalTexture']
		local name = _G["BidButton"..i..'Name']
		
		E:CreateBackdrop(btn, icon, default_button_border, { 0, 0, 0, 0 })
		
		normal:SetTexture(nil)
		border:SetTexture(nil)
		
		button:StripTextures()
		
		hooksecurefunc(border, 'SetVertexColor', function(self, r, g, b)
			icon:SetUIBackdropBorderColor(r, g, b, 1)
		end)
		hooksecurefunc(border, 'Hide', function(self, r, g, b)
			icon:SetUIBackdropBorderColor(0, 0, 0, 1)
		end)
			
		icon:SetTexCoord(unpack(E.media.texCoord))
		name:SetFont(default_font, Skins.default_font_size, 'NONE')
		
		if button then		
			button:GetHighlightTexture():SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
			button:GetHighlightTexture():ClearAllPoints()
			button:GetHighlightTexture():SetPoint("TOPLEFT", icon, "TOPRIGHT", 2, 0)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		end
	end
	
end)