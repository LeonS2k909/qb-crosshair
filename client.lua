local QBCore = exports['qb-core']:GetCoreObject()

-- KVP keys
local KVP_TYPE        = "qb_crosshair_type"        -- "modern" | "classic" | "custom" | "none"
local KVP_ENABLED     = "qb_crosshair_enabled"     -- "true" | "false"
local KVP_CUSTOM      = "qb_crosshair_custom"      -- json cfg
local KVP_HITCFG      = "qb_crosshair_hit_cfg"     -- json cfg for global hit marker

-- State
local crosshairType    = GetResourceKvpString(KVP_TYPE) or "modern"
local crosshairEnabled = (GetResourceKvpString(KVP_ENABLED) or "true") == "true"
local lastActive = false

-- Utils
local function clamp(v, a, b) return math.min(math.max(v, a), b) end
local function deepcopy(t) if type(t)~="table" then return t end local r={} for k,v in pairs(t) do r[k]=deepcopy(v) end return r end

-- Default custom crosshair cfg
local defaultCustom = {
    color = { r = 60, g = 255, b = 122 },
    alpha = 1.0,
    thickness = 2,
    size = 10,
    gap = 6,
    dot = true,
    tstyle = false,
    outline = true,
    outlineThickness = 2,
    outlineAlpha = 0.8,
    dynamicMove = true,
    dynamicFire = true,
    moveInfluence = 0.6,
    fireInfluence = 0.6
}

-- Default global hit marker cfg
-- style: "none" | "flash" | "x" | "ring" | "dot" | "diamond"
local defaultHit = {
    style = "flash",
    color = { r = 60, g = 255, b = 122 },
    alpha = 1.0,
    thickness = 3,
    size = 32,
    outline = true,
    outlineThickness = 2,
    outlineAlpha = 0.8,
    duration = 420
}

-- Loaders
local function loadCustom()
    local raw = GetResourceKvpString(KVP_CUSTOM)
    if raw and raw ~= "" then
        local ok, cfg = pcall(json.decode, raw)
        if ok and type(cfg) == "table" then
            cfg.color = cfg.color or {}
            cfg.color.r = clamp(tonumber(cfg.color.r or defaultCustom.color.r) or defaultCustom.color.r, 0, 255)
            cfg.color.g = clamp(tonumber(cfg.color.g or defaultCustom.color.g) or defaultCustom.color.g, 0, 255)
            cfg.color.b = clamp(tonumber(cfg.color.b or defaultCustom.color.b) or defaultCustom.color.b, 0, 255)
            cfg.alpha = clamp(tonumber(cfg.alpha or defaultCustom.alpha) or defaultCustom.alpha, 0.0, 1.0)
            cfg.thickness = math.floor(clamp(tonumber(cfg.thickness or defaultCustom.thickness) or defaultCustom.thickness, 1, 12))
            cfg.size = math.floor(clamp(tonumber(cfg.size or defaultCustom.size) or defaultCustom.size, 2, 64))
            cfg.gap = math.floor(clamp(tonumber(cfg.gap or defaultCustom.gap) or defaultCustom.gap, 0, 48))
            cfg.dot = cfg.dot ~= false
            cfg.tstyle = cfg.tstyle == true
            cfg.outline = cfg.outline ~= false
            cfg.outlineThickness = math.floor(clamp(tonumber(cfg.outlineThickness or defaultCustom.outlineThickness) or defaultCustom.outlineThickness, 0, 8))
            cfg.outlineAlpha = clamp(tonumber(cfg.outlineAlpha or defaultCustom.outlineAlpha) or defaultCustom.outlineAlpha, 0.0, 1.0)
            cfg.dynamicMove = cfg.dynamicMove ~= false
            cfg.dynamicFire = cfg.dynamicFire ~= false
            cfg.moveInfluence = clamp(tonumber(cfg.moveInfluence or defaultCustom.moveInfluence) or defaultCustom.moveInfluence, 0.0, 1.0)
            cfg.fireInfluence = clamp(tonumber(cfg.fireInfluence or defaultCustom.fireInfluence) or defaultCustom.fireInfluence, 0.0, 1.0)
            return cfg
        end
    end
    return deepcopy(defaultCustom)
end

