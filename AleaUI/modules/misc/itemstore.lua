local addonName, E = ...
local L = E.L

if ( E.isClassic ) then 
	return 
end

local IS = E:Module("ItemStore")

local bank_db, bags_db, reagent_db

local GetItemCount = GetItemCount

local ignoreItems = {
	[38682] = true,
	[113681] = true,
	[79249] = true,
	[118354] = true,
	[118897] = true,
	[122580] = true,
	[6948] = true,
	[110560] = true,
}
local ban = {
	[6948] = true,
	[110560] = true,
}

local trottle = CreateFrame("Frame")
trottle:Hide()
trottle.elapsed = 0		
trottle:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0		
		IS:UpdateItemStore(true)
	end
end)

local lastitemid = nil
local REAGENTBANK_CONTAINER = REAGENTBANK_CONTAINER
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

function IS:UpdateItemStore(force)
	if not force then
		trottle:Show()		
		return
	end
	
	trottle:Hide()
	
	if BankFrame:IsShown() then
		wipe(AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bank"])
	end
		
	wipe(AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["reagent"])

	
	wipe(AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bags"])

	bank_db = AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bank"]
	bags_db = AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bags"]
	reagent_db = AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["reagent"]
	
	
	for i=-1, NUM_CONTAINER_FRAMES, 1 do
	
		for slot=1, GetContainerNumSlots(i), 1 do
			local texture, count, locked, quality, readable, lootable, link, isFiltered = GetContainerItemInfo(i, slot)
			local itemId = GetContainerItemID(i, slot);

			if itemId and not ignoreItems[itemId] then
			
				if i == -1 or i > 4 then 
					if BankFrame:IsShown() then
						bank_db[itemId] = ( bank_db[itemId] or 0 ) + count
					end
				else	
					bags_db[itemId] = ( bags_db[itemId] or 0 ) + count 
				end
			end
		end
	end
	
	for slot=1, GetContainerNumSlots(REAGENTBANK_CONTAINER), 1 do
		local texture, count, locked, quality, readable, lootable, link, isFiltered = GetContainerItemInfo(REAGENTBANK_CONTAINER, slot)
		local itemId = GetContainerItemID(REAGENTBANK_CONTAINER, slot);

		if itemId and not ignoreItems[itemId] then
			reagent_db[itemId] = ( reagent_db[itemId] or 0 ) + count 
		end
	end

	lastitemid = nil
--	print("IS:UpdateItemStore")
end

local ex_servers_db = {}
local my_server_db = {}
local ex_servers = ""
local my_servers = ""
local inbags, inbank, inreagent
local ex_server_total
local my_server_total

function IS:SearchItem(itemID, tooltip)
	if ban[itemID] then return end
	if ignoreItems[itemID] then return end
	
	if lastitemid ~= itemID then
		lastitemid = itemID
	
		wipe(ex_servers_db)
		wipe(my_server_db)
		
		inbank = nil
		inbags = nil
		inreagent = nil
		
		for server,server_data in pairs(AleaUIDB.itemStore) do
			for name, name_data in pairs(server_data) do

				for itemid, count in pairs(name_data.bank) do
					
				
					if itemid == itemID then
					
						if server ~= GetRealmName() then 				
							ex_servers_db[server] = ( ex_servers_db[server] or 0 ) + 1
						end
						
						if server == GetRealmName() then
							 
							if name == UnitName("player") then
								inbank = ( inbank or 0 ) + count
							else
								my_server_db[name] = ( my_server_db[name] or 0 ) + count
							end
						end
					end
					
				end
				if name_data.bags then
					for itemid, count in pairs(name_data.bags) do
						
						if itemid == itemID then

							if server ~= GetRealmName() then 				
								ex_servers_db[server] = ( ex_servers_db[server] or 0 ) + 1
							end
							
							if server == GetRealmName() then
								if name == UnitName("player") then
									inbags = ( inbags or 0 ) + count
								else
									my_server_db[name] = ( my_server_db[name] or 0 ) + count
								end
							end
						
						end
				
					end
				end
				
				if name_data.reagent then
					for itemid, count in pairs(name_data.reagent) do
						
						if itemid == itemID then

							if server ~= GetRealmName() then 				
								ex_servers_db[server] = ( ex_servers_db[server] or 0 ) + 1
							end
							
							if server == GetRealmName() then
								if name == UnitName("player") then
									inreagent = ( inreagent or 0 ) + count
								else
									my_server_db[name] = ( my_server_db[name] or 0 ) + count
								end
							end
						
						end
				
					end
				end
				
				ex_server_total = 0
				ex_servers = ""
				
				for servers, totalnumber in pairs(ex_servers_db) do
					ex_server_total = ex_server_total + 1
					
					if ex_server_total == 1 then
						ex_servers = ex_servers .. format("%s(%d)", servers, totalnumber)
					elseif ex_server_total%4 == 0 then
						ex_servers = ex_servers .. format(",\n    %s(%d)", servers, totalnumber)
					else
						ex_servers = ex_servers .. format(", %s(%d)", servers, totalnumber)
					end
					
				end
				
				my_server_total = 0
				my_servers = ""
				
				for name1, amount in pairs(my_server_db) do
					my_server_total = my_server_total + 1
					
					if my_server_total == 1 then
						my_servers = my_servers .. format("%s(%d)", name1, amount)
					elseif my_server_total%4 == 0 then						
						my_servers = my_servers .. format(",\n    %s(%d)", name1, amount)
					else
						my_servers = my_servers .. format(", %s(%d)", name1, amount)
					end
			
				end
			end
		end
	end
			
	if inbags then
		tooltip:AddLine((L["|cFFFFFFFFBags:%d"]):format(inbags))				
	end
	if inbank then
		tooltip:AddLine((L["|cFFFFFFFFBank:%d"]):format(inbank))
	end
	if inreagent then
		tooltip:AddLine((L["|cFFFFFFFFReagents:%d"]):format(inreagent))
	end
	
	if my_server_total > 0 then
		tooltip:AddLine((L["|cFFFFFFFFServer:%s"]):format(my_servers))				
	end	
	if ex_server_total > 0 then				
		tooltip:AddLine((L["|cFFFFFFFFMore: %s"]):format(ex_servers))
	end
	
	return ex_server_total, ex_servers, inbags, inbank
end



IS:RegisterEvent("BAG_UPDATE")
IS:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
IS:RegisterEvent("BANKFRAME_OPENED")
if ( not E.isClassic ) then 
IS:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
end 

function IS:BAG_UPDATE()
	IS:UpdateItemStore(force)
end

IS.PLAYERBANKSLOTS_CHANGED = IS.BAG_UPDATE
IS.BANKFRAME_OPENED = IS.BAG_UPDATE
IS.PLAYERREAGENTBANKSLOTS_CHANGED = IS.BAG_UPDATE

local function IS_Init()

	
	if not AleaUIDB then AleaUIDB = {} end
	if not AleaUIDB.itemStore then AleaUIDB.itemStore = {} end
	if not AleaUIDB.itemStore[GetRealmName()] then AleaUIDB.itemStore[GetRealmName()] = {} end
	if not AleaUIDB.itemStore[GetRealmName()][UnitName("player")] then AleaUIDB.itemStore[GetRealmName()][UnitName("player")] = {} end
	if not AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bank"] then AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bank"] = {} end
	if not AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bags"] then AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bags"] = {} end
	if not AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["reagent"] then AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["reagent"] = {} end
	
	bank_db = AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bank"]
	bags_db = AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["bags"]
	reagent_db = AleaUIDB.itemStore[GetRealmName()][UnitName("player")]["reagent"]
	
	IS:UpdateItemStore()
end


E:OnInit2(IS_Init)