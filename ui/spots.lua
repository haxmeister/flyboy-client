
local spots= {}
local sector = {}
sector.new = function(sectorName, spotList)
    local box = iup.hudrightframe{
        expand = "NO",
        iup.vbox{
            iup.label{
                title = sectorName,
                font=Font.H3*HUD_SCALE*1.00,
                alignment="ALEFT",
                expand="HORIZONTAL",
                bgcolor="4 0 0 ",
                fgcolor=FactionColor_RGB[GetSectorAlignment()],
            },
            iup.label{title = "some spot"},
            iup.label{title = "another sdfsdfdsf spot"},
            iup.label{title = "more spot"},
        }
    }
    return box
end

spots.holder = iup.vbox {
    --visible="YES",
    iup.fill { size="%80" },
    iup.hbox {
        iup.fill {},

        sector.new("Dau L-10",""),iup.fill {size = 3},
        sector.new("Dau L-10",""),iup.fill {size = 3},
        sector.new("Dau L-10",""),

        iup.fill {},
    },
    iup.fill {},
    alignment="ACENTER",
    gap=2
}

spots.update = function(data)
    print ("recieved spots")
end


iup.Append(HUD.pluginlayer, spots.holder)
return spots
