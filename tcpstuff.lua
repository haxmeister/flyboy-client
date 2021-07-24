--[[
flyboy 1.0
By Haxmeister
Using orignal Voce code By TheRedSpy
]]


dofile("json.lua") -- json.encode and json.decode
dofile("tcpsock.lua") -- Socket stuff

flyboy.getfact = function(fact) -- Return faction text with correct color
    if (fact==nil) then return "" end
    if (fact==-1) then return "" end
    local factionstr = factionfriendlyness(fact)
    local color = rgbtohex(factionfriendlynesscolor(fact))
    if (factionstr=="Kill on Sight") then factionstr = "KOS" end
    if (factionstr=="Pillar of Society") then factionstr = "POS" end
    return color .. factionstr
end


flyboy.TCPConn = flyboy.TCPConn or {}

flyboy.TCPConn.isConnected = false
flyboy.TCPConn.isLoggedIn = false
flyboy.ConnectedAccountName = nil
flyboy.TCPConn.reconnect_timer = Timer()
flyboy.TCPConn.connect_attempts = 0

-- OnConnect
flyboy.TCPConn.OnConnect = function(sock, errmsg)
    local connOk = false
    if (sock) then
        if (sock.tcp:GetPeerName()~=nil) then -- We are connected
            flyboy.TCPConn.Socket = sock
            flyboy.Send = sock.Send
            connOk = true
        else
            connOk = false
        end
    end
    if (connOk) then -- We are connected OK
        flyboy.TCPConn.isConnected = true
        flyboy.TCPConn.isLoggedIn = false
        flyboy.TCPConn.connect_attempts = 0
        flyboy.print("Connected to server ok.")
        flyboy.TCPConn.Login()
    else
        flyboy.TCPConn.isConnected = false
        flyboy.TCPConn.isLoggedIn = false

        if flyboy.TCPConn.connect_attempts == 0 then
            if (errmsg) then
                flyboy.printerror("Error connecting to server: " .. errmsg)
            else
                flyboy.printerror("Error connecting to server.")
            end
        end
    end
end

flyboy.TCPConn.Login = function()
    flyboy.print("Logging in to the server...")
    flyboy.TCPConn.SendData({ action="auth", username=GetPlayerName(), password="anon"})
end

flyboy.TCPConn.Disconnect = function()
    flyboy.TCPConn.reconnect_timer:Kill()
    flyboy.TCPConn.connect_attempts = 0

    if (flyboy.TCPConn.isLoggedIn) then
        flyboy.TCPConn.Logout()
    end
    flyboy.TCPConn.isConnected = false
    flyboy.TCPConn.isLoggedIn = false
    flyboy.TCPConn.Socket.tcp:Disconnect()
    -- flyboy.printerror("Disconnected from the server");
end

flyboy.TCPConn.Logout = function()
    -- flyboy.print("Logging out from the server...")
    flyboy.TCPConn.SendData({ action="logout" })
end

flyboy.TCPConn.SendData = function(data)
    if (flyboy.TCPConn.isConnected) then
        flyboy.TCPConn.Socket:Send(json.encode(data) .. "\r\n")
    else
        flyboy.printerror("Unable to communicate with the server - not connected to server.")
    end
end

-- OnDisconnect
flyboy.TCPConn.OnDisconnect = function()
    flyboy.TCPConn.isConnected = false
    flyboy.TCPConn.isLoggedIn = false

    local function reconnect_cb()
        flyboy.TCPConn.connect_attempts = flyboy.TCPConn.connect_attempts + 1
        flyboy.TCPConn.connect()
    end

    local timeout = (flyboy.TCPConn.connect_attempts < 5) and 5 or 60
    flyboy.TCPConn.reconnect_timer:SetTimeout(timeout * 1000, reconnect_cb)

    flyboy.printerror("Disconnected from server. Reconnecting in "..tostring(timeout).."s.")
end

flyboy.TCPConn.OnData = function(sock, input)
    local data = string.gsub(input, "[\r\n]", "")
    data = json.decode(data)
    local action = data.action
    local result = tonumber(data.result)
    if (result<1) then
        flyboy.printerror("Error executing command: " .. action)
        if (data.error) then
            flyboy.printerror(data.error)
        end
        return
    end
    if (flyboy.Events[action]) then
        flyboy.Events[action](data)

    else
        flyboy.printerror("Invalid response from server: " .. action)
    end
