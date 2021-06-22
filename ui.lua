--[[
flyboy 2.0
By TheRedSpy
]]


flyboy.UI = flyboy.UI or {}
flyboy.UI.Display = flyboy.UI.Display or {}
flyboy.UI.NotifyTimer = Timer()

flyboy.UI.Init = function()
    if (flyboy.UI.NotifyHolder==nil) then
        flyboy.UI.NotifyHolder = iup.vbox { margin="8x4", expand="YES", alignment="ALEFT" }
        flyboy.UI.NotifyHolder2 = iup.vbox {
            visible="NO",
            iup.fill { size="%80" },
            iup.hbox {
                iup.fill {},
                iup.hudrightframe {
                    border="2 2 2 2",
                    iup.vbox {
                        expand="NO",
                        iup.hudrightframe {
                            border="0 0 0 0",
                            iup.hbox {
                                flyboy.UI.NotifyHolder,
                            },
                        },
                    },
                },
                iup.fill {},
            },
            iup.fill {},
            alignment="ACENTER",
            gap=2
        }
        iup.Append(HUD.pluginlayer, flyboy.UI.NotifyHolder2)
    end
        -- warranty status window
flyboy.Notifier.UpdateNotifyDisplayTimer:SetTimeout(1500, flyboy.Notifier.UpdateNotifyDisplay)
end
