local E = AleaUI
local L = E.L

local slotSize = 28
local bankperrow = 22

local frameStrata = 'MEDIUM'
local frameLevel = 30
--[==[
do
	local listFrames = {}
	
	hooksecurefunc('ContainerFrame_OnLoad', function(self)
		print('T', 'ContainerFrame_OnLoad', self:GetName())
		listFrames[self] = true
	end)
	
	hooksecurefunc('ContainerFrame_OnShow', function(self)
		print('T', 'ContainerFrame_OnShow', self:GetName())
		listFrames[self] = true
	end)
	
	
	hooksecurefunc('ContainerFrame_OnHide', function(self)
		print('T', 'ContainerFrame_OnHide', self:GetName())
		listFrames[self] = true
	end)
	
	hooksecurefunc('ContainerFrame_OnEvent', function(self, event)
		print('T', 'ContainerFrame_OnEvent', self:GetName(), event)
		listFrames[self] = true
	end)
	
end
]==]

local defaults = {
	enable = true,
	spacing = 1,
	bpr = 10,
	
	bankperrow = 11,
	banksize = 33,
	
	reagensperrow = 7,
	reagentsize = 28,
	
	scale = 1,

	separate = false,
	
	apSpecLocker = true,
	apSpecSettings = {},
	
	showTransmog = true,
	showApItem = true,
	showEquipSet = true,
	showItemLevel = true,
	showBoE = true,
}

local config = defaults

E.default_settings.containers = defaults

local UpdateBankItems
local UpdateReagentFrame

local frameHeader = "AleaUI_"
local blank_func = function()end
local togglemain, togglebank = 0, 0
local bagsIcons = {
	['bags'] = {},
	['bank'] = {},
	['reagent'] = {},
}

local AleUI_API = {}


local containers = {
	["bag"] 		= { width = 100, height = 100},
	["bank"] 		= { width = 100, height = 100},
	["reagent"] 	= { width = 100, height = 100},
}


local function CreateBackdrop(frame)
	E:CreateBackdrop(frame, nil, {0,0,0,1}, {0,0,0,0.6})
end
--[==[
function ContainerFrameItemButton_UpdateItemUpgradeIcon()
	
end
]==]
local function SkinEditBox(frame)

	if not frame then return end
	if frame._skinned then return end
	
--	print("TEST", frame:GetName())
	
	_G[frame:GetName()].Left:Hide()
	_G[frame:GetName()].Right:Hide()
	_G[frame:GetName()].Middle:Hide()


	frame:SetFrameStrata(frameStrata)
	frame:SetFrameLevel(frameLevel+2)
	frame:SetWidth(100)
	frame:SetScale(E.db.containers.scale)
	
	local framebg = CreateFrame('frame', nil, frame)
	framebg:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 0)
	framebg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  
	E:CreateBackdrop(framebg, nil, {0,0,0,1}, {0,0,0,0.6})
	
    framebg:SetUIBackgroundColor(1,1,1,.4)
    framebg:SetUIBackdropBorderColor(0,0,0,1)
	framebg:SetFrameLevel(frameLevel+2)
	
	frame._skinned = framebg
end

local GetItemQualityColor = GetItemQualityColor


local LocalGetNumEquipmentSets = C_EquipmentSet and C_EquipmentSet.GetNumEquipmentSets or GetNumEquipmentSets
local LocalGetEquipmentSetInfo = C_EquipmentSet and C_EquipmentSet.GetEquipmentSetInfo or GetEquipmentSetInfo

local ProfessionColors = {
	[0x0008] = {224/255, 187/255, 74/255}, -- Leatherworking
	[0x0010] = {74/255, 77/255, 224/255}, -- Inscription
	[0x0020] = {18/255, 181/255, 32/255}, -- Herbs
	[0x0040] = {160/255, 3/255, 168/255}, -- Enchanting
	[0x0080] = {232/255, 118/255, 46/255}, -- Engineering
	[0x0200] = {8/255, 180/255, 207/255}, -- Gems
	[0x0400] = {105/255, 79/255,  7/255}, -- Mining
	[0x010000] = {222/255, 13/255,  65/255} -- Cooking
}

local hidenFrame = CreateFrame('Frame')
hidenFrame:Hide()

local function ItemBackdrop(frame)
	
	if not frame.itembgdone then
		frame.itembgdone = true

		frame:GetPushedTexture():SetColorTexture(1,1,1, 0.2)
		frame:GetHighlightTexture():SetColorTexture(1,1,1, 0.2)
		
		_G[frame:GetName().."Cooldown"]:SetBlingTexture("")	
		_G[frame:GetName().."NormalTexture"]:SetParent(hidenFrame)
	--	frame.IconBorder:SetParent(hidenFrame)

		_G[frame:GetName()..'Cooldown'].SizeOverride = 0.7				
		E:RegisterCooldown(_G[frame:GetName()..'Cooldown'])

		frame._IconBackground = frame:CreateTexture()
		frame._IconBackground:SetDrawLayer('BORDER', -1)
		frame._IconBackground:SetTexture([[Interface\Buttons\WHITE8x8]])
		frame._IconBackground:SetAllPoints(frame)
		frame._IconBackground:SetVertexColor(0.15,0.15,0.15,1)
		
		frame._IconBorder = frame:CreateTexture()
		frame._IconBorder:SetDrawLayer('BORDER', -2)
		frame._IconBorder:SetTexture([[Interface\Buttons\WHITE8x8]])
		frame._IconBorder:SetOutside(frame._IconBackground)
		frame._IconBorder:SetVertexColor(0,0,0,1)
		
		if frame.IconQuestTexture then
			frame.IconQuestTexture:SetTexCoord(.07, .93, .07, .93)
			frame.IconQuestTexture:SetAllPoints(frame)
		end
		
		if _G[frame:GetName().."IconQuestTexture"] then
			_G[frame:GetName().."IconQuestTexture"]:SetTexCoord(.07, .93, .07, .93)
			_G[frame:GetName().."IconQuestTexture"]:SetAllPoints(frame)
		end
		
		frame.icon:SetTexCoord(AleaUI.media.texCoord[1],AleaUI.media.texCoord[2],AleaUI.media.texCoord[3],AleaUI.media.texCoord[4])
	end

	local bagID, slotID = ( frame.BagID or frame:GetParent():GetID()), frame:GetID() --frame:GetParent():GetID(), frame:GetID()
	local texture, itemCount, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(bagID, slotID);

	local isQuestItem, questId, isActive
	if ( GetContainerItemQuestInfo ) then 
	isQuestItem, questId, isActive = GetContainerItemQuestInfo(bagID, slotID);
	end

	local bagFreeSlots, bagType = GetContainerNumFreeSlots(bagID)

	if quality then
		if quality > 1 then		
			local r, g, b, hex = GetItemQualityColor(quality)
			frame._IconBorder:SetVertexColor(r,g,b,1)
		elseif quality > 0 then
			frame._IconBorder:SetVertexColor(0, 0, 0, 1)
		else
			frame._IconBorder:SetVertexColor(0.5,0.5,0.5,1)
		end
	else
		frame._IconBorder:SetVertexColor(0, 0, 0, 1)
	end
	
	if ProfessionColors[bagType] then
		frame._IconBackground:SetVertexColor(ProfessionColors[bagType][1], ProfessionColors[bagType][2], ProfessionColors[bagType][3], 0.4)
	else
		frame._IconBackground:SetVertexColor(0.17,0.17,0.17,1)
	end
	
	if isQuestItem then
		frame._IconBorder:SetVertexColor(230/255,191/255,51/255,1)
	end
end

local _addons = CreateFrame("Frame")
_addons:RegisterEvent("BAG_UPDATE_DELAYED")
_addons:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

if ( not E.isClassic ) then 
	_addons:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
end 

_addons:RegisterEvent("BANKFRAME_OPENED")
_addons:SetScript("OnEvent", function(self, elapsed)
	for k in pairs(bagsIcons['bags']) do
		ItemBackdrop(k)	
	end
	SkinEditBox(BagItemSearchBox)

	for k in pairs(bagsIcons['bank']) do
		ItemBackdrop(k)	
	end
	for k in pairs(bagsIcons['reagent']) do
		ItemBackdrop(k)	
	end
	
	SkinEditBox(BankItemSearchBox)
end)