local function loadHit()
    local raw = GetResourceKvpString(KVP_HITCFG)
    if raw and raw ~= "" then
        local ok, cfg = pcall(json.decode, raw)
        if ok and type(cfg) == "table" then
            cfg.style = tostring(cfg.style or defaultHit.style)
            if cfg.style ~= "none" and cfg.style ~= "flash" and cfg.style ~= "x" and cfg.style ~= "ring" and cfg.style ~= "dot" and cfg.style ~= "diamond" then
                cfg.style = defaultHit.style
            end
            cfg.color = cfg.color or {}
            cfg.color.r = clamp(tonumber(cfg.color.r or defaultHit.color.r) or defaultHit.color.r, 0, 255)
            cfg.color.g = clamp(tonumber(cfg.color.g or defaultHit.color.g) or defaultHit.color.g, 0, 255)
            cfg.color.b = clamp(tonumber(cfg.color.b or defaultHit.color.b) or defaultHit.color.b, 0, 255)
            cfg.alpha = clamp(tonumber(cfg.alpha or defaultHit.alpha) or defaultHit.alpha, 0.0, 1.0)
            cfg.thickness = math.floor(clamp(tonumber(cfg.thickness or defaultHit.thickness) or defaultHit.thickness, 1, 16))
            cfg.size = math.floor(clamp(tonumber(cfg.size or defaultHit.size) or defaultHit.size, 6, 120))
            cfg.outline = cfg.outline ~= false
            cfg.outlineThickness = math.floor(clamp(tonumber(cfg.outlineThickness or defaultHit.outlineThickness) or defaultHit.outlineThickness, 0, 8))
            cfg.outlineAlpha = clamp(tonumber(cfg.outlineAlpha or defaultHit.outlineAlpha) or defaultHit.outlineAlpha, 0.0, 1.0)
            cfg.duration = math.floor(clamp(tonumber(cfg.duration or defaultHit.duration) or defaultHit.duration, 120, 1200))
            return cfg
        end
    end
    return deepcopy(defaultHit)
end

local customCfg = loadCustom()
local hitCfg = loadHit()

-- Savers
local function saveCustom() SetResourceKvp(KVP_CUSTOM, json.encode(customCfg)) end
local function saveHit() SetResourceKvp(KVP_HITCFG, json.encode(hitCfg)) end

-- Push to NUI
local function pushCoreState()
    SendNUIMessage({ action = "setActive", active = false })
    SendNUIMessage({ action = "setEnabled", enabled = crosshairEnabled })
    SendNUIMessage({ action = "setCrosshair", ctype = crosshairType })
    SendNUIMessage({ action = "setCustom", cfg = customCfg })
    SendNUIMessage({ action = "setHitOptions", cfg = hitCfg })
    SendNUIMessage({ action = "hidePopup" })
end

local function setEnabled(flag)
    crosshairEnabled = flag and true or false
    SetResourceKvp(KVP_ENABLED, crosshairEnabled and "true" or "false")
    SendNUIMessage({ action = "setEnabled", enabled = crosshairEnabled })
    if not crosshairEnabled then
        lastActive = false
        SendNUIMessage({ action = "setActive", active = false })
    end
end

local function setType(t)
    if t == "modern" or t == "classic" or t == "custom" or t == "none" then
        crosshairType = t
        SetResourceKvp(KVP_TYPE, crosshairType)
        SendNUIMessage({ action = "setCrosshair", ctype = crosshairType })
        QBCore.Functions.Notify("Crosshair set to "..t, "success")
    end
end

-- Init
CreateThread(function()
    Wait(200)
    SetNuiFocus(false, false)
    pushCoreState()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    pushCoreState()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SetNuiFocus(false, false)
    pushCoreState()
end)

-- Visibility gate
CreateThread(function()
    local unarmed = joaat("WEAPON_UNARMED")
    while true do
        Wait(120)
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        local armed = weapon ~= 0 and weapon ~= unarmed
        local inVeh = IsPedInAnyVehicle(ped, false)
        local paused = IsPauseMenuActive()
        local aiming = IsPlayerFreeAiming(PlayerId()) or IsAimCamActive()
        local shouldShow = dbgForce or (crosshairEnabled and aiming and armed and not inVeh and not paused and crosshairType ~= "none")
        if shouldShow ~= lastActive then
            lastActive = shouldShow
            SendNUIMessage({ action = "setActive", active = shouldShow })
        end
    end
end)

-- Send a hit pulse to NUI
local function pulseHit()
    -- config is already pushed separately; keep the hit message tiny for spam safety
    SendNUIMessage({ action = "playHitMarker" })
end

-- Game event hit detection (players + NPCs). Triggers for most bullets.
AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    local victim = args[1]
    local attacker = args[2]
    if attacker ~= PlayerPedId() then return end
    if not DoesEntityExist(victim) then return end
    if victim == PlayerPedId() then return end
    if not IsEntityAPed(victim) then return end
    pulseHit()
