local addonName, E = ...
local ABS = E:Module("BarSaver")

--if true then return end
if ( E.isClassic ) then 
	return 
end 

local restoreErrors, spellCache, macroCache, macroNameCache, highestRanks = {}, {}, {}, {}, {}
local playerClass

local MAX_MACROS = 54
local MAX_CHAR_MACROS = 18
local MAX_GLOBAL_MACROS = 36
local MAX_ACTION_BUTTONS = 144
local POSSESSION_START = 121
local POSSESSION_END = 132

local MAX_CHAR_MACROS = MAX_CHARACTER_MACROS
local MAX_GLOBAL_MACROS = MAX_ACCOUNT_MACROS
local MAX_MACROS = MAX_CHAR_MACROS + MAX_GLOBAL_MACROS

local selectedProfile = nil
local selecterActionButtons = nil

local defaults_spec = {
	enable = false,
	onlyOnce = true,
	character = {},
}

E.default_settings.specProfiles = defaults_spec

function ABS:OnInitialize()
	local defaults = {
		macro = false,
		checkCount = false,
		restoreRank = false,
		spellSubs = {},
		sets = {}
	}
	
	if not AleaUIDB then AleaUIDB = {} end		
	if not AleaUIDB["ActionBarSaverDB"] then AleaUIDB["ActionBarSaverDB"] = {} end

	-- Load defaults in
	for key, value in pairs(defaults) do
		if( AleaUIDB["ActionBarSaverDB"][key] == nil ) then
			AleaUIDB["ActionBarSaverDB"][key] = value
		end
	end
	
	for classToken in pairs(RAID_CLASS_COLORS) do
		AleaUIDB["ActionBarSaverDB"].sets[classToken] = AleaUIDB["ActionBarSaverDB"].sets[classToken] or {}
	end
	
	self.db = AleaUIDB["ActionBarSaverDB"]
	
	E.db.specProfiles.character[E.myname..'-'..E.myrealm] = E.db.specProfiles.character[E.myname..'-'..E.myrealm] or {}
	
	self.spec_db = E.db.specProfiles.character[E.myname..'-'..E.myrealm]
	
	playerClass = select(2, UnitClass("player"))
end

-- Text "compression" so it can be stored in our format fine
function ABS:CompressText(text)
	text = string.gsub(text, "\n", "/n")
	text = string.gsub(text, "/n$", "")
	text = string.gsub(text, "||", "/124")
	
	return string.trim(text)
end

function ABS:UncompressText(text)
	text = string.gsub(text, "/n", "\n")
	text = string.gsub(text, "/124", "|")
	
	return string.trim(text)
end

-- Restore a saved profile
function ABS:SaveProfile(name)
	self.db.sets[playerClass][name] = self.db.sets[playerClass][name] or {}
	local set = self.db.sets[playerClass][name]
	
	for actionID=1, MAX_ACTION_BUTTONS do
		set[actionID] = nil
		
		local type, id, subType, extraID = GetActionInfo(actionID)
		if( type and id and ( actionID < POSSESSION_START or actionID > POSSESSION_END ) ) then
			-- DB Format: <type>|<id>|<binding>|<name>|<extra ...>
			-- Save a companion
			if( type == "companion" ) then
				set[actionID] = string.format("%s|%s|%s|%s|%s|%s", type, id, "", "", subType, "")
			-- Save an equipment set
			elseif( type == "equipmentset" ) then
				set[actionID] = string.format("%s|%s|%s", type, id, "")
			-- Save an item
			elseif( type == "item" ) then
				set[actionID] = string.format("%s|%d|%s|%s", type, id, "", (GetItemInfo(id)) or "")
			-- Save a spell
			elseif( type == "spell" and id > 0 ) then
			    local spellName, spellStance = GetSpellInfo(id)
				if( spellName and spellStance ) then
					set[actionID] = string.format("%s|%d|%s|%s|%s|%s", type, id, "", spellName, spellStance or "", extraID or "")
				end
			-- Save a macro
			elseif( type == "macro" ) then
				local name, icon, macro = GetMacroInfo(id)
				if( name and icon and macro ) then
					set[actionID] = string.format("%s|%d|%s|%s|%s|%s", type, actionID, "", self:CompressText(name), icon, self:CompressText(macro))
				end
			-- Flyout mnenu
		    elseif( type == "flyout" ) then
		        set[actionID] = string.format("%s|%d|%s|%s|%s", type, id, "", (GetFlyoutInfo(id)), "")
			end
		end
	end
	
	self:Print(string.format("Saved profile %s!", name))