local bagsFrame = CreateFrame("Frame", frameHeader.."bagsFrame", UIParent)
bagsFrame:EnableMouse(true)
bagsFrame:SetSize(config.bpr*39, 600)
bagsFrame:SetPoint("CENTER")
bagsFrame:SetFrameStrata(frameStrata)
bagsFrame:SetFrameLevel(frameLevel)

bagsFrame.bag0 = CreateFrame('Frame', nil, bagsFrame)
bagsFrame.bag0:SetID(0)
bagsFrame.bag1 = CreateFrame('Frame', nil, bagsFrame)
bagsFrame.bag1:SetID(1)
bagsFrame.bag2 = CreateFrame('Frame', nil, bagsFrame)
bagsFrame.bag2:SetID(2)
bagsFrame.bag3 = CreateFrame('Frame', nil, bagsFrame)
bagsFrame.bag3:SetID(3)
bagsFrame.bag4 = CreateFrame('Frame', nil, bagsFrame)
bagsFrame.bag4:SetID(4)

bagsFrame:SetMovable(true)
bagsFrame:Hide()
bagsFrame:HookScript('OnShow', _addons:GetScript('OnEvent'))
--[==[
bagsFrame.bg = bagsFrame:CreateTexture(nil, 'ARTWORK')
bagsFrame.bg:SetAllPoints()
bagsFrame.bg:SetColorTexture(0,0,0,0.8)
]==]

E:CreateBackdrop(bagsFrame, nil, {0,0,0,1}, {0.1,0.1,0.1,0.9})

-- CharacterBag0Slot
-- CharacterBag1Slot
-- CharacterBag2Slot
-- CharacterBag3Slot

bagsFrame.bagOverlay = CreateFrame('Frame', nil, bagsFrame)
bagsFrame.bagOverlay:SetSize(1, 1)
bagsFrame.bagOverlay:SetPoint('TOPRIGHT', bagsFrame, 'TOPLEFT',0,0)
bagsFrame.bagOverlay:SetFrameLevel(frameLevel+1)
bagsFrame.bagOverlay:SetFrameStrata(frameStrata)

CharacterBag0Slot:ClearAllPoints()
CharacterBag0Slot:SetParent(bagsFrame.bagOverlay)

CharacterBag1Slot:ClearAllPoints()
CharacterBag1Slot:SetParent(bagsFrame.bagOverlay)

CharacterBag2Slot:ClearAllPoints()
CharacterBag2Slot:SetParent(bagsFrame.bagOverlay)

CharacterBag3Slot:ClearAllPoints()
CharacterBag3Slot:SetParent(bagsFrame.bagOverlay)

local function CombinedOnClickHandler(self, button)
	PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or "igMainMenuOptionCheckBoxOn");
	ToggleDropDownMenu(1, nil, _G["ContainerFrame"..self._filterDropdownID..'FilterDropDown'] , self, 0, 0);
end

local updateBagsOnChange = CreateFrame('Frame')
updateBagsOnChange:SetScript('OnEvent', function(self)
	self:UnregisterAllEvents()
	CloseAllBags()
	OpenAllBags()
end)

local function SetCombinedHandler(frame, id)

	frame._onClick = frame:GetScript('OnClick')
	frame._filterDropdownID = id
	frame:SetScript('OnClick', CombinedOnClickHandler)
	frame:HookScript('OnReceiveDrag', function(self)
	--	self._onClick(self, 'LeftButton')
	
	--	CloseAllBags()
	--	C_Timer.After(0.5, OpenAllBags)
		updateBagsOnChange:RegisterEvent('BAG_UPDATE_DELAYED')
	end)
	
--	frame:StripTextures2('Interface\\Buttons\\CheckButtonHilight')
	frame:StyleButton()
	
	frame.__pushed:Kill(true)
	--frame.__checked:Kill(true)
--	frame.IconBorder:Kill(true)
	frame:SetSize(20, 20*0.7)
	_G[frame:GetName()..'NormalTexture']:Kill(true)
	
	_G[frame:GetName()..'IconTexture']:SetTexCoord(.07, 0.93, .23, 0.77)

	local border = frame:CreateTexture()
	border:SetDrawLayer('BACKGROUND')
	border:SetOutside()
	border:SetColorTexture(0,0,0,1)
	
	frame:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 135 - ((20+5)*id+2), -8)
end

SetCombinedHandler(CharacterBag0Slot, 2)
SetCombinedHandler(CharacterBag1Slot, 3)
SetCombinedHandler(CharacterBag2Slot, 4)
SetCombinedHandler(CharacterBag3Slot, 5)

local portrit_size = 20

for port = 1, 1 do

	_G["ContainerFrame"..port.."PortraitButton"]:SetFrameStrata(frameStrata)
	_G["ContainerFrame"..port.."PortraitButton"]:SetFrameLevel(frameLevel+1)
	_G["ContainerFrame"..port.."PortraitButton"]:ClearAllPoints()
	_G["ContainerFrame"..port.."PortraitButton"]:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 135 - ((portrit_size+5)*port), -8)
	_G["ContainerFrame"..port.."PortraitButton"]:SetSize(portrit_size, portrit_size*0.7)
	
	_G["ContainerFrame"..port.."PortraitButton"].Highlight:SetPoint("CENTER")
	_G["ContainerFrame"..port.."PortraitButton"].Highlight:SetSize(portrit_size, portrit_size*0.7)
	_G["ContainerFrame"..port.."PortraitButton"].Highlight:SetTexture([[Interface\Buttons\WHITE8x8]])
	_G["ContainerFrame"..port.."PortraitButton"].Highlight:SetVertexColor(1, 1, 1, 0.3)
	
	_G["ContainerFrame"..port.."Portrait"] = _G["ContainerFrame"..port.."PortraitButton"]:CreateTexture(nil, "ARTWORK")
	_G["ContainerFrame"..port.."Portrait"]:ClearAllPoints()
	_G["ContainerFrame"..port.."Portrait"]:SetSize(portrit_size, portrit_size*0.7)
	_G["ContainerFrame"..port.."Portrait"]:SetPoint("CENTER")
	_G["ContainerFrame"..port.."Portrait"]:SetTexCoord(.07, 0.93, .23, 0.77)
	
	E:CreateBackdrop(_G["ContainerFrame"..port.."PortraitButton"], nil, {0,0,0,1}, {0,0,0,0.6})
	
	SetPortraitToTexture(_G["ContainerFrame"..port.."Portrait"], "Interface\\ICONS\\INV_Misc_Bag_08");
end

if ( BagItemSearchBox ) then 

	BagItemSearchBox:ClearAllPoints()
	BagItemSearchBox:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 170, -5)
	BagItemSearchBox:SetPoint("TOPRIGHT", bagsFrame, "TOPRIGHT", -30, -5)
	BagItemSearchBox:SetParent(bagsFrame)
	BagItemSearchBox:Show()

	BagItemSearchBox._ClearAllPoints = BagItemSearchBox.ClearAllPoints
	BagItemSearchBox._SetPoint = BagItemSearchBox.SetPoint
	BagItemSearchBox._SetParent = BagItemSearchBox.SetParent

	BagItemSearchBox.ClearAllPoints = blank_func
	BagItemSearchBox.SetPoint = blank_func
	BagItemSearchBox.SetParent = blank_func

	BagItemAutoSortButton:ClearAllPoints()
	BagItemAutoSortButton:SetPoint("TOPLEFT", BagItemSearchBox, "TOPRIGHT", 5, 0)
	BagItemAutoSortButton:SetSize(18,18)
	BagItemAutoSortButton:SetParent(BagItemSearchBox)
	BagItemAutoSortButton:Show()
	BagItemAutoSortButton:GetNormalTexture():SetTexCoord(.13, 0.87, .13, 0.87)
	E:CreateBackdrop(BagItemAutoSortButton, nil, {0,0,0,1}, {0,0,0,0.6})

	BagItemAutoSortButton.ClearAllPoints = blank_func
	BagItemAutoSortButton.SetPoint = blank_func
	BagItemAutoSortButton.SetParent = blank_func

end 


local bankFrame = CreateFrame("Frame", frameHeader.."bankFrame", UIParent)
bankFrame:SetSize(config.bankperrow*39+config.reagensperrow*39 + 20, 600)
bankFrame:SetPoint("CENTER")
bankFrame:SetFrameStrata(frameStrata)
bankFrame:SetFrameLevel(frameLevel+1)

bankFrame.reagent = CreateFrame("Frame", nil, bankFrame)
bankFrame.reagent:SetPoint("CENTER")
bankFrame.reagent:SetID(-3)
bankFrame.reagent:SetFrameStrata(frameStrata)
bankFrame.reagent:SetFrameLevel(frameLevel+7)
			