end)

-- High-rate fallback based on impact point to cover spray scenarios and non-networked peds.
CreateThread(function()
    local lastTick = 0
    local lastImpact = vector3(0.0, 0.0, 0.0)
    while true do
        Wait(0)
        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then goto continue end
        if not IsPedShooting(ped) then goto continue end

        local ok, impact = GetPedLastWeaponImpactCoord(ped)
        if ok then
            local now = GetGameTimer()
            -- de-duplicate very dense events at the exact same point
            if (now - lastTick) > 25 or #(impact - lastImpact) > 0.05 then
                -- ray from camera to impact to resolve entity hit (peds only)
                local cam = GetGameplayCamCoord()
                local handle = StartShapeTestRay(cam.x, cam.y, cam.z, impact.x, impact.y, impact.z, 4, ped, 0) -- 4 = peds
                local _, hit, _, _, ent = GetShapeTestResult(handle)
                if hit == 1 and ent ~= 0 and DoesEntityExist(ent) and IsEntityAPed(ent) and ent ~= ped then
                    pulseHit()
                    lastTick = now
                    lastImpact = impact
                end
            end
        end
        ::continue::
    end
end)

-- Dynamic factor for custom crosshair
CreateThread(function()
    local lastFactor = -1.0
    local shootPulse = 0.0
    while true do
        local sleep = 200
        if lastActive and crosshairType == "custom" then
            sleep = 0
            local ped = PlayerPedId()
            local moveFactor = 0.0
            if customCfg.dynamicMove then
                local speed = GetEntitySpeed(ped)
                moveFactor = clamp(speed / 6.0, 0.0, 1.0) * (customCfg.moveInfluence or 0.0)
            end
            if IsPedShooting(ped) and customCfg.dynamicFire then
                shootPulse = 1.0
            else
                shootPulse = shootPulse * 0.88
            end
            local fireFactor = shootPulse * (customCfg.fireInfluence or 0.0)
            local factor = math.max(moveFactor, fireFactor)
            if math.abs(factor - lastFactor) > 0.02 then
                lastFactor = factor
                SendNUIMessage({ action = "dynamic", factor = factor })
            end
        end
        Wait(sleep)
    end
end)

-- Command to open popup (default to Crosshair tab)
RegisterCommand("crosshair", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openPopup",
        current = crosshairType,
        enabled = crosshairEnabled,
        cfg = customCfg,
        hit = hitCfg,
        defaultTab = "crosshair"
    })
end)

-- NUI callbacks
RegisterNUICallback("selectCrosshair", function(data, cb)
    if data and data.ctype then setType(string.lower(data.ctype)) end
    cb({ ok = true })
end)

RegisterNUICallback("toggleEnabled", function(data, cb)
    setEnabled(data and data.enabled)
    cb({ ok = true })
end)

RegisterNUICallback("updateCustom", function(data, cb)
    if type(data) == "table" then
        local c = customCfg
        if data.color then
            c.color.r = clamp(tonumber(data.color.r or c.color.r) or c.color.r, 0, 255)
            c.color.g = clamp(tonumber(data.color.g or c.color.g) or c.color.g, 0, 255)
            c.color.b = clamp(tonumber(data.color.b or c.color.b) or c.color.b, 0, 255)
        end
        if data.alpha ~= nil then c.alpha = clamp(tonumber(data.alpha) or c.alpha, 0.0, 1.0) end
        if data.thickness ~= nil then c.thickness = math.floor(clamp(tonumber(data.thickness) or c.thickness, 1, 12)) end
        if data.size ~= nil then c.size = math.floor(clamp(tonumber(data.size) or c.size, 2, 64)) end
        if data.gap ~= nil then c.gap = math.floor(clamp(tonumber(data.gap) or c.gap, 0, 48)) end
        if data.dot ~= nil then c.dot = data.dot and true or false end
        if data.tstyle ~= nil then c.tstyle = data.tstyle and true or false end
        if data.outline ~= nil then c.outline = data.outline and true or false end
        if data.outlineThickness ~= nil then c.outlineThickness = math.floor(clamp(tonumber(data.outlineThickness) or c.outlineThickness, 0, 8)) end
        if data.outlineAlpha ~= nil then c.outlineAlpha = clamp(tonumber(data.outlineAlpha) or c.outlineAlpha, 0.0, 1.0) end
        if data.dynamicMove ~= nil then c.dynamicMove = data.dynamicMove and true or false end
        if data.dynamicFire ~= nil then c.dynamicFire = data.dynamicFire and true or false end
        if data.moveInfluence ~= nil then c.moveInfluence = clamp(tonumber(data.moveInfluence) or c.moveInfluence, 0.0, 1.0) end
        if data.fireInfluence ~= nil then c.fireInfluence = clamp(tonumber(data.fireInfluence) or c.fireInfluence, 0.0, 1.0) end
        saveCustom()
        SendNUIMessage({ action = "setCustom", cfg = customCfg })
    end
    cb({ ok = true })
end)

