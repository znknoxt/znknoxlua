--Zn_Knox MOD MENU V8 - ULTIMATE EDITION (COMPLETE)
-- Merged:Zn_Knox SRC DUMPED + Enhanced Features (Wallhack, ESP, Skins, 165 FPS)
-- Mod Menu System:Zn_Knox Style

do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED_V8 and _G._MOD_PC_V8 == pc then return end
    _G._MOD_LOADED_V8 = true
    _G._MOD_PC_V8 = pc
end

-- ==================== INITIALIZE CONFIG ====================
_G.LexusConfig = _G.LexusConfig or {
    -- VISUAL MODS
    EnableFOV = false,
    FOVValue = 90,
    EnableNoGrass = false,
    EnableBlackSky = false,
    
    -- COMBAT MODS
    EnableMagic = false,
    MagicLevel = 70,
    EnableAutoAim = false,
    AutoAimBone = "Head",
    EnableAiming = false,
    AimingLevel = "LOW",
    EnableNoRecoil = false,
    EnableNoShake = false,
    RecoilLevel = "LESS",
    
    -- WEAPON MODS
    EnableWeaponMod = false,
    WeaponMod = {
        [101001] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101002] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101003] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101004] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101005] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101006] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101007] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101008] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101009] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101010] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false}
    },
    
    -- NEW FEATURES (Merged from second script)
    EnableWallhack = false,
    EnableESP = false,
    EnableSkinChanger = false,
    Enable165FPS = true,
    AimbotStrength = 50,
    
    -- CHAMS COLORS
    EnableChamsGreen = false,
    EnableChamsYellow = false,
    ChamsGreenRGB = {R=0, G=255, B=0, A=255},
    ChamsYellowRGB = {R=255, G=255, B=0, A=255}
}

_G.LexusState = _G.LexusState or {}
_G._MBones = _G._MBones or {}

-- ==================== BYPASS FUNCTIONS ====================
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end

function _G.TryBypassMD5()
    if _G.MD5Bypassed then return end
    pcall(function()
        require("client.client_entry")
        if _G.NetUtil then
            _G.NetUtil.check_dh_packet_key = function(packet_key, svr_packet_key_md5, from, dh_ext_info, bReportDSInfo)
                if type(dh_ext_info) == "table" then
                    dh_ext_info.packet_key_md5 = svr_packet_key_md5 or ""
                    dh_ext_info.svr_packet_key_md5 = svr_packet_key_md5 or ""
                end
                return true
            end
            _G.MD5Bypassed = true
        end
    end)
end

function _G.BypassCacheMD5()
    if _G.CacheMD5Bypassed then return end
    pcall(function()
        local CacheMgr = require("common.CustomAsset.CustomAssetCacheManager")
        if CacheMgr then
            CacheMgr._UpdateAssetCacheState = function(self, AssetKey, SuffixType)
                local CacheMetaInfo = self:GetCustomAssetCacheMetaInfo(AssetKey, SuffixType)
                if CacheMetaInfo then
                    CacheMetaInfo.CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
                end
            end
            _G.CacheMD5Bypassed = true
        end
    end)
end

_G.BypassSecurityUtils = function()
    pcall(function()
        local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")        
        if SecurityCommonUtils then
            if SecurityCommonUtils.EStrategyTypeInReplay then
                for k, v in pairs(SecurityCommonUtils.EStrategyTypeInReplay) do
                    SecurityCommonUtils.EStrategyTypeInReplay[k] = 0
                end
            end
            SecurityCommonUtils.LogIf = function(Condition, sFormat, ...) return false end
            SecurityCommonUtils.IsFunctionCheckPass = function(FunctionOuter, sFuncName, ...) return true end
            SecurityCommonUtils.IsHealthStatusHealthy = function(nHealthStatus) return true end
            SecurityCommonUtils.IsHealthStatusAlive = function(nHealthStatus) return true end
            SecurityCommonUtils.IsTrue = function(Value) return true end            
            _G.SecurityCommonUtils = SecurityCommonUtils
        end
    end)
end

_G.BypassHiggsComponent = function()
    pcall(function()
        local HiggsComponentClass = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")        
        if HiggsComponentClass then
            local CHiggsBosonComponent = HiggsComponentClass
            if type(HiggsComponentClass) == "table" and HiggsComponentClass.__index then
                CHiggsBosonComponent = HiggsComponentClass.__index
            end
            CHiggsBosonComponent.StaticShowSecurityAlertInDev = function(uPlayerController, sMessage, bIsClientShowWindow, bSkipServer) return end
            CHiggsBosonComponent._ClientShowSecurityAlertWindow = function(sMessage) return end
            CHiggsBosonComponent._ReportChatRobot = function(sMessage, uHiggsBosonComponent) return end
            CHiggsBosonComponent._ProcessReportChatRobotQueue = function() return end
            CHiggsBosonComponent.RecordStrategyTimestampInReplay = function(nStrategyTypeInReplay, nValue, uController, nTimeInSecondsOffSet) return end
            CHiggsBosonComponent.SendAntiDataFlow = function(self) return end
            CHiggsBosonComponent.SendHitFireBtnFlow = function(self) return end
            CHiggsBosonComponent.OnBattleResult = function(self) return end
            CHiggsBosonComponent.SendHisarData = function() return end
            if CHiggsBosonComponent.ClientRPC then
                CHiggsBosonComponent.ClientRPC.RPC_Client_ShowSecurityAlertWindow = function(self, sMessage) return end
                CHiggsBosonComponent.ClientRPC.RPC_Client_ServerNameAck = function(self) return end
            end
            if CHiggsBosonComponent.ServerRPC then
                CHiggsBosonComponent.ServerRPC.RPC_Server_TellServerName = function(self, sServerName) return end
            end
        end
    end)
end

local function BypassTelemetry()
    pcall(function()
        local callbacks = _G.GameplayCallbacks or _G.GC
        if callbacks then
            local kills = {
                "SendTssSdkAntiDataToLobby","SendDSErrorLogToLobby","SendDSHawkEyePatrolLogToLobby",
                "SendSecTLog","SendDataMiningTLog","SendActivityTLog","SendClientMemUsage","SendClientFPS",
                "OnClientCrashReport","OnNetworkLossDetected","ReportMatchRoomData","ReportPlayersPing",
                "SendClientStats","SendServerAvgTickDelta","ReportHitFlow","OnPlayerActorChannelError","OnPlayerRPCValidateFailed"
            }
            for _, fn in ipairs(kills) do if callbacks[fn] then callbacks[fn] = nop end end
        end
        if _G.TApmHelper then _G.TApmHelper.postEvent = nop end
    end)
end

-- ==================== CORE FEATURES ====================

