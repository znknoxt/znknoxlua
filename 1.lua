-- ============================================
-- COMBINED FEATURES MODULE
-- Magic Bullet | Anti-Ban Bypass | No Grass | 165 FPS | iPad FOV
-- ============================================

local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")

-- ============================================
-- CONFIGURATION
-- ============================================
local Config = {
    -- Magic Bullet (Enlarged Hitboxes)
    ENABLE_MAGIC_BULLET = true,
    MAGIC_SCALE = {
        head = 130,
        neck = 110,
        spine = 110,
        arms = 120,
        legs = 120,
    },
    
    -- No Grass
    ENABLE_NO_GRASS = true,
    
    -- 165 FPS
    ENABLE_165_FPS = true,
    
    -- iPad FOV
    ENABLE_IPAD_FOV = true,
    IPAD_FOV_VALUE = 120,
    
    -- Tick rate (how often features apply)
    TICK_RATE = 0.1,
}

-- ============================================
-- ANTI-BAN BYPASS (Disables Telemetry)
-- ============================================
local function AntiBanBypass()
    pcall(function()
        -- Disable TSS Anti-Cheat Callbacks
        local gameplayCallbacks = _G.GameplayCallbacks or _G["GC"]
        if gameplayCallbacks then
            local nop = function() end
            gameplayCallbacks.SendTssSdkAntiDataToLobby = nop
            gameplayCallbacks.SendDSErrorLogToLobby = nop
            gameplayCallbacks.SendDSHawkEyePatrolLogToLobby = nop
            gameplayCallbacks.SendSecTLog = nop
            gameplayCallbacks.SendDataMiningTLog = nop
            gameplayCallbacks.SendActivityTLog = nop
            gameplayCallbacks.OnPlayerRPCValidateFailed = nop
            gameplayCallbacks.OnPlayerActorChannelError = nop
        end

        -- Disable Higgs Boson Anti-Cheat
        local higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if higgs then
            higgs.ControlMHActive = nop
            higgs.Tick = nop
            higgs.OnTick = nop
            higgs.MHActiveLogic = nop
            higgs.TriggerAvatarCheck = nop
            higgs.StartAvatarCheck = nop
            higgs.ReportItemID = nop
            higgs.GetNetAvatarItemIDs = function() return {} end
        end

        -- Disable Client Report System
        local clientReport = require("GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem")
        if clientReport then
            clientReport.OnInit = nop
            clientReport._OnPlayerKilledOtherPlayer = nop
            clientReport._RecordFatalDamager = nop
        end

        -- Disable DS Report System
        local dsReport = require("GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem")
        if dsReport then
            dsReport.OnInit = nop
            dsReport._OnCharacterDied = nop
        end

        print("[ANTI-BAN] Bypass activated successfully")
    end)
end

-- ============================================
-- MAGIC BULLET (Enlarged Hitboxes)
-- ============================================
local scaledAssets = {}

local function ApplyMagicBullet()
    if not Config.ENABLE_MAGIC_BULLET then return end
    
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local mesh = player.Mesh
        if not slua.isValid(mesh) then return end
        
        local physAsset = mesh.PhysicsAssetOverride
        if not slua.isValid(physAsset) and mesh.SkeletalMesh then
            physAsset = mesh.SkeletalMesh.PhysicsAsset
        end
        
        if not slua.isValid(physAsset) or not physAsset.SkeletalBodySetups then
            return
        end
        
        local assetName = physAsset:GetName() or tostring(physAsset)
        if scaledAssets[assetName] then return end
        
        local setups = physAsset.SkeletalBodySetups
        local scaledCount = 0
        
        for i = 1, 80 do
            local bodySetup = nil
            if type(setups.Get) == "function" then
                bodySetup = setups:Get(i - 1)
            else
                bodySetup = setups[i]
            end
            
            if not bodySetup or not slua.isValid(bodySetup) then break end
            
            local boneName = tostring(bodySetup.BoneName):lower()
            local scalePercent = nil
            
            -- Check which bone this is
            if string.find(boneName, "head") then
                scalePercent = Config.MAGIC_SCALE.head
            elseif string.find(boneName, "neck") then
                scalePercent = Config.MAGIC_SCALE.neck
            elseif string.find(boneName, "spine") then
                scalePercent = Config.MAGIC_SCALE.spine
            elseif string.find(boneName, "arm") then
                scalePercent = Config.MAGIC_SCALE.arms
            elseif string.find(boneName, "leg") or string.find(boneName, "thigh") or string.find(boneName, "calf") then
                scalePercent = Config.MAGIC_SCALE.legs
            end
            
            if scalePercent then
                local scale = 1.0 + scalePercent / 100.0
                local aggGeom = bodySetup.AggGeom
                
                -- Scale Box Elements
                local boxes = (aggGeom and aggGeom.BoxElems) or bodySetup.BoxElems
                if boxes then
                    local box = (type(boxes.Get) == "function") and boxes:Get(0) or boxes[1]
                    if box then
                        box.X = (box.X or 30) * scale
                        box.Y = (box.Y or 30) * scale
                        box.Z = (box.Z or 60) * scale
                        if type(boxes.Set) == "function" then
                            boxes:Set(0, box)
                        else
                            boxes[1] = box
                        end
                        scaledCount = scaledCount + 1
                    end
                end
                
                -- Scale Capsule (Sphyl) Elements
                local sphyls = (aggGeom and aggGeom.SphylElems) or bodySetup.SphylElems
                if sphyls then
                    local sphyl = (type(sphyls.Get) == "function") and sphyls:Get(0) or sphyls[1]
                    if sphyl then
                        if sphyl.Radius then sphyl.Radius = sphyl.Radius * scale end
                        if sphyl.Length then sphyl.Length = sphyl.Length * scale end
                        scaledCount = scaledCount + 1
                    end
                end
            end
        end
        
        if scaledCount > 0 then
            scaledAssets[assetName] = true
            if mesh.RecreatePhysicsState then
                mesh:RecreatePhysicsState()
            end
            print("[MAGIC] Hitboxes enlarged:", scaledCount, "bones modified")
        end
    end)