bankFrame.bag5 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag5:SetID(5)
bankFrame.bag5:SetFrameLevel(frameLevel+7)
bankFrame.bag6 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag6:SetID(6)
bankFrame.bag6:SetFrameLevel(frameLevel+7)
bankFrame.bag7 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag7:SetID(7)
bankFrame.bag7:SetFrameLevel(frameLevel+7)
bankFrame.bag8 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag8:SetID(8)
bankFrame.bag8:SetFrameLevel(frameLevel+7)
bankFrame.bag9 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag9:SetID(9)
bankFrame.bag9:SetFrameLevel(frameLevel+7)
bankFrame.bag10 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag10:SetID(10)
bankFrame.bag10:SetFrameLevel(frameLevel+7)
bankFrame.bag11 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag11:SetID(11)
bankFrame.bag11:SetFrameLevel(frameLevel+7)
bankFrame.bag12 = CreateFrame('Frame', nil, bankFrame)
bankFrame.bag12:SetID(12)
bankFrame.bag12:SetFrameLevel(frameLevel+7)

E:CreateBackdrop(bankFrame, nil, {0,0,0,1}, {0.1,0.1,0.1,0.9})


bankFrame:EnableMouse(true)
bankFrame:SetMovable(true)
bankFrame:RegisterForDrag("LeftButton")	
bankFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
bankFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
bankFrame:Hide()

local function CheckReagentFramePurchase()
	
	if ReagentBankFrameUnlockInfoPurchaseButton:IsShown() then
		
	end
end

bankFrame:SetScript("OnShow", CheckReagentFramePurchase)

if ( BankFrameMoneyFrameInset ) then 
	BankFrameMoneyFrameInset:Hide()
	BankFrameMoneyFrameBorder:Hide()
end 
if ( BankFrameCloseButton ) then 
	BankFrameCloseButton:Hide()
end 

BankPortraitTexture:Hide()

BankFrame:EnableMouse(false)
BankFrame:SetAlpha(0)
BankFrame.SetAlpha = blank_func
BankFrame.EnableMouse = blank_func
BankFrame:SetIgnoreFramePositionManager(true)

BankFrame:DisableDrawLayer("ARTWORK")
BankFrame:DisableDrawLayer("BACKGROUND")
BankFrame:DisableDrawLayer("BORDER")

ContainerFrame1MoneyFrame:ClearAllPoints()
ContainerFrame1MoneyFrame:Hide()
ContainerFrame1MoneyFrame:SetPoint("BOTTOMLEFT", bagsFrame, "BOTTOMLEFT", 6, 10)
ContainerFrame1MoneyFrame:SetFrameStrata(frameStrata)
ContainerFrame1MoneyFrame:SetFrameLevel(frameLevel+2)
ContainerFrame1MoneyFrame:SetScale(config.scale)
				
--[[
BankSlotsFrame:DisableDrawLayer("ARTWORK")
BankSlotsFrame:DisableDrawLayer("BACKGROUND")
BankSlotsFrame:DisableDrawLayer("BORDER")
]]

for i=1, 7 do
	if ( BankSlotsFrame["Bag"..i] ) then 
		BankSlotsFrame["Bag"..i]:SetParent(bankFrame)
		BankSlotsFrame["Bag"..i]:Show()
		BankSlotsFrame["Bag"..i]:ClearAllPoints()
		BankSlotsFrame["Bag"..i]:SetPoint("BOTTOMLEFT", bankFrame, "BOTTOMLEFT", 30+39*(i), 30)
	end 
end

if ( BankFrameTab1 ) then 
	BankFrameTab1:Disable()
	BankFrameTab1:Hide()
	BankFrameTab1.Show = blank_func
end 

if ( BankFrameTab2 ) then 
	BankFrameTab2:Disable()
	BankFrameTab2:Hide()
	BankFrameTab2.Show = blank_func
end 

BankFrameTitleText:Hide()
BankFrameTitleText.Show = blank_func

if ( BankItemSearchBox ) then 
	BankItemSearchBox:ClearAllPoints()
	BankItemSearchBox:SetPoint("TOPLEFT", bankFrame, "TOPLEFT", 200, -5)
	BankItemSearchBox:SetPoint("RIGHT", bankFrame, "RIGHT", -40, 0)

	BankItemSearchBox:SetParent(BankFrameItem1)
	BankItemSearchBox:SetFrameStrata('HIGH')
	BankItemSearchBox:SetFrameLevel(bankFrame:GetFrameLevel()+1)
	BankItemSearchBox.ClearAllPoints = blank_func
	BankItemSearchBox.SetPoint = blank_func
	BankItemSearchBox.SetParent = blank_func

	BankItemAutoSortButton:ClearAllPoints()
	BankItemAutoSortButton:SetPoint("TOPLEFT", BankItemSearchBox, "TOPRIGHT", 5, 0)
	BankItemAutoSortButton:SetParent(BankItemSearchBox)
	BankItemAutoSortButton:SetSize(18,18)
	BankItemAutoSortButton:GetNormalTexture():SetTexCoord(.13, 0.87, .13, 0.87)
	BankItemAutoSortButton:SetScript('OnClick', function()
		SortBankBags();
		SortReagentBankBags();
	end)

	E:CreateBackdrop(BankItemAutoSortButton, nil, {0,0,0,1}, {0,0,0,0.6})

	BankItemAutoSortButton.ClearAllPoints = blank_func
	BankItemAutoSortButton.SetPoint = blank_func
	BankItemAutoSortButton.SetParent = blank_func
end 

BankFramePurchaseButton:ClearAllPoints()
BankFramePurchaseButton:SetPoint("BOTTOMLEFT", bankFrame, "BOTTOMLEFT", 100, 0)
BankFramePurchaseButton:SetParent(bankFrame)

if ( ReagentBankFrameUnlockInfoPurchaseButton ) then 
	ReagentBankFrameUnlockInfoPurchaseButton:ClearAllPoints()
	ReagentBankFrameUnlockInfoPurchaseButton:SetPoint("BOTTOM", bankFrame, "BOTTOM", 200, 100)
	ReagentBankFrameUnlockInfoPurchaseButton:SetParent(bankFrame)

	ReagentBankFrame.DespositButton:ClearAllPoints()
	ReagentBankFrame.DespositButton:SetPoint("BOTTOM", bankFrame, "BOTTOM", 216, 50)
	ReagentBankFrame.DespositButton:SetParent(bankFrame)
end 
			
BankSlotsFrame:Show()

if ( ReagentBankFrame ) then 
ReagentBankFrame:Show()
ReagentBankFrame.Hide = ReagentBankFrame.Show
end 

local function BuildBagFrame()


end

local initupdate = true