-- IPAD VIEW / FOV
function _G.SetFOV(value)
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local camera = player.ThirdPersonCameraComponent
    if not camera then return end
    camera:SetFieldOfView(value)
end

-- WEAPON MODS
_G.otherWeapon = function()
    if not _G.LexusConfig.EnableWeaponMod then return end
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not slua.isValid(shootComp) then return end
        local wid = shootComp.WeaponID
        if type(wid) ~= "number" then return end
        local cfg = _G.LexusConfig.WeaponMod[wid]
        if not cfg then return end
        if cfg.FireSpeed then shootComp.ShootInterval = 0.07 end
        if cfg.InstanHit then shootComp.BulletFireSpeed = 130000 end
        if cfg.FastSwitch then
            shootComp.SwitchFromIdleToBackpackTime = 0
            shootComp.SwitchFromBackpackToIdleTime = 0
        end
        if cfg.FastScope then shootComp.WeaponAimInTime = 7 end
    end)
end

-- MAGIC BULLET
_G.ResetHitbox = function()
    pcall(function()
        local allChars = Game:GetAllPlayerPawns()
        if allChars then
            for _, enemy in pairs(allChars) do
                if slua.isValid(enemy) and slua.isValid(enemy.Mesh) then
                    enemy.Mesh:RecreatePhysicsState()
                    enemy.Mesh:UpdateBounds()
                end
            end
        end
        _G._MBones = {}
    end)
end

_G.Magic = function()
    if not _G.LexusConfig.EnableMagic then 
        if _G._MBones and next(_G._MBones) ~= nil then _G.ResetHitbox() end
        return 
    end
    pcall(function()
        local char = GameplayData.GetPlayerCharacter()
        if not slua.isValid(char) then return end
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        _G._MBones = _G._MBones or {}
        local currentMagicScale = _G.LexusConfig.MagicLevel or 70
        for _, enemy in pairs(allChars) do
            pcall(function()
                if not slua.isValid(enemy) or enemy == char or enemy.TeamID == char.TeamID then return end
                local mesh = enemy.Mesh
                if not slua.isValid(mesh) then return end
                local physAsset = mesh.PhysicsAssetOverride
                if not slua.isValid(physAsset) and slua.isValid(mesh.SkeletalMesh) then
                    physAsset = mesh.SkeletalMesh.PhysicsAsset
                end
                if not slua.isValid(physAsset) then return end
                local assetName = tostring((physAsset.GetName and physAsset:GetName()) or physAsset)
                if _G._MBones[assetName] then return end
                local setups = physAsset.SkeletalBodySetups
                if not setups then return end
                local scaleMap = { head = currentMagicScale, neck = currentMagicScale }
                for i = 0, 60 do
                    pcall(function()
                        local bs = (type(setups.Get) == "function" and setups:Get(i)) or setups[i]
                        if not bs or not slua.isValid(bs) then return end
                        local boneName = tostring(bs.BoneName):lower()
                        local scale = nil
                        for pattern, value in pairs(scaleMap) do
                            if string.find(boneName, pattern:lower()) then scale = value; break end
                        end
                        if not scale then return end
                        local ag = bs.AggGeom
                        if not ag then return end
                        pcall(function()
                            local box = ag.BoxElems
                            if box then
                                local elem = (type(box.Get) == "function" and box:Get(0)) or box[1]
                                if elem then
                                    elem.X, elem.Y, elem.Z = scale, scale, scale
                                    if type(box.Set) == "function" then box:Set(0, elem) else box[1] = elem end
                                end
                            end
                        end)
                        pcall(function()
                            local sphyl = ag.SphylElems
                            if sphyl then
                                local elem = (type(sphyl.Get) == "function" and sphyl:Get(0)) or sphyl[1]
                                if elem then
                                    if elem.Radius then elem.Radius = scale end
                                    if elem.Length then elem.Length = scale end
                                    if type(sphyl.Set) == "function" then sphyl:Set(0, elem) else sphyl[1] = elem end
                                end
                            end
                        end)
                    end)
                end
                pcall(function()
                    mesh:RecreatePhysicsState()
                    mesh:WakeAllRigidBodies()
                    mesh:UpdateBounds()
                end)
                _G._MBones[assetName] = true
            end)
        end
    end)
end

-- AUTO AIM
_G.ApplyAutoAim = function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local autoComp = player.AutoAimComp
    if not autoComp then return end
    if _G.LexusConfig.EnableAutoAim then
        local targetBone = _G.LexusConfig.AutoAimBone or "Head"
        autoComp.Bones = { targetBone, targetBone, targetBone }
    else
        autoComp.Bones = nil 
    end
end

-- AIMBOT
_G.ApplyAimingConfig = function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local weaponManager = player.WeaponManagerComponent
    if not slua.isValid(weaponManager) then return end
    local currentWeapon = weaponManager.CurrentWeaponReplicated
    if not slua.isValid(currentWeapon) then return end
    local shootComp = currentWeapon.ShootWeaponEntityComp
    if not shootComp then return end
    local aa = shootComp.AutoAimingConfig
    if not aa then return end

    local strength = (_G.LexusConfig.AimbotStrength or 50) / 100
    local level = _G.LexusConfig.AimingLevel or "LOW"
    
    local configs = {
        LOW     = { S = 5 * strength,  SR = 5 * strength,  RR = 1 * strength,  RRS = 1 * strength,  SRS = 5 * strength,  CSR = 3 * strength,  CR = 1,   PR = 1,   DR = 0, GDF = 0 },
        MEDIUM  = { S = 7 * strength,  SR = 7 * strength,  RR = 2 * strength,  RRS = 2 * strength,  SRS = 7 * strength,  CSR = 5 * strength,  CR = 2,   PR = 2,   DR = 0, GDF = 0 },
        HARD    = { S = 10 * strength, SR = 10 * strength, RR = 10 * strength, RRS = 10 * strength, SRS = 10 * strength, CSR = 7 * strength,  CR = 2,   PR = 2,   DR = 0, GDF = 0 },
        EXTREME = { S = 50 * strength, SR = 20 * strength, RR = 20 * strength, RRS = 20 * strength, SRS = 20 * strength, CSR = 15 * strength, CR = 5,   PR = 5,   DR = 0, GDF = 0 }
    }

    if not _G.LexusConfig.EnableAiming then
        local d = { S = 3.5, SR = 1, RR = 1, RRS = 1, SRS = 1, CSR = 1, CR = 0.5, PR = 0.10, DR = 1, GDF = 0 }
        aa.OuterRange.Speed = d.S; aa.InnerRange.Speed = d.S
        aa.OuterRange.SpeedRate = d.SR; aa.InnerRange.SpeedRate = d.SR
        aa.OuterRange.RangeRate = d.RR; aa.InnerRange.RangeRate = d.RR
        aa.OuterRange.RangeRateSight = d.RRS; aa.InnerRange.RangeRateSight = d.RRS
        aa.OuterRange.SpeedRateSight = d.SRS; aa.InnerRange.SpeedRateSight = d.SRS
        aa.OuterRange.CenterSpeedRate = d.CSR; aa.InnerRange.CenterSpeedRate = d.CSR
        aa.OuterRange.CrouchRate = d.CR; aa.InnerRange.CrouchRate = d.CR
        aa.OuterRange.ProneRate = d.PR; aa.InnerRange.ProneRate = d.PR
        aa.OuterRange.DyingRate = d.DR; aa.InnerRange.DyingRate = d.DR
        shootComp.GameDeviationFactor = d.GDF
        return
    end

    local c = configs[level] or configs.LOW
    aa.OuterRange.Speed = c.S; aa.InnerRange.Speed = c.S
    aa.OuterRange.SpeedRate = c.SR; aa.InnerRange.SpeedRate = c.SR
    aa.OuterRange.RangeRate = c.RR; aa.InnerRange.RangeRate = c.RR
    aa.OuterRange.RangeRateSight = c.RRS; aa.InnerRange.RangeRateSight = c.RRS
    aa.OuterRange.SpeedRateSight = c.SRS; aa.InnerRange.SpeedRateSight = c.SRS
    aa.OuterRange.CenterSpeedRate = c.CSR; aa.InnerRange.CenterSpeedRate = c.CSR
    aa.OuterRange.CrouchRate = c.CR; aa.InnerRange.CrouchRate = c.CR
    aa.OuterRange.ProneRate = c.PR; aa.InnerRange.ProneRate = c.PR
    aa.OuterRange.DyingRate = c.DR; aa.InnerRange.DyingRate = c.DR
    shootComp.GameDeviationFactor = c.GDF
