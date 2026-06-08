-- ============================================================================
-- GHOST PROTOCOL + AIMBOT + ESP - STANDALONE INJECTOR ADDON
-- Is file ko apne injector ke saath load karo, original code mein kuch change mat karo
-- ============================================================================

local GhostCore = {}
GhostCore.Version = "5.0-GHOST-PLUS-ESP"
GhostCore.Active = false
GhostCore.AimbotActive = false
GhostCore.ESPActive = false

-- ============================================================================
-- CORE UTILITIES
-- ============================================================================
local function SafeExec(func)
    local success, result = pcall(func)
    return success and result or nil
end

local function RetTrueMimic()
    return math.random(1, 100) > 5
end

local function RetFalseMimic()
    return math.random(1, 100) <= 5
end

local function SafeWrap(originalFunc, mockFunc, mimicChance)
    mimicChance = mimicChance or 0
    if type(originalFunc) ~= "function" then return mockFunc end
    return function(...)
        if mimicChance > 0 and math.random(1, 100) <= mimicChance then
            return originalFunc(...)
        end
        return mockFunc(...)
    end
end

-- ============================================================================
-- MODULE 1: SLUA BYPASS
-- ============================================================================
local function Module_SLuaBypass()
    SafeExec(function()
        if slua and slua.getSignature then
            slua.getSignature = function() return math.random(0xDE000000, 0xFFFFFFFF) end
        end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = SafeWrap(loader.verifyBytecode, RetTrueMimic, 5)
            loader.checkIntegrity = SafeWrap(loader.checkIntegrity, RetTrueMimic, 5)
        end
        if _G.slua_verify then _G.slua_verify = SafeWrap(_G.slua_verify, RetTrueMimic, 5) end
    end)
end

