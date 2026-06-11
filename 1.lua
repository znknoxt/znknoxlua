local function ApplyVisualMods(localPlayer, enemy, pc, mWh, mWp)
    if not Valid(enemy) then return end
    local meshes = {}
    pcall(function()
        if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
        local SkelClass = import("SkeletalMeshComponent")
        if SkelClass then
            local childs = enemy:GetComponentsByClass(SkelClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for c = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(c-1) or childs[c]
                    if Valid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
                end
            end
        end
    end)
    local isEnabled = mWh or mWp
    if isEnabled then
        local depthTest = mWh
        local blendMode = mWh and 2 or 1
        pcall(function()
            for _, comp in ipairs(meshes) do
                if Valid(comp) then
                    local s, matInterface = pcall(function() return comp:GetMaterial(0) end)
                    if s and Valid(matInterface) then
                        local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                        if s2 and Valid(baseMat) then
                            if baseMat.bDisableDepthTest ~= depthTest then baseMat.bDisableDepthTest = depthTest end
                            if baseMat.BlendMode ~= blendMode then baseMat.BlendMode = blendMode end
                        end
                    end
                end
            end
        end)
        pcall(function()
            for _, comp in ipairs(meshes) do
                if Valid(comp) then
                    comp.UseScopeDistanceCulling = false 
                    comp.PrimitiveShadingStrategy = 1; comp.ShadingRate = 6
                end
            end
            local finalColor
            if mWh then
                local isVisible = false
                if Valid(pc) and Valid(enemy) and type(pc.LineOfSightTo) == "function" then pcall(function() isVisible = pc:LineOfSightTo(enemy) end) end
                local hiddenColor  = { R = 25.0, G = 0.0,  B = 25.0, A = 1.0, r = 25.0, g = 0.0,  b = 25.0, a = 1.0 }
                local visibleColor = { R = 0.0,  G = 25.0, B = 25.0, A = 1.0, r = 0.0,  g = 25.0, b = 25.0, a = 1.0 }
                finalColor = isVisible and visibleColor or hiddenColor
            else
                finalColor = { R = 50.0, G = 50.0, B = 50.0, A = 1.0, r = 50.0, g = 50.0, b = 50.0, a = 1.0 }
            end
            local scale = { R = 3.0,  G = 3.0,  B = 0.0,  A = 0.0, r = 3.0,  g = 3.0,  b = 0.0,  a = 0.0 }
            enemy.WH_MIDs = enemy.WH_MIDs or {}
            local stateChanged = (enemy.WH_LastColorR ~= finalColor.R) or (enemy.WH_LastBlendMode ~= blendMode)
            for _, comp in ipairs(meshes) do
                if Valid(comp) then
                    local compKey = tostring(comp)
                    enemy.WH_MIDs[compKey] = enemy.WH_MIDs[compKey] or {}
                    for i = 0, 10 do 
                        local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                        if not s or not Valid(matInterface) then break end
                        local isNewMID = false; local needCacheUpdate = false; local currentCached = enemy.WH_MIDs[compKey][i]
                        if not Valid(currentCached) then
                            local s2, newMid = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                            if s2 and Valid(newMid) then enemy.WH_MIDs[compKey][i] = newMid; currentCached = newMid; isNewMID = true; needCacheUpdate = true end
                        else
                            if matInterface ~= currentCached then pcall(function() comp:SetMaterial(i, currentCached) end); needCacheUpdate = true end
                        end
                        if Valid(currentCached) and (stateChanged or isNewMID or needCacheUpdate) then
                            pcall(function()
                                currentCached:SetVectorParameterValue("颜色", finalColor); currentCached:SetVectorParameterValue("Extra Light Color", finalColor)
                                currentCached:SetVectorParameterValue("Para_Color", finalColor); currentCached:SetVectorParameterValue("Para_ColorTint", finalColor)
                                currentCached:SetVectorParameterValue("Para_Color_1", finalColor); currentCached:SetVectorParameterValue("Tint", finalColor)
                                currentCached:SetVectorParameterValue("Color", finalColor); currentCached:SetVectorParameterValue("BaseColor", finalColor)
                                currentCached:SetVectorParameterValue("BodyColor", finalColor); currentCached:SetVectorParameterValue("MainColor", finalColor)
                                currentCached:SetVectorParameterValue("DiffuseColor", finalColor); currentCached:SetVectorParameterValue("EmissiveColor", finalColor)
                                currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                            end)
                        end
                    end
                end
            end
            if stateChanged then enemy.WH_LastColorR = finalColor.R; enemy.WH_LastBlendMode = blendMode end
        end)
    else
        pcall(function()
            for _, comp in ipairs(meshes) do
                if Valid(comp) then
                    local s, matInterface = pcall(function() return comp:GetMaterial(0) end)
                    if s and Valid(matInterface) then
                        local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                        if s2 and Valid(baseMat) then
                            if baseMat.bDisableDepthTest ~= false then baseMat.bDisableDepthTest = false end
                            if baseMat.BlendMode ~= 1 then baseMat.BlendMode = 1 end
                        end
                    end
                end
            end
        end)
        enemy.WH_LastColorR = nil; enemy.WH_LastBlendMode = nil; enemy.WH_MIDs = nil
    end
end