end

-- NO RECOIL
_G.ApplyNoRecoil = function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local weaponManager = player.WeaponManagerComponent
    if not slua.isValid(weaponManager) then return end
    local currentWeapon = weaponManager.CurrentWeaponReplicated
    if not slua.isValid(currentWeapon) then return end
    local shootComp = currentWeapon.ShootWeaponEntityComp
    if not shootComp then return end

    local level = (_G.LexusConfig.EnableNoRecoil and _G.LexusConfig.RecoilLevel) or "DEFAULT"
    local r = shootComp.RecoilInfo

    if level == "DEFAULT" then
        shootComp.RecoilKickADS = 0.2
        shootComp.AccessoriesHRecoilFactor = 0.5
        shootComp.AccessoriesRecoveryFactor = 0.6
        shootComp.AccessoriesVRecoilFactor = 0.5
        if r then
            r.VerticalRecoilMin = 0; r.VerticalRecoilMax = 7; r.VerticalRecoveryMax = 5
            r.RecoilValueClimb = 0.75; r.RecoilValueFail = 2.2; r.VerticalRecoveryModifier = 0.5
            r.RecovertySpeedVertical = 9; r.VerticalRecoveryClamp = 10
            r.LeftMax = -0.8; r.RightMax = 0.8; r.HorizontalTendency = 0.1
            r.RecoilHorizontalMinScalar = 0.1; r.RecoilSpeedHorizontal = 11; r.RecoilSpeedVertical = 11
        end
    elseif level == "LESS" then
        shootComp.RecoilKickADS = 0
        shootComp.AccessoriesHRecoilFactor = 0.2
        shootComp.AccessoriesRecoveryFactor = 0.2
        shootComp.AccessoriesVRecoilFactor = 0.2
        if r then
            r.VerticalRecoilMin = 0; r.VerticalRecoilMax = 2; r.VerticalRecoveryMax = 2
            r.RecoilValueClimb = 0.2; r.RecoilValueFail = 2; r.VerticalRecoveryModifier = 0.2
            r.RecovertySpeedVertical = 2; r.VerticalRecoveryClamp = 2
            r.LeftMax = -0.2; r.RightMax = 0.2; r.HorizontalTendency = 0.1
            r.RecoilHorizontalMinScalar = 0.1; r.RecoilSpeedHorizontal = 2; r.RecoilSpeedVertical = 2
        end
    elseif level == "NO" then
        shootComp.RecoilKickADS = 0
        shootComp.AccessoriesHRecoilFactor = 0
        shootComp.AccessoriesRecoveryFactor = 0
        shootComp.AccessoriesVRecoilFactor = 0
        if r then
            r.VerticalRecoilMin = 0; r.VerticalRecoilMax = 0; r.VerticalRecoveryMax = 0
            r.RecoilValueClimb = 0; r.RecoilValueFail = 0; r.VerticalRecoveryModifier = 0
            r.RecovertySpeedVertical = 0; r.VerticalRecoveryClamp = 0
            r.LeftMax = 0; r.RightMax = 0; r.HorizontalTendency = 0
            r.RecoilHorizontalMinScalar = 0; r.RecoilSpeedHorizontal = 0; r.RecoilSpeedVertical = 0
        end
    end
    
    if _G.LexusConfig.EnableNoShake then
        shootComp.AnimationKick = 0
    end
end

-- NO GRASS
_G.DisableGrass = function()
    local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
    local gi = logic_setting_graphics.GetGameInstance()
    if not gi then return end
    if _G.LexusConfig.EnableNoGrass then
        gi:ExecuteCMD("grass.heightScale", "0")
        gi:ExecuteCMD("grass.DensityScale", "0")
    else
        gi:ExecuteCMD("grass.heightScale", "1")
        gi:ExecuteCMD("grass.DensityScale", "1")
    end
end

-- BLACK SKY
_G.BlackSky = function()
    local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
    local gi = logic_setting_graphics.GetGameInstance()
    if not gi then return end
    if _G.LexusConfig.EnableBlackSky then
        gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
    else
        gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0")
    end
end

-- 165 FPS
_G.Enable165FPS = function()
    if not _G.LexusConfig.Enable165FPS then return end
    pcall(function()
        local gi = slua_GameFrontendHUD and slua_GameFrontendHUD:GetGameInstance()
        if gi then
            gi:ExecuteCMD("t.MaxFPS", "165")
            gi:ExecuteCMD("r.FrameRateLimit", "165")
        end
        local GSC_FPS = package.loaded["client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS"]
            or require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        if GSC_FPS and GSC_FPS.__inner_impl then
            local impl = GSC_FPS.__inner_impl
            impl.GetMaxFPSLevel = function() return 8, 8 end
            impl.InitRealSupportFPS = function(self)
                local tbl = {}
                for i = 1, 8 do tbl[i] = { true, true } end
                local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, tbl, false)
                return tbl
            end
        end
    end)
end

