

Flyboy.Events = {

    -- an updated table of player spots has been received from the server
    FB_PLAYER_SPOTS = function (event, data)
        Flyboy.MDItargetlist.players_update(data)
        --Flyboy.ui.update(data)
    end,


    -- flyboy HUD messages may come from the server or the plugin itself
    FB_HUD_MSG = function (event, data)
        if (data.type == "error") then
            pcall(function() HUD:PrintSecondaryMsg("\127FF7E00Flyboy\1270080FF | \127FF0001" .. data.str) end)
        else
            pcall(function() HUD:PrintSecondaryMsg("\127FF7E00Flyboy\1270080FF | \127dddddd" .. data.str) end)
        end
    end,

    -- flyboy chatbox messages may come from the server or the plugin itself
    FB_CHATBOX_MSG = function (event, data)
        if (data.type == "error") then
            print("\127FF7E00Flyboy\1270080FF | \127FF0001" .. data.str)
        else
            print("\127FF7E00Flyboy\1270080FF | \127dddddd" .. data.str)
        end
    end,

    -- flyboy has connected to the server
    FB_CONNECTED = function (event, data)
        ProcessEvent("FB_HUD_MSG", {type = "clear", str = data.str })
    end,

    -- flyboy has disconnected from the server
    FB_DISCONNECTED = function(event, data)
        ProcessEvent("FB_HUD_MSG", {type = "error", str = data.str })
    end,


    -- server reports that unrats have been seen
    FB_UNRATS_SEEN = function (event, data)

    -- data contains a structure like this: {"dentLocation":"unknown","location":"unknown"}
        if (tostring(data.dentLocation) ~= "unknown")then
            ProcessEvent("FB_CHATBOX_MSG", {type = "clear", str = "Unrat trident seen at"..data.dentLocation })
        end

        if (tostring(data.location) ~= "unknown")then
            ProcessEvent("FB_CHATBOX_MSG", {type = "clear", str = "Unrats seen at"..data.location })
        end
    end,

    FB_ALLIANCE_CHAT_RECV = function(event, data)
        print ("chat from server arrived")
        print (json.encode(data))
        ProcessEvent("ALLIANCE_CHAT_RECV", data)
    end,

    -- an alliance chat message has been recieved
    ALLIANCE_CHAT_SEND = function(event, data)
        data.event = event
        Flyboy.Conn:Send(data)
    end,

    PLAYER_ENTERED_GAME = function(event, data)
        Flyboy.Conn:Connect(Flyboy.server, Flyboy.port)
    end,

    PLAYER_ENTERED_SECTOR = function(event, data)
--ForEachPlayer(function (id) print(id) end)
    end,

    SECTOR_LOADED = function(event, data)
        --ProcessEvent("FB_PLAYER_SPOTS", {blank = "empty"})

    end,

    UNLOAD_INTERFACE = function(event, data)
        Flyboy.Conn:Disconnect()
    end,

    PLAYER_LOGGED_OUT = function(event, data)
        Flyboy.Conn:Disconnect()
    end,

    TARGET_SCANNED = function(event,data)
        local nodeid, objectid = radar.GetRadarSelectionID()
        local msg = {
            ["event"]  = event,
            ["data"]   = data,
            ["name"]   = tostring(GetTargetInfo()),
            ["location"] = ShortLocationStr(GetCurrentSectorid()),
            ["objectid"] = objectid,
        }

        Flyboy.Conn:Send(msg)

    end,
}

-- Register all events
for name, value in pairs(Flyboy.Events) do
    RegisterEvent(Flyboy.Events[name], name)
end



local timer2 = Timer()
timer2:SetTimeout(
    3000,
    function()
        ForEachPlayer(function (id)


            local msg = {
                ['event']        = "PLAYER_SPOTS",
                ['id']           = id,
                ['name']         = GetPlayerName(id),
                ['health']       = GetPlayerHealth(id),
                ['ship']         = GetPrimaryShipNameOfPlayer(id) or 'Station',
                ['guild']        = GetGuildTag(id),
                ['faction']      = FactionName[GetPlayerFaction(id)] or '',
                ['factionID']    = GetPlayerFaction(id),
                ['sectorID']     = GetCurrentSectorid(),
                ['factionColor'] = rgbtohex(FactionColor_RGB[tonumber(GetPlayerFaction(id))]) or '127FFFFFF',
                ['location']     = AbbrLocationStr(GetCurrentSectorid()),
                ['sectorFaction']= GetSectorAlignment(),
                ['sectorFactionColor']=rgbtohex(FactionColor_RGB[tonumber( GetSectorAlignment() )]) or '127FFFFFF',

            }
            -- skip NPCs but not unrats
            if string.find(msg.name, "^\*") then
                if (GetPlayerFaction(id) == "unaligned") then
                    Flyboy.Conn:Send(msg)
                end
            else
                -- send player spots
                Flyboy.Conn:Send(msg)
            end
        end)
        timer2:SetTimeout(3000)
    end
)

return Flyboy.Events




