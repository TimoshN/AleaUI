local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName1 = 'playertalents'
local varName2 = 'playerglyphs'
AleaUI.default_settings.skins[varName1] = true
AleaUI.default_settings.skins[varName2] = true

do
	
	AleaUI:OnAddonLoad('Blizzard_GlyphUI', function()
		if AleaUI.IsLegion then return end
		if not AleaUI.db.skins.enableAll then return end
		if not AleaUI.db.skins[varName2] then return end

		Skins.MassKillTexture('GlyphFrameSide')	
		
		Skins.ThemeBackdrop('GlyphFrame')
		
		Skins.ThemeScrollBar('GlyphFrameScrollFrameScrollBar')
		
		Skins.ThemeEditBox('GlyphFrameSearchBox', true)
	
		local leftCorter = GlyphFrame:CreateTexture(nil, 'BACKGROUND', nil, 1)
		leftCorter:SetTexture("Interface\\TalentFrame\\glyph-bg")
		leftCorter:SetPoint('TOPLEFT', GlyphFrame, 'TOPLEFT', 1, 0)
		leftCorter:SetSize(100, 100)
		leftCorter:SetTexCoord(0.857, 0.665, 0.002, 0.1)
		

		hooksecurefunc('GlyphFrame_Update', function()
			local isActiveTalentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup == GetActiveSpecGroup();
			SetDesaturation(leftCorter, not isActiveTalentGroup);		
		end)
		
		Skins.ThemeDropdown('GlyphFrameFilterDropDown')
		
		for i=1, 10 do
			local button = _G["GlyphFrameScrollFrameButton"..i]
			local icon = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

			button:StripTextures()
			
			local highlight = button:CreateTexture(nil, 'ARTWORK')
			highlight:SetAllPoints()
			highlight:SetColorTexture(1,1,1,0.3)
			
			button:SetHighlightTexture(highlight)
			
			icon:SetTexCoord(unpack(AleaUI.media.texCoord))
			
			Skins.ThemeBackdrop(button)
		end
		
	end)
	
	AleaUI:OnAddonLoad('Blizzard_TalentUI', function()
	
		if not AleaUI.db.skins.enableAll then return end
		if not AleaUI.db.skins[varName1] then return end

		Skins.ThemeButton('PlayerTalentFramePetSpecializationLearnButton')
		Skins.ThemeButton('PlayerTalentFrameSpecializationLearnButton')
	--	Skins.ThemeButton('PlayerTalentFrameTalentsLearnButton')
		Skins.ThemeButton('PlayerTalentFrameActivateButton')
		
		PlayerTalentFrameSpecializationTutorialButton:Kill()
		PlayerTalentFrameTalentsTutorialButton:Kill()
		
		PlayerTalentFrameSpecializationBRCorner:SetAlpha(0)
		PlayerTalentFrameSpecializationBLCorner:SetAlpha(0)
		PlayerTalentFrameSpecializationTLCorner:SetAlpha(0)
		PlayerTalentFrameSpecializationTRCorner:SetAlpha(0)
		
		PlayerTalentFrameSpecialization:StripTextures2([[Interface\Common\bluemenu-main]])
		PlayerTalentFrameSpecialization:StripTextures2([[Interface\Common\bluemenu-vert]])
		PlayerTalentFrameSpecialization:StripTextures2([[Interface\Common\bluemenu-goldborder-horiz]])
		
		PlayerTalentFrameSpecializationBRCorner:GetParent():StripTextures()
		
		_G['PlayerTalentFrameTitleGlowCenter']:SetAlpha(0)
		_G['PlayerTalentFrameTitleGlowRight']:SetAlpha(0)
		
		_G['PlayerTalentFrame']:StripTextures()
		_G['PlayerTalentFrameInset']:StripTextures()
		_G['PlayerTalentFrameInset'].NineSlice:StripTextures()

		Skins.ThemeBackdrop('PlayerTalentFrame')
		
		Skins.ThemeFrameRing('PlayerTalentFrame')
		
		local SpecializationBorder = CreateFrame('Frame', nil, PlayerTalentFrame)
		SpecializationBorder:SetPoint('TOPRIGHT', PlayerTalentFrame, 'TOPRIGHT', -5, -24)
		SpecializationBorder:SetSize(420, 410)
		SpecializationBorder:SetFrameLevel(PlayerTalentFrameSpecialization:GetFrameLevel()+10)
	--	SpecializationBorder:SetFrameStrata('HIGH')
		AleaUI:CreateBackdrop(SpecializationBorder, nil, { 0, 0, 0, 1 }, {0,0,0,0})
		SpecializationBorder:SetUIBorderDrawLayer('OVERLAY', 1)
		
		local blueTextureArtwork = CreateFrame('Frame', nil, PlayerTalentFrame)
		blueTextureArtwork:SetSize(210, 410)
		blueTextureArtwork:SetPoint('TOPLEFT', PlayerTalentFrame, 'TOPLEFT', 5, -24)
		
		AleaUI:CreateBackdrop(blueTextureArtwork, nil, default_border_color, default_background_color)
		
		blueTextureArtwork:SetUIBorderDrawLayer('BORDER', -1)
		blueTextureArtwork:SetUIBackgroundDrawLayer('BACKGROUND', -1)
		
		PlayerTalentFrameSpecialization.bg:SetAlpha(1)
		PlayerTalentFrameSpecialization.bg:SetTexCoord(0, 1, 0.1, 1)
		PlayerTalentFrameSpecialization.bg:SetSize(550, 488)
		PlayerTalentFrameSpecialization.bg:SetPoint('TOPLEFT', 217, 0)

		PlayerTalentFrameSpecialization:HookScript('OnShow', function(self)
			SpecializationBorder:Show()
			blueTextureArtwork:Show()
		end)
		PlayerTalentFrameSpecialization:HookScript('OnHide', function(self)
			SpecializationBorder:Hide()
			blueTextureArtwork:Hide()
		end)
	
		
	--	local finder = Skins.GetAllTextureObject('PlayerTalentFrameSpecialization', [[Interface\Common\bluemenu-vert]])
		
	--	finder:SetAlpha(0)
		
		_G['PlayerTalentFrameTalents']:StripTextures()
		
		local border = Skins.NewBackdrop('PlayerTalentFrameTalents')
		border:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 1)
		border:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
		border:SetPoint('TOPLEFT', _G['PlayerTalentFrameTalents'], 'TOPLEFT', 2, -10)
		border:SetPoint('BOTTOMRIGHT', _G['PlayerTalentFrameTalents'], 'BOTTOMRIGHT', -2, 10)
		
		for i=1, 3 do
			Skins.ThemeTab('PlayerTalentFrameTab'..i)
		end
		
		
		local buttonPattern = 'PlayerTalentFrameTalentsTalentRow%dTalent%d'
	
		for t=1, MAX_TALENT_TIERS do
			
			_G['PlayerTalentFrameTalentsTalentRow'..t]:StripTextures()
			
			for a=1, NUM_TALENT_COLUMNS do
				local name = format(buttonPattern, t,a)
				
				Skins.ThemeSpellButton(name, true)
				
				_G[name..'Selection']:SetColorTexture(0, 0.5, 0, 0.5)
				_G[name..'Selection']:SetDrawLayer('ARTWORK', 4)
				_G[name..'IconTexture']:SetDrawLayer('ARTWORK', 5)
				_G[name..'Name']:SetDrawLayer('ARTWORK', 5)
				_G[name].highlight:Kill()
				_G[name..'IconTexture']:SetUIBorderDrawLayer('ARTWORK', 5)
				_G[name..'IconTexture']:SetUIBackgroundColor(0, 0, 0, 0)
				_G[name..'IconTexture']:SetUIBackdropBorderColor(0, 0, 0, 1)
				
				AleaUI:CreateBackdrop(_G[name], _G[name..'Selection'], { 0, 0, 0, 1 }, {0,0,0,0}, 'ARTWORK')
			end
		end
		
		local function UpdateTalentSelection()
			for t=1, MAX_TALENT_TIERS do
				for a=1, NUM_TALENT_COLUMNS do				
					local name = format(buttonPattern, t,a)
					
					if(_G[name].knownSelection ~= nil) then
						if _G[name].knownSelection:IsShown() then
							_G[name].knownSelection:SetUIBackdropBorderColor(0, 0, 0, 1)
						else
							_G[name].knownSelection:SetUIBackdropBorderColor(0, 0, 0, 0)
						end
						
						local _, _, _, selected, _, _, _, _, _, _, grantedByAura = GetTalentInfo(t, a, 1);
						
						if grantedByAura then
							_G[name].knownSelection:SetColorTexture(0.5, 0, 0, 0.5)
						else
							_G[name].knownSelection:SetColorTexture(0, 0.5, 0, 0.5)
						end
						
						_G[name].knownSelection:SetDrawLayer('ARTWORK', 4)
					end
				end
			end
		end
		
		hooksecurefunc('PlayerTalentFrame_Refresh', UpdateTalentSelection)
		hooksecurefunc('TalentFrame_Update', UpdateTalentSelection)
		
		local function SkinTab(tab)
			tab:DisableDrawLayer('BACKGROUND')
			tab:GetNormalTexture():SetTexCoord(unpack(AleaUI.media.texCoord))
			tab:GetNormalTexture():SetSize(20, 20)
		
			tab.pushed = true;
			
			local checked = tab:GetCheckedTexture()
			local step = 0.06
			checked:SetTexCoord(step, 1-step, step, 1-step)
		
		
			Skins.ThemeBackdrop(tab)

			local point, relatedTo, point2, x, y = tab:GetPoint()
			tab:SetPoint(point, relatedTo, point2, 1, y)
		end
	
		for i=1, 2 do
			local framebg = _G['PlayerSpecTab'..i] --.'Background'
			
			if framebg then
				SkinTab(framebg)
			end
		end
		
		PlayerTalentFrameTalentsPvpTalentFrame:StripTextures()
		
		--[==[
		
		PlayerTalentFramePVPTalents:StripTextures()
		PlayerTalentFramePVPTalents.Talents:StripTextures()
		
		local border = Skins.NewBackdrop(PlayerTalentFramePVPTalents.Talents)
		border:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 1)
		border:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
		border:SetPoint('TOPLEFT', PlayerTalentFramePVPTalents.Talents, 'TOPLEFT', 2, -10)
		border:SetPoint('BOTTOMRIGHT', PlayerTalentFramePVPTalents.Talents, 'BOTTOMRIGHT', -2, 10)
		
		
		for t=1, 3 do
			for a=1, 6 do
				
				local button = PlayerTalentFramePVPTalents.Talents['Tier'..a]['Talent'..t]
				
				PlayerTalentFramePVPTalents.Talents['Tier'..a]:StripTextures()
	
				button.highlight:SetParent(AleaUI.hidenframe)
				button.LeftCap:SetParent(AleaUI.hidenframe)
				button.RightCap:SetParent(AleaUI.hidenframe)			
				button.Cover:SetParent(AleaUI.hidenframe)
				
				button.Name:SetDrawLayer('ARTWORK', 5)
				
				button.Name:SetFont(default_font, Skins.default_font_size, 'NONE')
				button.Name:SetShadowOffset(1, -1)
				button.Name:SetShadowColor(0, 0, 0, 1)
		
				button.Icon:SetDrawLayer('ARTWORK', 5)
				button.Icon:SetTexCoord(unpack(AleaUI.media.texCoord))
				button.knownSelection:SetDrawLayer('ARTWORK', 4)
				button.knownSelection:SetColorTexture(0, 0.5, 0, 0.5)
				
				AleaUI:CreateBackdrop(button, button.Icon, { 0, 0, 0, 1 }, {0,0,0,0}, 'ARTWORK')
				button.Icon:SetUIBorderDrawLayer('ARTWORK', 5)
				button.Icon:SetUIBackgroundColor(0, 0, 0, 0)
				button.Icon:SetUIBackdropBorderColor(0, 0, 0, 1)
				
				AleaUI:CreateBackdrop(button, button.knownSelection, { 0, 0, 0, 1 }, {0,0,0,0}, 'ARTWORK')
			end
		end
		
		hooksecurefunc('PVPTalentFrame_Update', function()
			for t=1, 3 do
				for a=1, 6 do
					local button = PlayerTalentFramePVPTalents.Talents['Tier'..a]['Talent'..t]
			
					if button.knownSelection:IsShown() then
						button.knownSelection:SetUIBackdropBorderColor(0, 0, 0, 1)
					else
						button.knownSelection:SetUIBackdropBorderColor(0, 0, 0, 0)
					end
				end
			end
		end)
		]==]
	end)
end