end

flyboy.TCPConn.connect = function()
    flyboy.TCPConn.reconnect_timer:Kill()

    if (flyboy.TCPConn.isConnected) then
        flyboy.TCPConn.Disconnect()
    end

    if flyboy.TCPConn.connect_attempts == 0 then
        flyboy.print("Trying to connect to server...")
    end

    if (flyboy.server~=nil and flyboy.port~=nil and flyboy.server~="" and flyboy.port~="") then
        TCP.make_client(flyboy.server, flyboy.port, flyboy.TCPConn.OnConnect, flyboy.TCPConn.OnData, flyboy.TCPConn.OnDisconnect)
    else
        flyboy.printerror("Server or port not set - cant connect.")
    end
end

-- Interface unloaded
flyboy.TCPConn.UnloadInterface = function()
    flyboy.TCPConn.Disconnect()
end

--[[:::::::::::::::::::::: EVENTS FROM SERVER :::::::::::::::::::::::::::::]]
flyboy.Events = flyboy.Events or {}

-- Response to Authentication
flyboy.Events["auth"] = function(params)
    flyboy.print("Logged in OK")
    flyboy.TCPConn.isLoggedIn = true
end

-- Response from Logout
flyboy.Events["logout"] = function(params)
    flyboy.print("Logged out from the server.")
end

-- Response to Add to Ally list
flyboy.Events["addally"] = function(params)
    flyboy.print("Added ALLY status for " .. params.name)
end

-- Response to Remove from Ally list
flyboy.Events["removeally"] = function(params)
    flyboy.print("No more ALLY records for " .. params.name)
end

-- Response to findore
flyboy.Events["findore"] = function(params)
    table.sort(params)
    --params[action] = nil
    --params[result] = nil
    for k,v in pairs(params) do
        if (tonumber(k))then
            local sector = AbbrLocationStr( tonumber(k) )

            print (sector..": "..params[k]["max"].."% in "..params[k]["roids"].." roids")
        end
    end

end

flyboy.DisplayNotification = function(txt)
    local exists = false
    for _, noti in ipairs(flyboy.Notifier.NotificationsDisplay) do
        if (noti.txt==txt) then
            exists=true
            break
        end
    end
    if (exists==false) and (txt ~= "") then
        table.insert(flyboy.Notifier.NotificationsDisplay, { time=os.time(), txt=txt, label=nil })
    end
end

flyboy.Refuel = function(tbl)
    local txt = ""
    local guild = ""
    local tbl1 = tbl[2]
    if ((tbl1.name~=GetPlayerName()) and (tonumber(tbl1.sectorid)~=GetCurrentSectorid()) and (tbl1.reporter~=GetPlayerName())) then
        if ((tbl1.guildtag or "")~="") then
            guild = "[" .. tbl1.guildtag .. "] "
        end
        local reporterguild = ""
        if ((tbl1.reporterguild or "")~="") then
            reporterguild = "[" .. tbl1.reporterguild .. "] "
        end
        local factioncolor = ""
        if ((tonumber(tbl1.faction) or 0) > 0) then
            factioncolor = rgbtohex(FactionColor_RGB[tonumber(tbl1.faction)])
        else
            factioncolor = '\127FF0000'
        end
        local reporterfactioncolor = ""
        if ((tonumber(tbl1.reporterfaction) or 0) > 0) then
            reporterfactioncolor = rgbtohex(FactionColor_RGB[tonumber(tbl1.reporterfaction)])
        else
            reporterfactioncolor = '\127FF0000'
        end
        local location = "Unknown Location"
        local sectid = tbl1.sectorid or -1
        if (sectid>0) then
            location = ShortLocationStr(sectid)
        end
        local shipname = (tbl1.shipname) or ""
        if (shipname~="") then
            if (tonumber(tbl1.health)>0) then
                tbl1.health = string.format("%d", tbl1.health)
                shipname = shipname .. " (" .. tbl1.health .. "%)"
            end
            shipname = " flying a " .. shipname
        else
            shipname = " either docked or out of range"
        end
        tbl1.t = tonumber(tbl1.t or 0)
        txt = "\127FFFFFF" .. factioncolor .. guild .. tbl1.name .. '\127cccccc' .. " just refuelled at " .. '\127FFFFFF' .. location .. "\127cccccc" .. shipname .. "."
        flyboy.DisplayNotification(txt)
    end