function UpdateBankItems()
	

	local totalAmountSlots = 28

	for bag = 6, 12 do
		totalAmountSlots = totalAmountSlots + ( GetContainerNumSlots(bag) or 0 )
	end

	--if totalAmountSlots > 150 then
	--	slotSize = 28
	--	bankperrow = 14
	--elseif totalAmountSlots > 176 then
	--	slotSize = 28
	--	bankperrow = 13
	--else
		slotSize = 28
		bankperrow = 13
	--end
	
	local baseHeight = 30 + ceil(totalAmountSlots/bankperrow)*(E.db.containers.spacing+slotSize+3) + 150
	
	
	local numrows, lastrowbutton, numbuttons, lastbutton = 0, ContainerFrame1Item1, 1, ContainerFrame1Item1
	
	ContainerFrame2MoneyFrame:Show()
	ContainerFrame2MoneyFrame:ClearAllPoints()
	ContainerFrame2MoneyFrame:SetPoint("TOPLEFT", bankFrame, "TOPLEFT", 6, -10)
	ContainerFrame2MoneyFrame:SetFrameStrata(frameStrata)
	ContainerFrame2MoneyFrame:SetFrameLevel(frameLevel+4)
	ContainerFrame2MoneyFrame:SetParent(bankFrame)
		
	for bank = 1, 28 do
		local bankitems = _G["BankFrameItem"..bank]
		bankFrame:SetID(-1)
		bankitems:SetParent(bankFrame)
		bankitems:SetID(bank)
		bankitems:ClearAllPoints()
		bankitems:SetWidth(slotSize)
		bankitems:SetHeight(slotSize)
		bankitems:SetFrameStrata(frameStrata)
		bankitems:SetFrameLevel(frameLevel+8)
		bankitems:SetScale(E.db.containers.scale)
		bankitems.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		bankitems:SetToplevel(false)
		
		ItemBackdrop(bankitems, bank, "bank")

		bagsIcons['bank'][bankitems] = true
	
		BankFrameMoneyFrame:Hide()
		if bank==1 then
			bankitems:SetPoint("TOPLEFT", bankFrame, "TOPLEFT", 10, -30)
			lastrowbutton = bankitems
			lastbutton = bankitems
		elseif numbuttons==bankperrow then
			bankitems:SetPoint("TOPRIGHT", lastrowbutton, "TOPRIGHT", 0, -(E.db.containers.spacing+slotSize+3))
			bankitems:SetPoint("BOTTOMLEFT", lastrowbutton, "BOTTOMLEFT", 0, -(E.db.containers.spacing+slotSize+3))
			lastrowbutton = bankitems
			numrows = numrows + 1
			numbuttons = 1
		else
			bankitems:SetPoint("TOPRIGHT", lastbutton, "TOPRIGHT", (E.db.containers.spacing+slotSize+3), 0)
			bankitems:SetPoint("BOTTOMLEFT", lastbutton, "BOTTOMLEFT", (E.db.containers.spacing+slotSize+3), 0)
			numbuttons = numbuttons + 1
		end
		lastbutton = bankitems
	end
	
	bankFrame:SetHeight(max(baseHeight, (((E.db.containers.spacing+slotSize+3)*14)+150)))
	
	local numSlots,full = GetNumBankSlots();
	
	if full then
		BankFramePurchaseButton:Hide()
	else
		BankFramePurchaseButton:Show()
	end
	

	UpdateReagentFrame()
		
	return numrows, lastrowbutton, numbuttons, lastbutton
end

local initReagentFrame = true

function UpdateReagentFrame()
	local lastrowbutton, lastbutton
	
	if not ReagentBankFrame.slots_initialized then		
		ReagentBankFrame_OnShow(ReagentBankFrame)
	end
	
	if initReagentFrame then
		initReagentFrame = false
	--	C_Timer.After(0.2, UpdateReagentFrame)	
	end
	
--	print('T', 'UpdateReagentFrame', IsReagentBankUnlocked())
	
	for reagent = 1, 98 do
		local reagentitem = _G["ReagentBankFrameItem"..reagent]
	
		reagentitem:SetParent(bankFrame.reagent)
		reagentitem:SetID(reagent)
		reagentitem.BagID = -3
		
	--	E:RegisterCooldown(_G[reagentitem:GetName().."Cooldown"])
		
		if not reagentitem._ClearAllPoints then
			reagentitem._ClearAllPoints = reagentitem.ClearAllPoints
			reagentitem.ClearAllPoints = blank_func
		end
		
		reagentitem:_ClearAllPoints()
		
		if not reagentitem._SetPoint then
			reagentitem._SetPoint = reagentitem.SetPoint
			reagentitem.SetPoint = blank_func
		end
		
		reagentitem.IconBorder:SetTexture("")
		reagentitem.IconBorder.SetTexture = blank_func
			
		reagentitem:SetWidth(E.db.containers.reagentsize)
		reagentitem:SetHeight(E.db.containers.reagentsize)
		reagentitem:SetFrameStrata(frameStrata)
		reagentitem:SetFrameLevel(frameLevel+8)
		reagentitem:SetScale(E.db.containers.scale)
		reagentitem.icon:SetTexCoord(unpack(AleaUI.media.texCoord))
		_G[reagentitem:GetName().."NormalTexture"]:SetTexture("")
		
		ItemBackdrop(reagentitem, bank, "bank")
		
	--	_G[bankitems:GetName().."IconQuestTexture"]:SetTexture("")
		
		bagsIcons['reagent'][reagentitem] = true

		--ContainerFrame2MoneyFrame:SetScale(E.db.containers.scale)

		if ( not IsReagentBankUnlocked()) then
			reagentitem:Hide()			
			ReagentBankFrameUnlockInfoPurchaseButton:Show()
		else
			ReagentBankFrameUnlockInfoPurchaseButton:Hide()
			reagentitem:Show()
		end
		
		if reagent==1 then
			reagentitem:_SetPoint("TOPLEFT", bankFrame, "TOPLEFT", 450, -30)
			lastrowbutton = reagentitem
			lastbutton = reagentitem
			numbuttons = 1
		elseif numbuttons == E.db.containers.reagensperrow then
			reagentitem:_SetPoint("TOPRIGHT", lastrowbutton, "TOPRIGHT", 0, -(E.db.containers.spacing+E.db.containers.reagentsize+3))
			reagentitem:_SetPoint("BOTTOMLEFT", lastrowbutton, "BOTTOMLEFT", 0, -(E.db.containers.spacing+E.db.containers.reagentsize+3))
			lastrowbutton = reagentitem
			numbuttons = 1
		else
			reagentitem:_SetPoint("TOPRIGHT", lastbutton, "TOPRIGHT", (E.db.containers.spacing+E.db.containers.reagentsize+3), 0)
			reagentitem:_SetPoint("BOTTOMLEFT", lastbutton, "BOTTOMLEFT", (E.db.containers.spacing+E.db.containers.reagentsize+3), 0)
			numbuttons = numbuttons + 1
		end
		lastbutton = reagentitem		
	end
end

if ( BuyReagentBank ) then 
	hooksecurefunc('BuyReagentBank', UpdateReagentFrame)
end 

--[==[

	BankFrame:IsShown() then
		UpdateReagentFrame()
]==]

local bagsHolder1 = CreateFrame("Frame", nil, bagsFrame)
bagsHolder1:EnableMouse(true)
bagsHolder1:SetFrameStrata(frameStrata)
bagsHolder1:SetFrameLevel(frameLevel)
bagsHolder1:Hide()
E:CreateBackdrop(bagsHolder1, nil, {0,0,0,1}, {0.1,0.1,0.1,0.9})

local bagsHolder2 = CreateFrame("Frame", nil, bagsFrame)
bagsHolder2:EnableMouse(true)
bagsHolder2:SetFrameStrata(frameStrata)
bagsHolder2:SetFrameLevel(frameLevel)
bagsHolder2:Hide()
E:CreateBackdrop(bagsHolder2, nil, {0,0,0,1}, {0.1,0.1,0.1,0.9})

local bagsHolder3 = CreateFrame("Frame", nil, bagsFrame)
bagsHolder3:EnableMouse(true)
bagsHolder3:SetFrameStrata(frameStrata)
bagsHolder3:SetFrameLevel(frameLevel)
bagsHolder3:Hide()
E:CreateBackdrop(bagsHolder3, nil, {0,0,0,1}, {0.1,0.1,0.1,0.9})

local bagsHolder4 = CreateFrame("Frame", nil, bagsFrame)
bagsHolder4:EnableMouse(true)
bagsHolder4:SetFrameStrata(frameStrata)
bagsHolder4:SetFrameLevel(frameLevel)
bagsHolder4:Hide()
E:CreateBackdrop(bagsHolder4, nil, {0,0,0,1}, {0.1,0.1,0.1,0.9})


local function UpdateBagSlotPosition()
	if E.db.containers.separate then
		_G["ContainerFrame1PortraitButton"]:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 15, -8)
		
		CharacterBag0Slot:SetPoint("TOPLEFT", bagsHolder1, "TOPLEFT", 15, -8)
		CharacterBag1Slot:SetPoint("TOPLEFT", bagsHolder2, "TOPLEFT", 15, -8)
		CharacterBag2Slot:SetPoint("TOPLEFT", bagsHolder3, "TOPLEFT", 15, -8)
		CharacterBag3Slot:SetPoint("TOPLEFT", bagsHolder4, "TOPLEFT", 15, -8)
	else
		_G["ContainerFrame1PortraitButton"]:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 135 - ((portrit_size+5)*1), -8)
		CharacterBag0Slot:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 135 - ((20+5)*2+2), -8)
		CharacterBag1Slot:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 135 - ((20+5)*3+2), -8)
		CharacterBag2Slot:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 135 - ((20+5)*4+2), -8)
		CharacterBag3Slot:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 135 - ((20+5)*5+2), -8)
	end
end

