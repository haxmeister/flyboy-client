--[[

--]]

-- tables for targetlist tabs
Flyboy.MDItargetlist = Flyboy.MDItargetlist or {
    unrats = {},
    players = {},
}

Flyboy.MDItargetlist.unrats.tab_definition = {
    title = "Unrats",
    controls = "linked" or "unlinked",  -- (optional) force the tab to use linked or unlinked selection
     columns = { -- Only 3 columns.  Width can be 0 and title can be empty.
        {
            title = "col1",
            width = 0.2,
        },
        {
            title = "col2",
            width = 0.7,
        },
        {
            title = "col3",
            width = 0.1,
        },
    },

}

Flyboy.MDItargetlist.players.tab_definition = {
   title = "Players",
    controls = "linked" or "unlinked",  -- (optional) force the tab to use linked or unlinked selection
     columns = { -- Only 3 columns.  Width can be 0 and title can be empty.
        {
            title = "Location",
            width = 0.2,
        },
        {
            title = "Name/Ship",
            width = 0.8,
        },

    },
}

Flyboy.MDItargetlist.players_seen = {}
Flyboy.MDItargetlist.unrats_seen = {}

-- recieves a table from the FB_PLAYER_SPOTS event and
-- structures it suitable for targetlist and calls its updating function
Flyboy.MDItargetlist.players_update = function(data)
    local targetlist_players = {}
    for sector, sector_players in pairs(data) do
        for name, details in pairs (sector_players)do
            local health_color = rgbtohex (calc_health_color(tonumber(details.health), 255, "") )
            local player = {
                details.sectorFactionColor..sector,
                details.factionColor.."["..details.guild.."]"..name.." "..health_color..details.ship,
                highlight  = false ,
                pin        = false ,
            }
            table.insert(targetlist_players, player)
        end
    end
    Flyboy.MDItargetlist.players_seen = targetlist_players
    targetlist.API.UpdateDisplay(Flyboy.MDItargetlist.players.tab_definition, targetlist_players)
end

function Flyboy.MDItargetlist.unrats.load(event, data)
    if isdeclared("targetlist")then
        targetlist.API.RegisterTab(Flyboy.MDItargetlist.unrats.tab_definition)
    end
end

function Flyboy.MDItargetlist.players.load(event, data)
    print("Flyboy.MDItargetlist.players.load")
    if isdeclared("targetlist")then
        targetlist.API.RegisterTab(Flyboy.MDItargetlist.players.tab_definition)
    end
end

RegisterEvent(Flyboy.MDItargetlist.unrats.load, "PLUGINS_LOADED")
RegisterEvent(Flyboy.MDItargetlist.players.load, "PLUGINS_LOADED")

return Flyboy.MDItargetlist