end

flyboy.Multispot = function(tbl)
local finaltable = {}
local multi_list = {}
    for _,player in ipairs(tbl or {}) do
        local guild = ""
        if ((player.guildtag or "")~="") then
            guild = "[" .. player.guildtag .. "] "
        end
        local reporterguild = ""
        if ((player.reporterguild or "")~="") then
            reporterguild = "[" .. player.reporterguild .. "] "
        end
        local factioncolor = ""
        if ((tonumber(player.faction) or 0) > 0) then
            factioncolor = rgbtohex(FactionColor_RGB[tonumber(player.faction)])
        else
            factioncolor = '\127FF0000'
        end
        local reporterfactioncolor = ""
        if ((tonumber(player.reporterfaction) or 0) > 0) then
            reporterfactioncolor = rgbtohex(FactionColor_RGB[tonumber(player.reporterfaction)])
        else
            reporterfactioncolor = '\127FF0000'
        end
        local location = "Unknown Location"
        local sectid = player.sectorid or -1
        if (sectid>0) then
            location = ShortLocationStr(sectid)
        end
        local shipname = (player.shipname) or ""
        player.t = tonumber(player.t or 0)
        player.name = factioncolor .. guild .. player.name
        multi_list[player.t] = multi_list[player.t] or {} --create sectorid entry if it doesn't already exist
        multi_list[player.t][player.sectorid] = multi_list[player.t][player.sectorid] or {} --create muffin entry if doesn't exist
        table.insert(multi_list[player.t][player.sectorid], player.name)
    end
    for t,sector in pairs(multi_list) do
        local themessage = ""
        local exists = false
        if (t == 0) then
            if (tonumber(sector)~=GetCurrentSectorid()) then
                for sectorid,names in pairs(sector) do
                    local printer = table.concat(names,"\127cccccc, ") .. "\127cccccc spotted in " .. '\127ffffff' .. ShortLocationStr(sectorid) .. "\127cccccc."
                    local mystring = printer:gsub(",([^,]+)$", " and%1")
                    themessage = mystring
                end
            end
        elseif (t == 1) then
            if (tonumber(sector)~=GetCurrentSectorid()) then
                for sectorid,names in pairs(sector) do
                    local printer = table.concat(names,"\127cccccc, ") .. "\127cccccc have left " .. '\127ffffff' .. ShortLocationStr(sectorid) .. "\127cccccc."
                    local mystring = printer:gsub(",([^,]+)$", " and%1")
                    themessage = mystring
                end
            end
        elseif (t == 2) then
            if (tonumber(sector)~=GetCurrentSectorid()) then
                for sectorid,names in pairs(sector) do
                    local printer = table.concat(names,"\127cccccc, ") .. "\127cccccc last seen in " .. '\127ffffff' .. ShortLocationStr(sectorid) .. "\127cccccc."
                    local mystring = printer:gsub(",([^,]+)$", " and%1")
                    themessage = mystring
                end
            end
        end
    flyboy.DisplayNotification(themessage)
    end
end