RegisterNUICallback("resetCustom", function(_, cb)
    customCfg = deepcopy(defaultCustom)
    saveCustom()
    SendNUIMessage({ action = "setCustom", cfg = customCfg })
    cb({ ok = true })
end)

RegisterNUICallback("setHitStyle", function(data, cb)
    if type(data) == "table" and data.style then
        local s = tostring(data.style)
        if s == "none" or s == "flash" or s == "x" or s == "ring" or s == "dot" or s == "diamond" then
            hitCfg.style = s
            saveHit()
            SendNUIMessage({ action = "setHitOptions", cfg = hitCfg })
        end
    end
    cb({ ok = true })
end)

RegisterNUICallback("setHitColor", function(data, cb)
    if type(data) == "table" and data.color then
        hitCfg.color.r = clamp(tonumber(data.color.r or hitCfg.color.r) or hitCfg.color.r, 0, 255)
        hitCfg.color.g = clamp(tonumber(data.color.g or hitCfg.color.g) or hitCfg.color.g, 0, 255)
        hitCfg.color.b = clamp(tonumber(data.color.b or hitCfg.color.b) or hitCfg.color.b, 0, 255)
        saveHit()
        SendNUIMessage({ action = "setHitOptions", cfg = hitCfg })
    end
    cb({ ok = true })
end)

RegisterNUICallback("updateHit", function(data, cb)
    if type(data) == "table" then
        if data.style then
            local s = tostring(data.style)
            if s == "none" or s == "flash" or s == "x" or s == "ring" or s == "dot" or s == "diamond" then
                hitCfg.style = s
            end
        end
        if data.color then
            hitCfg.color.r = clamp(tonumber(data.color.r or hitCfg.color.r) or hitCfg.color.r, 0, 255)
            hitCfg.color.g = clamp(tonumber(data.color.g or hitCfg.color.g) or hitCfg.color.g, 0, 255)
            hitCfg.color.b = clamp(tonumber(data.color.b or hitCfg.color.b) or hitCfg.color.b, 0, 255)
        end
        if data.alpha ~= nil then hitCfg.alpha = clamp(tonumber(data.alpha) or hitCfg.alpha, 0.0, 1.0) end
        if data.thickness ~= nil then hitCfg.thickness = math.floor(clamp(tonumber(data.thickness) or hitCfg.thickness, 1, 16)) end
        if data.size ~= nil then hitCfg.size = math.floor(clamp(tonumber(data.size) or hitCfg.size, 6, 120)) end
        if data.outline ~= nil then hitCfg.outline = data.outline and true or false end
        if data.outlineThickness ~= nil then hitCfg.outlineThickness = math.floor(clamp(tonumber(data.outlineThickness) or hitCfg.outlineThickness, 0, 8)) end
        if data.outlineAlpha ~= nil then hitCfg.outlineAlpha = clamp(tonumber(data.outlineAlpha) or hitCfg.outlineAlpha, 0.0, 1.0) end
        if data.duration ~= nil then hitCfg.duration = math.floor(clamp(tonumber(data.duration) or hitCfg.duration, 120, 1200)) end
        saveHit()
        SendNUIMessage({ action = "setHitOptions", cfg = hitCfg })
    end
    cb({ ok = true })
end)

RegisterNUICallback("closePopup", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "hidePopup" })
    cb({ ok = true })
end)

-- toggleable debug
local dbgForce = false

RegisterCommand("crosshairdebug", function()
    dbgForce = not dbgForce
    if dbgForce then
        setEnabled(true)
        setType("modern")
        lastActive = true
        SendNUIMessage({ action = "setActive", active = true })
        print("^2[Crosshair] Debug forced ON^0")
    else
        lastActive = false
        SendNUIMessage({ action = "setActive", active = false })
        pushCoreState() -- resync enabled/type/cfg to NUI
        print("^2[Crosshair] Debug OFF^0")
    end
end)