function ContainerFrame_GenerateFrame(frame, size, id)
-- Centralize and rewrite bag rendering function

	--wipe(bagsIcons)

	frame.size = size;
	for i=1, size, 1 do
		local index = size - i + 1;
		local itemButton = _G[frame:GetName().."Item"..i];
		itemButton:SetID(index);
		itemButton:Show();
		itemButton:SetToplevel(false)
		itemButton:SetWidth(33)
		itemButton:SetHeight(33)
		itemButton:SetScale(E.db.containers.scale)
		itemButton:SetFrameStrata(frameStrata)
		itemButton:SetFrameLevel(frameLevel+4)
		itemButton.icon:SetTexCoord(AleaUI.media.texCoord[1],AleaUI.media.texCoord[2],AleaUI.media.texCoord[3],AleaUI.media.texCoord[4])		
	end
	frame:SetID(id);
	frame:Show()
	
--	UpdateBagSlotPosition()
	
	if ( id < 5 ) then
	
		bagsHolder1:Hide()
		bagsHolder2:Hide()
		bagsHolder3:Hide()
		bagsHolder4:Hide()
	
		local numrows, lastrowbutton, numbuttons, lastbutton = 0, ContainerFrame1Item1, 1, ContainerFrame1Item1
		local leftSideHeight
		
		local holder1, holder2, holder3, holder4
		
		for bag = 1, 5 do
			local slots = GetContainerNumSlots(bag-1)
			
			SetBagPortraitTexture(_G["ContainerFrame"..bag.."Portrait"], bag-1)
			_G["ContainerFrame"..bag.."PortraitButton"]:SetID(bag-1);
			
			for item = 1, slots, 1 do
				local itemframes = _G["ContainerFrame"..bag.."Item"..item]
				itemframes:ClearAllPoints()
				itemframes:SetParent(bagsFrame['bag'..bag-1])
				
				ItemBackdrop(itemframes, bag, item)

				bagsIcons['bags'][itemframes] = true
		
				local leftStep = -10
				
				if E.db.containers.separate then
					
					if bag == 1 then
						if item == 1 then
							itemframes:SetPoint("BOTTOMRIGHT", bagsFrame, "BOTTOMRIGHT", leftStep, 25)
							lastrowbutton = itemframes
							lastbutton = itemframes
							numrows = numrows + 1
							numbuttons = 1
						elseif numbuttons == 4 then
							itemframes:SetPoint("BOTTOMRIGHT", lastrowbutton, "TOPRIGHT", 0, 3)
							lastrowbutton = itemframes
							numrows = numrows + 1
							numbuttons = 1
						else
							itemframes:SetPoint("RIGHT", lastbutton, "LEFT", -3, 0)
							numbuttons = numbuttons + 1
						end
						lastbutton = itemframes
					
					elseif bag == 2 then

						if item == 1 then
							itemframes:SetPoint("BOTTOMRIGHT", bagsFrame, "BOTTOMRIGHT", leftStep, 85 + numrows*(39))
							lastrowbutton = itemframes
							lastbutton = itemframes
							numrows = numrows + 1
							numbuttons = 1
							
							bagsHolder1:SetPoint('BOTTOMRIGHT', itemframes, 'BOTTOMRIGHT', 10, -10)
							bagsHolder1:SetSize(5 + 4*39, 15 + ceil(GetContainerNumSlots(bag-1)/4)*39)
							bagsHolder1:Show()
						elseif numbuttons == 4 then
							itemframes:SetPoint("BOTTOMRIGHT", lastrowbutton, "TOPRIGHT", 0, 3)
							lastrowbutton = itemframes
							numrows = numrows + 1
							numbuttons = 1
						else
							itemframes:SetPoint("RIGHT", lastbutton, "LEFT", -3, 0)
							numbuttons = numbuttons + 1
						end
						lastbutton = itemframes
						
					elseif bag == 3 then
						
						if item == 1 then
							itemframes:SetPoint("BOTTOMRIGHT", bagsFrame, "BOTTOMRIGHT", leftStep -170, 10)
							lastrowbutton = itemframes
							leftSideHeight = 1
							lastbutton = itemframes
							numbuttons = 1
							
							bagsHolder2:SetPoint('BOTTOMRIGHT', itemframes, 'BOTTOMRIGHT', 10, -10)
							bagsHolder2:SetSize(5 + 4*39, 15 + ceil(GetContainerNumSlots(bag-1)/4)*39)
							bagsHolder2:Show()
						elseif numbuttons == 4 then
							itemframes:SetPoint("BOTTOMRIGHT", lastrowbutton, "TOPRIGHT", 0, 3)
							lastrowbutton = itemframes
							leftSideHeight = leftSideHeight + 1
							numrows = numrows + 1
							numbuttons = 1
						else
							itemframes:SetPoint("RIGHT", lastbutton, "LEFT", -3, 0)
							numbuttons = numbuttons + 1
						end
						lastbutton = itemframes
					elseif bag == 4 then
						
						if item == 1 then
							itemframes:SetPoint("BOTTOMRIGHT", bagsFrame, "BOTTOMRIGHT", leftStep -170, 30 + leftSideHeight*(39))
							lastrowbutton = itemframes
							lastbutton = itemframes
							numbuttons = 1
							
							bagsHolder3:SetPoint('BOTTOMRIGHT', itemframes, 'BOTTOMRIGHT', 10, -10)
							bagsHolder3:SetSize(5 + 4*39, 15 + ceil(GetContainerNumSlots(bag-1)/4)*39)
							bagsHolder3:Show()
						elseif numbuttons == 4 then
							itemframes:SetPoint("BOTTOMRIGHT", lastrowbutton, "TOPRIGHT", 0, 3)
							lastrowbutton = itemframes
							numbuttons = 1
						else
							itemframes:SetPoint("RIGHT", lastbutton, "LEFT", -3, 0)
							numbuttons = numbuttons + 1
						end
						lastbutton = itemframes
						
					elseif bag == 5 then
					
						if item == 1 then
							itemframes:SetPoint("BOTTOMRIGHT", bagsFrame, "BOTTOMRIGHT", leftStep - 170 -170, 10)
							lastrowbutton = itemframes
							lastbutton = itemframes
							numbuttons = 1
							
							bagsHolder4:SetPoint('BOTTOMRIGHT', itemframes, 'BOTTOMRIGHT', 10, -10)
							bagsHolder4:SetSize(5 + 4*39, 15 + ceil(GetContainerNumSlots(bag-1)/4)*39)
							bagsHolder4:Show()
						elseif numbuttons == 4 then
							itemframes:SetPoint("BOTTOMRIGHT", lastrowbutton, "TOPRIGHT", 0, 3)
							lastrowbutton = itemframes
							numbuttons = 1
						else
							itemframes:SetPoint("RIGHT", lastbutton, "LEFT", -3, 0)
							numbuttons = numbuttons + 1
						end
						lastbutton = itemframes
						
					end
				else
				
					if bag==1 and item==1 then
						itemframes:SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 10, -30)
						lastrowbutton = itemframes
						lastbutton = itemframes
					elseif numbuttons==E.db.containers.bpr then
						itemframes:SetPoint("TOPRIGHT", lastrowbutton, "TOPRIGHT", 0, -(E.db.containers.spacing+36))
						itemframes:SetPoint("BOTTOMLEFT", lastrowbutton, "BOTTOMLEFT", 0, -(E.db.containers.spacing+36))
						lastrowbutton = itemframes
						numrows = numrows + 1
						numbuttons = 1
					else
						itemframes:SetPoint("TOPRIGHT", lastbutton, "TOPRIGHT", (E.db.containers.spacing+36), 0)
						itemframes:SetPoint("BOTTOMLEFT", lastbutton, "BOTTOMLEFT", (E.db.containers.spacing+36), 0)
						numbuttons = numbuttons + 1
					end
					lastbutton = itemframes
				end
			end
		end

		local header_1 = 20
		
		if E.db.containers.separate then
			bagsFrame:SetHeight(header_1 + 20 + 30 + 4*(39))
			bagsFrame:SetWidth(5 + 4*39)
			
			if ( BagItemSearchBox ) then
			BagItemSearchBox:_SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 15, -30)
			BagItemSearchBox:_SetPoint("TOPRIGHT", bagsFrame, "TOPRIGHT", -30, -30)
			end
		else
			bagsFrame:SetHeight(((E.db.containers.spacing+36)*(numrows+1)+40+header_1)-E.db.containers.spacing)			
			bagsFrame:SetWidth(E.db.containers.bpr*39)
			
			if ( BagItemSearchBox ) then
			BagItemSearchBox:_SetPoint("TOPLEFT", bagsFrame, "TOPLEFT", 170, -5)
			BagItemSearchBox:_SetPoint("TOPRIGHT", bagsFrame, "TOPRIGHT", -30, -5)
			end
		end
	else
		local numrows, lastrowbutton, numbuttons, lastbutton = UpdateBankItems()
		
		for bag = 6, 12 do
			local slots = GetContainerNumSlots(bag-1)
			for item = slots, 1, -1 do
				local itemframes = _G["ContainerFrame"..bag.."Item"..item]
				itemframes:ClearAllPoints()
				itemframes:SetWidth(slotSize)
				itemframes:SetHeight(slotSize)
				itemframes:SetParent(bankFrame['bag'..(bag-1)])
				
				itemframes:SetScale(E.db.containers.scale)
				itemframes:SetFrameStrata(frameStrata)
				itemframes:SetFrameLevel(frameLevel+8)
		
				ItemBackdrop(itemframes, bag, item)
				
				bagsIcons['bank'][itemframes] = true
				
				if numbuttons==bankperrow then
					itemframes:SetPoint("TOPRIGHT", lastrowbutton, "TOPRIGHT", 0, -(E.db.containers.spacing+slotSize+3))
					itemframes:SetPoint("BOTTOMLEFT", lastrowbutton, "BOTTOMLEFT", 0, -(E.db.containers.spacing+slotSize+3))
					lastrowbutton = itemframes
					numrows = numrows + 1
					numbuttons = 1
				else
					itemframes:SetPoint("TOPRIGHT", lastbutton, "TOPRIGHT", (E.db.containers.spacing+slotSize+3), 0)
					itemframes:SetPoint("BOTTOMLEFT", lastbutton, "BOTTOMLEFT", (E.db.containers.spacing+slotSize+3), 0)
					numbuttons = numbuttons + 1
				end
				lastbutton = itemframes
			end
		end
	end
	