flyboy.SingleSpot = function(tbl)
    for idx, player in ipairs(tbl) do
        if (player.name~="") then
            local guild = ""
            if ((player.guildtag or "")~="") then
                guild = "[" .. player.guildtag .. "] "
            end
            local reporterguild = ""
            if ((player.reporterguild or "")~="") then
                reporterguild = "[" .. player.reporterguild .. "] "
            end
            local factioncolor = ""
            if ((tonumber(player.faction) or 0) > 0) then
                factioncolor = rgbtohex(FactionColor_RGB[tonumber(player.faction)])
            else
                factioncolor = '\127FF0000'
            end
            local reporterfactioncolor = ""
            if ((tonumber(player.reporterfaction) or 0) > 0) then
                reporterfactioncolor = rgbtohex(FactionColor_RGB[tonumber(player.reporterfaction)])
            else
                reporterfactioncolor = '\127FF0000'
            end
            local location = "Unknown Location"
            local sectid = player.sectorid or -1
            if (sectid>0) then
                location = ShortLocationStr(sectid)
            end
            local shipname = (player.shipname) or ""
            player.t = tonumber(player.t or 0)
            local txt = ""
            if (player.t==1) then -- Left sector
                if (player.name~=GetPlayerName()) and (tonumber(player.sectorid)~=GetCurrentSectorid() and player.reporter~=GetPlayerName()) then
                txt = factioncolor .. guild .. player.name .. "\127cccccc has left " .. '\127FFFFFF' .. location .. "\127cccccc."
                end --flyboy.GetTheKillMessage = function(killer, killerhp, killerguild, killerfaction, victim, victimguild, victimfaction)
            elseif (player.t==2) then -- Lost - WE left sector
                if (player.name~=GetPlayerName()) and (tonumber(player.sectorid)~=GetCurrentSectorid() and player.reporter~=GetPlayerName()) then
                txt = factioncolor .. guild .. player.name .. '\127cccccc was last seen in ' .. '\127FFFFFF' .. location .. "\127cccccc."
                end
            elseif (player.t==3) then -- A spotter kills
                if (player.name ~= GetPlayerName()) then
                txt = flyboy.GetTheKillMessage(player.reporter, player.reporterhealth, reporterguild, reporterfactioncolor, player.name, guild, factioncolor)
                end
            elseif (player.t==4) then -- A spotter gets killed
                if (player.name ~= GetPlayerName()) then
                txt = factioncolor .. guild .. player.name .. "\127cccccc" .." has destroyed " .. reporterfactioncolor .. reporterguild .. player.reporter .. "\127cccccc."
                end
            else -- Entered sector
            if (player.name~=GetPlayerName()) and (tonumber(player.sectorid)~=GetCurrentSectorid() and player.reporter~=GetPlayerName()) then
                if (shipname~="") then
                    if (tonumber(player.health)>0) then
                        player.health = string.format("%d", player.health)
                        shipname = shipname .. " (" .. player.health .. "%)"
                    end
                    shipname = " flying a " .. shipname
                else
                    shipname = " either docked or out of range"
                end
                txt = "\127FFFFFF" .. factioncolor .. guild .. player.name .. '\127cccccc' .. " spotted in " .. '\127FFFFFF' .. location .. "\127cccccc" .. shipname .. "." .. '\127FFFFFF'
            end
            end
            flyboy.DisplayNotification(txt)
        end
    end
end


-- Response to PLAYERSEEN
flyboy.Events["playerseen"] = function(params)
    local playerlist = params.playerlist or {}
    local multi_list = flyboy.Notifier.CurrentState or {}
    for idx,player in ipairs(playerlist) do
        local guild = ""
        if ((player.guildtag or "")~="") then
            guild = "[" .. player.guildtag .. "] "
        end
        local reporterguild = ""
        if ((player.reporterguild or "")~="") then
            reporterguild = "[" .. player.reporterguild .. "] "
        end
        local factioncolor = ""
        if ((tonumber(player.faction) or 0) > 0) then
            factioncolor = rgbtohex(FactionColor_RGB[tonumber(player.faction)])
        else
            factioncolor = '\127FF0000'
        end
        local reporterfactioncolor = ""
        if ((tonumber(player.reporterfaction) or 0) > 0) then
            reporterfactioncolor = rgbtohex(FactionColor_RGB[tonumber(player.reporterfaction)])
        else
            reporterfactioncolor = '\127FF0000'
        end
        local location = "Unknown Location"
        local sectid = player.sectorid or -1
        if (sectid>0) then
            location = ShortLocationStr(sectid)
        end
        local shipname = (player.shipname) or ""
        player.t = tonumber(player.t or 0)
        player.name = factioncolor .. guild .. player.name
        multi_list[player.sectorid] = multi_list[player.sectorid] or {} --create muffin entry if doesn't exist
        if player.sectorid ~= GetCurrentSectorid() then
            if (player.t == 0) then
                -- NOTE: uncomment the if statement to only flash the display if the values actually changed
                local playervars = multi_list[player.sectorid][player.name] or {}
                --if shipname ~= playervars[1] or player.health ~= playervars[2] then
                    -- the third field indicates that the entry has changed. it is cleared by the display function
                    playervars = {shipname, player.health, true}
                --end
                multi_list[player.sectorid][player.name] = playervars
            else
                multi_list[player.sectorid][player.name] = nil
            end
        end
        if table.getn2(multi_list[player.sectorid]) == 0 then multi_list[player.sectorid] = nil end
    end
    flyboy.Notifier.CurrentState = multi_list
