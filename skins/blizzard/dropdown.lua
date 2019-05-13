local names = { 'DropDownList1MenuBackdrop', 'DropDownList2MenuBackdrop', 'DropDownList1Backdrop' }

DropDownList1MenuBackdrop:SetBackdrop({ 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
	})
DropDownList1MenuBackdrop:SetBackdropColor(0.05,0.05,0.05,0.9)
DropDownList1MenuBackdrop:SetBackdropBorderColor(0,0,0,1)

DropDownList2MenuBackdrop:SetBackdrop({ 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
	})
DropDownList2MenuBackdrop:SetBackdropColor(0.05,0.05,0.05,0.9)
DropDownList2MenuBackdrop:SetBackdropBorderColor(0,0,0,1)

DropDownList1Backdrop:SetBackdrop({ 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
	})
DropDownList1Backdrop:SetBackdropColor(0.05,0.05,0.05,0.9)
DropDownList1Backdrop:SetBackdropBorderColor(0,0,0,1)

for i, name in pairs(names) do
	local f = _G[name]
	
	f:SetBackdrop({ 
		bgFile = [[Interface\Buttons\WHITE8x8]], 
		edgeFile =	[[Interface\Buttons\WHITE8x8]],
		edgeSize = 1,
	})
	f:SetBackdropColor(0.05,0.05,0.05,0.9)
	f:SetBackdropBorderColor(0,0,0,1)
end

if Lib_EasyMenu then	
	for i, name in pairs(names) do
		local f = _G['Lib_'..name]
		
		f:SetBackdrop({ 
			bgFile = [[Interface\Buttons\WHITE8x8]], 
			edgeFile =	[[Interface\Buttons\WHITE8x8]],
			edgeSize = 1,
		})
		f:SetBackdropColor(0.05,0.05,0.05,0.9)
		f:SetBackdropBorderColor(0,0,0,1)
	end
end