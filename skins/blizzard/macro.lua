local Skins = AleaUI:Module("Skins")

local varName = 'macro'
AleaUI.default_settings.skins[varName] = true

AleaUI:OnAddonLoad('Blizzard_MacroUI', function()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	MacroFrame:StripTextures()
	MacroFrameInset:StripTextures()
	Skins.ThemeBackdrop(MacroFrame)
	Skins.ThemeFrameRing(MacroFrame)

	for i=1, 2 do
		Skins.ThemeUpperTabs(_G['MacroFrameTab'..i])
		
	end
	
	Skins.ThemeButton(MacroSaveButton)
	Skins.ThemeButton(MacroEditButton)
	Skins.ThemeButton(MacroCancelButton)
	Skins.ThemeButton(MacroDeleteButton)
	Skins.ThemeButton(MacroNewButton)
	Skins.ThemeButton(MacroExitButton)
	
	Skins.ThemeScrollBar(MacroButtonScrollFrameScrollBar)
	Skins.ThemeScrollBar(MacroFrameScrollFrameScrollBar)
	
	MacroFrameTextBackground:StripTextures()
	
	local backdrop = Skins.NewBackdrop(MacroFrameTextBackground)
	backdrop:SetPoint('TOPLEFT', MacroFrameTextBackground, 'TOPLEFT', 3, -3)
	backdrop:SetPoint('BOTTOMRIGHT', MacroFrameTextBackground, 'BOTTOMRIGHT', 0, 1)
	
	for i=1, MAX_ACCOUNT_MACROS do
		local macroButtonName = "MacroButton"..i;
		local macroButton = _G[macroButtonName];
		local macroIcon = _G[macroButtonName.."Icon"];
		local macroName = _G[macroButtonName.."Name"];
		
		macroName:SetFont(Skins.default_font, Skins.default_font_size, 'OUTLINE')
		
		local checked = macroButton:GetCheckedTexture()
		local step = 0.06
		checked:SetTexCoord(step, 1-step, step, 1-step)

		local highlight = macroButton:GetHighlightTexture()
		highlight:SetAllPoints(macroIcon)
		highlight:SetColorTexture(1, 1, 1, 0.2)
		
		macroIcon:SetTexCoord(unpack(AleaUI.media.texCoord))
		
		local background = Skins.GetTextureObject(macroButton, [[Interface\Buttons\UI-EmptySlot-Disabled]])
		background:SetColorTexture(0, 0, 0, 1)
		background:SetOutside(macroIcon)
	end
	
	
	local background = Skins.GetTextureObject(MacroFrameSelectedMacroButton, [[Interface\Buttons\UI-EmptySlot-Disabled]])
		background:SetColorTexture(0, 0, 0, 1)
		background:SetOutside(MacroFrameSelectedMacroButtonIcon)
		
	local highlight = MacroFrameSelectedMacroButton:GetHighlightTexture()
		highlight:SetAllPoints(MacroFrameSelectedMacroButtonIcon)
		highlight:SetColorTexture(1, 1, 1, 0.2)
		
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(AleaUI.media.texCoord))
	
	MacroPopupNameLeft:SetAlpha(0)
	MacroPopupNameRight:SetAlpha(0)
	MacroPopupNameMiddle:SetAlpha(0)
	
	MacroPopupFrame:StripTextures()
	MacroPopupFrame.BorderBox:StripTextures()
	
	Skins.ThemeScrollBar(MacroPopupScrollFrameScrollBar)
	Skins.ThemeEditBox(MacroPopupEditBox, true)
	Skins.ThemeButton(MacroPopupFrame.BorderBox.OkayButton)
	Skins.ThemeButton(MacroPopupFrame.BorderBox.CancelButton)
	Skins.ThemeBackdrop(MacroPopupFrame)
	Skins.SetAllFontString(MacroPopupFrame, Skins.default_font, Skins.default_font_size, 'OUTLINE')
	
	local themeButtons = true
	local function ThemeMacroIconButtons()
		if themeButtons then
			themeButtons = false
		
			for i=1, NUM_MACRO_ICONS_SHOWN do
				local macroButtonName = "MacroPopupButton"..i;
				local macroButton = _G[macroButtonName];
				local macroIcon = _G[macroButtonName.."Icon"];
			--	local macroName = _G[macroButtonName.."Name"];
			--	macroName:SetFont(Skins.default_font, Skins.default_font_size, 'OUTLINE')
			
				if not macroButton then
					print('Unknown button', macroButtonName)
				else
					local checked = macroButton:GetCheckedTexture()
					local step = 0.06
					checked:SetTexCoord(step, 1-step, step, 1-step)

					local highlight = macroButton:GetHighlightTexture()
					highlight:SetAllPoints(macroIcon)
					highlight:SetColorTexture(1, 1, 1, 0.2)
					
					macroIcon:SetTexCoord(unpack(AleaUI.media.texCoord))
					
					local background = Skins.GetTextureObject(macroButton, [[Interface\Buttons\UI-EmptySlot-Disabled]])
					background:SetColorTexture(0, 0, 0, 1)
					background:SetOutside(macroIcon)
				end
			end
		end
	end
	
	C_Timer.After(0.5, ThemeMacroIconButtons)
	
end)