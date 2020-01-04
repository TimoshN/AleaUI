local E = AleaUI
local LR = E:Module("LootRoll")

if ( E.isClassic ) then 
	return 
end 

local pos = 'BOTTOM';
local cancelled_rolls = {}
local FRAME_WIDTH, FRAME_HEIGHT = 328, 28
LR.RollBars = {}

local tinsert = table.insert

local mover = CreateFrame("Frame", nil, AleaUI.UIParent)
mover:SetPoint("CENTER", AleaUI.UIParent, "CENTER", 0,0)
mover:SetSize(FRAME_WIDTH+FRAME_HEIGHT, FRAME_HEIGHT)

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local function HideTip() GameTooltip:Hide() end
local function HideTip2() GameTooltip:Hide(); ResetCursor() end

local rolltypes = {[1] = "need", [2] = "greed", [3] = "disenchant", [0] = "pass"}
local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	if frame:IsEnabled() == 0 then GameTooltip:AddLine("|cffff3333"..L["Can't Roll"]) end
	for name,roll in pairs(frame.parent.rolls) do if rolltypes[roll] == rolltypes[frame.rolltype] then GameTooltip:AddLine(name, 1, 1, 1) end end
	GameTooltip:Show()
end

local function OnEvent(frame, event, rollID)
	cancelled_rolls[rollID] = true
	if frame.rollID ~= rollID then return end

	frame.rollID = nil
	frame.time = nil
	frame:Hide()
end

local function SetItemTip(frame)
	if not frame.link then return end
	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end


local function ItemOnUpdate(self)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorOnUpdate(self)
end


local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end

local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:SetPoint(...)
	f:SetSize(FRAME_HEIGHT - 4, FRAME_HEIGHT - 4)
	f:SetNormalTexture(ntex)
	if ptex then f:SetPushedTexture(ptex) end
	f:SetHighlightTexture(htex)
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)
	local txt = f:CreateFontString(nil, nil)
	txt:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	txt:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)
	return f, txt
end

--[[
	local parent = BonusRollFrame:IsShown() and BonusRollFrame or next(LR.RollBars) and LR.RollBars[#LR.RollBars] or mover

	if pos == "TOP" then
		f:SetPoint("TOP", parent, "BOTTOM", ( parent == mover and FRAME_HEIGHT/2 or 0 ), -4)
	else
		f:SetPoint("BOTTOM", parent, "TOP", ( parent == mover and FRAME_HEIGHT/2 or 0 ), 4)
	end
]]


local function UpdateLootAnchors()

	local last = mover
	local height = FRAME_HEIGHT/2
	
	if BonusRollFrame:IsShown() then
		last = BonusRollFrame
		height = 0
	end
	
	for i=1, #LR.RollBars do
		local f = LR.RollBars[i]
		
		f:ClearAllPoints()
			
		if pos == "TOP" then
			f:SetPoint("TOP", last, "BOTTOM", height, -4)
		else
			f:SetPoint("BOTTOM", last, "TOP", height, 4)
		end
		height = 0
		last = f
	end

end

function LR:CreateRollFrame()
	local frame = CreateFrame("Frame", nil, AleaUI.UIParent)
	frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	frame:SetFrameStrata('HIGH')
	frame:SetScript("OnEvent", OnEvent)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")
	frame:Hide()
	frame:SetScript('OnShow', UpdateLootAnchors)
	frame:SetScript('OnHide', UpdateLootAnchors)
	
	E:CreateBackdrop(frame, nil, {0,0,0,1}, {0,0,0,0}, true)
	
	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("RIGHT", frame, 'LEFT', -4, 0)
	button:SetSize(FRAME_HEIGHT, FRAME_HEIGHT)

	E:CreateBackdrop(button, nil, {0,0,0,1}, {0,0,0,0}, true)
	
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)
	
	frame.button = button
	
	button.icon = button:CreateTexture(nil, 'OVERLAY')
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(AleaUI.media.texCoord))
	
	local tfade = frame:CreateTexture(nil, "BORDER")
	tfade:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 0)
	tfade:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
	tfade:SetTexture([[Interface\Buttons\WHITE8x8]])
	tfade:SetBlendMode("ADD")
	tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .1, .1, .1, 0)

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetPoint('TOPLEFT', button, 'TOPRIGHT', 4, 0)
	status:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, 0)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	status:SetStatusBarTexture("Interface\\AddOns\\AleaUI\\media\\Minimalist.tga")
	status:SetStatusBarColor(.8, .8, .8, .9)
	status.parent = frame
	frame.status = status
	
