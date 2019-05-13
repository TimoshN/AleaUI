local DT = AleaUI:Module('DataText')
local L = AleaUI.L

local join = string.join
local displayString = DURABILITY..": |cFFFFFFFF%d%%|r"
local tooltipString = "%d%%"
local totalDurability = 0
local current, max, lastPanel
local invDurability = {}
local slots = {
	["SecondaryHandSlot"] = L['Offhand'],
	["MainHandSlot"] = L['Main Hand'],
	["FeetSlot"] = L['Feet'],
	["LegsSlot"] = L['Legs'],
	["HandsSlot"] = L['Hands'],
	["WristSlot"] = L['Wrist'],
	["WaistSlot"] = L['Waist'],
	["ChestSlot"] = L['Chest'],
	["ShoulderSlot"] = L['Shoulder'],
	["HeadSlot"] = L['Head'],
}

local function OnEvent(self, event, ...)
	lastPanel = self
	totalDurability = 100

	for index, value in pairs(slots) do		
		local slot = GetInventorySlotInfo(index)
		current, max = GetInventoryItemDurability(slot)
	
		if current then
			invDurability[value] = (current/max)*100
			
			if ((current/max) * 100) < totalDurability then
				totalDurability = (current/max) * 100
			end
		end
	end
	
	self.text:SetFormattedText(displayString, totalDurability)
end

local function Click()
	ToggleCharacter("PaperDollFrame")
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	for slot, durability in pairs(invDurability) do
		DT.tooltip:AddDoubleLine(slot, format(tooltipString, durability), 1, 1, 1, AleaUI:ColorGradient(durability * 0.01, 1 , 1, 0, 0, 1, 1, 0, 0, 1, 0))
	end
		
	DT.tooltip:Show()
end

DT:RegisterDatatext('Durability', {'PLAYER_ENTERING_WORLD', "UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW"}, OnEvent, nil, Click, OnEnter)