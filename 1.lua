-- ============================================
-- 2.lua - MAGIC BULLET (Enlarged Hitboxes)
-- ============================================

print("[2.lua] Loading Magic Bullet...")

local function EnableMagicBullet()
    pcall(function()
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
                        local assetName = physAsset:GetName() or tostring(physAsset)
                        if not _G._MBones[assetName] then
                            local mb = {
                                ["head"] = 200,
                                ["neck"] = 150,
                                ["spine"] = 150,
                                ["arm"] = 150,
                                ["leg"] = 150,
                            }
                            local setups = physAsset.SkeletalBodySetups
                            for i = 1, 80 do
                                local bs = setups:Get(i-1)
                                if not bs then break end
                                local bn = tostring(bs.BoneName):lower()
                                local pct = nil
                                for pat, val in pairs(mb) do
                                    if string.find(bn, pat) then pct = val; break end
                                end
                                if pct then
                                    local sc = 1.0 + pct / 100.0
                                    if bs.AggGeom and bs.AggGeom.BoxElems then
                                        local box = bs.AggGeom.BoxElems:Get(0)
                                        if box then
                                            box.X = (box.X or 30) * sc
                                            box.Y = (box.Y or 30) * sc
                                            box.Z = (box.Z or 60) * sc
                                            bs.AggGeom.BoxElems:Set(0, box)
                                        end
                                    end
                                    if bs.AggGeom and bs.AggGeom.SphylElems then
                                        local sphyl = bs.AggGeom.SphylElems:Get(0)
                                        if sphyl and sphyl.Radius then
                                            sphyl.Radius = sphyl.Radius * sc
                                            bs.AggGeom.SphylElems:Set(0, sphyl)
                                        end
                                    end
                                end
                            end
                            _G._MBones[assetName] = true
                            mesh:RecreatePhysicsState()
                            print("[MAGIC] Hitboxes enlarged for:", assetName)
                        end
                    end
                end
            end
        end
    end)
end

-- Run magic bullet every 0.1 seconds
local pc = slua_GameFrontendHUD:GetPlayerController()
if slua.isValid(pc) and pc.AddGameTimer then
    pc:AddGameTimer(0.1, true, EnableMagicBullet)
    print("[2.lua] Magic Bullet loaded - 200% larger hitboxes")
end