--	print(id, initReagentFrame, BankFrame:IsShown())
	
	if ( id == 0 or initReagentFrame ) and BankFrame:IsShown() then
		UpdateReagentFrame()
	end
end

function OpenBag(id, fromb)
    if ( not CanOpenPanels() ) then
        if ( UnitIsDead("player") ) then
            NotWhileDeadError();
        end
        return;
    end
	
	if (fromb) then
		local size = GetContainerNumSlots(id);
		if ( size > 0 ) then
			local containerShowing;
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				local frame = _G["ContainerFrame"..i];
				if ( frame:IsShown() and frame:GetID() == id ) then
					containerShowing = i;
				end
			end
			if ( not containerShowing ) then
				ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
			end
		end
	else
		ToggleAllBags()
	end
end

-- Centralize and rewrite bag opening functions
function UpdateContainerFrameAnchors() end
function ToggleBag() ToggleAllBags() end
function ToggleBackpack() ToggleAllBags() end

function OpenAllBags() 
	
--	print("OpenAllBags")
	togglemain = 0
	
	ToggleAllBags() 
	
end
function OpenBackpack()  ToggleAllBags() end

function ManageBackpackTokenFrame() end

local old_ContainerFrameItemButton_SetForceExtended = ContainerFrameItemButton_SetForceExtended

function ContainerFrameItemButton_SetForceExtended(itemButton, extended)
	
end

function CloseBackpack() 
	
--	print("CloseBackpack")
	
	ToggleAllBags() 
end

function CloseAllBags() 

--	print("CloseAllBags")
	
	togglemain = 1
	ToggleAllBags() 
end

function ToggleAllBags()

	if (togglemain == 1) or ( IsOptionFrameOpen() ) or ( ChatConfigFrame:IsShown() ) then
		if(not BankFrame:IsShown()) then 
			togglemain = 0
			CloseBag(0,1)
			bagsFrame:Hide()
			for i=1, NUM_BAG_FRAMES, 1 do CloseBag(i) end
		end
	else
		togglemain = 1
		bagsFrame:Show()
		OpenBag(0,1)
		for i=1, NUM_BAG_FRAMES, 1 do OpenBag(i,1) end
	end

	if( BankFrame:IsShown() ) then
		if (togglebank == 1) or ( IsOptionFrameOpen() ) or ( ChatConfigFrame:IsShown() ) then
			togglebank = 0
			bankFrame:Hide()
			HideUIPanel(BankFrame) -- BankFrame:Hide()
			
		--	CloseBag(-1,1)
			
			for i=NUM_BAG_FRAMES+1, NUM_CONTAINER_FRAMES, 1 do
				if ( IsBagOpen(i) ) then CloseBag(i) end
			end
		else
			togglebank = 1
			bankFrame:Show()
			ShowUIPanel(BankFrame) --:Show()
			
		--	OpenBag(-1,1)
			
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				if (not IsBagOpen(i)) then OpenBag(i,1) end
			end
		end
	end
end

ContainerFrame1:SetIgnoreFramePositionManager(true)
ContainerFrame1:HookScript("OnHide", function()
	bagsFrame:Hide()
	togglemain = 1
	ToggleAllBags()
end)

GameMenuFrame:HookScript("OnShow", function()
	togglemain = 1
	ToggleAllBags()
end)

BankFrame:HookScript("OnHide", function() 
	bankFrame:Hide()
	togglebank = 0
end)

BankFrame:HookScript("OnShow", function() 
	bankFrame:Show()
	UpdateBankItems()
end)

E:OnInit(function() 
	E:Mover(bagsFrame, "bagsFrameHeader",100, 50, "BOTTOMRIGHT")	
end)