--	E:CreateBackdrop(status, nil, {0,0,0,1}, {0,0,0,0.3}, true)
	
	status.bg = status:CreateTexture(nil, 'BACKGROUND')
	status.bg:SetAlpha(0.1)
	status.bg:SetAllPoints()
	status.bg:SetDrawLayer('BACKGROUND', 2)
	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:SetSize(14, FRAME_HEIGHT)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	
	
	local de, detext
	de, detext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", 0, -1)
	
	
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 2)
	frame.needbutt, frame.greedbutt, frame.disenchantbutt = need, greed, de
	frame.need, frame.greed, frame.pass, frame.disenchant = needtext, greedtext, passtext, detext

	local bind = frame:CreateFontString()
	bind:SetPoint("LEFT", pass, "RIGHT", 3, 1)
	bind:SetFont(AleaUI.media.default_font, 12, "OUTLINE")
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:SetFont(AleaUI.media.default_font, 12, "OUTLINE")
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	loot:SetSize(200, 10)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	frame.rolls = {}

	return frame
end

-------------------------
-- Blizzard Bonus Roll --
-------------------------
if ( BonusRollFrame ) then
	local brf_pos1, brf_pos2, brf_x, brf_y = "BOTTOM", "TOP", FRAME_HEIGHT/2, 4 -- FRAME_HEIGHT
	if pos == 'TOP' then
		brf_pos1, brf_pos2, brf_x, brf_y = "TOP", "BOTTOM", FRAME_HEIGHT/2,-4 -- FRAME_HEIGHT
	end

	hooksecurefunc(BonusRollFrame, 'SetPoint', function(self, pos1, parent, pos2, x, y)
	--	print("T", 'BonusRollFrame', 'SetPoint', pos1, parent, pos2, x, y)
		if pos1 ~= brf_pos1 or parent ~= mover or pos2 ~= brf_pos2 or x ~= brf_x or y ~= brf_y then
		--	print('T', 'BonusRollFrame', 'Reposition')
			BonusRollFrame:ClearAllPoints()
			BonusRollFrame:SetPoint(brf_pos1, mover, brf_pos2, brf_x, brf_y)
		end
	end)

	BonusRollFrame:ClearAllPoints()
	BonusRollFrame:SetPoint(brf_pos1, mover, brf_pos2, brf_x, brf_y)
	BonusRollFrame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)

	BonusRollFrame.Background:SetAlpha(0)

	BonusRollFrame.RollingFrame.myText = BonusRollFrame.RollingFrame:CreateFontString(nil, 'OVERLAY', nil, 4)
	BonusRollFrame.RollingFrame.myText:SetPoint("LEFT", BonusRollFrame.PromptFrame.PassButton, 'RIGHT')
	BonusRollFrame.RollingFrame.myText:SetFont(AleaUI.media.default_font, 12, "OUTLINE")
	BonusRollFrame.RollingFrame.myText:SetText(E.L['Rolling'])
	BonusRollFrame.RollingFrame.myText:SetTextColor(1, 1, 1, 1)

	BonusRollFrame.RollingFrame.Label.Show = BonusRollFrame.RollingFrame.Label.Hide
	BonusRollFrame.RollingFrame.Label:Hide()

	BonusRollFrame.RollingFrame.DieIcon.Show = BonusRollFrame.RollingFrame.DieIcon.Hide
	BonusRollFrame.RollingFrame.DieIcon:Hide()


	BonusRollFrame.PromptFrame.Icon:ClearAllPoints()
	BonusRollFrame.PromptFrame.Icon:SetPoint('RIGHT', BonusRollFrame, 'LEFT', -4, 0)
	BonusRollFrame.PromptFrame.Icon:SetSize(FRAME_HEIGHT, FRAME_HEIGHT)

	BonusRollFrame.RollingFrame.LootSpinnerFinalText.Show = BonusRollFrame.RollingFrame.LootSpinnerFinalText.Hide
	BonusRollFrame.RollingFrame.LootSpinnerFinalText:Hide()

	BonusRollFrame.LootSpinnerBG:ClearAllPoints()
	BonusRollFrame.LootSpinnerBG:SetPoint("CENTER", BonusRollFrame.PromptFrame.Icon, 'CENTER')
	BonusRollFrame.LootSpinnerBG:SetSize(FRAME_HEIGHT, FRAME_HEIGHT)
	BonusRollFrame.IconBorder:SetSize(FRAME_HEIGHT, FRAME_HEIGHT)

	BonusRollFrame.PromptFrame.Timer:ClearAllPoints()
	BonusRollFrame.PromptFrame.Timer:SetPoint('TOPLEFT', BonusRollFrame, 'TOPLEFT', 0, 0)
	BonusRollFrame.PromptFrame.Timer:SetPoint('BOTTOMRIGHT', BonusRollFrame, 'BOTTOMRIGHT', 0, 0)
	BonusRollFrame.PromptFrame.Timer:SetStatusBarTexture("Interface\\AddOns\\AleaUI\\media\\Minimalist.tga")

	E:CreateBackdrop(BonusRollFrame, nil, {0,0,0,1}, {0,0,0,0}, true)

	BonusRollFrame.PromptFrame.RollButton:ClearAllPoints()
	BonusRollFrame.PromptFrame.RollButton:SetPoint('LEFT', BonusRollFrame, 'LEFT', 3, 0)
	BonusRollFrame.PromptFrame.RollButton:SetSize(24, 24)

	BonusRollFrame.PromptFrame.PassButton:ClearAllPoints()
	BonusRollFrame.PromptFrame.PassButton:SetPoint('LEFT', BonusRollFrame.PromptFrame.RollButton, 'RIGHT', 3, 0)
	BonusRollFrame.PromptFrame.PassButton:SetSize(24, 24)

	BonusRollFrame.PromptFrame.InfoFrame:ClearAllPoints()
	BonusRollFrame.PromptFrame.InfoFrame:SetPoint("TOPLEFT", BonusRollFrame.PromptFrame.PassButton, 'TOPRIGHT')
	BonusRollFrame.PromptFrame.InfoFrame:SetAlpha(0)
	BonusRollFrame.PromptFrame.InfoFrame.Cost.Show = BonusRollFrame.PromptFrame.InfoFrame.Cost.Hide
	BonusRollFrame.PromptFrame.InfoFrame.Cost:Hide()

	BonusRollFrame.PromptFrame.EncounterJournalLinkButton:ClearAllPoints()
	BonusRollFrame.PromptFrame.EncounterJournalLinkButton:SetAllPoints(BonusRollFrame.PromptFrame.InfoFrame)

	BonusRollFrame.PromptFrame.myText = BonusRollFrame.PromptFrame.Timer:CreateFontString(nil, 'OVERLAY', nil, 4)
	BonusRollFrame.PromptFrame.myText:SetPoint("LEFT", BonusRollFrame.PromptFrame.PassButton, 'RIGHT')
	BonusRollFrame.PromptFrame.myText:SetFont(AleaUI.media.default_font, 12, "OUTLINE")
	BonusRollFrame.PromptFrame.myText:SetText(E.L['Bonus loot'])
	BonusRollFrame.PromptFrame.myText:SetTextColor(1, 1, 1, 1)

	BonusRollFrame.SpecRing:ClearAllPoints()
	BonusRollFrame.SpecRing:SetPoint('TOPLEFT', BonusRollFrame, 'TOPLEFT', -65, 3)

	BonusRollFrame.SpecIcon:ClearAllPoints()
	BonusRollFrame.SpecIcon:SetPoint('CENTER', BonusRollFrame.SpecRing, 'CENTER', -14, 14)

	BonusRollFrame.IconBorder.bg = BonusRollFrame:CreateTexture(nil, 'ARTWORK')
	BonusRollFrame.IconBorder.bg:SetColorTexture(0,0,0,1)
	BonusRollFrame.IconBorder.bg:SetOutside(BonusRollFrame.IconBorder)

	BonusRollFrame:HookScript('OnShow', UpdateLootAnchors)
	BonusRollFrame:HookScript('OnHide', UpdateLootAnchors)
	--------------------------