-- ==================== WALLHACK ====================
local function ApplyWallhack(localPlayer, enemy)
    if not _G.LexusConfig.EnableWallhack then return end
    if not slua.isValid(enemy) then return end
    pcall(function()
        local meshes = {}
        if slua.isValid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
        for _, comp in ipairs(meshes) do
            if slua.isValid(comp) then
                local ok, mat = pcall(function() return comp:GetMaterial(0) end)
                if ok and slua.isValid(mat) then
                    local ok2, base = pcall(function() return mat:GetBaseMaterial() end)
                    if ok2 and slua.isValid(base) then
                        base.bDisableDepthTest = true
                        base.BlendMode = 2
                    end
                end
                comp.UseScopeDistanceCulling = false
            end
        end
    end)
end

-- ==================== ESP ====================
local cachedPawns = {}
local lastPawnRefresh = 0
local boneList = {"head","neck_01","spine_01","spine_02","spine_03","pelvis",
    "upperarm_l","upperarm_r","lowerarm_l","lowerarm_r","hand_l","hand_r",
    "calf_l","calf_r","foot_l","foot_r"}

local function TextScale(distM)
    local t = math.min(distM / 400, 1)
    return 0.35 - t * 0.2
end

local function HPBar(pct)
    local n = math.floor((pct * 4) + 0.5)
    local s = ""
    for i = 1, 4 do s = s .. (i <= n and "█" or "░") end
    return s
end

local function IsPawnAlive(p)
    if not slua.isValid(p) then return false end
    if p.HealthStatus then
        local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus)
    end
    if p.IsAlive then return p:IsAlive() end
    return p.GetHealth and (p:GetHealth() or 0) > 0 or false
end

local function ESPTick()
    if not _G.LexusConfig.EnableESP then return end
    local uCon = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uCon) then return end
    local currentPawn = uCon:GetCurPawn()
    if not slua.isValid(currentPawn) then return end
    
    local myTeamId = 0
    pcall(function()
        local char = uCon:GetPlayerCharacterSafety()
        if slua.isValid(char) and char.TeamID then myTeamId = char.TeamID
        elseif currentPawn.TeamID then myTeamId = currentPawn.TeamID end
    end)
    
    local myPos = nil
    pcall(function() myPos = currentPawn:K2_GetActorLocation() end)
    if not myPos then return end
    local myEyePos = myPos
    pcall(function()
        if currentPawn.GetHeadLocation then myEyePos = currentPawn:GetHeadLocation(false) or myPos end
    end)
    
    local HUD = uCon:GetHUD()
    local now = os.clock()
    
    if now - lastPawnRefresh > 1.0 then
        lastPawnRefresh = now
        cachedPawns = Game:GetAllPlayerPawns() or {}
    end
    
    for _, tPawn in pairs(cachedPawns) do
        if slua.isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId then
            if IsPawnAlive(tPawn) then
                local enemyPos = tPawn:K2_GetActorLocation()
                local dx = enemyPos.X - myPos.X
                local dy = enemyPos.Y - myPos.Y
                local dz = enemyPos.Z - myPos.Z
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                
                if dist < 600000 and HUD then
                    local name = tPawn.PlayerName or "UNKNOWN"
                    local distM = dist / 100
                    
                    local hp = tPawn.Health
                    local maxHp = tPawn.HealthMax
                    local hpPercent = 0
                    if hp and maxHp and maxHp > 0 and hp > 0 then
                        hpPercent = hp / maxHp
                    end
                    
                    local hpColor = {R=0,G=255,B=0,A=255}
                    if hpPercent < 0.3 then hpColor = {R=255,G=0,B=0,A=255}
                    elseif hpPercent < 0.7 then hpColor = {R=255,G=255,B=0,A=255} end
                    
                    local bones = {}
                    local mesh = tPawn.Mesh
                    if slua.isValid(mesh) then
                        for _, bn in ipairs(boneList) do
                            bones[bn] = mesh:GetSocketLocation(bn)
                        end
                    end
                    
                    local headPos = bones["head"]
                    local hpOffset = headPos and (headPos.Z - enemyPos.Z + 70) or 90
                    local nameOffset = headPos and (headPos.Z - enemyPos.Z - 80) or -85
                    
                    -- Determine visibility for color
                    local isVisible = false
                    pcall(function()
                        isVisible = uCon:LineOfSightTo(tPawn)
                    end)
                    
                    local nameColor = {R=0,G=255,B=0,A=255}
                    if isVisible then
                        if _G.LexusConfig.EnableChamsGreen then
                            nameColor = _G.LexusConfig.ChamsGreenRGB
                        end
                    else
                        if _G.LexusConfig.EnableChamsYellow then
                            nameColor = _G.LexusConfig.ChamsYellowRGB
                        end
                    end
                    
                    HUD:AddDebugText(string.format("[%.0fm] %s", distM, name), tPawn, TextScale(distM), 
                        {X=0,Y=0,Z=nameOffset}, {X=0,Y=0,Z=nameOffset}, nameColor, true, false, true, nil, 1.0, true)
                    
                    local hpText = HPBar(hpPercent) .. " " .. math.floor(hpPercent * 100) .. "%"
                    HUD:AddDebugText(hpText, tPawn, TextScale(distM), 
                        {X=0,Y=0,Z=hpOffset}, {X=0,Y=0,Z=hpOffset}, hpColor, true, false, true, nil, 1.0, true)
                    
                    pcall(ApplyWallhack, currentPawn, tPawn)
                end
            end
        end
    end
end

-- ==================== SKIN CHANGER ====================
_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.SkinLoadedCache = _G.SkinLoadedCache or {}

_G.get_skin_id = function(weaponID)
    if not weaponID or weaponID == 0 then return nil end
    return _G.WeaponSkinMap[weaponID]
end

_G.download_item = function(i)
    if not i then return end
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        local PC = require("client.slua.logic.download.puffer_const")
        if PM.GetState(PC.ENUM_DownloadType.ODPAK, {i}) ~= PC.ENUM_DownloadState.Done then
            PM.Download(PC.ENUM_DownloadType.ODPAK, {i})
        end
    end)
end

_G.ApplyWeaponSkins = function(pawn)
    if not _G.LexusConfig.EnableSkinChanger then return end
    if not slua.isValid(pawn) then return end
    pcall(function()
        local wm = pawn:GetWeaponManager()
        if not slua.isValid(wm) then return end
        for i = 1, 3 do
            local wpn = wm:GetInventoryWeaponByPropSlot(i)
            if slua.isValid(wpn) then
                local targetID = _G.get_skin_id(wpn:GetWeaponID())
                if targetID and targetID > 0 then
                    if not _G.SkinLoadedCache[targetID] then
                        pcall(_G.download_item, targetID)
                        _G.SkinLoadedCache[targetID] = true
                    end
                    if wpn.SetWeaponAvatarID then wpn:SetWeaponAvatarID(targetID) end
                end
            end
        end
    end)