do	

	local hidegametooltip = CreateFrame("Frame")
	hidegametooltip:Hide()
	local gametooltip = CreateFrame("GameTooltip", "AleaUI_ContainerMog_GameToolTip", hidegametooltip, 'GameToolTipTemplate')
	gametooltip:SetScript('OnTooltipAddMoney', function()end)
	gametooltip:SetScript('OnTooltipCleared', function()end)
	gametooltip:SetScript('OnHide', function()end)
	gametooltip:SetScript('OnTooltipSetDefaultAnchor',function()end)
	gametooltip:SetOwner(hidegametooltip,"ANCHOR_NONE")
	
	local match = string.match

	local function CheckForContainTooltip(link, str)
	
		if not link then return false end
		
		gametooltip:ClearLines()
		gametooltip:SetHyperlink(link)	

		for i = 1, gametooltip:NumLines() do		
			local left = _G[gametooltip:GetName().."TextLeft"..i]:GetText()
			local right = _G[gametooltip:GetName().."TextRight"..i]:GetText()
			
			if left then
				local result = match(left, str)
				if result then
					return result, left
				end
			end
			
			if right then
				local result = match(right, str)
				if result then
					return result, right
				end
			end
		end		
		return false
	end
	
	local IconText = {}
	local byte, format = string.byte, string.format
	local tinsert, twipe = table.insert, table.wipe

	local infoArray = {}
	local equipmentMap = {}
	
	local function Utf8Sub(str, start, numChars)
	  local currentIndex = start
	  while numChars > 0 and currentIndex <= #str do
		local char = byte(str, currentIndex)
		if char > 240 then
		  currentIndex = currentIndex + 4
		elseif char > 225 then
		  currentIndex = currentIndex + 3
		elseif char > 192 then
		  currentIndex = currentIndex + 2
		else
		  currentIndex = currentIndex + 1
		end
		numChars = numChars -1
	  end
	  return str:sub(start, currentIndex - 1)
	end

	local quickFormat = {
		[0] = function(font, map) font:SetText() end,
		[1] = function(font, map) font:SetFormattedText("|cffffffaa%s|r", Utf8Sub(map[1], 1, 4)) end,
		[2] = function(font, map) font:SetFormattedText("|cffffffaa%s %s|r", Utf8Sub(map[1], 1, 4), Utf8Sub(map[2], 1, 4)) end,
		[3] = function(font, map) font:SetFormattedText("|cffffffaa%s %s %s|r", Utf8Sub(map[1], 1, 4), Utf8Sub(map[2], 1, 4), Utf8Sub(map[3], 1, 4)) end,
	}

	
	local queueframe = CreateFrame("Frame")
	queueframe:Hide()
	queueframe.elapsed = 0
	queueframe:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < 0.25 then return end
		self:Hide()
		
		IconText.UpdateItemsSets()
	end)

	IconText.QueueUpdate = function(self)
	
		if ( E.isClassic ) then return end
		if queueframe:IsShown() then return end
		
	--	print("QUEUE")
		queueframe.elapsed = 0
		queueframe:Show()
	end
	
	local function QueueItemInfoText1(obj, itemLink, itemID)
		if E.db.containers.showTransmog and 
			( classID == 4 or classID == 2 ) and
			( subclassID == 2 or subclassID == 1 or subclassID == 3 or subclassID == 4 ) and 
			CheckForContainTooltip(itemLink, L['TRANSMOG_MODEL_PATTERN']) then
			
			obj.infoText1:SetText('|cFFfb89e8MOG|r')
		elseif 	E.db.containers.showEquipSet then --and
		--	( classID == 4 or classID == 2 ) and 
		--	( subclassID == 2 or subclassID == 1 or subclassID == 3 or subclassID == 4 or subclassID == 0 ) then
			
			IconText.GetItemSet(obj.infoText1, (obj.BagID or obj:GetParent():GetID()), obj:GetID())
		else
			obj.infoText1:SetText('')
		end
	end
	
	local function QueueItemInfoText2(obj, itemLink, itemID, itemRarity, bindType)
		if itemRarity == 2 and bindType == 2 and E.db.containers.showBoE and CheckForContainTooltip(itemLink, ITEM_BIND_ON_EQUIP) then
					
			obj.infoText2:SetText('BoE')
			local r, g, b = GetItemQualityColor(itemRarity);
		 
			obj.infoText2:SetTextColor(r or 1, g or 1, b or 1)
		elseif E.db.containers.showItemLevel then
			local itemLevel = GetDetailedItemLevelInfo(itemLink)

			obj.infoText2:SetText((itemLevel and itemLevel > 1 ) and itemLevel or '')
			local r, g, b = GetItemQualityColor(itemRarity);
		 
			obj.infoText2:SetTextColor(r or 1, g or 1, b or 1)
		else
			obj.infoText2:SetText('')
		end
	end
	
	local function prepareFrame(frame)
		if ( not frame.infoText1 ) then
			frame.infoText1 = frame:CreateFontString(nil, "OVERLAY")
			frame.infoText1:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
			frame.infoText1:SetWordWrap(true)
			frame.infoText1:SetJustifyH('LEFT')
			frame.infoText1:SetJustifyV('BOTTOM')
			
			frame.infoText1:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 2, 0)	
			frame.infoText1:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 2, -1)	
		end
		
		if ( not frame.infoText2 ) then
			frame.infoText2 = frame:CreateFontString(nil, "OVERLAY")
			frame.infoText2:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
			frame.infoText2:SetWordWrap(true)
			frame.infoText2:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 2, 0)	
			frame.infoText2:SetJustifyH('RIGHT')
			frame.infoText2:SetJustifyV('MIDDLE')
		end

		local ItemLink = GetContainerItemLink((frame.BagID or frame:GetParent():GetID()), frame:GetID())
		if ItemLink then
			local itemID = ItemLink and GetItemInfoFromHyperlink(ItemLink) or 0
			
			local _, _, itemRarity, itemLevel, itemMinLevel, _, _, _, _, _, _, classID, subclassID, bindType, expansion, itemSetID, isCraftReagent = GetItemInfo(ItemLink)

		--	frame.infoText1:SetText('')
		--	frame.infoText2:SetText('')
			
			if classID == 4 or classID == 2 or classID == 3 then
				-- 2 green
				-- bindType 2 boe 1 bop
				
				if itemRarity == 2 and bindType == 2 and E.db.containers.showBoE then
					E.QueueForRun(frame:GetName()..'-HandleText2', QueueItemInfoText2, frame, ItemLink, itemID, itemRarity, bindType)	
				elseif E.db.containers.showItemLevel then					
					E.QueueForRun(frame:GetName()..'-HandleText2', QueueItemInfoText2, frame, ItemLink, itemID, itemRarity, bindType)	
				else
					frame.infoText2:SetText('')
				end
			else
			--	frame.infoText2:SetText(classID)
				frame.infoText2:SetText('')
			end
			
		--	frame.infoText2:SetText(classID..'+'..subclassID)
			
			if IsArtifactPowerItem(itemID) and E:IsLockApItem() then
				frame:RegisterForClicks("LeftButtonUp")
			else
				frame:RegisterForClicks("LeftButtonUp", 'RightButtonUp')
			end
			
			if E.db.containers.showApItem and IsArtifactPowerItem(itemID) then
				frame.infoText1:SetText('|cFFFFEF99AP|r')
			elseif E.db.containers.showTransmog and 
				( classID == 4 or classID == 2 ) and
				( subclassID == 2 or subclassID == 1 or subclassID == 3 or subclassID == 4 ) then 
				
					E.QueueForRun(frame:GetName()..'-HandleText1', QueueItemInfoText1, frame, ItemLink, itemID)	
			elseif E.db.containers.showEquipSet then
			--and
			--	( classID == 4 or classID == 2 ) and 
			--	( subclassID == 2 or subclassID == 1 or subclassID == 3 or subclassID == 4 or subclassID == 0 ) then
				
				IconText.GetItemSet(frame.infoText1, (frame.BagID or frame:GetParent():GetID()), frame:GetID())
			else
				frame.infoText1:SetText('')
			end
		else
			frame.infoText1:SetText('')
			frame.infoText2:SetText('')
		end
	end
	
	IconText.UpdateItemsSets = function()
		
		for k, v in pairs(equipmentMap) do
			twipe(v)
		end
	
		local name, player, bank, bags, slot, bag, key, arg1
		for i = 1, C_EquipmentSet.GetNumEquipmentSets() do
			name = C_EquipmentSet.GetEquipmentSetInfo(i-1)
			if name then
				local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(name)
				
				
				for _, location in pairs(C_EquipmentSet.GetItemLocations(equipmentSetID)) do

					if type(location) == "number" and ( location < -1 or location > 1 ) then
						player, bank, bags, arg1, slot, bag = EquipmentManager_UnpackLocation(location)
						if (bags and slot and bag) then
							key = format("%d_%d", bag, slot)
							equipmentMap[key] = equipmentMap[key] or {}
							tinsert(equipmentMap[key], name)
						elseif bank and slot then
							key = format("%d_%d", -1, slot-39)
							equipmentMap[key] = equipmentMap[key] or {}
							tinsert(equipmentMap[key], name)
						end
					end
				end
			end
		end
		
		if bagsFrame:IsShown() then
			for frame in pairs(bagsIcons['bags']) do			
				prepareFrame(frame)
			end
		end
		if bankFrame:IsShown() then
			for frame in pairs(bagsIcons['bank']) do			
				prepareFrame(frame)
			end
		end
	end
	
	IconText.GetItemSet = function(frame, bag, slot)
		local key = format("%d_%d", bag, slot)
		
	--	print(key)
		if equipmentMap[key] then
			quickFormat[#equipmentMap[key] < 4 and #equipmentMap[key] or 3](frame, equipmentMap[key])
		else
			quickFormat[0](frame, nil)
		end
	end
	
	bagsFrame:HookScript('OnShow', IconText.QueueUpdate)
	bankFrame:HookScript('OnShow', IconText.QueueUpdate)
	
	IconText.eventframe = CreateFrame("Frame")	

	if ( not E.isClassic ) then
		IconText.eventframe:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		IconText.eventframe:RegisterEvent("BAG_UPDATE")
		IconText.eventframe:RegisterEvent("BANKFRAME_OPENED")
		IconText.eventframe:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		IconText.eventframe:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		IconText.eventframe:SetScript("OnEvent", IconText.QueueUpdate)
	end 
end

do
	--[==[		
		0. Poor (gray): Broken I.W.I.N. Button
		1. Common (white): Archmage Vargoth's Staff
		2. Uncommon (green): X-52 Rocket Helmet
		3. Rare / Superior (blue): Onyxia Scale Cloak
		4. Epic (purple): Talisman of Ephemeral Power
		5. Legendary (orange): Fragment of Val'anyr
		6. Artifact (golden yellow): The Twin Blades of Azzinoth
		7. Heirloom (light yellow): Bloodied Arcanite Reaper	
	]==]
	
	local checkForILevel = {
		[1] = false,
		[2] = true,
		[3] = true,
	}
	
	local frame = CreateFrame("FRAME");
	frame:RegisterEvent("MERCHANT_SHOW");
	frame:RegisterEvent("MERCHANT_CLOSED");

	local function requiresPlural(item)
		if item > 1 then return true else return false end
	end
	
	local ItemsToSell = {}
	
	local trottle = CreateFrame("Frame")
	trottle:Hide()
	trottle:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = ( self.elapsed or 0 ) + elapsed
		if self.elapsed < 0.2 then return end

		for i=1, 10 do			
			local slot = table.remove(ItemsToSell, 1)			
			if not slot then 
				self:Hide()
				return 
			end
			UseContainerItem(slot[1], slot[2]) -- This will sell the item.
		end
		
		self.elapsed = -1
	end)
	
	local function SellItems(index, number)
				
		table.insert(ItemsToSell, { index, number })
		
		trottle.elapsed = 0
		trottle:Show()
	end
	
	local sellByItemID = {
	--	['114745'] = true,
	--	['114822'] = true,
	--	['114128'] = true,
	--	['114129'] = true,
	--	['114131'] = true,
	--	['114808'] = true,
	--	['113478'] = true,
	}
	local sellItemsFromList = false
	
	local function eventHandler(sellgreen)	
		local b = {}
		
		wipe(ItemsToSell)
		
		for i = 0, NUM_BAG_SLOTS do
			b[i] = GetContainerNumSlots(i)	
		end
		
		for i = 0, #b do
			for n = 1, b[i] do
				local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(i, n);

				if itemLink then
					-- Need to get the info like this because the quality return is broken with the container item info call (-1):
					local name, link, rquality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemLink)
					
					local itemID = GetItemInfoInstant(itemLink) -- string.match(link, "|Hitem:(%-?%d+):(%d+):(%d+).*")
					
					-- Find the grey items:
					
					if sellgreen then
						if rquality == 2 and reqLevel > 1 and iLevel > 1 and vendorPrice > 0 then 				
							SellItems(i, n)
						elseif rquality == 3 and reqLevel > 1 and reqLevel < 100 and iLevel > 1 and vendorPrice > 0 then 
						--	print('T', name, reqLevel, iLevel, vendorPrice)
							SellItems(i, n)
						elseif sellItemsFromList and sellByItemID[itemID] then
							SellItems(i, n)
						end
						
					elseif rquality == 0 and vendorPrice > 0 then
						SellItems(i, n)
					end
				end
			end
		end
	end
	
	local button = CreateFrame("Button", nil, bagsFrame)
	button:SetSize(58, 18)
	button:SetPoint('TOP', bagsFrame, 'TOP', 10, -5)
	button:Hide()
	
	button.bg = button:CreateTexture()
	button.bg:SetAllPoints()
	button.bg:SetColorTexture(0.3, 0.3, 1,1)
	
	button.text = button:CreateFontString()
	button.text:SetPoint('CENTER')
	button.text:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
	button.text:SetText('Sell')
	
	button:SetScript("OnClick", function()	
		eventHandler(true)
	end)
	
	frame:SetScript("OnEvent", function(self, event)
		if event == 'MERCHANT_SHOW' then
			eventHandler()
			button:Hide()
			
			if E.db.containers.separate then
				button:SetSize(18, 18)
				button:SetPoint('TOP', bagsFrame, 'TOP', 65, -5)
			else
				button:SetSize(58, 18)
				button:SetPoint('TOP', bagsFrame, 'TOP', 10, -5)
			end
		else
			button:Hide()
		end
	end)	
