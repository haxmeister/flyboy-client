--[[
flyboy
By Haxmeister
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


-- list window

flyboy.List = flyboy.List or {}

local alpha, selalpha = ListColors.Alpha, ListColors.SelectedAlpha
local even, odd, sel = ListColors[0], ListColors[1], ListColors[2]

flyboy.List.bg = {
    [0] = even.." "..alpha,
    [1] = odd.." "..alpha,
    [2] = sel.." "..selalpha
}

flyboy.List.List = flyboy.List.List or iup.pdasubsubmatrix {
    numcol=3,
    expand='YES',
    edit_mode='NO',
    bgcolor='0 0 0 128 *',
    edition_cb = function()
        return iup.IGNORE
    end,
    enteritem_cb = function(self, line, col)
        self:setattribute("BGCOLOR", line, -1, flyboy.List.bg[2])
    end,
    leaveitem_cb = function(self, line, col)
        self:setattribute("BGCOLOR", line, -1, flyboy.List.bg[math.fmod(line,2)])
    end

    --
    --click_cb = function(self, line, col)
        --if line == 0 then
            ---- Click on header
            --if sortd == -1 then
                --sortd = 1
            --elseif sortd == 1 then
                --sortd = -1
            --end
            --flyboy.List.Sort(flyboy.List.List,col,sortd)
        --else
            ---- Not header - select a line
        --end
    --end

}

flyboy.List.List['0:1'] = 'Sector'
flyboy.List.List['0:2'] = 'Roids'
flyboy.List.List['0:3'] = 'Max'

flyboy.List.List['ALIGNMENT1'] = 'ALEFT'
flyboy.List.List['ALIGNMENT3'] = 'ARIGHT'
flyboy.List.List['WIDTH'.. 1]='100'
flyboy.List.List['WIDTH'.. 2]='50'
flyboy.List.List['WIDTH'.. 3]='50'


flyboy.List.closeBtn = flyboy.List.closeBtn or iup.stationbutton {
    title = "Close",
    ALIGNMENT="ACENTER",
    EXPAND="NO",
    action = function(self)
        HideDialog(flyboy.List.ListWindow)
    end
}

flyboy.List.ListWindow = flyboy.List.ListWindow or iup.dialog{
    iup.hbox {
        iup.fill {},
        iup.vbox {
            iup.fill {},
            iup.stationhighopacityframe{
                expand="NO",
                size="x500",
                iup.stationhighopacityframebg{
                    iup.vbox { margin="15x15",
                        iup.hbox {
                            iup.fill{}, iup.label { title="Ores Found", font=Font.H3 }, iup.fill{},
                        },
                        iup.fill { size="15" },
                        iup.hbox {
                            flyboy.List.List,
                        },
                        iup.fill { size="15" },
                        iup.hbox {
                            iup.fill {},
                            flyboy.List.closeBtn,
                            iup.fill {},
                        },
                    },
                },
            },
            iup.fill {},
        },
        iup.fill {},
    },
    border="NO",menubox="NO",resize="NO",
    defaultesc=flyboy.List.closeBtn,
    topmost="YES",
    modal="YES",
    alignment="ACENTER",
    bgcolor="0 0 0 92 *",
    fullscreen="YES"
}
flyboy.List.ListWindow:map()





--RegisterEvent(flyboy.Notifier.TargetChanged, "TARGET_CHANGED")
