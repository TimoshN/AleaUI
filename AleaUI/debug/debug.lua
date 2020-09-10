local addonName, E = ...
-- COMBO_POINTS_COST = "%d Combo |4Point:Points;";
do
	
	local function deepcopy(t)
		if type(t) ~= 'table' then return t end
		
		local mt = getmetatable(t)
		local res = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				v = deepcopy(v)
			end
			res[k] = v
		end
		setmetatable(res,mt)
		return res
	end
	
	E.deepcopy = deepcopy
end

do
	local _G = _G
	
	local function find_global_by_value(value)
	
		for key, val in pairs(_G) do
			
			if val == value then return key end
		
		end
	end
	
	E.FindGlobalByValue = find_global_by_value
end
	
do
	local dumpf = SlashCmdList["DUMP"]
	E.Dump = function(func, values)
		dumpf(func.."("..tostring(values)..")")
	end
end

do
	local debugparse
	local ts = tostring
	
	function debugparse(t, name, count)
		local countn =0
		if not count then
			countn = 0
		elseif count then
			countn = countn + 1
		end
		local tab = ""
		for i=1, countn do
			tab = tab.."   "
		end
		
		print(tab..ts(name).."={")
		for k,v in pairs(t) do
			if type(v) == "table" then
				debugparse(v, k, true)
			else
				print(tab.."    ["..ts(k).."] ="..ts(v))
			end
		end
			print(tab.."}")
		end
		
	E.Showtable = debugparse
end

do
	local GetSpellInfo = GetSpellInfo
	
	local unknownIcon = "\124TInterface\\Icons\\Inv_misc_questionmark:10\124t "..UNKNOWN
	
	local spellstringcache = {}

	function E:SpellString(spellid)
	
		if not spellid then 
			return unknownIcon	
		end
		
		if not spellstringcache[spellid] then
			local name, _, icon = GetSpellInfo(spellid)
			
			if not name then
				return unknownIcon	
			end
			
			spellstringcache[spellid] = "\124T"..icon..":10\124t "..name
		end
		
		return spellstringcache[spellid]
	end
end