end

function E:IsLockApItem()
	local index = GetSpecialization()
	local id = GetSpecializationInfo(index)
	
	if E.db.containers.apSpecLocker then	
		return not E.db.containers.apSpecSettings[id]
	end
	
	return false
end

local function LoadModule()

	E.GUI.args.Containers = {
		name = L['Bags'],
		type = "group",
		order = 5,
		args = {},
	}
	
	E.GUI.args.Containers.args.separate = {
		name = L['Separate'],
		order = 1,
		type = "toggle",
		set = function(self, value)
			E.db.containers.separate = not E.db.containers.separate
		end,
		get = function(self)
			return E.db.containers.separate
		end,
	}
	
	E.GUI.args.Containers.args.unlock = {
		name = L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover('bagsFrameHeader') 
		end,
		get = function(self)
		end,
	}
	
	E.GUI.args.Containers.args.ItemInfo = {
		name = L['Item info'],
		order = 2,
		type = 'group',
		embend = true,
		args = {},
	}
	E.GUI.args.Containers.args.ItemInfo.args.showTransmog = {
		name = L['Show transmog info'],
		order = 1,
		type = "toggle",
		set = function(self, value)
			E.db.containers.showTransmog = not E.db.containers.showTransmog
		end,
		get = function(self)
			return E.db.containers.showTransmog
		end,
	}
	E.GUI.args.Containers.args.ItemInfo.args.showApItem = {
		name = L['Show artifact item'],
		order = 2,
		type = "toggle",
		set = function(self, value)
			E.db.containers.showApItem = not E.db.containers.showApItem
		end,
		get = function(self)
			return E.db.containers.showApItem
		end,
	}
	E.GUI.args.Containers.args.ItemInfo.args.showEquipSet = {
		name = L['Show equip set'],
		order = 3,
		type = "toggle",
		set = function(self, value)
			E.db.containers.showEquipSet = not E.db.containers.showEquipSet
		end,
		get = function(self)
			return E.db.containers.showEquipSet
		end,
	}
	E.GUI.args.Containers.args.ItemInfo.args.showItemLevel = {
		name = L['Show item level'],
		order = 4,
		type = "toggle",
		set = function(self, value)
			E.db.containers.showItemLevel = not E.db.containers.showItemLevel
		end,
		get = function(self)
			return E.db.containers.showItemLevel
		end,
	}
	E.GUI.args.Containers.args.ItemInfo.args.showBoE = {
		name = L['Show BoE item'],
		order = 5,
		type = "toggle",
		set = function(self, value)
			E.db.containers.showBoE = not E.db.containers.showBoE
		end,
		get = function(self)
			return E.db.containers.showBoE
		end,
	}
	
	E.GUI.args.Containers.args.ApLockerSpec = {
		name = L['Specialization'],
		order = 3,
		type = 'group',
		embend = true,
		args = {},
	}
	
	E.GUI.args.Containers.args.ApLockerSpec.args.ApLocker = {
		name = L['Disable artifact power item usable'],
		order = 1,
		type = "toggle",
		width = 'full',
		set = function(self, value)
			E.db.containers.apSpecLocker = not E.db.containers.apSpecLocker
		end,
		get = function(self)
			return E.db.containers.apSpecLocker
		end,
	}
	
	if ( not E.isClassic ) then 
		if GetNumSpecializations() == 0 then
			local handler = CreateFrame('Frame')
			handler:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
			handler:RegisterEvent("PLAYER_LOGIN")
			handler:SetScript('OnEvent', function(self, event, unit)
				unit = unit or 'player'
				if unit ~= 'player' then return end
				
				if GetNumSpecializations() == 0 then return end
				for i=1, GetNumSpecializations() do
					local id, name, description, icon, background, role = GetSpecializationInfo(i)
					local tName = name and "|T"..icon ..":0:0:0:0|t"..name or L['Not selected']
					
					if E.db.containers.apSpecSettings[id] == nil then
						E.db.containers.apSpecSettings[id] = true
					end
					
					E.GUI.args.Containers.args.ApLockerSpec.args['spec'..i..'choose'] = {
						name = tName,
						order = 1.9,
						type = "toggle",
						set = function(self, value)
							E.db.containers.apSpecSettings[id] = not E.db.containers.apSpecSettings[id]
						end,
						get = function(self) 
							return E.db.containers.apSpecSettings[id]
						end,
					}
				end
				
				handler:UnregisterAllEvents()
			end)
		else
			for i=1, GetNumSpecializations() do
				local id, name, description, icon, background, role = GetSpecializationInfo(i)
				local tName = name and "|T"..icon ..":0:0:0:0|t"..name or L['Not selected']
				
				if E.db.containers.apSpecSettings[id] == nil then
					E.db.containers.apSpecSettings[id] = true
				end
					
				E.GUI.args.Containers.args.ApLockerSpec.args['spec'..i..'choose'] = {
					name = tName,
					order = 1.9,
					type = "toggle",
					set = function(self, value)
						E.db.containers.apSpecSettings[id] = not E.db.containers.apSpecSettings[id]
					end,
					get = function(self) 
						return E.db.containers.apSpecSettings[id]
					end,
				}
			end
		end
	end
end

E:OnInit2(LoadModule)