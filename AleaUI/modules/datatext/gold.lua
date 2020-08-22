local addonName, E = ...
local DT = E:Module('DataText')
local L = E.L

local abs = math.abs
local floor = math.floor
local join = string.join
local format = string.format

local defaultColor = { 1, 1, 1 }
local Profit	= 0
local Spent		= 0
local copperFormatter = join("", "%d", "|cffeda55f"..L['COPPER_ABB'].."|r")
local silverFormatter = join("", "%d", "|cffc7c7cf"..L['SILVER_ABB'].."|r", " %.2d", "|cffeda55f"..L['COPPER_ABB'].."|r")
local goldFormatter =  join("", "%s", "|cffffd700"..L['GOLD_ABB'].."|r", " %.2d", "|cffc7c7cf"..L['SILVER_ABB'].."|r", " %.2d", "|cffeda55f"..L['COPPER_ABB'].."|r")
local resetInfoFormatter = join("", "|cffaaaaaa", L["Reset Data: Hold Shift + Right Click"], "|r")

local function FormatMoney(money)
	local gold, silver, copper = floor(abs(money / 10000)), abs(mod(money / 100, 100)), abs(mod(money, 100))
	if gold ~= 0 then
		return format(goldFormatter, BreakUpLargeNumbers(gold), silver, copper)
	elseif silver ~= 0 then
		return format(silverFormatter, silver, copper)
	else
		return format(copperFormatter, copper)
	end
end

local function FormatTooltipMoney(money)
	if not money then return end
	local gold, silver, copper = floor(abs(money / 10000)), abs(mod(money / 100, 100)), abs(mod(money, 100))
	return format(goldFormatter, BreakUpLargeNumbers(gold), silver, copper)
end

local function OnEvent(self, event, ...)
	if not IsLoggedIn() then return end
	local NewMoney = GetMoney();
	AleaUIDB = AleaUIDB or { };
	AleaUIDB['gold'] = AleaUIDB['gold'] or {};
	AleaUIDB['gold'][E.myrealm] = AleaUIDB['gold'][E.myrealm] or {};
	AleaUIDB['gold'][E.myrealm][E.myname] = AleaUIDB['gold'][E.myrealm][E.myname] or NewMoney;

	local OldMoney = AleaUIDB['gold'][E.myrealm][E.myname] or NewMoney

	local Change = NewMoney-OldMoney -- Positive if we gain money
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end

	self.text:SetText(FormatMoney(NewMoney))

	AleaUIDB['gold'][E.myrealm][E.myname] = NewMoney
end

local function Click(self, btn)
	if btn == "RightButton" and IsShiftKeyDown() then
		AleaUIDB.gold = nil;
		OnEvent(self)
		DT.tooltip:Hide();
	else
		ToggleAllBags()
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L['Session:'])
	DT.tooltip:AddDoubleLine(L["Earned:"], FormatMoney(Profit), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Spent:"], FormatMoney(Spent), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		DT.tooltip:AddDoubleLine(L["Deficit:"], FormatMoney(Profit-Spent), 1, 0, 0, 1, 1, 1)
	elseif (Profit-Spent)>0 then
		DT.tooltip:AddDoubleLine(L["Profit:"], FormatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
	end
	DT.tooltip:AddLine' '

	local totalGold = 0
	DT.tooltip:AddLine(L["Character: "])

	for k,_ in pairs(AleaUIDB['gold'][E.myrealm]) do
		if AleaUIDB['gold'][E.myrealm][k] then
			DT.tooltip:AddDoubleLine(k, FormatTooltipMoney(AleaUIDB['gold'][E.myrealm][k]), 1, 1, 1, 1, 1, 1)
			totalGold=totalGold+AleaUIDB['gold'][E.myrealm][k]
		end
	end

	DT.tooltip:AddLine' '
	DT.tooltip:AddLine(L["Server"]..": ")
	DT.tooltip:AddDoubleLine(L["Total"]..": ", FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)

	if ( MAX_WATCHED_TOKENS ) then 
		for i = 1, MAX_WATCHED_TOKENS do
			local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
			if name and i == 1 then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(CURRENCY)
			end
			if name and count then DT.tooltip:AddDoubleLine(name, count, 1, 1, 1) end
		end
	end 

	DT.tooltip:AddLine' '
	DT.tooltip:AddLine(resetInfoFormatter)

	DT.tooltip:Show()
end

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
DT:RegisterDatatext('Gold', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED'}, OnEvent, nil, Click, OnEnter)