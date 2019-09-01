local E = AleaUI
local DT = E:Module('DataText')
local L = E.L

if ( E.isClassic ) then 
	return 
end

local format = string.format
local join = string.join
local lastPanel, active
local displayString = '';
local talent = {}
local activeString = join("", "|cff00FF00" , ACTIVE_PETS, "|r")
local inactiveString = join("", "|cffFF0000", FACTION_INACTIVE, "|r")
local menuFrame = CreateFrame("Frame", "LootSpecializationDatatextClickMenu", E.UIParent, (Lib_EasyMenu and 'Lib_UIDropDownMenuTemplate' or "UIDropDownMenuTemplate"))
local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true, func = function() SetLootSpecialization(0) end },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}

local menuList2 = {
	{ text = L['Available specializations:'], isTitle = true, notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
}

local function OnEvent(self, event)
	lastPanel = self

	local specIndex = GetSpecialization();
	if not specIndex then return end

	active = GetActiveSpecGroup()

	local talent, loot = '', ''
	
	if GetSpecialization(false, false, active) then
		local texture = select(4, GetSpecializationInfo(GetSpecialization(false, false, active))) or ''
		talent = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
	end

	local specialization = GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization();

		if specIndex then
			local specID, _, _, texture = GetSpecializationInfo(specIndex);
			loot = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture or '')
		else
			loot = 'N/A'
		end
	else
		local specID, _, _, texture = GetSpecializationInfoByID(specialization);
		if specID then
			loot = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture or '')
		else
			loot = 'N/A'
		end
	end

	self.text:SetText(format('%s:%s %s:%s ', L['Spec'], talent, LOOT, loot))
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for i = 1, GetNumSpecGroups() do
		if GetSpecialization(false, false, i) then
			DT.tooltip:AddLine(join(" ", format(displayString, select(2, GetSpecializationInfo(GetSpecialization(false, false, i)))), (i == active and activeString or inactiveString)),1,1,1)
		end
	end

	DT.tooltip:AddLine(' ')
	local specialization = GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization();

		if specIndex then
			local specID, name = GetSpecializationInfo(specIndex);
			DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, format(LOOT_SPECIALIZATION_DEFAULT, name)))
		end
	else
		local specID, name = GetSpecializationInfoByID(specialization);
		if specID then
			DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, name))
		end
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L['|cffFFFFFFLeft Click:|r Change Talent Specialization'])
	DT.tooltip:AddLine(L['|cffFFFFFFRight Click:|r Change Loot Specialization'])

	DT.tooltip:Show()
end

local function OnClick(self, button)
	local specIndex = GetSpecialization();
	if not specIndex then return end

	if button == "LeftButton" then
		DT.tooltip:Hide()
	
	--	print('T','Current', GetSpecialization(), GetNumSpecializations())
	
		for index = 1, 4 do
			local id, name = GetSpecializationInfo(index);
			if ( id ) then
				menuList2[index + 1].text = name
				menuList2[index + 1].func = function() SetSpecialization(index) end
				menuList2[index + 1].disabled = ( index == specIndex );
			else
				menuList2[index + 1] = nil
			end
		end

		E.EasyMenu(menuList2, menuFrame, "cursor", -15, -7, "MENU", 2)
	else
		DT.tooltip:Hide()
		local specID, specName = GetSpecializationInfo(specIndex);
		menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName);

		for index = 1, 4 do
			local id, name = GetSpecializationInfo(index);
			if ( id ) then
				menuList[index + 2].text = name
				menuList[index + 2].func = function() SetLootSpecialization(id) end
			else
				menuList[index + 2] = nil
			end
		end

		E.EasyMenu(menuList, menuFrame, "cursor", -15, -7, "MENU", 2)
	end
end

DT:RegisterDatatext('Talent/Loot Specialization',{"PLAYER_ENTERING_WORLD", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED", 'PLAYER_LOOT_SPEC_UPDATED'}, OnEvent, nil, OnClick, OnEnter)