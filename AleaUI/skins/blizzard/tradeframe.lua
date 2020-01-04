local Skins = AleaUI:Module("Skins")

local varName = 'tradeframe'
AleaUI.default_settings.skins[varName] = true

local function Skin_TradeFrame()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	TradeFrame:StripTextures()
	TradeFrameInset:StripTextures()
	TradePlayerEnchantInset:StripTextures()
	TradePlayerInputMoneyInset:StripTextures()
	TradePlayerItemsInset:StripTextures()
	TradeRecipientItemsInset:StripTextures()
	TradeRecipientEnchantInset:StripTextures()
	TradeRecipientMoneyInset:StripTextures()
	TradeRecipientMoneyBg:StripTextures()

	Skins.ThemeBackdrop(TradeFrame)

	Skins.ThemeButton(TradeFrameTradeButton)
	Skins.ThemeButton(TradeFrameCancelButton)

	Skins.ThemeEditBox(TradePlayerInputMoneyFrameGold, true)
	Skins.ThemeEditBox(TradePlayerInputMoneyFrameSilver, true, 38)
	Skins.ThemeEditBox(TradePlayerInputMoneyFrameCopper, true, 38)
	
	--TradeHighlightPlayerMiddle
	--TradeHighlightPlayerTop
	--TradeHighlightPlayerBottom

	--TradeHighlightPlayerEnchantMiddle
	--TradeHighlightPlayerEnchantTop
	--TradeHighlightPlayerEnchantBottom

	--TradeHighlightRecipientMiddle
	--TradeHighlightRecipientTop
	--TradeHighlightRecipientBottom

	--TradeHighlightRecipientEnchantMiddle
	--TradeHighlightRecipientEnchantTop
	--TradeHighlightRecipientEnchantBottom

	TradeHighlightPlayerTop:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerBottom:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerMiddle:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightPlayer:SetFrameStrata("HIGH")

	TradeHighlightPlayerEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchant:SetFrameStrata("HIGH")

	TradeHighlightRecipientTop:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientBottom:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientMiddle:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightRecipient:SetFrameStrata("HIGH")

	TradeHighlightRecipientEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchant:SetFrameStrata("HIGH")
		
	for i=1, 7 do
		Skins.MerchantItems('TradePlayerItem'..i, true)
		Skins.MerchantItems('TradeRecipientItem'..i, true)
	end


	local texture = Skins.GetAllTextureObject('TradePlayerItem7', [[Interface\TradeFrame\UI-TradeFrame-EnchantIcon]])
	texture:Kill()

	local texture = Skins.GetAllTextureObject('TradeRecipientItem7', [[Interface\TradeFrame\UI-TradeFrame-EnchantIcon]])
	texture:Kill()
	
	local icon = Skins.GetAllTextureObject('MerchantRepairItemButton', [[Interface\MerchantFrame\UI-Merchant-RepairIcons]])
	icon:SetTexCoord(0+0.029, 0.28125-0.022, 0+0.068, 0.5625-0.044)

	local iconBorder = CreateFrame('Frame', nil, MerchantRepairItemButton)
	iconBorder:SetFrameLevel(iconBorder:GetParent():GetFrameLevel()+1)
	iconBorder:SetInside(icon)
	AleaUI:CreateBackdrop(iconBorder, nil, {0,0,0,1}, {0.1,0.1,0.1,0})
	
	local icon = Skins.GetAllTextureObject('MerchantRepairAllButton', [[Interface\MerchantFrame\UI-Merchant-RepairIcons]])
	icon:SetTexCoord(0.28125+0.025, 0.5625-0.022, 0+0.055, 0.5625-0.013)
	
	local iconBorder = CreateFrame('Frame', nil, MerchantRepairAllButton)
	iconBorder:SetFrameLevel(iconBorder:GetParent():GetFrameLevel()+1)
	iconBorder:SetInside(icon)
	AleaUI:CreateBackdrop(iconBorder, nil, {0,0,0,1}, {0.1,0.1,0.1,0})
	
	local icon = Skins.GetAllTextureObject('MerchantGuildBankRepairButton', [[Interface\MerchantFrame\UI-Merchant-RepairIcons]])
	icon:SetTexCoord(0.5625, 0.84375, 0, 0.5625)
	
	local iconBorder = CreateFrame('Frame', nil, MerchantGuildBankRepairButton)
	iconBorder:SetFrameLevel(iconBorder:GetParent():GetFrameLevel()+1)
	iconBorder:SetInside(icon)
	AleaUI:CreateBackdrop(iconBorder, nil, {0,0,0,1}, {0.1,0.1,0.1,0})
end

AleaUI:OnInit2(Skin_TradeFrame)