end

-- Finds the macroID in case it's changed
function ABS:FindMacro(id, name, data)
	if( macroCache[id] == data ) then
		return id
	end
		
	-- No such luck, check text
	for id, currentMacro in pairs(macroCache) do
		if( currentMacro == data ) then
			return id
		end
	end
	
	-- Still no luck, let us try name
	if( macroNameCache[name] ) then
		return macroNameCache[name]
	end
	
	return nil
end

-- Restore any macros that don't exist
function ABS:RestoreMacros(set)
	local perCharacter = true
	for id, data in pairs(set) do
		local type, id, binding, macroName, macroIcon, macroData = string.split("|", data)
		if( type == "macro" ) then
			-- Do we already have a macro?
			local macroID = self:FindMacro(id, macroName, macroData)
			if( not macroID ) then
				local globalNum, charNum = GetNumMacros()
				-- Make sure we aren't at the limit
				if( globalNum == MAX_GLOBAL_MACROS and charNum == MAX_CHAR_MACROS ) then
					table.insert(restoreErrors, "Unable to restore macros, you already have 36 global and 18 per character ones created.")
					break

				-- We ran out of space for per character, so use global
				elseif( charNum == MAX_CHAR_MACROS ) then
					perCharacter = false
				end
				
				macroName = self:UncompressText(macroName)

				-- GetMacroInfo still returns the full path while CreateMacro needs the relative
				-- can also return INTERFACE\ICONS\ aswell, apparently.
				macroIcon = macroIcon and string.gsub(macroIcon, "[iI][nN][tT][eE][rR][fF][aA][cC][eE]\\[iI][cC][oO][nN][sS]\\", "")
				
				-- No macro name means a space has to be used or else it won't be created and saved
				CreateMacro(macroName == "" and " " or macroName, macroIcon or "INV_Misc_QuestionMark", self:UncompressText(macroData), perCharacter)
			end
		end
	end
	
	-- Recache macros due to any additions
	local blacklist = {}
	for i=1, MAX_MACROS do
		local name, icon, macro = GetMacroInfo(i)
		
		if( name ) then
			-- If there are macros with the same name, then blacklist and don't look by name
			if( macroNameCache[name] ) then
				blacklist[name] = true
				macroNameCache[name] = i
			elseif( not blacklist[name] ) then
				macroNameCache[name] = i
			end
		end
		
		macroCache[i] = macro and self:CompressText(macro) or nil
	end
end