end 

local function GetFrame()
	for i,f in ipairs(LR.RollBars) do
		if not f.rollID then return f end
	end

	local f = LR:CreateRollFrame()

	tinsert(LR.RollBars, f)
	return f
end

AleaUI_TEXT_LOOT = function()
	
	local f = GetFrame()
	f.rollID = 1
	f:Show()
	
	f = GetFrame()
	f.rollID = 1
	f:Show()
	
	f = GetFrame()
	f.rollID = 1
	f:Show()
	
	f = GetFrame()
	f.rollID = 1
	f:Show()
	
	f = GetFrame()
	f.rollID = 1
	f:Show()
	
	f = GetFrame()
	f.rollID = 1
	f:Show()
	
	f = GetFrame()
	f.rollID = 1
	f:Show()
	
	UpdateLootAnchors()
end

function LR:START_LOOT_ROLL(event, rollID, time)
	if cancelled_rolls[rollID] then return end
	local f = GetFrame()
	f.rollID = rollID
	f.time = time

	for i in pairs(f.rolls) do f.rolls[i] = nil end
	f.need:SetText(0)
	f.greed:SetText(0)
	f.pass:SetText(0)
	f.disenchant:SetText(0)

	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
	f.button.icon:SetTexture(texture)
	f.button.link = GetLootRollItemLink(rollID)

	if canNeed then f.needbutt:Enable() else f.needbutt:Disable() end
	if canGreed then f.greedbutt:Enable() else f.greedbutt:Disable() end
	if canDisenchant then f.disenchantbutt:Enable() else f.disenchantbutt:Disable() end
	SetDesaturation(f.needbutt:GetNormalTexture(), not canNeed)
	SetDesaturation(f.greedbutt:GetNormalTexture(), not canGreed)
	SetDesaturation(f.disenchantbutt:GetNormalTexture(), not canDisenchant)
	if canNeed then f.needbutt:SetAlpha(1) else f.needbutt:SetAlpha(0.2) end
	if canGreed then f.greedbutt:SetAlpha(1) else f.greedbutt:SetAlpha(0.2) end
	if canDisenchant then f.disenchantbutt:SetAlpha(1) else f.disenchantbutt:SetAlpha(0.2) end

	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	local color = ITEM_QUALITY_COLORS[quality]
	f.fsloot:SetText(name)
	f.status:SetStatusBarColor(color.r, color.g, color.b, .7)
	f.status.bg:SetColorTexture(color.r, color.g, color.b)
	
	f.status:SetMinMaxValues(0, time)
	f.status:SetValue(time)

	f:Show()
	AlertFrame:UpdateAnchors();
	
	if ( false ) and UnitLevel('player') == MAX_PLAYER_LEVEL and quality == 2 and not bop then
		if canDisenchant then
			RollOnLoot(rollID, 3)
		else
			RollOnLoot(rollID, 2)
		end		
	end	
end

function LR:LOOT_HISTORY_ROLL_CHANGED(event, itemIdx, playerIdx)
	local rollID, itemLink, numPlayers, isDone, winnerIdx, isMasterLoot = C_LootHistory.GetItem(itemIdx);
	local name, class, rollType, roll, isWinner = C_LootHistory.GetPlayerInfo(itemIdx, playerIdx);

	if name and rollType then
		for _,f in ipairs(LR.RollBars) do
			if f.rollID == rollID then
				f.rolls[name] = rollType
				f[rolltypes[rollType]]:SetText(tonumber(f[rolltypes[rollType]]:GetText()) + 1)
				return
			end
		end
	end
end

local function LoadLootRoll()	
	if not true then return end
	
	LR:RegisterEvent('LOOT_HISTORY_ROLL_CHANGED')
	LR:RegisterEvent("START_LOOT_ROLL")

	E:Mover(mover, "lootrollFrame")
	
	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end

AleaUI:OnInit2(LoadLootRoll)