do

	local movers = {}
	
	local buttons_name = { 'LEFT', 'UP', 'DOWN', 'RIGHT' }
	local buttons_move = { { -1, 0 } , { 0, 1 }, { 0, -1} , { 1, 0} }

	local function round(num)
		return floor(num+0.5)
	end
	
	local format = string.format
	local split = string.split

	local defaultposition = format('%s\031%s\031%s\031%d\031%d', "CENTER", "AleaUIParent", "CENTER", 0, 0)
	
	local function GetPoint(obj)
		local point, anchor, secondaryPoint, x, y = obj:GetPoint()
		if not anchor then anchor = AleaUIParent end

		return format('%s\031%s\031%s\031%d\031%d', point, anchor:GetName(), secondaryPoint, round(x), round(y))
	end

	
	local function SetFrameOptsCustom(name, point, anchor, secondaryPoint, x, y, handler)
		if not E.db.Frames then E.db.Frames = {} end
		if not E.db.Frames[name] then E.db.Frames[name] = {} end
		if not E.db.Frames[name].point then E.db.Frames[name].point = defaultposition end	
		if not anchor then anchor = AleaUIParent end
		
		E.db.Frames[name].point = format('%s\031%s\031%s\031%d\031%d', point, anchor.GetName and anchor:GetName() or anchor, secondaryPoint, round(x), round(y))
		
		if handler then 
			handler('SetFrameOpts', point, anchor.GetName and anchor:GetName() or anchor, secondaryPoint, round(x), round(y))
		end
	end
	
	
	E.SetFrameOptsCustom = SetFrameOptsCustom
	
	local function GetFrameOpts(name, handler)
		
		if not E.db.Frames then E.db.Frames = {} end
		if not E.db.Frames[name] then E.db.Frames[name] = {} end
		if not E.db.Frames[name].point then E.db.Frames[name].point = defaultposition end
		
		local point, anchor, secondaryPoint, x, y = split('\031', E.db.Frames[name].point)
		
		if handler then 
			handler('GetFrameOpts', point, anchor, secondaryPoint, x, y) 
		end
		
		return point, anchor, secondaryPoint, x, y
	end
	
	E.GetFrameOpts = GetFrameOpts
	
	
	local function UnpackFrameOpts(opts)
		opts = opts or defaultposition
		
		local point, anchor, secondaryPoint, x, y = split('\031', opts)
		
		return point, anchor, secondaryPoint, x, y
	end
	
	E.UnpackFrameOpts = UnpackFrameOpts
	
	local function SetFrameOpts(name, obj, handler)
		if not E.db.Frames then E.db.Frames = {} end
		if not E.db.Frames[name] then E.db.Frames[name] = {} end
		if not E.db.Frames[name].point then E.db.Frames[name].point = defaultposition end
		E.db.Frames[name].point = GetPoint(obj)
	
	end

	
	local function createbutton(parent, name)
		if not parent.buttons then parent.buttons = {} end
		
		local f = CreateFrame("Button", nil , parent, BackdropTemplateMixin and 'BackdropTemplate')
		f:SetFrameLevel(parent:GetFrameLevel() + 1)
		f.parent = parent
		f:SetText(name)
		f:SetWidth(20) --С€РёСЂРёРЅР°
		f:SetHeight(20) --РІС‹СЃРѕС‚Р°
		f:SetNormalFontObject("GameFontNormalSmall")
		f:SetHighlightFontObject("GameFontHighlightSmall")
		f:SetFrameStrata("HIGH")
		f:SetBackdrop({
			bgFile = [[Interface\Buttons\WHITE8x8]],
			edgeFile = [[Interface\Buttons\WHITE8x8]],
			edgeSize = 1,
			insets = {top = 0, left = 0, bottom = 0, right = 0},
		})
		f:SetBackdropColor(0,0,0,1)
		f:SetBackdropBorderColor(.3,.3,.3,1)
		
		f:SetScript("OnEnter", function(self)
			self:SetBackdropBorderColor(1,1,1,1) --С†РІРµС‚ РєСЂР°РµРІ
		end)
		f:SetScript("OnLeave", function(self)
			self:SetBackdropBorderColor(.3,.3,.3,1) --С†РІРµС‚ РєСЂР°РµРІ
		end)
			
		local t = f:GetFontString()
		t:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
		t:SetJustifyH("CENTER")
		t:SetJustifyV("CENTER")
		f.text = t
		
		f:SetScript("OnClick", function(self)
			
		--	print('T', 'OnClick', self.owner.handler, self.parent.handler)
		--	print('T', 'OnClick', self.owner.handler, self.parent.handler)
			
			if self.owner.opt then
				local point, anchor, secondaryPoint, x, y = GetFrameOpts(self.owner.opt, self.owner.handler)		
				SetFrameOptsCustom(self.owner.opt, point, anchor, secondaryPoint, x + buttons_move[self.i][1], y + buttons_move[self.i][2], self.owner.handler)
				self.owner.frame:ClearAllPoints()
				self.owner.frame:SetPoint(GetFrameOpts(self.owner.opt, self.owner.handler))	
			end
			
			for k,v in pairs(self.owner.editboxes) do
				v:UpdateText()					
			end
		end)
				
		return f
	end

	
	local function createeditboxe(parent)
		if not parent.editboxes then parent.editboxes = {} end
		local textbox = CreateFrame("EditBox", nil, parent, BackdropTemplateMixin and 'BackdropTemplate')
		textbox:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
		textbox:SetFrameLevel(parent:GetFrameLevel() + 1)
		textbox:SetAutoFocus(false)
		textbox:SetWidth(50)
		textbox:SetHeight(20)
		textbox:SetJustifyH("LEFT")
		textbox:SetJustifyV("CENTER")
		textbox:SetFrameStrata("HIGH")
		textbox:SetBackdrop({
			bgFile = [[Interface\Buttons\WHITE8x8]],
			edgeFile = [[Interface\Buttons\WHITE8x8]],
			edgeSize = 1,
			insets = {top = 0, left = 0, bottom = 0, right = 0},
		})
		textbox:SetBackdropColor(0,0,0,1)
		textbox:SetBackdropBorderColor(1,1,1,0.5)
		
		textbox.ok = createbutton(textbox, "OK")
		textbox.ok.editbox = textbox
		textbox.ok.text:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE")
		textbox.ok:SetSize(15,15)
		textbox.ok:SetPoint("RIGHT", textbox, "RIGHT", -2, 0)
		textbox.ok:Hide()
		
		textbox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
		end)
		textbox:SetScript("OnEnterPressed", function(self)
			self.ChangePosition(self.ok)
		end)
		
		textbox:SetScript("OnShow", function(self) self:UpdateText() end)
		
		textbox.ChangePosition = function(self)
			local num = tonumber(self.editbox:GetText())				
			if num then
				if self.editbox.owner.opt then
					
					
					local point, anchor, secondaryPoint, x, y = GetFrameOpts(self.editbox.owner.opt, self.editbox.owner.handler)	

					if self.editbox.i == 1 then
						x = num
					else
						y = num
					end
		
					SetFrameOptsCustom(self.editbox.owner.opt, point, anchor, secondaryPoint, x, y, self.editbox.owner.handler)
					
					self.editbox.owner.frame:ClearAllPoints()
					self.editbox.owner.frame:SetPoint(GetFrameOpts(self.editbox.owner.opt, self.editbox.owner.handler))

				end
			else
				self.editbox:UpdateText()
			end
			self:SetScript("OnClick", nil)
			self:Hide()
			
			self.editbox:ClearFocus()
		end
		
		textbox.UpdateText = function(self)
			if self.owner.opt then
				local point, anchor, secondaryPoint, x, y = GetFrameOpts(self.owner.opt, self.owner.handler)	
				
				if self.i == 1 then						
					self:SetText(x)
				else
					self:SetText(y)
				end
				
			end
		end
				
				
		return textbox
	end
	
	local mover_buttons = CreateFrame("Frame", nil, E.UIParent)
	mover_buttons:SetPoint("CENTER")
	mover_buttons:EnableMouse(true)
	mover_buttons:SetClampedToScreen(true)
	mover_buttons:SetSize(150,50)
	mover_buttons.buttons = {}
	mover_buttons.editboxes = {}
	mover_buttons:Hide()
	mover_buttons:SetFrameStrata("HIGH")
	
	for i=1,4 do				
		mover_buttons.buttons[i] = createbutton(mover_buttons, ' ')
		
		mover_buttons.buttons[i].icon = mover_buttons.buttons[i]:CreateTexture(nil, 'ARTWORK')
		mover_buttons.buttons[i].icon:SetSize(13, 13)
		mover_buttons.buttons[i].icon:SetPoint('CENTER')
		mover_buttons.buttons[i].icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
		mover_buttons.buttons[i].icon:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500)
		
		SquareButton_SetIcon(mover_buttons.buttons[i], buttons_name[i])
		
		mover_buttons.buttons[i]:SetScript('OnMouseDown', function(self)
			self.icon:SetPoint("CENTER", -1, -1);
		end)
		
		mover_buttons.buttons[i]:SetScript('OnMouseUp', function(self)
			self.icon:SetPoint("CENTER", 0, 0);
		end)
		
		
		mover_buttons.buttons[i].i = i
		mover_buttons.buttons[i].owner = mover_buttons
			
		if i == 1 then
			mover_buttons.buttons[i]:SetPoint("TOPRIGHT", mover_buttons, "TOP", 0, -3)
		elseif i == 2 then
			mover_buttons.buttons[i]:SetPoint("TOPRIGHT", mover_buttons, "TOP", -21, -3)
		elseif i == 3 then
			mover_buttons.buttons[i]:SetPoint("TOPLEFT", mover_buttons, "TOP", 0, -3)
		elseif i == 4 then
			mover_buttons.buttons[i]:SetPoint("TOPLEFT", mover_buttons, "TOP", 21, -3)
		end				
	end
	for i=1,2 do				
		mover_buttons.editboxes[i] = createeditboxe(mover_buttons)
		mover_buttons.editboxes[i].i = i
		mover_buttons.editboxes[i].owner = mover_buttons
		
		if i == 1 then
			mover_buttons.editboxes[i]:SetPoint("TOPRIGHT", mover_buttons, "TOP", -1, -30)
		else
			mover_buttons.editboxes[i]:SetPoint("TOPLEFT", mover_buttons, "TOP", 1, -30)
		end
		
		mover_buttons.editboxes[i]:SetScript("OnTextChanged", function(self, user)
			if user then
				self.ok:Show()
				
				self.ok:SetScript("OnClick", self.ChangePosition)
			end
		end)
		
		mover_buttons.editboxes[i]:UpdateText()
	end
	
	local function SetMoverButtons(self)

		if not mover_buttons:IsMouseOver() then
			mover_buttons.mover = self
			mover_buttons.frame = self.parent
			mover_buttons.opt = self.opt
			mover_buttons.handler = self.handler
			mover_buttons:ClearAllPoints()
			mover_buttons:SetParent(self)
			mover_buttons:SetPoint("TOP", self, "BOTTOM")
			mover_buttons:Show()
			
			for k,v in pairs(mover_buttons.editboxes) do
				v:UpdateText()					
			end
		end
	end

	local function MoverOnUpdate(self)
		local x, y = self.parent:GetCenter()
		local ux, uy = E.UIParent:GetCenter()
		local screenWidth, screenHeight = E.UIParent:GetRight(), E.UIParent:GetTop()
		
		
		local LEFT = screenWidth / 4
		local TOP = screenHeight / 4
		
		local xpos, ypos = 0, 0
		local point1, point2 =  "CENTER", ""
		local point3, point4 =  "CENTER", ""
	
		--[[
						|
						|
						|
						|
						|
						|
		  ----------------------------- OX
						|
						|
						|
						|
						|
						OY
		
		]]
	--	print("T1", LEFT, TOP)
		
		local rX, rY = round(x-ux), round(y-uy)
		
	--	print("T2", "rX", rX, "rY", rY)
	
		if rX < -LEFT then
			point1, point3 = "LEFT", "LEFT"			
		elseif rX > LEFT then
			point1, point3 = "RIGHT", "RIGHT"			
		end
		
		if rY < -TOP then
			point2, point4 = "BOTTOM", "BOTTOM"
			
			if point1 == "CENTER" then point1 = '' end
			if point3 == "CENTER" then point3 = '' end
			
		elseif rY > TOP then
			point2, point4 = "TOP", "TOP"
			
			if point1 == "CENTER" then point1 = '' end
			if point3 == "CENTER" then point3 = '' end
			
		end
		
		if point1 == "CENTER" then
			xpos, ypos = rX, rY
		else
			
			if point1 == "LEFT" then
				xpos = self.parent:GetLeft() - E.UIParent:GetLeft()
			elseif point1 == "RIGHT" then
				xpos = self.parent:GetRight() - E.UIParent:GetRight()
			else
				xpos = rX
			end
			
			if point2 == "TOP" then
				ypos = self.parent:GetTop() - E.UIParent:GetTop()
			elseif point2 == "BOTTOM" then
				ypos = self.parent:GetBottom() - E.UIParent:GetBottom()
			else
				ypos = rY
			end
		end
		
	--	print(point2..point1, E.UIParent, point4..point3, xpos, ypos)
		
		SetFrameOptsCustom(self.opt,  point2..point1, E.UIParent, point4..point3, xpos, ypos, self.handler)	
	end
	
	
	function E:Mover(frame, opt, width, height, point, handler)
	
		frame:ClearAllPoints()
		frame:SetPoint(GetFrameOpts(opt, handler))
		
		if movers[frame] then 
			movers[frame].opt = opt
			movers[frame].parent = frame
			movers[frame].handler = handler
			movers[frame].t:SetText(opt)
			return 
		end

		local _width, _height = frame:GetSize()
		
		local mover = CreateFrame("Frame", nil, E.UIParent, BackdropTemplateMixin and 'BackdropTemplate')
		mover.opt = opt
		mover.parent = frame
		mover.handler = handler
		mover:SetSize(10,10)
		mover:SetFrameStrata("TOOLTIP")
		mover:SetFrameLevel(frame:GetFrameLevel()+1)
		mover.buttons = {}
	
		if width or height or point then		
			mover:SetPoint(point or "TOPLEFT", frame,0,0)
			mover:SetSize(width or _width, height or _height)			
		else	
			mover:SetPoint("TOPLEFT", frame, "TOPLEFT",0,0)
			mover:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT",0,0)		
		end
		
		mover.t = mover:CreateFontString(nil, "OVERLAY", "GameFontNormal");

		mover.t:SetPoint("CENTER", mover, "CENTER", 0, 0)	
		mover.t:SetTextColor(1,1,1)
		mover.t:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
		mover.t:SetAlpha(1)
		mover.t:SetJustifyH("LEFT")
		mover.t:SetText(opt)
		
		mover:SetClampedToScreen(true)
		mover:EnableMouse(true)
		mover:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8x8]],})	
		mover:SetBackdropColor(0, 0, 0, 0.7)
		mover:SetMovable(false)
		mover:RegisterForDrag("LeftButton")
		mover:Hide()
		mover:SetScript("OnDragStart", function(self) 
			self.parent:StartMoving(); 		
			self:SetScript("OnUpdate", MoverOnUpdate)
		end)
		mover:SetScript("OnDragStop", function(self) 
			self.parent:StopMovingOrSizing()
			self:SetScript("OnUpdate", nil)

			for k,v in pairs(mover_buttons.editboxes) do
				v:UpdateText()					
			end
		end)
		
		mover:SetScript("OnEnter", SetMoverButtons)
		
		movers[frame] = mover
		
		return movers[frame]
	end
	
	
	SlashCmdList["AUIMOVEFRAMES"] = function()
		
		for k,v in pairs(movers) do
			
			if v and v:IsShown() then
				v:Hide()
				v.parent:SetMovable(false)
			else
				v:Show()
				v.parent:SetMovable(true)
			end
		end
	end
	
	function E:UnlockMover(opt)
		for k,v in pairs(movers) do		
			if v.opt == opt then
				if v and v:IsShown() then
					v:Hide()
					v.parent:SetMovable(false)
				else
					v:Show()
					v.parent:SetMovable(true)
				end
				break
			end
		end
	end
	
	function E:IsUnlocked(opt)
		for k,v in pairs(movers) do		
			if v.opt == opt then
				if v then
					return v:IsShown()
				end
				return false
			end
		end	
	end
	
	function E:UpdateAllMovers()
		for frame, mover in pairs(movers) do		
		
			frame:ClearAllPoints()
			frame:SetPoint(GetFrameOpts(mover.opt, mover.handler))
		end
	end
	
	
	SLASH_AUIMOVEFRAMES1 = "/moveframes"