-- Restore a saved profile
function ABS:RestoreProfile(name, overrideClass)
	local set = self.db.sets[overrideClass or playerClass][name]
	if( not set ) then
		self:Print(string.format("No profile with the name \"%s\" exists.", set))
		return
	elseif( InCombatLockdown() ) then
		self:Print(string.format("Unable to restore profile \"%s\", you are in combat.", set))
		return
	end
	
	table.wipe(macroCache)
	table.wipe(spellCache)
	table.wipe(macroNameCache)
	
	-- Cache spells
	for book=1, MAX_SKILLLINE_TABS do
		local _, _, offset, numSpells, _, offSpecID = GetSpellTabInfo(book)

		for i=1, numSpells do
			if offSpecID == 0 then -- don't process grayed-out "offspec" tabs
				for i=1, numSpells do
					local index = offset + i
					local spell, stance = GetSpellBookItemName(index, BOOKTYPE_SPELL)
				
					-- This way we restore the max rank of spells
					spellCache[spell] = index
					spellCache[string.lower(spell)] = index
				
					if( stance and stance ~= "" ) then
						spellCache[spell .. stance] = index
					end
	 			end
			end
		end
	end
		
	
	-- Cache macros
	local blacklist = {}
	for i=1, MAX_MACROS do
		local name, icon, macro = GetMacroInfo(i)
		
		if( name ) then
			-- If there are macros with the same name, then blacklist and don't look by name
			if( macroNameCache[name] ) then
				blacklist[name] = true
				macroNameCache[name] = i
			elseif( not blacklist[name] ) then
				macroNameCache[name] = i
			end
		end
		
		macroCache[i] = macro and self:CompressText(macro) or nil
	end
	
	-- Check if we need to restore any missing macros
	if( self.db.macro ) then
		self:RestoreMacros(set)
	end
	
	-- Start fresh with nothing on the cursor
	ClearCursor()
	
	-- Save current sound setting
	local soundToggle = GetCVar("Sound_EnableAllSound")
	-- Turn sound off
	SetCVar("Sound_EnableAllSound", 0)

	for i=1, MAX_ACTION_BUTTONS do
		if( i < POSSESSION_START or i > POSSESSION_END ) then
			local type, id = GetActionInfo(i)
		
			-- Clear the current spot
			if( id or type ) then
				PickupAction(i)
				ClearCursor()
			end
		
			-- Restore this spot
			if( set[i] ) then
				self:RestoreAction(i, string.split("|", set[i]))
			end
		end
	end
	
	-- Restore old sound setting
	SetCVar("Sound_EnableAllSound", soundToggle)
	
	-- Done!
	if( #(restoreErrors) == 0 ) then
		self:Print(string.format("Restored profile %s!", name))
	else
		self:Print(string.format("Restored profile %s, failed to restore %d buttons type /abs errors for more information.", name, #(restoreErrors)))
	end
end

function ABS:RestoreAction(i, type, actionID, binding, ...)
	-- Restore a spell, flyout or companion
	if( type == "spell" or type == "flyout" or type == "companion" ) then
		local spellName, spellRank = ...
		if( spellCache[spellName] ) then
			PickupSpellBookItem(spellCache[spellName], BOOKTYPE_SPELL);
		else
		    PickupSpell(actionID)
		end
		
		if( GetCursorInfo() ~= type ) then
			-- Bad restore, check if we should link at all
			local lowerSpell = string.lower(spellName)
			for spell, linked in pairs(self.db.spellSubs) do
				if( lowerSpell == spell and spellCache[linked] ) then
					self:RestoreAction(i, type, actionID, binding, linked, nil, arg3)
					return
				elseif( lowerSpell == linked and spellCache[spell] ) then
					self:RestoreAction(i, type, actionID, binding, spell, nil, arg3)
					return
				end
			end
			
			table.insert(restoreErrors, string.format("Unable to restore spell \"%s\" to slot #%d, it does not appear to have been learned yet.", spellName, i))
			ClearCursor()
			return
		end

		PlaceAction(i)
	-- Restore flyout
    elseif( type == "flyout" ) then
        PickupSpell(actionID)
        if( GetCursorInfo() ~= "flyout" ) then
			table.insert(restoreErrors, string.format("Unable to restore flyout spell \"%s\" to slot #%d, it does not appear to exist anymore.", actionID, i))
			ClearCursor()
			return
        end
        PlaceAction(i)
        
	-- Restore an equipment set button
	elseif( type == "equipmentset" ) then
		local slotID = -1
		for i=1, C_EquipmentSet.GetNumEquipmentSets() do
			if( C_EquipmentSet.GetEquipmentSetInfo(i-1) == actionID ) then
				slotID = i
				break
			end
		end
		
		PickupEquipmentSet(slotID)
		if( GetCursorInfo() ~= "equipmentset" ) then
			table.insert(restoreErrors, string.format("Unable to restore equipment set \"%s\" to slot #%d, it does not appear to exist anymore.", actionID, i))
			ClearCursor()
			return
		end
		
		PlaceAction(i)
			
	-- Restore an item
	elseif( type == "item" ) then
		PickupItem(actionID)

		if( GetCursorInfo() ~= type ) then
			local itemName = select(i, ...)
			table.insert(restoreErrors, string.format("Unable to restore item \"%s\" to slot #%d, cannot be found in inventory.", itemName and itemName ~= "" and itemName or actionID, i))
			ClearCursor()
			return
		end
		
		PlaceAction(i)
	-- Restore a macro
	elseif( type == "macro" ) then
		local name, _, content = ...
		PickupMacro(self:FindMacro(actionID, name, content or -1))
		if( GetCursorInfo() ~= type ) then
			table.insert(restoreErrors, string.format("Unable to restore macro id #%d to slot #%d, it appears to have been deleted.", actionID, i))
			ClearCursor()
			return
		end
		
		PlaceAction(i)
	end
end

function ABS:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99AleaUI|r: " .. msg)
end

SLASH_ACTIONBARSAVER1 = nil
SlashCmdList["ACTIONBARSAVER"] = nil

SLASH_ABS1 = "/abs"
SLASH_ABS2 = "/actionbarsaver"
SlashCmdList["ABS"] = function(msg)
	msg = msg or ""
	
	local cmd, arg = string.split(" ", msg, 2)
	cmd = string.lower(cmd or "")
	arg = string.lower(arg or "")
	
	local self = ABS
	
	-- Profile saving
	if( cmd == "save" and arg ~= "" ) then
		self:SaveProfile(arg)
	
	-- Spell sub
	elseif( cmd == "link" and arg ~= "" ) then
		local first, second = string.match(arg, "\"(.+)\" \"(.+)\"")
		first = string.trim(first or "")
		second = string.trim(second or "")
		
		if( first == "" or second == "" ) then
			self:Print("Invalid spells passed, remember you must put quotes around both of them.")
			return
		end
		
		self.db.spellSubs[first] = second
		
		self:Print(string.format("Spells \"%s\" and \"%s\" are now linked.", first, second))
		
	-- Profile restoring
	elseif( cmd == "restore" and arg ~= "" ) then
		for i=#(restoreErrors), 1, -1 do table.remove(restoreErrors, i) end
				
		if( not self.db.sets[playerClass][arg] ) then
			self:Print(string.format("Cannot restore profile \"%s\", you can only restore profiles saved to your class.", arg))
			return
		end
		
		self:RestoreProfile(arg, playerClass)
		
	-- Profile renaming
	elseif( cmd == "rename" and arg ~= "" ) then
		local old, new = string.split(" ", arg, 2)
		new = string.trim(new or "")
		old = string.trim(old or "")
		
		if( new == old ) then
			self:Print(string.format("You cannot rename \"%s\" to \"%s\" they are the same profile names.", old, new))
			return
		elseif( new == "" ) then
			self:Print(string.format("No name specified to rename \"%s\" to.", old))
			return
		elseif( self.db.sets[playerClass][new] ) then
			self:Print(string.format("Cannot rename \"%s\" to \"%s\" a profile already exists for %s.", old, new, (UnitClass("player"))))
			return
		elseif( not self.db.sets[playerClass][old] ) then
			self:Print(string.format("No profile with the name \"%s\" exists.", old))
			return
		end
		
		self.db.sets[playerClass][new] = CopyTable(self.db.sets[playerClass][old])
		self.db.sets[playerClass][old] = nil
		
		self:Print(string.format("Renamed \"%s\" to \"%s\"", old, new))
		
	-- Restore errors
	elseif( cmd == "errors" ) then
		if( #(restoreErrors) == 0 ) then
			self:Print("No errors found!")
			return
		end

		self:Print(string.format("Errors found: %d", #(restoreErrors)))
		for _, text in pairs(restoreErrors) do
			DEFAULT_CHAT_FRAME:AddMessage(text)
		end

	-- Delete profile
	elseif( cmd == "delete" ) then
		self.db.sets[playerClass][arg] = nil
		self:Print(string.format("Deleted saved profile %s.", arg))
	
	-- List profiles
	elseif( cmd == "list" ) then
		local classes = {}
		local setList = {}
		
		for class, sets in pairs(self.db.sets) do
			table.insert(classes, class)
		end
		
		table.sort(classes, function(a, b)
			return a < b
		end)
		
		for _, class in pairs(classes) do
			for i=#(setList), 1, -1 do table.remove(setList, i) end
			for setName in pairs(self.db.sets[class]) do
				table.insert(setList, setName)
			end
			
			if( #(setList) > 0 ) then
				DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99%s|r: %s", class or "???", table.concat(setList, ", ")))
			end
		end
		
	-- Macro restoring
	elseif( cmd == "macro" ) then
		self.db.macro = not self.db.macro

		if( self.db.macro ) then
			self:Print("Auto macro restoration is now enabled!")
		else
			self:Print("Auto macro restoration is now disabled!")
		end
	
	-- Item counts
	elseif( cmd == "count" ) then
		self.db.checkCount = not self.db.checkCount

		if( self.db.checkCount ) then
			self:Print("Checking item count is now enabled!")
		else
			self:Print("Checking item count is now disabled!")		
		end
	
	-- Rank restore
	elseif( cmd == "rank" ) then
		self.db.restoreRank = not self.db.restoreRank
		
		if( self.db.restoreRank ) then
			self:Print("Auto restoring highest spell rank is now enabled!")
		else
			self:Print("Auto restoring highest spell rank is now disabled!")
		end
		
	-- Halp
	else
		self:Print("Slash commands")
		DEFAULT_CHAT_FRAME:AddMessage("/abs save <profile> - Saves your current action bar setup under the given profile.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs restore <profile> - Changes your action bars to the passed profile.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs delete <profile> - Deletes the saved profile.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs rename <oldProfile> <newProfile> - Renames a saved profile from oldProfile to newProfile.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs link \"<spell 1>\" \"<spell 2>\" - Links a spell with another, INCLUDE QUOTES for example you can use \"Shadowmeld\" \"War Stomp\" so if War Stomp can't be found, it'll use Shadowmeld and vica versa.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs count - Toggles checking if you have the item in your inventory before restoring it, use if you have disconnect issues when restoring.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs macro - Attempts to restore macros that have been deleted for a profile.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs rank - Toggles if ABS should restore the highest rank of the spell, or the one saved originally.")
		DEFAULT_CHAT_FRAME:AddMessage("/abs list - Lists all saved profiles.")
	end
end



ABS.Executor = function(cmd, arg)
	SlashCmdList["ABS"](cmd..' '..arg)
end

E:OnInit2(function()
	ABS:OnInitialize()
end)


E.GUI.args.SpecAssists = {
	name = E.L['Spec profiles'],
	type = "group",
	order = 5,
	expand = true,
	args = {},
}
	
E.GUI.args.SpecAssists.args.CreateNew = {
	name = E.L['New profile'],
	type = 'execute',
	order = 1,
	width = 'full',
	set = function()
		ABS.spec_db.numProfiles = ( ABS.spec_db.numProfiles or 0 ) + 1
		
		local name = E.L['Profile']..' #'..ABS.spec_db.numProfiles
		
		ABS.spec_db.profiles = ABS.spec_db.profiles or {}
		
		
		ABS.spec_db.profiles[name] = {
			enable = true,
			name = name,
			specs = {},
			checkTalents = false,
			talents = {},
			buttons_enable = false,
			buttons_profile = false,
			items_enable = false,
			items_profile = false,
		}
		
		for i=1, GetNumSpecializations() do
			local id = GetSpecializationInfo(i)
			ABS.spec_db.profiles[name].specs[id] = true
		end
		
		selectedProfile = name
	end,
	get = function()
	
	end,
}

E.GUI.args.SpecAssists.args.SelectProfile = {
	name = E.L['Select profile'],
	type = 'dropdown',
	order = 2,
	width = 'full',
	values = function()
		local t = {}
		
		for k,v in pairs( ABS.spec_db.profiles or {} ) do	
			t[k] = v.name or k
		end
		
		return t
	end,
	set = function(info, value)		
		selectedProfile = value		
	end,
	get = function()
		return selectedProfile
	end,
}

E.GUI.args.SpecAssists.args.ProfileName = {
	name = E.L['Name'],
	type = 'editbox',
	order = 3,
	width = 'full',
	set = function(info, value)
		if selectedProfile then
			ABS.spec_db.profiles[selectedProfile].name = value
		end
	end,	
	get = function()
		if selectedProfile then
			return ABS.spec_db.profiles[selectedProfile].name or selectedProfile
		end
		
		return ''
	end,
	
}

E.GUI.args.SpecAssists.args.autoUsed = {
	name = E.L['Activation'],
	type = "group",
	order = 4,
	embend = true,
	args = {},
}

E.GUI.args.SpecAssists.args.autoUsed.args.Enable = {
	name = E.L['Enable'],
	order = 1,
	type = 'toggle',
	set = function()
		if selectedProfile then
			ABS.spec_db.profiles[selectedProfile].enable = not ABS.spec_db.profiles[selectedProfile].enable
		end
	end,
	get = function()
		if selectedProfile then
			return ABS.spec_db.profiles[selectedProfile].enable
		end
		return false
	end,
}

E.GUI.args.SpecAssists.args.autoUsed.args.CheckTalents = {
	name = E.L['Check talents'],
	order = 2,
	type = 'toggle',
	set = function()
		if selectedProfile then
			ABS.spec_db.profiles[selectedProfile].checkTalents = not ABS.spec_db.profiles[selectedProfile].checkTalents
		end
	end,
	get = function()
		if selectedProfile then
			return ABS.spec_db.profiles[selectedProfile].checkTalents
		end
		return false
	end,
}

E.GUI.args.SpecAssists.args.autoUsed.args.UpdateTalents = {
	name = E.L['Update talents'],
	order = 3,
	width = 'full',
	type = 'execute',
	set = function()
	
	end,
	get = function()
		return true
	end,
}

for i=1, GetNumSpecializations() do
	local id, name, description, icon, background, role = GetSpecializationInfo(i)
	E.GUI.args.SpecAssists.args.autoUsed.args['spec'..id] = {
		name = name and "|T"..icon ..":0:0:0:0|t"..name or E.L['Non-selected'],

		order = 4+i,
		type = 'toggle',
		set = function()
			if selectedProfile then
				ABS.spec_db.profiles[selectedProfile].specs[i] = not ABS.spec_db.profiles[selectedProfile].specs[i]
			end
		end,
		get = function()
			if selectedProfile then
				return ABS.spec_db.profiles[selectedProfile].specs[i]
			end		
			return false
		end,
	}
end


E.GUI.args.SpecAssists.args.actionBars = {
	name = E.L['Action bars'],
	type = "group",
	order = 5,
	embend = true,
	args = {},
}

E.GUI.args.SpecAssists.args.actionBars.args.Enable = {
	name = E.L['Enable'],
	order = 1,
	type = 'toggle',
	set = function()
		if selectedProfile then
			ABS.spec_db.profiles[selectedProfile].buttons_enable = not ABS.spec_db.profiles[selectedProfile].buttons_enable
		end
	end,
	get = function()
		if selectedProfile then
			return ABS.spec_db.profiles[selectedProfile].buttons_enable
		end		
		return false
	end,
}


E.GUI.args.SpecAssists.args.actionBars.args.CreateNew = {
	name = E.L['New profile'],
	type = 'execute',
	order = 1,
	width = 'full',
	set = function()
		ABS.spec_db.num_abs = ( ABS.spec_db.num_abs or 0 ) + 1
		ABS.Executor('save', 'profile'..ABS.spec_db.num_abs)
	end,
	get = function()
	
	end,
}

E.GUI.args.SpecAssists.args.actionBars.args.SelectProfile = {
	name = E.L['Select profile'],
	type = 'dropdown',
	order = 2,
	width = 'full',
	values = function()
		local t = {}
	
		for k,v in pairs( ABS.db.sets[playerClass] ) do
		
			t[k] = k
		end
		
		return t
	end,
	set = function(info, value)

		if selectedProfile then
			ABS.spec_db.profiles[selectedProfile].buttons_profile = value
		end
	end,
	get = function()
		if selectedProfile then
			return ABS.spec_db.profiles[selectedProfile].buttons_profile
		end
		return false
	end,
}

E.GUI.args.SpecAssists.args.actionBars.args.ProfileName = {
	name = E.L['Name'],
	type = 'editbox',
	order = 3,
	width = 'full',
	set = function(info, value)
		if selectedProfile and ABS.spec_db.profiles[selectedProfile].buttons_profile then
			ABS.Executor('rename', ABS.spec_db.profiles[selectedProfile].buttons_profile..' '..value)
		end
	end,
	
	get = function()
		if selectedProfile and ABS.spec_db.profiles[selectedProfile].buttons_profile then	
			return ABS.spec_db.profiles[selectedProfile].buttons_profile
		end
		return ''
	end,
	
}

E.GUI.args.SpecAssists.args.actionBars.args.Apply = {
	name = E.L['Apply'],
	type = 'execute',
	order = 4,
	width = 'full',
	set = function()
		if selectedProfile and ABS.spec_db.profiles[selectedProfile].buttons_profile then	
			ABS.Executor('restore', ABS.spec_db.profiles[selectedProfile].buttons_profile)
		end
	end,
	get = function()
	
	end,
}

E.GUI.args.SpecAssists.args.actionBars.args.Delete = {
	name = E.L['Delete'],
	type = 'execute',
	order = 5,
	width = 'full',
	set = function()
		if selectedProfile and ABS.spec_db.profiles[selectedProfile].buttons_profile then	
			ABS.Executor('delete', ABS.spec_db.profiles[selectedProfile].buttons_profile)
			
			ABS.spec_db.profiles[selectedProfile].buttons_profile = false
		end
	end,
	get = function()
	
	end,
}

E.GUI.args.SpecAssists.args.itemSet = {
	name = E.L['Equip sets'],
	type = "group",
	order = 6,
	embend = true,
	args = {},
}

E.GUI.args.SpecAssists.args.itemSet.args.Enable = {
	name = E.L['Enable'],
	order = 1,
	type = 'toggle',
	set = function()
		if selectedProfile then
			ABS.spec_db.profiles[selectedProfile].items_enable = not ABS.spec_db.profiles[selectedProfile].items_enable
		end
	end,
	get = function()
		if selectedProfile then
			return ABS.spec_db.profiles[selectedProfile].items_enable
		end		
		return false
	end,
}

E.GUI.args.SpecAssists.args.itemSet.args.SelectProfile = {
	name = E.L['Select profile'],
	type = 'dropdown',
	order = 2,
	width = 'full',
	values = function()
		local t = {}

		for i = 1, C_EquipmentSet.GetNumEquipmentSets() do
			local name = C_EquipmentSet.GetEquipmentSetInfo(i-1)			
			t[name] = name				
		end
		
		return t
	end,
	set = function(info, value)
		if selectedProfile then
			ABS.spec_db.profiles[selectedProfile].items_profile = value
		end
	end,
	get = function()
		if selectedProfile then
			return ABS.spec_db.profiles[selectedProfile].items_profile
		end		
		return false
	end,
}

E.GUI.args.SpecAssists.args.itemSet.args.Apply = {
	name = E.L['Apply'],
	type = 'execute',
	order = 4,
	width = 'full',
	set = function()
		if selectedProfile and ABS.spec_db.profiles[selectedProfile].items_profile then	
			local success = C_EquipmentSet.UseEquipmentSet(ABS.spec_db.profiles[selectedProfile].items_profile);
			print('T', 'SpecAssists', 'UseEquipmentSet', success)
		end
	end,
	get = function()
	
	end,
}
