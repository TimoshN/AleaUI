local addonName, E = ...
local L = E.L

local ExtraAction_OnLoad = function(self)
	
	local ExtraActionBarHolder = CreateFrame('Frame', 'AleaUIExtraActionMover', E.UIParent)
	ExtraActionBarHolder:SetSize(ExtraActionBarFrame:GetSize())
	ExtraActionBarHolder:Show()
	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', ExtraActionBarHolder, 'CENTER')
	ExtraActionBarFrame.ignoreFramePositionManager  = true

	local ZoneAbilityHolder = CreateFrame('Frame', nil, E.UIParent)
	ZoneAbilityHolder:SetPoint('BOTTOM', ExtraActionBarFrame, 'TOP', 0, 2)
	ZoneAbilityHolder:SetSize(ExtraActionBarFrame:GetSize())
	ZoneAbilityHolder:Show()
	ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint('CENTER', ZoneAbilityHolder, 'CENTER', 0, 0)
	ZoneAbilityFrame.ignoreFramePositionManager = true

	function E:Extra_SetScale()
		local scale = E.db.Frames["extraActionFrame"].scale or 1

		if ExtraActionBarFrame then
			ExtraActionBarFrame:SetScale(scale)
			ExtraActionBarHolder:SetSize(ExtraActionBarFrame:GetWidth() * scale, ExtraActionBarFrame:GetWidth() * scale)
		end

		if ZoneAbilityFrame then
			ZoneAbilityFrame:SetScale(scale)
			ZoneAbilityHolder:SetSize(ZoneAbilityFrame:GetWidth() * scale, ZoneAbilityFrame:GetWidth() * scale)
		end
	end

	local Skins = E:Module("Skins")
	
	E:Mover(ExtraActionBarHolder, "extraActionFrame")
	E:Mover(ZoneAbilityHolder, "ZoneAbilityFrame")
	
	for i=1, 1 do --ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			--[==[
			button:StyleButton()
			
			Skins.SetTemplate(button, 'BORDERED')
			
			_G["ExtraActionButton"..i..'Icon']:SetDrawLayer('ARTWORK')
			local tex = button:CreateTexture(nil, 'OVERLAY')
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)
			
			button.icon:SetTexCoord(unpack(E.media.texCoord))
			]==]
			
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button.icon:SetDrawLayer('OVERLAY', 2)

			button.icon:SetAlpha(1)
			button.style:SetAlpha(1)
		--	button.icon:SetInside()
			button.NormalTexture:SetAlpha(0)

			E:SecureCreateBackdrop(button, button.icon, {}, {0,0,0,1}, { 0, 0, 0, 0}, 'OVERLAY'):SetUIBorderDrawLayer('OVERLAY', 5)

			button.HotKey:SetFont(E.media.default_font2, E.media.default_font_size2, 'NONE')
			
			--[==[
			local tex = button:CreateTexture(nil, 'OVERLAY')
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)

			local tex = button:CreateTexture(nil, 'OVERLAY')
			tex:SetColorTexture(1, 1, 1, 0.3)
			tex:SetInside()
			button:SetHighlightTexture(tex)
			]==]
			
			local tex = button:GetHighlightTexture()
			tex:SetColorTexture(1,1,1,0.3)
			tex:SetInside()
			
			local tex = button:GetCheckedTexture()
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			
			if(button.cooldown) then
				button.cooldown:SetInside()
				E:RegisterCooldown(button.cooldown)
			--	button.cooldown:HookScript("OnShow", FixExtraActionCD)
			end
		end
	end
	
	local button = ZoneAbilityFrame.SpellButton
	if button then
		button:SetNormalTexture('')
		button:StyleButton(false, false, true)
		Skins.SetTemplate(button, 'BORDERED')		
		button.Icon:SetDrawLayer('ARTWORK')
		button.Icon:SetTexCoord(unpack(E.media.texCoord))
		button.Icon:SetInside()

		if(button.Cooldown) then
			E:RegisterCooldown(button.Cooldown)
		end
	end
	
	if HasExtraActionBar() then
		ExtraActionBarFrame:Show();
	end
	
	E:Extra_SetScale()
	
	E.numActonBars = ( E.numActonBars or 0 ) + 1
	
	E.GUI.args.actionbars.args.extraActionFrame = {
		name = L["ExtraActionButton"],
		order = E.numActonBars,
		expand = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.actionbars.args.extraActionFrame.args.unlock = {
		name = L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("extraActionFrame") 
			E:UnlockMover('ZoneAbilityFrame')
		end,
		get = function(self)end
	}
	
	E.GUI.args.actionbars.args.extraActionFrame.args.scale = {
		name = L["Scale"],
		order = 4,
		type = "slider",
		min = 0.5, max = 3, step = 0.1,
		set = function(self, value)
			E.db.Frames["extraActionFrame"].scale = value
			E:Extra_SetScale()
		end,
		get = function(self) 
			return E.db.Frames["extraActionFrame"].scale or 1
		end
	}
end

if (not E.isClassic) then 
	E:OnInit2(ExtraAction_OnLoad)
end