end


do
	local SendChatMessage = SendChatMessage
	local IsInRaid, IsInGroup = IsInRaid, IsInGroup
	
	function E.Message(msg, chat)
		
		if chat == "RAID_WARNING" then
			SendChatMessage(msg, "RAID_WARNING")
		elseif chat == "PARTY" then
			SendChatMessage(msg, "PARTY")
		elseif chat == "GUILD" then
			SendChatMessage(msg, "GUILD")
		elseif chat == "PRINT" then
			print(msg)
		else
			local chatType = "PRINT"
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
				chatType = "INSTANCE_CHAT"
			elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
				chatType = "RAID"
			elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
				chatType = "PARTY"
			end
			
			if chatType == "PRINT" then
				print(msg)
			else
				SendChatMessage(msg, chatType)
			end
		end
	--	AddOn:print("Message", msg, chatType)
	end
end

do
	E.Serializer = {}
	
	local Serializer = E.Serializer
	
	-- Lua APIs
	local strbyte, strchar, gsub, gmatch, format = string.byte, string.char, string.gsub, string.gmatch, string.format
	local assert, error, pcall = assert, error, pcall
	local type, tostring, tonumber = type, tostring, tonumber
	local pairs, select, frexp = pairs, select, math.frexp
	local tconcat = table.concat
	local string_byte = string.byte
	local bit_band, bit_lshift, bit_rshift = bit.band, bit.lshift, bit.rshift
	local string_char, strsplit = string.char, strsplit
	
	local inf = math.huge

	local serNaN
	local serInf = tostring(inf)
	local serNegInf = tostring(-inf)

	local bytetoB64 = {
		[0]="a","b","c","d","e","f","g","h",
		"i","j","k","l","m","n","o","p",
		"q","r","s","t","u","v","w","x",
		"y","z","A","B","C","D","E","F",
		"G","H","I","J","K","L","M","N",
		"O","P","Q","R","S","T","U","V",
		"W","X","Y","Z","0","1","2","3",
		"4","5","6","7","8","9","(",")"
	}

	local B64tobyte = {
		  a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
		  i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
		  q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
		  y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
		  G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
		  O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
		  W = 48,  X = 49,  Y = 50,  Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
		["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
	}

	

	local encodeB64Table = {};

	function Serializer:encode(str)
		local B64 = encodeB64Table;
		local remainder = 0;
		local remainder_length = 0;
		local encoded_size = 0;
		local l=#str
		local code
		for i=1,l do
			code = string_byte(str, i);
			remainder = remainder + bit_lshift(code, remainder_length);
			remainder_length = remainder_length + 8;
			while(remainder_length) >= 6 do
				encoded_size = encoded_size + 1;
				B64[encoded_size] = bytetoB64[bit_band(remainder, 63)];
				remainder = bit_rshift(remainder, 6);
				remainder_length = remainder_length - 6;
			end
		end
		if remainder_length > 0 then
			encoded_size = encoded_size + 1;
			B64[encoded_size] = bytetoB64[remainder];
		end
		return tconcat(B64, "", 1, encoded_size)
	end

	local decodeB64Table = {}

	function Serializer:decode(str)
		local bit8 = decodeB64Table;
		local decoded_size = 0;
		local ch;
		local i = 1;
		local bitfield_len = 0;
		local bitfield = 0;
		local l = #str;
		while true do
			if bitfield_len >= 8 then
				decoded_size = decoded_size + 1;
				bit8[decoded_size] = string_char(bit_band(bitfield, 255));
				bitfield = bit_rshift(bitfield, 8);
				bitfield_len = bitfield_len - 8;
			end
			ch = B64tobyte[str:sub(i, i)];
			bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
			bitfield_len = bitfield_len + 6;
			if i > l then
				break;
			end
			i = i + 1;
		end
		return tconcat(bit8, "", 1, decoded_size)
	end

	local function SerializeStringHelper(ch)

		local n = strbyte(ch)
		if n==30 then
			return "\126\122"
		elseif n<=32 then
			return "\126"..strchar(n+64)
		elseif n==94 then
			return "\126\125"
		elseif n==126 then
			return "\126\124"
		elseif n==127 then
			return "\126\123"
		else
			assert(false)
		end
	end

	local function SerializeValue(v, res, nres)
		local t=type(v)
		
		if t=="string" then
			res[nres+1] = "^S"
			res[nres+2] = gsub(v,"[%c \94\126\127]", SerializeStringHelper)
			nres=nres+2
		
		elseif t=="number" then
			local str = tostring(v)
			if tonumber(str)==v or str==serInf or str==serNegInf then
				res[nres+1] = "^N"
				res[nres+2] = str
				nres=nres+2
			else
				local m,e = frexp(v)
				res[nres+1] = "^F"
				res[nres+2] = format("%.0f",m*2^53)
				res[nres+3] = "^f"
				res[nres+4] = tostring(e-53)
				nres=nres+4
			end
		
		elseif t=="table" then
			nres=nres+1
			res[nres] = "^T"
			for k,v in pairs(v) do
				nres = SerializeValue(k, res, nres)
				nres = SerializeValue(v, res, nres)
			end
			nres=nres+1
			res[nres] = "^t"
		
		elseif t=="boolean" then
			nres=nres+1
			if v then
				res[nres] = "^B"
			else
				res[nres] = "^b"
			end
		
		elseif t=="nil" then
			nres=nres+1
			res[nres] = "^Z"
		
		else
			error(MAJOR..": Cannot serialize a value of type '"..t.."'")
		end
		
		return nres
	end



	local serializeTbl = { "^1" }

	function Serializer:Serialize(...)
		local nres = 1
		
		for i=1,select("#", ...) do
			local v = select(i, ...)
			nres = SerializeValue(v, serializeTbl, nres)
		end
		
		serializeTbl[nres+1] = "^^"
		
		return tconcat(serializeTbl, "", 1, nres+1)
	end

	local function DeserializeStringHelper(escape)
		if escape<"~\122" then
			return strchar(strbyte(escape,2,2)-64)
		elseif escape=="~\122" then
			return "\030"
		elseif escape=="~\123" then
			return "\127"
		elseif escape=="~\124" then
			return "\126"
		elseif escape=="~\125" then
			return "\94"
		end
		error("DeserializeStringHelper got called for '"..escape.."'?!?")
	end

	local function DeserializeNumberHelper(number)
		if number == serNegInf then
			return -inf
		elseif number == serInf then
			return inf
		else
			return tonumber(number)
		end
	end

	local function DeserializeValue(iter,single,ctl,data)

		if not single then
			ctl,data = iter()
		end

		if not ctl then 
			error("Supplied data misses AceSerializer terminator ('^^')")
		end	

		if ctl=="^^" then
			return
		end

		local res
		
		if ctl=="^S" then
			res = gsub(data, "~.", DeserializeStringHelper)
		elseif ctl=="^N" then
			res = DeserializeNumberHelper(data)
			if not res then
				error("Invalid serialized number: '"..tostring(data).."'")
			end
		elseif ctl=="^F" then
			local ctl2,e = iter()
			if ctl2~="^f" then
				error("Invalid serialized floating-point number, expected '^f', not '"..tostring(ctl2).."'")
			end
			local m=tonumber(data)
			e=tonumber(e)
			if not (m and e) then
				error("Invalid serialized floating-point number, expected mantissa and exponent, got '"..tostring(m).."' and '"..tostring(e).."'")
			end
			res = m*(2^e)
		elseif ctl=="^B" then
			res = true
		elseif ctl=="^b" then
			res = false
		elseif ctl=="^Z" then
			res = nil
		elseif ctl=="^T" then
			res = {}
			local k,v
			while true do
				ctl,data = iter()
				if ctl=="^t" then break end
				k = DeserializeValue(iter,true,ctl,data)
				if k==nil then 
					error("Invalid AceSerializer table format (no table end marker)")
				end
				ctl,data = iter()
				v = DeserializeValue(iter,true,ctl,data)
				if v==nil then
					error("Invalid AceSerializer table format (no table end marker)")
				end
				res[k]=v
			end
		else
			error("Invalid AceSerializer control code '"..ctl.."'")
		end
		
		if not single then
			return res,DeserializeValue(iter)
		else
			return res
		end
	end

	function Serializer:Deserialize(str)
		str = gsub(str, "[%c ]", "")

		local iter = gmatch(str, "(^.)([^^]*)")
		local ctl,data = iter()
		if not ctl or ctl~="^1" then

			return false, "Supplied data is not AceSerializer data (rev 1)"
		end

		return pcall(DeserializeValue, iter)
	end
	
end

--[==[
do
	local syncer = CreateFrame('Frame')
	syncer:SetScript('OnEvent', function(self, event, ...)
		self[event](self, event, ...)
	end)
	
	local Serializer
	
	local compress = true
	
	E.Sync_Data = {}
	
		
	local handlers_OnInit = {}
	local handlers_PostInit = {}
	
	function E:RegisterInitAccountSync(func)
		handlers_OnInit[#handlers_OnInit+1] = func	
	end
	
	function E:RegisterPostAccountSync(func)
		handlers_PostInit[#handlers_PostInit+1] = func	
	end
	
	local function CheckInfoMacro()
		local name, texture, body = GetMacroInfo("AleaUI_Sync_Data")		
		if not name then				
			body = "0"
			CreateMacro("AleaUI_Sync_Data", "INV_MISC_QUESTIONMARK", body, false);
		end
		
		return body
	end
	
	local function ChangeMacro(id, data)		
		local index = GetMacroIndexByName("AleaUI_Sync_"..id)		
		if not index or index == 0 then
			CreateMacro("AleaUI_Sync_"..id, "INV_MISC_QUESTIONMARK",  data, false);
		else
			EditMacro(index, "AleaUI_Sync_"..id, "INV_MISC_QUESTIONMARK", data)
		end
	end
	
	local dataToSave = {}
	
	local maxLen = 250
	local function StoreData(dataString)
	
		local fullLen = dataString:len()
		local prevNum = CheckInfoMacro(); prevNum = tonumber(prevNum);
		
		local numMacros = ceil(fullLen/maxLen)
		
		for i=1, numMacros do
		   local from = (i-1)*maxLen
		   dataToSave[i] = string.sub(dataString, from+1, from+maxLen)
		end
		
		for i=1, #dataToSave do		
			ChangeMacro(i, dataToSave[i])	
		end

		EditMacro(GetMacroIndexByName("AleaUI_Sync_Data"), "AleaUI_Sync_Data", "INV_MISC_QUESTIONMARK", tostring(#dataToSave))
		
		for i=#dataToSave+1, prevNum do
			DeleteMacro("AleaUI_Sync_"..i)
		end
	end
	
	local function GetDataFromMacro()
		local prevNum = CheckInfoMacro(); prevNum = tonumber(prevNum);
		local finded = 0
		
		local strDate = ''
		
		for i=1, prevNum do
			
			local name, texture, body = GetMacroInfo("AleaUI_Sync_"..i)		
			if body then			
				finded = finded + 1

				strDate = strDate .. body:gsub('\n', '')
			end
		
		end
		
		if finded == prevNum  then
			
			for i=1, prevNum do
				DeleteMacro("AleaUI_Sync_"..i)
			end
		
			return strDate
		end
		
		for i=1, prevNum do
			DeleteMacro("AleaUI_Sync_"..i)
		end
			
		return false
	end
	
	function syncer:PLAYER_LOGIN()
		Serializer = E.Serializer
		
		local data = GetDataFromMacro()
		local final_data = nil

		if data then
			if compress then
				local data3 = data
				local data1, message = Serializer:decode(data3) -- libC:Decompress(data2)				
				if(not data1) then
					print("AleaUI: error decompressing: " .. message)
					return
				end			
				local done, final = Serializer:Deserialize(data1)			
				if (not done) then
					print("AleaUI: error deserializing " .. final)
					return
				end
				final_data = final				
			else
				local data1 = data				
				local done, final = Serializer:Deserialize(data1)			
				if (not done) then
					print("AleaUI: error deserializing " .. final)
					return
				end
				final_data = final
			end
		end
		
		E.Sync_Data = final_data or {}
		
	--	AleaUI.Showtable(E.Sync_Data, 'E.Sync_Data')
		
		for i=1, #handlers_OnInit do
			handlers_OnInit[i]()
		end
	end
	
	function syncer:PLAYER_LOGOUT()
		for i=1, #handlers_PostInit do
			handlers_PostInit[i]()
		end
		
		if compress then
		
			local data3 = Serializer:Serialize(E.Sync_Data)
			local data1 = Serializer:encode(data3)
			StoreData(data1)
		else
		
			local data3 = Serializer:Serialize(E.Sync_Data)
			StoreData(data3)
		end
	end

	syncer:RegisterEvent('PLAYER_LOGIN')
	syncer:RegisterEvent('PLAYER_LOGOUT')
end

do
	
	local dir = 'mpvar#111'
	local datas = {}
	local realm, player
	
	local syncer = CreateFrame('Frame')
	syncer:SetScript('OnEvent', function(self, event, ...)
		self[event](self, event, ...)
	end)
	
	local function SyncMasterPlan()
		if E.Sync_Data[dir] then
			
			
			datas = E.Sync_Data[dir]
			
			realm = realm or GetRealmName() or ''
			player = player or UnitName("player") or ''
			
			if datas[realm] and datas[realm][player] and MasterPlanA then
				MasterPlanA.data.lastCacheTime = datas[realm][player]
			end
		end

	end
	
	local function SaveMasterPlan()
	
		E.Sync_Data[dir] = datas
	end
	
	E:RegisterInitAccountSync(SyncMasterPlan)
	
	E:RegisterPostAccountSync(SaveMasterPlan)
	
	function syncer:SHOW_LOOT_TOAST(event, rt, rl, q, _4, _5, _6, source)
		if rt == "currency" and source == 10 and rl:match("currency:824") then
			
			realm = realm or GetRealmName() or ''
			player = player or UnitName("player") or ''
			
			datas[realm] = datas[realm] or {}
			datas[realm][player] = time()
			
			if MasterPlanA then
				MasterPlanA.data.lastCacheTime = time()
			end
		end
	end
	
	syncer:RegisterEvent('SHOW_LOOT_TOAST')
end
]==]
--[==[
local guidList = {}
local guidSort = {}

local function customSort(x,y)
   return x[1] < y[1]
end

local function RegisterGUIDIndex(guid)
   local numValues = select('#', strsplit('-', guid))
   
   local index = select(numValues, strsplit('-', guid))
   local id= select(numValues-1, strsplit('-', guid))
   
   local n1 = tonumber(index:sub(1, 2), 16)
   local n2 = tonumber(index:sub(3, 4), 16)
   local n3 = tonumber(index:sub(5, 6), 16)
   local n4 = tonumber(index:sub(7, 8), 16)
   local n5 = tonumber(index:sub(9,10), 16)
   
   guidSort[id] = guidSort[id] or {}
   if not guidList[guid] then     
      guidList[guid] = 0
      
      table.insert(guidSort[id], { n4+n5+(n3*0.0001)+(n2*0.1)+n1, guid })
      
      table.sort(guidSort[id], customSort)
      
      for i=1, #guidSort[id] do
         if guidSort[id][i][2] == guid then
            guidList[guid]= i
            break
         end        
      end     
   end
   
   return  guidList[guid]
end
]==]

do
	local aura_env = {}
	
	local tonumber = tonumber
	local function GuidToID(guid)	
		if not guid then 
			return 0 
		else
			local id = guid:match("[^%-]+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%w+")
			return tonumber(id or 0)
		end
	end
	
	function Test_MarkUnits(num)
		local list = {}
		
		for i=1, #aura_env.unitList do
			local unit = aura_env.unitList[i]
			
			local guid = UnitGUID(unit)
			local name = UnitName(unit)
			
			if guid and name == UnitName('target') then
				local index = aura_env.RegisterGUIDIndex(guid)
				list[#list+1] = unit
				print('AddToList', guid,index,unit)  
			end        
		end
		
		for i=1, #list do
			local unit = list[i]
			local guid = UnitGUID(unit)
			local name = UnitName(unit)
			local index = aura_env.RegisterGUIDIndex(guid)
			
			print(guid, unit, i, index)

			if index and index > 0 and index%num == 0  then
				if not (GetRaidTargetIndex(unit) == 1) then
					print("Marking "..guid.." ("..unit.."):"..index)
					SetRaidTarget(unit, 1)
				end
			end 
		end
	end
	
	local guidList = {}
	local guidSort = {}

	local function customSort(x,y)
		return x[1] < y[1]
	end

	local function RegisterGUIDIndex(guid)
		local numValues = select('#', strsplit('-', guid))
		
		local index = select(numValues, strsplit('-', guid))
		local id= select(numValues-1, strsplit('-', guid))
		
		local n1 = tonumber(index:sub(1, 2), 16)
		local n2 = tonumber(index:sub(3, 4), 16)
		local n3 = tonumber(index:sub(5, 6), 16)
		local n4 = tonumber(index:sub(7, 8), 16)
		local n5 = tonumber(index:sub(9,10), 16)
		
		if not n5 or not n4 or not n3 or not n2 or not n1 then
			return 0
		end
		
		guidSort[id] = guidSort[id] or {}
		if not guidList[guid] then     
			guidList[guid] = 0
			
			table.insert(guidSort[id], { n4+n5+(n3*0.0001)+(n2*0.1)+n1, guid })
			
			table.sort(guidSort[id], customSort)
			
			for i=1, #guidSort[id] do
				guidList[guidSort[id][i][2]] = i      
			end     
		end
		
		return guidList[guid]
	end

	aura_env.RegisterGUIDIndex = RegisterGUIDIndex

	aura_env.unitList =  {"target", "mouseover", "party1target", "party2target", "party3target", "party4target", "nameplate1", "nameplate2", "nameplate3", "nameplate4", "nameplate5", "nameplate6", "nameplate7", "nameplate8"}

end