-- ============================================================================
-- MODULE 2: MD5 BYPASS
-- ============================================================================
local function Module_MD5Bypass()
    SafeExec(function()
        local console = import("KismetSystemLibrary")
        if console then
            pcall(function() console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1") end)
            pcall(function() console.ExecuteConsoleCommand(nil, "sig.Check 0") end)
        end
        
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function() return string.rep(string.format("%x", math.random(0, 255)), 16) end
            CreativeModeBlueprintLibrary.MD5HashFile = function() return string.rep(string.format("%x", math.random(0, 255)), 16) end
            CreativeModeBlueprintLibrary.VerifyFileIntegrity = SafeWrap(CreativeModeBlueprintLibrary.VerifyFileIntegrity, RetTrueMimic, 5)
        end
        
        if _G.MD5Hash then _G.MD5Hash = function() return "OK" end end
        if _G.CRC32 then _G.CRC32 = function() return math.random(0, 0xFFFFFFFF) end end
        
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            TssSdk.GetFileMD5 = function() return "OK" end
            TssSdk.VerifyFileSignature = SafeWrap(TssSdk.VerifyFileSignature, RetTrueMimic, 5)
        end
    end)
end

-- ============================================================================
-- MODULE 3: LOG BLOCKER
-- ============================================================================
local function Module_LogBlocker()
    SafeExec(function()
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info = function() end
            TLog.Warning = function() end
            TLog.Error = function() end
            TLog.Report = function() end
            TLog.Send = function() end
        end
        
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then
            CrashSight.ReportException = function() end
            CrashSight.Log = function() end
        end
        
        local ScreenshotMTDer = import("ScreenshotMTDer")
        if ScreenshotMTDer then
            ScreenshotMTDer.MTDePicture = function() return "" end
            ScreenshotMTDer.TakeScreenshot = function() end
        end
    end)
end

-- ============================================================================
-- MODULE 4: NETWORK PACKET BLOCK
-- ============================================================================
local function Module_NetworkBlock()
    SafeExec(function()
        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blocked = {
                ["ReportAttackFlow"] = true, ["ReportSecAttackFlow"] = true,
                ["ReportAimFlow"] = true, ["ReportHitFlow"] = true,
                ["ReportMrpcsFlow"] = true, ["Heartbeat"] = true,
                ["SwiftHawk"] = true, ["AntiCheatReport"] = true
            }
            NetUtil.SendPacket = function(name, ...)
                if blocked[name] then return nil end
                return originalSend(name, ...)
            end
        end
    end)
end

-- ============================================================================
-- MODULE 5: HIGGS BOSON BYPASS
-- ============================================================================
local function Module_HiggsBypass()
    SafeExec(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            Higgs.ControlMHActive = function() end
            Higgs.ReportViolation = function() end
            Higgs.bMHActive = false
            Higgs.IsMHActive = RetFalseMimic
        end
        
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pcall(function() pc.HiggsBoson:ControlMHActive(0) end)
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pcall(function() pc.HiggsBosonComponent:ControlMHActive(0) end)
            end
        end
    end)
end

-- ============================================================================
-- MODULE 6: REPORT FLOW BLOCKER
-- ============================================================================
local function Module_ReportBlocker()
    SafeExec(function()
        local reports = {
            "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
            "ReportHurtFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportCircleFlow"
        }
        for _, name in ipairs(reports) do
            if _G[name] then _G[name] = function() end end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[name] then
                _G.GameplayCallbacks[name] = function() end
            end
        end
    end)
end

-- ============================================================================
-- MODULE 7: MAGIC BULLET (ENLARGED HITBOXES)
-- ============================================================================
local function EnableMagicBullet()
    SafeExec(function()
        local allChars = Game:GetAllPlayerPawns() or {}
        for _, c in pairs(allChars) do
            if slua.isValid(c) then
                local mesh = c.Mesh
                if slua.isValid(mesh) then
                    local physAsset = mesh.PhysicsAssetOverride
                    if not slua.isValid(physAsset) and slua.isValid(mesh.SkeletalMesh) then
                        physAsset = mesh.SkeletalMesh.PhysicsAsset
                    end
                    if slua.isValid(physAsset) and physAsset.SkeletalBodySetups then
                        _G._MBones = _G._MBones or {}
                        local assetName = (physAsset.GetName and physAsset:GetName()) or tostring(physAsset)
                        if not _G._MBones[assetName] then
                            local setups = physAsset.SkeletalBodySetups
                            for i = 1, 80 do
                                local bs = nil
                                pcall(function() bs = (type(setups.Get) == "function") and setups:Get(i-1) or setups[i] end)
                                if not bs or not slua.isValid(bs) then break end
                                local bn = tostring(bs.BoneName):lower()
                                local scale = nil
                                if bn:find("head") then scale = 2.0
                                elseif bn:find("neck") then scale = 1.8
                                elseif bn:find("spine") or bn:find("pelvis") then scale = 1.5
                                elseif bn:find("arm") or bn:find("leg") or bn:find("thigh") then scale = 1.4
                                end
                                if scale then
                                    local ag = bs.AggGeom
                                    pcall(function()
                                        local bx = (ag and ag.BoxElems) or bs.BoxElems
                                        if bx then
                                            local b = (type(bx.Get) == "function") and bx:Get(0) or bx[1]
                                            if b then
                                                b.X = (b.X or 30) * scale
                                                b.Y = (b.Y or 30) * scale
                                                b.Z = (b.Z or 60) * scale
                                            end
                                        end
                                    end)
                                    pcall(function()
                                        local sp = (ag and ag.SphylElems) or bs.SphylElems
                                        if sp then
                                            local s = (type(sp.Get) == "function") and sp:Get(0) or sp[1]
                                            if s and s.Radius then s.Radius = s.Radius * scale end
                                        end
                                    end)
                                end
                            end
                            _G._MBones[assetName] = true
                            if mesh.RecreatePhysicsState then mesh:RecreatePhysicsState() end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- MODULE 8: AIMBOT
-- ============================================================================
_G._AimbotPC = nil

local function ApplyAimbot()
    SafeExec(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end
        
        local wm = char.WeaponManagerComponent
        if not slua.isValid(wm) then return end
        
        local weapon = wm.CurrentWeaponReplicated
        if not slua.isValid(weapon) then return end
        
        local entity = weapon.ShootWeaponEntityComp
        if slua.isValid(entity) then
            entity.RecoilKickADS = 0.02
            entity.GameDeviationFactor = 0.3
            entity.ExtraHitPerformScale = 9
        end
        
        local aimComp = char.BP_AutoAimingComponent_C or char.AutoAimingComponent
        if slua.isValid(aimComp) and aimComp.Bones then
            pcall(function() aimComp.Bones[0] = "head" end)
            pcall(function() aimComp.Bones[1] = "head" end)
        end
    end)
end

local function StartAimbot(pc)
    if not slua.isValid(pc) then return end
    if pc == _G._AimbotPC then return end
    _G._AimbotPC = pc
    GhostCore.AimbotActive = true
    if pc.AddGameTimer then
        pc:AddGameTimer(0.1, true, function()
            if not slua.isValid(_G._AimbotPC) then
                _G._AimbotPC = nil
                GhostCore.AimbotActive = false
                return
            end
            ApplyAimbot()
            EnableMagicBullet()
        end)
    end
end

-- ============================================================================
-- MODULE 9: ESP / WALLHACK
-- ============================================================================
local function TextScale(distM)
    return 0.35 - math.min(distM / 400, 1) * 0.2
end

local function HPBar(pct)
    local n = math.floor((pct * 4) + 0.5)
    local s = ""
    for i = 1, 4 do s = s .. (i <= n and "█" or "░") end
    return s
end

local function IsAlive(p)
    if not slua.isValid(p) then return false end
    return (p.Health or 0) > 0
end

local lastESPTime = 0

local function ESPTick()
    SafeExec(function()
        local uCon = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(uCon) then return end
        
        local currentPawn = uCon:GetCurPawn()
        if not slua.isValid(currentPawn) then return end
        
        local myTeamId = currentPawn.TeamID or 0
        local myPos = currentPawn:K2_GetActorLocation()
        local HUD = uCon:GetHUD()
        if not slua.isValid(HUD) then return end
        
        local allChars = Game:GetAllPlayerPawns() or {}
        local botCount, playerCount = 0, 0
        
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= currentPawn and enemy.TeamID ~= myTeamId and IsAlive(enemy) then
                local enemyPos = enemy:K2_GetActorLocation()
                local dist = math.sqrt((enemyPos.X - myPos.X)^2 + (enemyPos.Y - myPos.Y)^2 + (enemyPos.Z - myPos.Z)^2)
                
                local isBot = Game:IsAI(enemy) or false
                if isBot then botCount = botCount + 1 else playerCount = playerCount + 1 end
                
                if dist < 600000 then
                    local distM = dist / 100
                    local name = (enemy.PlayerName or "UNKNOWN"):sub(1, 12)
                    local hp = enemy.Health or 100
                    local hpPercent = hp / (enemy.HealthMax or 100)
                    
                    local color = {R=255,G=255,B=0,A=255}
                    local hpColor = hpPercent < 0.3 and {R=255,G=0,B=0,A=255} or {R=0,G=255,B=0,A=255}
                    
                    HUD:AddDebugText(string.format("[%.0fm] %s", distM, name), enemy, TextScale(distM),
                        {X=0,Y=0,Z=-80}, {X=0,Y=0,Z=-80}, color, true, false, true, nil, 1.0, true)
                    HUD:AddDebugText(HPBar(hpPercent), enemy, TextScale(distM),
                        {X=0,Y=0,Z=-50}, {X=0,Y=0,Z=-50}, hpColor, true, false, true, nil, 1.0, true)
                end
            end
        end
        
        HUD:AddDebugText(string.format("🎯 BOT: %d | 👤 PLAYER: %d", botCount, playerCount), currentPawn, 0.8,
            {X=0,Y=0,Z=200}, {X=0,Y=0,Z=200}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
    end)
end

local function StartESP(pc)
    if not slua.isValid(pc) then return end
    GhostCore.ESPActive = true
    if pc.AddGameTimer then
        pc:AddGameTimer(0.15, true, ESPTick)
    end
end

-- ============================================================================
-- MAIN INITIALIZATION
-- ============================================================================
local function InitializeAll()
    SafeExec(function()
        print("[GHOST] Initializing Bypasses...")
        Module_SLuaBypass()
        Module_MD5Bypass()
        Module_LogBlocker()
        Module_NetworkBlock()
        Module_HiggsBypass()
        Module_ReportBlocker()
        
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            StartAimbot(pc)
            StartESP(pc)
            
            -- Self-healing timer
            if pc.AddGameTimer then
                pc:AddGameTimer(30.0, true, function()
                    if GhostCore.Active then
                        Module_HiggsBypass()
                        Module_NetworkBlock()
                        if GhostCore.AimbotActive then
                            ApplyAimbot()
                            EnableMagicBullet()
                        end
                    end
                end)
            end
        end
        
        GhostCore.Active = true
        print("[GHOST] ✅ Bypass + Aimbot + ESP Active!")
    end)
end

-- ============================================================================
-- HOOK INTO GAME (WAIT FOR PLAYER CONTROLLER)
-- ============================================================================
local retries = 0
local function WaitForGame()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        local delay = math.random(5000, 10000) / 1000
        pc:AddGameTimer(delay, false, InitializeAll)
    elseif retries < 20 then
        retries = retries + 1
        local timer = require("timer")
        if timer and timer.SetTimeout then
            timer.SetTimeout(1000, WaitForGame)
        else
            slua.scheduleOnce(WaitForGame, 1.0)
        end
    end
end

-- START EVERYTHING
WaitForGame()

print("[GHOST] Addon Loaded - Waiting for game...")
