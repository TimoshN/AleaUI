local addonName, E = ...
local Skins = E:Module("Skins")

local function SkinWeakAuras()

	if not IsAddOnLoaded('WeakAuras') then return end
	
	
	local function Skin_WeakAuras(frame, ftype)
		local backdrop = frame.Backdrop
		if not backdrop then

			frame.Backdrop = Skins.NewBackdrop(frame)
			Skins.SetTemplate(frame.Backdrop, 'BORDERED')
			frame.Backdrop:SetOutside(frame)
			
			backdrop = frame.Backdrop
			
			if ftype == 'icon' then
				frame.icon.OldAlpha = frame.icon.SetAlpha
				frame.icon.SetAlpha = function(self, ...)
					frame.icon.OldAlpha(self, ...)
					backdrop:SetAlpha(...)
				end
			
				E:RegisterCooldown(frame.cooldown)
			end
		end

		if ftype == 'aurabar' then
			if false then
				backdrop:Hide()
			else
				backdrop:Show()
			end
		end

		frame.icon:SetTexCoord(unpack(E.media.texCoord))
		frame.icon.SetTexCoord = function()end
	end
	
	local function Create_Icon(parent, data)
		local region = WeakAuras.regionTypes.icon.OldCreate(parent, data)
		Skin_WeakAuras(region, 'icon')
		
		return region
	end
	
	local function Create_Aurabar(parent)
		local region = WeakAuras.regionTypes.aurabar.OldCreate(parent)
		Skin_WeakAuras(region, 'aurabar')

		return region
	end

	local function Modify_Icon(parent, region, data)
		WeakAuras.regionTypes.icon.OldModify(parent, region, data)

		Skin_WeakAuras(region, 'icon')
	end
	
	local function Modify_Aurabar(parent, region, data)
		WeakAuras.regionTypes.aurabar.OldModify(parent, region, data)

		Skin_WeakAuras(region, 'aurabar')
	end
	
	WeakAuras.regionTypes.icon.OldCreate = WeakAuras.regionTypes.icon.create
	WeakAuras.regionTypes.icon.create = Create_Icon
	
	WeakAuras.regionTypes.aurabar.OldCreate = WeakAuras.regionTypes.aurabar.create
	WeakAuras.regionTypes.aurabar.create = Create_Aurabar
	
	WeakAuras.regionTypes.icon.OldModify = WeakAuras.regionTypes.icon.modify
	WeakAuras.regionTypes.icon.modify = Modify_Icon
	
	WeakAuras.regionTypes.aurabar.OldModify = WeakAuras.regionTypes.aurabar.modify
	WeakAuras.regionTypes.aurabar.modify = Modify_Aurabar
	
	for weakAura, _ in pairs(WeakAuras.regions) do
		if WeakAuras.regions[weakAura].regionType == 'icon'
		   or WeakAuras.regions[weakAura].regionType == 'aurabar' then
			Skin_WeakAuras(WeakAuras.regions[weakAura].region, WeakAuras.regions[weakAura].regionType)
		end
	end
end

E:OnInit(SkinWeakAuras)
