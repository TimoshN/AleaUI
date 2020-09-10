local addOn, E = ...

local versionStr, internalVersion, dateofpatch, uiVersion = GetBuildInfo(); 
internalVersion = tonumber(internalVersion)

local uibuild = tonumber(uiVersion)

if ( uibuild > 20000 ) then return end 

E.UNIT_HEALTH_EVENT = 'UNIT_HEALTH_FREQUENT'

function E.GetCurrencyIcon(...)
    local result = C_CurrencyInfo.GetBasicCurrencyInfo(...)
    
    if not result then return end 

    return result.icon
end

function E.GetBackpackCurrencyInfo(...)
    return GetBackpackCurrencyInfo(...)
end

function E.UnitInPhase(...)
    return UnitInPhase(...)
end 