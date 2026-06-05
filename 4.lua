
local function InitModMenuTab()
    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if type(id) == "string" and not tonumber(id) then
                return id
            end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        local ModMenuStack = {
            { UI = AliasMap.Title, Text = "SETTING" },
            {
                Key = "ModMenu_Aimbot",
                UI = AliasMap.Switcher,
                Text = "AIMBOT",
                GetFunc = function() return _G.Mod_Aimbot_Enabled or false end,
                SetFunc = function(_, value)
                    _G.Mod_Aimbot_Enabled = value
                    return true
                end
            },
            {
                Key = "ESP",
                UI = AliasMap.Switcher,
                Text = " WALL",
                GetFunc = function() return _G.Mod_ESP_Enabled or false end,
                SetFunc = function(_, value)
                    _G.Mod_ESP_Enabled = value
                    return true
                end
            },
            {
                Key = "Title_ESP_Colors",
                UI = AliasMap.TitleSwitcher,
                Text = "COLOR",
                ExpandIndex = 0,
                GetFunc = function() return _G.Mod_ESP_Color_Expand or false end, 
                SetFunc = function(_, value) 
                    _G.Mod_ESP_Color_Expand = value
                    return true 
                end
            }
        }
        
        local colorNames = {"RED", "YELLOW"}
        for i, colorName in ipairs(colorNames) do
            table.insert(ModMenuStack, {
                Key = "ModMenu_Color_" .. i,
                UI = AliasMap.Switcher,
                Text = "       " .. colorName,
                ExpandHandle = "Title_ESP_Colors",
                GetFunc = function()
                    return (_G.Mod_ESP_Color_Index or 1) == i
                end,
                SetFunc = function(_, value)
                    if value then
                        _G.Mod_ESP_Color_Index = i
                        if _G.EventSystem and _G.EVENTTYPE_SETTING and _G.EVENTID_SETTING_OPTION_FORCEUPDATE then
                            for j = 1, #colorNames do
                                _G.EventSystem:postEvent(_G.EVENTTYPE_SETTING, _G.EVENTID_SETTING_OPTION_FORCEUPDATE, "ModMenu_Color_" .. j)
                            end
                        end
                    end
                    return true
                end
            })
        end
        
        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            loc = "MENU CHEAT",
            UIKey = "Setting_Page_Privacy", 
            Category = {
                {
                    Key = "ModMenu_Main",
                    loc = "SETTING", 
                    Stack = ModMenuStack
                }
            }
        }
        
        table.insert(SettingCatalog, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                local catalog = args[1]
                if catalog and (type(catalog) == "table" or type(catalog) == "userdata") then
                    local hasModMenu = false
                    local newCatalog = {}
                    for _, page in ipairs(catalog) do
                        table.insert(newCatalog, page)
                        if page.Key == "ModMenu" then
                            hasModMenu = true
                        end
                    end
                    
                    if not hasModMenu then
                        table.insert(newCatalog, SettingPageDefine.ModMenu)
                        args[1] = newCatalog
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args))
        end
        UIManager._IsModMenuHooked = true
    end
end

InitModMenuTab()
