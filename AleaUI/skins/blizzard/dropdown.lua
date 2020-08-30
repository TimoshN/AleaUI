local addonName, E = ...
local Skins = E:Module("Skins")

local varName = 'dropdowns'
E.default_settings.skins[varName] = true

local function Skin_DropDowns() 
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	local names = { 
		'DropDownList1MenuBackdrop', 'DropDownList2MenuBackdrop', 
		'DropDownList1Backdrop', 'DropDownList2Backdrop' 
	}

	for i, name in pairs(names) do
		local f = _G[name]
		
		if (f.SetBackdrop) then
			f:SetBackdrop({ 
				bgFile = [[Interface\Buttons\WHITE8x8]], 
				edgeFile =	[[Interface\Buttons\WHITE8x8]],
				edgeSize = 1,
			})
			f:SetBackdropColor(0,0,0,0)
			f:SetBackdropBorderColor(0,0,0,0)
		end 

		E:CreateBackdrop(f, f, {0,0,0,1}, {0.08,0.08,0.08,0.8}, 'ARTWORK', 1, 0)

		if f.Bg then f.Bg:SetAlpha(0) end
		if f.Center then f.Center:SetAlpha(0) end
		if f.RightEdge then f.RightEdge:SetAlpha(0) end
		if f.TopEdge then f.TopEdge:SetAlpha(0) end
		if f.LeftEdge then f.LeftEdge:SetAlpha(0) end
		if f.BottomEdge then f.BottomEdge:SetAlpha(0) end
	
		if f.TopLeftCorner then f.TopLeftCorner:SetAlpha(0) end
		if f.TopRightCorner then f.TopRightCorner:SetAlpha(0) end
	
		if f.BottomLeftCorner then f.BottomLeftCorner:SetAlpha(0) end
		if f.BottomRightCorner then f.BottomRightCorner:SetAlpha(0) end
	end
	
	if Lib_EasyMenu then	
		for i, name in pairs(names) do
			local f = _G['Lib_'..name]

			if (f.SetBackdrop) then
				f:SetBackdrop({ 
					bgFile = [[Interface\Buttons\WHITE8x8]], 
					edgeFile =	[[Interface\Buttons\WHITE8x8]],
					edgeSize = 1,
				})
				f:SetBackdropColor(0,0,0,0)
				f:SetBackdropBorderColor(0,0,0,0)
			end 
			
			E:CreateBackdrop(f, f, {0,0,0,1}, {0.08,0.08,0.08,0.8}, 'ARTWORK', 1, 0)

			if f.Bg then f.Bg:SetAlpha(0) end
			if f.Center then f.Center:SetAlpha(0) end
			if f.RightEdge then f.RightEdge:SetAlpha(0) end
			if f.TopEdge then f.TopEdge:SetAlpha(0) end
			if f.LeftEdge then f.LeftEdge:SetAlpha(0) end
			if f.BottomEdge then f.BottomEdge:SetAlpha(0) end
	
			if f.TopLeftCorner then f.TopLeftCorner:SetAlpha(0) end
			if f.TopRightCorner then f.TopRightCorner:SetAlpha(0) end
	
			if f.BottomLeftCorner then f.BottomLeftCorner:SetAlpha(0) end
			if f.BottomRightCorner then f.BottomRightCorner:SetAlpha(0) end
		end
	end	
end

E:OnInit2(Skin_DropDowns)