-- flyboy.print(table.tostring(flyboy.Notifier.NotificationsDisplay))
flyboy.Notifier.UpdateNotifyDisplay()
end


--{t=1, k=thekiller, health=tonumber(GetPlayerHealth(killer)), kguild=killerguild, kfaction=killerfaction, v=thevictim, vguild=victimguild, vfaction=victimfaction, w=weapon}


flyboy.Events["announce"] = function(params)
local playerlist = params.playerlist or {}
local myguild = "[" .. GetGuildTag() .. "] "
    for idx,announcement in ipairs(playerlist) do
        if (announcement.t == 1) then
            print(flyboy.GetTheKillMessage(announcement.k, announcement.health, announcement.kguild, announcement.kfaction, announcement.v, announcement.vguild, announcement.vfaction, announcement.w))
        elseif (announcement.t == 2) then
            print(announcement.vfaction .. announcement.vguild .. announcement.v .. "\127FFFFFF was destroyed by " .. announcement.kfaction .. announcement.kguild .. announcement.k .. "\127FFFFFF's " .. flyboy.GetWeaponMsg(announcement.w))
        elseif (announcement.t == 3) then
            flyboy.StreakAnnounce(announcement.k, announcement.kguild, announcement.kfaction, announcement.streak)
        elseif (announcement.t == 4) then
            flyboy.MultiKillAnnounce(announcement.k, announcement.kguild, announcement.kfaction, announcement.multi)
        elseif (announcement.t == 5) then
            SendSpot.Command2()
        end
    end

end

flyboy.Events["findore"] = function(params)
    flyboy.List.List.DELLIN = "1--1"
    --print (params.list)
    local sectorName
    local num
    local orderedlist ={}
    for item, info in pairs(params.list) do
        num = tonumber(item)
        --orderedlist[num] = info
        table.insert(orderedlist,num)

        --print(orderedlist[num])
    end
        --print(spickle(orderedlist))
    table.sort(orderedlist)
    local valstring
    for item,value in pairs(orderedlist) do
        --print(value)
        valstring = tostring(value)
        --print(params.list[valstring].roids)
        --print("are we looping?")
        flyboy.List.List.ADDLIN=1
        flyboy.List.List[ item .. ':1'] = AbbrLocationStr(value) --params.list[valstring].." "--record.sector
        flyboy.List.List[ item .. ':2'] = params.list[valstring].roids.." "
        flyboy.List.List[ item .. ':3'] = params.list[valstring].max.."% "
        --flyboy.List.List:setattribute("BGCOLOR", item, -1, flyboy.List.bg[2])
        --flyboy.List.List:setattribute("FGCOLOR", item, 2, colors[2])
    end
    ShowDialog(flyboy.List.ListWindow);
end

flyboy.TCPConn.Disconnect = function()
    if (flyboy.TCPConn.isLoggedIn) then
        flyboy.TCPConn.Logout()
    end
    flyboy.TCPConn.isConnected = false
    flyboy.TCPConn.isLoggedIn = false

    -- .Socket is nil if the connection was never established
    -- checking .isConnected would probably do too
    if flyboy.TCPConn.Socket then
        flyboy.TCPConn.Socket.tcp:Disconnect()
    end
    -- flyboy.printerror("Disconnected from the server");
end


--[[:::::::::::::::::::::: END EVENTS FROM SERVER :::::::::::::::::::::::::]]

RegisterEvent(flyboy.TCPConn.UnloadInterface, "UNLOAD_INTERFACE")
RegisterEvent(flyboy.TCPConn.Disconnect, "PLAYER_LOGGED_OUT")