end

_G.ApplyOutfitSkins = function(pawn)
    if not _G.LexusConfig.EnableSkinChanger then return end
    if not slua.isValid(pawn) then return end
    pcall(function()
        local ac = pawn:getAvatarComponent2()
        if slua.isValid(ac) and ac.NetAvatarData then
            if _G.OutfitMap.Suit and _G.OutfitMap.Suit > 0 then
                if not _G.SkinLoadedCache[_G.OutfitMap.Suit] then
                    pcall(_G.download_item, _G.OutfitMap.Suit)
                    _G.SkinLoadedCache[_G.OutfitMap.Suit] = true
                end
                ac:PutOnCustomEquipmentByID(_G.OutfitMap.Suit, {})
            end
        end
    end)
end

-- ==================== MOD MENU (BANGDE STYLE) ====================
function _G.TryShowLegalCredit()  
    if _G.LegalShown then return end 
    pcall(function() 
        local Legal = require("client.slua.logic.common.logic_common_legal_msg") 
        local onRefuse = function() end 
        local onAccept = function() end 
        local content = table.concat({
            "╔════════════════════════════════════════════════════╗",
            "║        ULTIMATEZn_Knox MOD MENU V8                 ║",
            "║     Merged Edition - Best Features Combined        ║",
            "╠════════════════════════════════════════════════════╣",
            "║                                                    ║",
            "║  DJTEAM CREW:                                      ║",
            "║  @BANGDE_REALONE                                   ║",
            "║  @JECKYF                                           ║",
            "║                                                    ║",
            "╠════════════════════════════════════════════════════╣",
            "║  FEATURES:                                         ║",
            "║  ✓ Aimbot (LOW/MEDIUM/HARD/EXTREME + Strength)     ║",
            "║  ✓ Auto Aim (Head/Neck/Pelvis)                     ║",
            "║  ✓ No Recoil / No Shake                            ║",
            "║  ✓ Magic Bullet (70/120/180)                       ║",
            "║  ✓ IPAD View / FOV Changer (80-140)                ║",
            "║  ✓ No Grass / Black Sky                            ║",
            "║  ✓ Weapon Mods (FireSpeed, Instan Hit, etc.)       ║",
            "║  ✓ Wallhack + Wall ESP                             ║",
            "║  ✓ 165 FPS Unlock                                  ║",
            "║  ✓ Skin Changer                                    ║",
            "║                                                    ║",
            "╠════════════════════════════════════════════════════╣",
            "║         ENJOY & PLAY SAFE!                         ║",
            "╚════════════════════════════════════════════════════╝"
        }, "\n") 
        Legal.ShowOnePopUI({
            tabType = 999,
            title = "BANGDE MOD MENU V8",
            content = content,
            tipsText = nil,
            btnOKText = "OK",
            btnCancleText = "CLOSE",
            acceptFunc = onAccept,
            refuseFunc = onRefuse
        }) 
        _G.LegalShown = true 
    end) 
