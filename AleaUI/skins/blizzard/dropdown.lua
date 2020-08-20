local names = { 
	'DropDownList1MenuBackdrop', 'DropDownList2MenuBackdrop', 
	'DropDownList1Backdrop', 'DropDownList2Backdrop' 
}

DropDownList1MenuBackdrop:SetBackdrop({ 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
})
DropDownList1MenuBackdrop:SetBackdropColor(0.08,0.08,0.08,0.8)
DropDownList1MenuBackdrop:SetBackdropBorderColor(0,0,0,1)

DropDownList2MenuBackdrop:SetBackdrop({ 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
})
DropDownList2MenuBackdrop:SetBackdropColor(0.08,0.08,0.08,0.8)
DropDownList2MenuBackdrop:SetBackdropBorderColor(0,0,0,1)

DropDownList1Backdrop:SetBackdrop({ 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
})
DropDownList1Backdrop:SetBackdropColor(0.08,0.08,0.08,0.9)
DropDownList1Backdrop:SetBackdropBorderColor(0,0,0,1)

for i, name in pairs(names) do
	local f = _G[name]
	
	f:SetBackdrop({ 
		bgFile = [[Interface\Buttons\WHITE8x8]], 
		edgeFile =	[[Interface\Buttons\WHITE8x8]],
		edgeSize = 1,
	})
	f:SetBackdropColor(0.08,0.08,0.08,0.8)
	f:SetBackdropBorderColor(0,0,0,1)

	if f.Bg then f.Bg:SetAlpha(0) end
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
		
		f:SetBackdrop({ 
			bgFile = [[Interface\Buttons\WHITE8x8]], 
			edgeFile =	[[Interface\Buttons\WHITE8x8]],
			edgeSize = 1,
		})
		f:SetBackdropColor(0.08,0.08,0.08,0.8)
		f:SetBackdropBorderColor(0,0,0,1)

		if f.Bg then f.Bg:SetAlpha(0) end
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