end

-- ============================================
-- NO GRASS (Remove Grass & Foliage)
-- ============================================
local function ApplyNoGrass()
    if not Config.ENABLE_NO_GRASS then return end
    
    pcall(function()
        local gameInstance = slua_GameFrontendHUD:GetGameInstance()
        if gameInstance then
            gameInstance:ExecuteCMD("grass.DensityScale", "0")
            gameInstance:ExecuteCMD("grass.DiscardDataOnLoad", "1")
            gameInstance:ExecuteCMD("foliage.DensityScale", "0")
            print("[NO GRASS] Grass removed")
        end
    end)
end

-- ============================================
-- 165 FPS UNLOCK
-- ============================================
local function Apply165FPS()
    if not Config.ENABLE_165_FPS then return end
    
    pcall(function()
        local gameInstance = slua_GameFrontendHUD:GetGameInstance()
        if gameInstance then
            gameInstance:ExecuteCMD("t.MaxFPS", "165")
            gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
            print("[FPS] 165 FPS unlocked")
        end
        
        -- Also patch the FPS settings UI
        local graphics = require("client.slua.logic.setting.logic_setting_graphics")
        if graphics then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then
                    local gi = slua_GameFrontendHUD:GetGameInstance()
                    if gi then
                        gi:ExecuteCMD("t.MaxFPS", "165")
                        gi:ExecuteCMD("r.FrameRateLimit", "165")
                    end
                end
            end
        end
    end)
end

-- ============================================
-- IPAD FOV (Extended Field of View)
-- ============================================
local function ApplyiPadFOV()
    if not Config.ENABLE_IPAD_FOV then return end
    
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local tpCam = player.ThirdPersonCameraComponent
        if slua.isValid(tpCam) then
            tpCam:SetFieldOfView(Config.IPAD_FOV_VALUE)
        end
        
        -- Patch FOV settings in config tables
        local settingConfigs = {
            require("client.logic.setting.setting_config"),
            require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        }
        
        for _, cfg in pairs(settingConfigs) do
            if cfg then
                if cfg.TpViewValue then
                    cfg.TpViewValue.max = Config.IPAD_FOV_VALUE
                    cfg.TpViewValue.Max = Config.IPAD_FOV_VALUE
                end
                if cfg.FpViewValue then
                    cfg.FpViewValue.max = Config.IPAD_FOV_VALUE
                    cfg.FpViewValue.Max = Config.IPAD_FOV_VALUE
                end
            end
        end
        
        print("[FOV] iPad FOV set to:", Config.IPAD_FOV_VALUE)
    end)
end

-- ============================================
-- MAIN TIMER (Applies all features)
-- ============================================
local function InitializeMod()
    -- Run anti-ban bypass first
    AntiBanBypass()
    
    -- Apply features on a timer
    local timerCount = 0
    
    local function Tick()
        pcall(function()
            -- Apply all features
            ApplyMagicBullet()
            ApplyNoGrass()
            Apply165FPS()
            ApplyiPadFOV()
            
            timerCount = timerCount + 1
            if timerCount % 10 == 0 then
                print("[MOD] All features active | Magic | NoGrass | 165FPS | iPadFOV")
            end
        end)
    end
    
    -- Get player controller and start timer
    local function StartTimer()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(Config.TICK_RATE, true, Tick)
            print("[MOD] Initialized successfully")
        else
            -- Retry after 1 second
            local timer = require("common.time_ticker")
            timer.AddTimerOnce(1.0, StartTimer)
        end
    end
    
    StartTimer()
end

-- ============================================
-- AUTO-START ON GAME LOAD
-- ============================================
pcall(function()
    -- Wait for game to fully load
    local timer = require("common.time_ticker")
    timer.AddTimerOnce(3.0, InitializeMod)
end)

print("[LOADER] Combined Features Mod Loaded")