end

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if type(id) == "string" and not tonumber(id) then return id end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")

    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")

        -- CATEGORY 1: VISUAL MODS
        local VisualStack = {
            { Key = "ModMenu_FOV_Ex", UI = AliasMap.TitleSwitcher, Text = "IPAD VIEW / FOV", ExpandIndex = 0,
              GetFunc = function() return _G.LexusConfig.EnableFOV end,
              SetFunc = function(c, v) _G.LexusConfig.EnableFOV = v; if not v then _G.SetFOV(90) else _G.SetFOV(_G.LexusConfig.FOVValue) end; return true end },
            { Key = "ModMenu_FOV_Slider", UI = AliasMap.Slider, Text = "   FOV Value (80-140)", ExpandHandle = "ModMenu_FOV_Ex", MinValue = 0, MaxValue = 60,
              GetFunc = function() return (_G.LexusConfig.FOVValue or 110) - 80 end,
              SetFunc = function(c, v) local finalFOV = v + 80; _G.LexusConfig.FOVValue = finalFOV; if _G.LexusConfig.EnableFOV then _G.SetFOV(finalFOV) end; return true end },
            { Key = "ModMenu_Grass_Ex", UI = AliasMap.TitleSwitcher, Text = "NO GRASS",
              GetFunc = function() return _G.LexusConfig.EnableNoGrass end,
              SetFunc = function(c, v) _G.LexusConfig.EnableNoGrass = v; _G.DisableGrass(); return true end },
            { Key = "ModMenu_BlackSky", UI = AliasMap.TitleSwitcher, Text = "BLACK SKY",
              GetFunc = function() return _G.LexusConfig.EnableBlackSky end,
              SetFunc = function(c, v) _G.LexusConfig.EnableBlackSky = v; _G.BlackSky(); return true end },
            { Key = "ModMenu_165FPS", UI = AliasMap.TitleSwitcher, Text = "165 FPS UNLOCK",
              GetFunc = function() return _G.LexusConfig.Enable165FPS end,
              SetFunc = function(c, v) _G.LexusConfig.Enable165FPS = v; _G.Enable165FPS(); return true end },
        }

        -- CATEGORY 2: COMBAT MODS
        local CombatStack = {
            { Key = "ModMenu_AimConfig_Ex", UI = AliasMap.TitleSwitcher, Text = "AIMBOT", ExpandIndex = 0,
              GetFunc = function() return _G.LexusConfig.EnableAiming end,
              SetFunc = function(c, v) _G.LexusConfig.EnableAiming = v; _G.ApplyAimingConfig(); return true end },
            { Key = "ModMenu_AimbotStrength", UI = AliasMap.Slider, Text = "   Aimbot Strength (0-100)", ExpandHandle = "ModMenu_AimConfig_Ex", MinValue = 0, MaxValue = 100,
              GetFunc = function() return _G.LexusConfig.AimbotStrength or 50 end,
              SetFunc = function(c, v) _G.LexusConfig.AimbotStrength = v; _G.ApplyAimingConfig(); return true end },
            { Key = "ModMenu_Aim_Level_Title", UI = AliasMap.Title, Text = "   SPEED LEVEL", ExpandHandle = "ModMenu_AimConfig_Ex" },
            { Key = "ModMenu_Aim_Low", UI = AliasMap.Switcher, Text = "      [ LOW ]", ExpandHandle = "ModMenu_AimConfig_Ex",
              GetFunc = function() return _G.LexusConfig.AimingLevel == "LOW" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "LOW"; _G.LexusConfig.EnableAiming = true; _G.ApplyAimingConfig() end; return true end },
            { Key = "ModMenu_Aim_Med", UI = AliasMap.Switcher, Text = "      [ MEDIUM ]", ExpandHandle = "ModMenu_AimConfig_Ex",
              GetFunc = function() return _G.LexusConfig.AimingLevel == "MEDIUM" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "MEDIUM"; _G.LexusConfig.EnableAiming = true; _G.ApplyAimingConfig() end; return true end },
            { Key = "ModMenu_Aim_Hard", UI = AliasMap.Switcher, Text = "      [ HARD ]", ExpandHandle = "ModMenu_AimConfig_Ex",
              GetFunc = function() return _G.LexusConfig.AimingLevel == "HARD" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "HARD"; _G.LexusConfig.EnableAiming = true; _G.ApplyAimingConfig() end; return true end },
            { Key = "ModMenu_Aim_Ext", UI = AliasMap.Switcher, Text = "      [ EXTREME ]", ExpandHandle = "ModMenu_AimConfig_Ex",
              GetFunc = function() return _G.LexusConfig.AimingLevel == "EXTREME" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "EXTREME"; _G.LexusConfig.EnableAiming = true; _G.ApplyAimingConfig() end; return true end },
            { Key = "ModMenu_AutoAim_Ex", UI = AliasMap.TitleSwitcher, Text = "AUTO AIM", ExpandIndex = 0,
              GetFunc = function() return _G.LexusConfig.EnableAutoAim end,
              SetFunc = function(c, v) _G.LexusConfig.EnableAutoAim = v; _G.ApplyAutoAim(); return true end },
            { Key = "ModMenu_Bones_Title", UI = AliasMap.Title, Text = "   TARGET BONES", ExpandHandle = "ModMenu_AutoAim_Ex" },
            { Key = "ModMenu_Aim_Head", UI = AliasMap.Switcher, Text = "      [ HEAD ]", ExpandHandle = "ModMenu_AutoAim_Ex",
              GetFunc = function() return _G.LexusConfig.AutoAimBone == "Head" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.AutoAimBone = "Head"; _G.ApplyAutoAim() end; return true end },
            { Key = "ModMenu_Aim_Neck", UI = AliasMap.Switcher, Text = "      [ NECK ]", ExpandHandle = "ModMenu_AutoAim_Ex",
              GetFunc = function() return _G.LexusConfig.AutoAimBone == "neck_01" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.AutoAimBone = "neck_01"; _G.ApplyAutoAim() end; return true end },
            { Key = "ModMenu_Aim_Pelvis", UI = AliasMap.Switcher, Text = "      [ PELVIS ]", ExpandHandle = "ModMenu_AutoAim_Ex",
              GetFunc = function() return _G.LexusConfig.AutoAimBone == "pelvis" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.AutoAimBone = "pelvis"; _G.ApplyAutoAim() end; return true end },
            { Key = "ModMenu_Magic_Ex", UI = AliasMap.TitleSwitcher, Text = "MAGIC BULLET", ExpandIndex = 0,
              GetFunc = function() return _G.LexusConfig.EnableMagic end,
              SetFunc = function(c, v) _G.LexusConfig.EnableMagic = v; _G.ResetHitbox(); return true end },
            { Key = "ModMenu_Magic_Low", UI = AliasMap.Switcher, Text = "   [ LEVEL: LOW (70) ]", ExpandHandle = "ModMenu_Magic_Ex",
              GetFunc = function() return _G.LexusConfig.MagicLevel == 70 end,
              SetFunc = function(c, v) if v then _G.ResetHitbox(); _G.LexusConfig.MagicLevel = 70 end; return true end },
            { Key = "ModMenu_Magic_Med", UI = AliasMap.Switcher, Text = "   [ LEVEL: MEDIUM (120) ]", ExpandHandle = "ModMenu_Magic_Ex",
              GetFunc = function() return _G.LexusConfig.MagicLevel == 120 end,
              SetFunc = function(c, v) if v then _G.ResetHitbox(); _G.LexusConfig.MagicLevel = 120 end; return true end },
            { Key = "ModMenu_Magic_High", UI = AliasMap.Switcher, Text = "   [ LEVEL: HARD (180) ]", ExpandHandle = "ModMenu_Magic_Ex",
              GetFunc = function() return _G.LexusConfig.MagicLevel == 180 end,
              SetFunc = function(c, v) if v then _G.ResetHitbox(); _G.LexusConfig.MagicLevel = 180 end; return true end },
            { Key = "ModMenu_Recoil_Ex", UI = AliasMap.TitleSwitcher, Text = "NO RECOIL", ExpandIndex = 0,
              GetFunc = function() return _G.LexusConfig.EnableNoRecoil end,
              SetFunc = function(c, v) _G.LexusConfig.EnableNoRecoil = v; _G.ApplyNoRecoil(); return true end },
            { Key = "ModMenu_NoShake", UI = AliasMap.Switcher, Text = "   [ NO SHAKE ]", ExpandHandle = "ModMenu_Recoil_Ex",
              GetFunc = function() return _G.LexusConfig.EnableNoShake end,
              SetFunc = function(c, v) _G.LexusConfig.EnableNoShake = v; _G.ApplyNoRecoil(); return true end },
            { Key = "ModMenu_Recoil_Less", UI = AliasMap.Switcher, Text = "   [ LESS RECOIL ]", ExpandHandle = "ModMenu_Recoil_Ex",
              GetFunc = function() return _G.LexusConfig.RecoilLevel == "LESS" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.RecoilLevel = "LESS"; _G.LexusConfig.EnableNoRecoil = true; _G.ApplyNoRecoil() end; return true end },
            { Key = "ModMenu_Recoil_No", UI = AliasMap.Switcher, Text = "   [ NO RECOIL ]", ExpandHandle = "ModMenu_Recoil_Ex",
              GetFunc = function() return _G.LexusConfig.RecoilLevel == "NO" end,
              SetFunc = function(c, v) if v then _G.LexusConfig.RecoilLevel = "NO"; _G.LexusConfig.EnableNoRecoil = true; _G.ApplyNoRecoil() end; return true end },
        }

        -- CATEGORY 3: ESP & WALLHACK
        local ESPStack = {
            { Key = "ModMenu_Wallhack", UI = AliasMap.TitleSwitcher, Text = "WALLHACK",
              GetFunc = function() return _G.LexusConfig.EnableWallhack end,
              SetFunc = function(c, v) _G.LexusConfig.EnableWallhack = v; return true end },
            { Key = "ModMenu_ESP", UI = AliasMap.TitleSwitcher, Text = "WALL ESP",
              GetFunc = function() return _G.LexusConfig.EnableESP end,
              SetFunc = function(c, v) _G.LexusConfig.EnableESP = v; return true end },
            { Key = "Title_ESP_Colors", UI = AliasMap.Title, Text = "CHAMS COLORS" },
            { Key = "ModMenu_GreenColor", UI = AliasMap.Switcher, Text = "   GREEN (Visible Enemies)",
              GetFunc = function() return _G.LexusConfig.EnableChamsGreen end,
              SetFunc = function(c, v) _G.LexusConfig.EnableChamsGreen = v; return true end },
            { Key = "ModMenu_GreenR", UI = AliasMap.Slider, Text = "      Green-R (0-255)", MinValue = 0, MaxValue = 255,
              GetFunc = function() return _G.LexusConfig.ChamsGreenRGB.R or 0 end,
              SetFunc = function(c, v) _G.LexusConfig.ChamsGreenRGB.R = v; return true end },
            { Key = "ModMenu_GreenG", UI = AliasMap.Slider, Text = "      Green-G (0-255)", MinValue = 0, MaxValue = 255,
              GetFunc = function() return _G.LexusConfig.ChamsGreenRGB.G or 255 end,
              SetFunc = function(c, v) _G.LexusConfig.ChamsGreenRGB.G = v; return true end },
            { Key = "ModMenu_GreenB", UI = AliasMap.Slider, Text = "      Green-B (0-255)", MinValue = 0, MaxValue = 255,
              GetFunc = function() return _G.LexusConfig.ChamsGreenRGB.B or 0 end,
              SetFunc = function(c, v) _G.LexusConfig.ChamsGreenRGB.B = v; return true end },
            { Key = "ModMenu_YellowColor", UI = AliasMap.Switcher, Text = "   YELLOW (Hidden Enemies)",
              GetFunc = function() return _G.LexusConfig.EnableChamsYellow end,
              SetFunc = function(c, v) _G.LexusConfig.EnableChamsYellow = v; return true end },
            { Key = "ModMenu_YellowR", UI = AliasMap.Slider, Text = "      Yellow-R (0-255)", MinValue = 0, MaxValue = 255,
              GetFunc = function() return _G.LexusConfig.ChamsYellowRGB.R or 255 end,
              SetFunc = function(c, v) _G.LexusConfig.ChamsYellowRGB.R = v; return true end },
            { Key = "ModMenu_YellowG", UI = AliasMap.Slider, Text = "      Yellow-G (0-255)", MinValue = 0, MaxValue = 255,
              GetFunc = function() return _G.LexusConfig.ChamsYellowRGB.G or 255 end,
              SetFunc = function(c, v) _G.LexusConfig.ChamsYellowRGB.G = v; return true end },
            { Key = "ModMenu_YellowB", UI = AliasMap.Slider, Text = "      Yellow-B (0-255)", MinValue = 0, MaxValue = 255,
              GetFunc = function() return _G.LexusConfig.ChamsYellowRGB.B or 0 end,
              SetFunc = function(c, v) _G.LexusConfig.ChamsYellowRGB.B = v; return true end },
        }

        -- CATEGORY 4: WEAPON MODS
        local WeaponStack = {
            { Key = "ModMenu_Weapon_Ex", UI = AliasMap.TitleSwitcher, Text = "WEAPON MODS", ExpandIndex = 0,
              GetFunc = function() return _G.LexusConfig.EnableWeaponMod end,
              SetFunc = function(c, v) _G.LexusConfig.EnableWeaponMod = v; return true end },
            -- AKM (101001)
            { Key = "ModMenu_W101001_Title", UI = AliasMap.Title, Text = "AKM", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101001_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101001].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101001].FireSpeed = v; return true end },
            { Key = "ModMenu_W101001_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101001].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101001].InstanHit = v; return true end },
            { Key = "ModMenu_W101001_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101001].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101001].FastSwitch = v; return true end },
            { Key = "ModMenu_W101001_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101001].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101001].FastScope = v; return true end },
            -- M416 (101004)
            { Key = "ModMenu_W101004_Title", UI = AliasMap.Title, Text = "M416", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101004_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101004].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101004].FireSpeed = v; return true end },
            { Key = "ModMenu_W101004_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101004].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101004].InstanHit = v; return true end },
            { Key = "ModMenu_W101004_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101004].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101004].FastSwitch = v; return true end },
            { Key = "ModMenu_W101004_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101004].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101004].FastScope = v; return true end },
            -- SCAR-L (101003)
            { Key = "ModMenu_W101003_Title", UI = AliasMap.Title, Text = "SCAR-L", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101003_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101003].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101003].FireSpeed = v; return true end },
            { Key = "ModMenu_W101003_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101003].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101003].InstanHit = v; return true end },
            { Key = "ModMenu_W101003_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101003].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101003].FastSwitch = v; return true end },
            { Key = "ModMenu_W101003_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101003].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101003].FastScope = v; return true end },
            -- Groza (101005)
            { Key = "ModMenu_W101005_Title", UI = AliasMap.Title, Text = "GROZA", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101005_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101005].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101005].FireSpeed = v; return true end },
            { Key = "ModMenu_W101005_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101005].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101005].InstanHit = v; return true end },
            { Key = "ModMenu_W101005_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101005].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101005].FastSwitch = v; return true end },
            { Key = "ModMenu_W101005_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101005].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101005].FastScope = v; return true end },
            -- AUG (101006)
            { Key = "ModMenu_W101006_Title", UI = AliasMap.Title, Text = "AUG", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101006_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101006].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101006].FireSpeed = v; return true end },
            { Key = "ModMenu_W101006_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101006].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101006].InstanHit = v; return true end },
            { Key = "ModMenu_W101006_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101006].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101006].FastSwitch = v; return true end },
            { Key = "ModMenu_W101006_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101006].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101006].FastScope = v; return true end },
            -- QBZ (101007)
            { Key = "ModMenu_W101007_Title", UI = AliasMap.Title, Text = "QBZ", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101007_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101007].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101007].FireSpeed = v; return true end },
            { Key = "ModMenu_W101007_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101007].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101007].InstanHit = v; return true end },
            { Key = "ModMenu_W101007_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101007].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101007].FastSwitch = v; return true end },
            { Key = "ModMenu_W101007_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101007].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101007].FastScope = v; return true end },
            -- M762 (101008)
            { Key = "ModMenu_W101008_Title", UI = AliasMap.Title, Text = "M762", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101008_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101008].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101008].FireSpeed = v; return true end },
            { Key = "ModMenu_W101008_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101008].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101008].InstanHit = v; return true end },
            { Key = "ModMenu_W101008_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101008].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101008].FastSwitch = v; return true end },
            { Key = "ModMenu_W101008_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101008].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101008].FastScope = v; return true end },
            -- Mk47 Mutant (101009)
            { Key = "ModMenu_W101009_Title", UI = AliasMap.Title, Text = "MK47 MUTANT", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101009_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101009].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101009].FireSpeed = v; return true end },
            { Key = "ModMenu_W101009_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101009].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101009].InstanHit = v; return true end },
            { Key = "ModMenu_W101009_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101009].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101009].FastSwitch = v; return true end },
            { Key = "ModMenu_W101009_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101009].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101009].FastScope = v; return true end },
            -- G36C (101010)
            { Key = "ModMenu_W101010_Title", UI = AliasMap.Title, Text = "G36C", ExpandHandle = "ModMenu_Weapon_Ex" },
            { Key = "ModMenu_W101010_F", UI = AliasMap.Switcher, Text = "   FIRESPEED", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101010].FireSpeed end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101010].FireSpeed = v; return true end },
            { Key = "ModMenu_W101010_I", UI = AliasMap.Switcher, Text = "   INSTAN HIT", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101010].InstanHit end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101010].InstanHit = v; return true end },
            { Key = "ModMenu_W101010_S", UI = AliasMap.Switcher, Text = "   FAST SWITCH", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101010].FastSwitch end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101010].FastSwitch = v; return true end },
            { Key = "ModMenu_W101010_O", UI = AliasMap.Switcher, Text = "   FAST SCOPE", ExpandHandle = "ModMenu_Weapon_Ex", GetFunc = function() return _G.LexusConfig.WeaponMod[101010].FastScope end, SetFunc = function(c, v) _G.LexusConfig.WeaponMod[101010].FastScope = v; return true end },
        }

        -- CATEGORY 5: SKINS
        local SkinStack = {
            { Key = "ModMenu_Skin_Ex", UI = AliasMap.TitleSwitcher, Text = "SKIN CHANGER", ExpandIndex = 0,
              GetFunc = function() return _G.LexusConfig.EnableSkinChanger end,
              SetFunc = function(c, v) _G.LexusConfig.EnableSkinChanger = v; return true end },
            { Key = "ModMenu_Suit_Title", UI = AliasMap.Title, Text = "OUTFIT SKINS", ExpandHandle = "ModMenu_Skin_Ex" },
            { Key = "ModMenu_Suit", UI = AliasMap.Input, Text = "   Suit ID (Outfit)", ExpandHandle = "ModMenu_Skin_Ex", DefaultText = "Enter Suit ID",
              GetFunc = function() return tostring(_G.OutfitMap.Suit or "") end,
              SetFunc = function(c, v) local num = tonumber(v); if num then _G.OutfitMap.Suit = num end; return true end },
            { Key = "ModMenu_Weapon_Title", UI = AliasMap.Title, Text = "WEAPON SKINS", ExpandHandle = "ModMenu_Skin_Ex" },
            { Key = "ModMenu_M416_Skin", UI = AliasMap.Input, Text = "   M416 Skin ID", ExpandHandle = "ModMenu_Skin_Ex", DefaultText = "Enter Skin ID",
              GetFunc = function() return tostring(_G.WeaponSkinMap[101004] or "") end,
              SetFunc = function(c, v) local num = tonumber(v); if num then _G.WeaponSkinMap[101004] = num end; return true end },
            { Key = "ModMenu_AKM_Skin", UI = AliasMap.Input, Text = "   AKM Skin ID", ExpandHandle = "ModMenu_Skin_Ex", DefaultText = "Enter Skin ID",
              GetFunc = function() return tostring(_G.WeaponSkinMap[101001] or "") end,
              SetFunc = function(c, v) local num = tonumber(v); if num then _G.WeaponSkinMap[101001] = num end; return true end },
            { Key = "ModMenu_SCAR_Skin", UI = AliasMap.Input, Text = "   SCAR-L Skin ID", ExpandHandle = "ModMenu_Skin_Ex", DefaultText = "Enter Skin ID",
              GetFunc = function() return tostring(_G.WeaponSkinMap[101003] or "") end,
              SetFunc = function(c, v) local num = tonumber(v); if num then _G.WeaponSkinMap[101003] = num end; return true end },
        }

        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            loc = "BANGDE MOD MENU V8",
            UIKey = "Setting_Page_Privacy",
            Category = {
                { Key = "Cat_Visual", loc = "VISUAL MODS", Stack = VisualStack },
                { Key = "Cat_Combat", loc = "COMBAT MODS", Stack = CombatStack },
                { Key = "Cat_ESP", loc = "ESP & WALLHACK", Stack = ESPStack },
                { Key = "Cat_Weapon", loc = "WEAPON MODS", Stack = WeaponStack },
                { Key = "Cat_Skin", loc = "SKINS", Stack = SkinStack }
            }
        }

        table.insert(SettingCatalog, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...)
            if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do if type(page) == "table" and page.Key == "ModMenu" then hasModMenu = true; break end end
                    if not hasModMenu then table.insert(catalog, SettingPageDefine.ModMenu) end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end

-- ==================== TICK FUNCTIONS ====================
local function OnTick()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    
    if _G.LexusConfig.EnableFOV then
        _G.SetFOV(_G.LexusConfig.FOVValue)
    end
    
    if _G.LexusConfig.EnableWeaponMod then
        _G.otherWeapon()
    end
    
    if _G.LexusConfig.EnableAiming then
        _G.ApplyAimingConfig()
    end
    
    if _G.LexusConfig.EnableNoRecoil then
        _G.ApplyNoRecoil()
    end
    
    if _G.LexusConfig.EnableMagic then
        _G.Magic()
    end
    
    if _G.LexusConfig.EnableAutoAim then
        _G.ApplyAutoAim()
    end
    
    if _G.LexusConfig.EnableSkinChanger then
        _G.ApplyWeaponSkins(player)
        _G.ApplyOutfitSkins(player)
    end
    
    _G.DisableGrass()
    _G.BlackSky()
    
    if _G.LexusConfig.Enable165FPS then
        _G.Enable165FPS()
    end
end

local function StartESPTimer()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) then
        if _G._ESPTimerHandle then pcall(function() pc:RemoveGameTimer(_G._ESPTimerHandle) end) end
        _G._ESPTimerHandle = pc:AddGameTimer(0.15, true, function() pcall(ESPTick) end)
    end
end

local function StartMainTimer()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) then
        if _G._MainTimerHandle then pcall(function() pc:RemoveGameTimer(_G._MainTimerHandle) end) end
        _G._MainTimerHandle = pc:AddGameTimer(0.1, true, function() pcall(OnTick) end)
        StartESPTimer()
    end
end

-- ==================== INITIALIZATION ====================
local M = {}

function M.OnBeginPlay(self)
    _G.InitModMenuTab()
    _G.TryShowLegalCredit()
    _G.TryBypassMD5()
    _G.BypassCacheMD5()
    _G.BypassSecurityUtils()
    _G.BypassHiggsComponent()
    BypassTelemetry()
    StartMainTimer()
end

return M
