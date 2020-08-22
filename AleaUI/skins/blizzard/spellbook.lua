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

local varName = 'spellbook'
E.default_settings.skins[varName] = true

local function Skin_SpellBook()
	
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end
	
	
	local function Custom_SpellButtonOnEnter(self)
		local slot = SpellBook_GetSpellBookSlot(self);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if ( GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType) ) then
			self.UpdateTooltip = Custom_SpellButtonOnEnter;
		else
			self.UpdateTooltip = nil;
		end
	end
	
	local function Custom_SpellButtonOnLeave(self)
		GameTooltip:Hide();
	end
	
	hooksecurefunc('SpellButton_OnEnter', function(self)
		print('SpellButton_OnEnter', self:GetName())
		print('    ', (debugstack(1, 1, 1)) )
	end)
	
	SpellBookFrame.NineSlice:StripTextures()
	SpellBookFrameInset.NineSlice:StripTextures()

	Skins.ThemeIconButton(SpellBookPrevPageButton)
	Skins.ThemeIconButton(SpellBookNextPageButton)
	
	Skins.MassKillTexture('SpellBookFrame')	
		
	Skins.ThemeBackdrop('SpellBookFrame')

	Skins.ThemeFrameRing('SpellBookFrame')
	for i=1, 4 do
		Skins.ThemeTab('SpellBookFrameTabButton'..i)
	end
	
	_G['PrimaryProfession1Rank']:SetFont(default_font, Skins.default_font_size, 'NONE')
	_G['PrimaryProfession2Rank']:SetFont(default_font, Skins.default_font_size, 'NONE')
	
	Skins.ThemeStatusBar('PrimaryProfession1StatusBar')
	Skins.ThemeStatusBar('PrimaryProfession2StatusBar')
	
	Skins.ThemeSpellButton('PrimaryProfession1SpellButtonBottom')
	Skins.ThemeSpellButton('PrimaryProfession1SpellButtonTop')
	Skins.ThemeSpellButton('PrimaryProfession2SpellButtonBottom')
	Skins.ThemeSpellButton('PrimaryProfession2SpellButtonTop')
		
	_G['PrimaryProfession1SpellButtonBottom']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['PrimaryProfession1SpellButtonBottom']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	
	_G['PrimaryProfession1SpellButtonTop']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['PrimaryProfession1SpellButtonTop']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	
	_G['PrimaryProfession2SpellButtonBottom']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['PrimaryProfession2SpellButtonBottom']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	
	_G['PrimaryProfession2SpellButtonTop']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['PrimaryProfession2SpellButtonTop']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	
	_G['SecondaryProfession1Rank']:SetFont(default_font, Skins.default_font_size, 'NONE')
	_G['SecondaryProfession2Rank']:SetFont(default_font, Skins.default_font_size, 'NONE')
	_G['SecondaryProfession3Rank']:SetFont(default_font, Skins.default_font_size, 'NONE')
	--_G['SecondaryProfession4Rank']:SetFont(default_font, Skins.default_font_size, 'NONE')
	
	Skins.ThemeStatusBar('SecondaryProfession1StatusBar')
	Skins.ThemeStatusBar('SecondaryProfession2StatusBar')
	Skins.ThemeStatusBar('SecondaryProfession3StatusBar')
	--Skins.ThemeStatusBar('SecondaryProfession4StatusBar')
	
	Skins.ThemeSpellButton('SecondaryProfession1SpellButtonLeft')
	Skins.ThemeSpellButton('SecondaryProfession1SpellButtonRight')
	Skins.ThemeSpellButton('SecondaryProfession2SpellButtonLeft')
	Skins.ThemeSpellButton('SecondaryProfession2SpellButtonRight')
	Skins.ThemeSpellButton('SecondaryProfession3SpellButtonLeft')
	Skins.ThemeSpellButton('SecondaryProfession3SpellButtonRight')
	
	_G['SecondaryProfession1SpellButtonLeft']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['SecondaryProfession1SpellButtonLeft']:SetScript('OnLeave', Custom_SpellButtonOnLeave)	
	_G['SecondaryProfession1SpellButtonRight']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['SecondaryProfession1SpellButtonRight']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	_G['SecondaryProfession2SpellButtonLeft']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['SecondaryProfession2SpellButtonLeft']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	_G['SecondaryProfession2SpellButtonRight']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['SecondaryProfession2SpellButtonRight']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	_G['SecondaryProfession3SpellButtonLeft']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['SecondaryProfession3SpellButtonLeft']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	_G['SecondaryProfession3SpellButtonRight']:SetScript('OnEnter', Custom_SpellButtonOnEnter)
	_G['SecondaryProfession3SpellButtonRight']:SetScript('OnLeave', Custom_SpellButtonOnLeave)
	
	--Skins.ThemeSpellButton('SecondaryProfession4SpellButtonLeft')
	--Skins.ThemeSpellButton('SecondaryProfession4SpellButtonRight')
	
	
	local function SPELL_UPDATE_COOLDOWN_HANDLER(self)
		SpellButton_UpdateCooldown(self.owner);
		-- Update tooltip
		if ( GameTooltip:GetOwner() == self.owner ) then
			Custom_SpellButtonOnEnter(self.owner);
		end
	end
	
	hooksecurefunc('SpellButton_OnShow', function(self)
		self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
		
		if not self.cooldownHandler then
			self.cooldownHandler = CreateFrame('Frame')
			self.cooldownHandler.owner = self
			self.cooldownHandler:SetScript('OnEvent', SPELL_UPDATE_COOLDOWN_HANDLER)
		end
		
		self.cooldownHandler:RegisterEvent('SPELL_UPDATE_COOLDOWN')	
	end)
	
	hooksecurefunc('SpellButton_OnHide', function(self)
		self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
		
		if not self.cooldownHandler then
			self.cooldownHandler = CreateFrame('Frame')
			self.cooldownHandler.owner = self
			self.cooldownHandler:SetScript('OnEvent', SPELL_UPDATE_COOLDOWN_HANDLER)
		end
		
		self.cooldownHandler:UnregisterEvent('SPELL_UPDATE_COOLDOWN')	
	end)
	
	for i=1, 12 do		
		
		_G['SpellButton'..i]:SetScript('OnEnter', Custom_SpellButtonOnEnter)
		_G['SpellButton'..i]:SetScript('OnLeave', Custom_SpellButtonOnLeave)
		_G['SpellButton'..i]:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
		
		
		_G['SpellButton'..i].cooldownHandler = CreateFrame('Frame')
		_G['SpellButton'..i].cooldownHandler.owner = _G['SpellButton'..i]
		_G['SpellButton'..i].cooldownHandler:SetScript('OnEvent', SPELL_UPDATE_COOLDOWN_HANDLER)
		
		--[==[
		_G['SpellButton'..i.."Cooldown"]:SetScript('OnEnter', Custom_SpellButtonOnEnter)
		_G['SpellButton'..i.."Cooldown"]:SetScript('OnLeave', Custom_SpellButtonOnLeave)
		]==]
		
		_G['SpellButton'..i..'SpellName']:SetFont(default_font, Skins.default_font_size, 'NONE')
		_G['SpellButton'..i..'SubSpellName']:SetFont(default_font, Skins.default_font_size, 'NONE')	
		
		E:RegisterCooldown(_G['SpellButton'..i.."Cooldown"])
		
	end
	
	local function SkinTab(tab)
		tab:DisableDrawLayer('BACKGROUND')
		tab:GetNormalTexture():SetTexCoord(unpack(E.media.texCoord))
		tab:GetNormalTexture():SetSize(20, 20)
	
		tab.pushed = true;
		
		local checked = tab:GetCheckedTexture()
		local step = 0.06
		checked:SetTexCoord(step, 1-step, step, 1-step)
		
		Skins.ThemeBackdrop(tab)

		local point, relatedTo, point2, x, y = tab:GetPoint()
		tab:SetPoint(point, relatedTo, point2, 1, y)
	end

	--Skill Line Tabs
	for i=1, MAX_SKILLLINE_TABS do
		local tab = _G["SpellBookSkillLineTab"..i]
		_G["SpellBookSkillLineTab"..i.."Flash"]:Kill()
		SkinTab(tab)
	end
	
	local function SkinSkillLine()
		for i=1, MAX_SKILLLINE_TABS do
			local tab = _G["SpellBookSkillLineTab"..i]
			local _, _, _, _, isGuild = GetSpellTabInfo(i)
			if isGuild then
				tab:GetNormalTexture():SetInside()
				tab:GetNormalTexture():SetTexCoord(unpack(E.media.texCoord))
			end
		end
	end
	hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", SkinSkillLine)
end

E:OnInit2(Skin_SpellBook)