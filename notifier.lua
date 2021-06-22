--[[
flyboy 1.0
By Haxmeister
Using orignal Voce code By TheRedSpy
]]


flyboy.Notifier = flyboy.Notifier or {}

dofile("notifierobject.lua")

flyboy.Notifier.UpdateNotifyDisplayTimer = Timer()
flyboy.Notifier.UpdateNotifyTimer = Timer()
flyboy.Notifier.Notifications = {}
flyboy.Notifier.NotificationsDisplay = {}
flyboy.Notifier.CurrentState = {}
SendSpot = {}
SendSpot2 = {t=8, spots={}}

flyboy.ClearSpots = function()
    for idx, notify in ipairs(flyboy.Notifier.NotificationsDisplay) do
            FadeStop(notify.label)
            iup.Detach(notify.label)
            iup.Destroy(notify.label)
            notify.label = nil
            notify.txt = nil
    end
    flyboy.Notifier.CurrentState = {}
    flyboy.Notifier.NotificationsDisplay = {}
    flyboy.Notifier.UpdateNotifyDisplay()

end

flyboy.Notifier.UpdateNotifyDisplay = function()
    for sector,sectorspots in pairs(flyboy.Notifier.CurrentState) do
        if sector ~= GetCurrentSectorid() then
            local updated
            local notification = ShortLocationStr(sector) .. ": "
            for name, vars in pairs(sectorspots) do
                -- vars[3] is set if the entry has changed
                if vars[3] then
                    vars[3] = nil
                    updated = true
                end

                if (table.getn2(sectorspots) == 1) then
                    local shipname = vars[1]
                    if shipname == "" then shipname = "Docked/Out of Range" end
                    notification = notification .. name .. '\127CCCCCC - ' .. shipname .. '\127CCCCCC, '
                else
                    notification = notification .. name .. '\127CCCCCC, '
                end
            end
            notification = notification:gsub(",(%s*)$", "") --makes it pretty removes the ", " at the end
            table.insert(flyboy.Notifier.NotificationsDisplay, {time=os.time(), txt=notification, label=nil, updated=updated})
        end
    end

    local now = os.time()
    for idx, notify in ipairs(flyboy.Notifier.NotificationsDisplay) do
        if (notify.label~=nil) then
            FadeStop(notify.label)
            iup.Detach(notify.label)
            iup.Destroy(notify.label)
            notify.label = nil
            notify.txt = nil
        end
        if (notify.notified==nil and GetCurrentSectorid() ~= notify.sect) then

            notify.label = iup.frame{iup.label{title=notify.txt, font=Font.H3*HUD_SCALE*0.75, alignment="ALEFT", expand="HORIZONTAL"}, segmented="0 0 1 1", bgcolor="255 0 0 0 *"}
            --if ((flyboy.Settings.notifyflash or "ON")=="ON") then
            if notify.updated then
                FadeControl(notify.label, 10, 0.5, 0)
            end
            --end
            if (flyboy.UI.NotifyHolder~=nil) then
                iup.Append(flyboy.UI.NotifyHolder, notify.label)
            end
--          if ((flyboy.Settings.notifychat or "ON")=="ON") then --TODO This statement causes issues with legacy users that had this option ON in the old FAMYTools
--              local rep = ""
--              if (notify.reporter) then rep = " -- (" .. notify.reporter .. ")" end
--              flyboy.print(notify.txt .. rep)
--          end
            flyboy.Notifier.NotificationsDisplay[idx].notified=true
        end

    end
    pcall(function()
        iup.Refresh(flyboy.UI.NotifyHolder)
    end)

    local tmp = {}
    for _, notify in ipairs(flyboy.Notifier.NotificationsDisplay) do
        if (notify.txt~=nil) then table.insert(tmp, notify) end
    end
    flyboy.Notifier.NotificationsDisplay = tmp
    if (#flyboy.Notifier.NotificationsDisplay>0) then
        if (flyboy.UI.NotifyHolder~=nil) then
            --if ((flyboy.Settings.notifyhud or "ON")=="ON") then
            flyboy.UI.NotifyHolder2.visible = "YES"
            --else
                --flyboy.UI.NotifyHolder2.visible = "NO"
            --end
        end
    else
        flyboy.UI.NotifyHolder2.visible = "NO"
    end

end

flyboy.Notifier.JumpSector = function()
    for idx, notify in ipairs(flyboy.Notifier.NotificationsDisplay) do
        if notify.sectorid == GetCurrentSectorid() then
            FadeStop(notify.label)
            iup.Detach(notify.label)
            iup.Destroy(notify.label)
            notify.label = nil
            notify.txt = nil
        end
    end
end


---extra function for debug purposes


function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

flyboy.Notifier.UpdateNotify = function()
    local tmplist = {}
    if (#flyboy.Notifier.Notifications>0) then -- Any unknowns?
        for idx, notif in ipairs(flyboy.Notifier.Notifications) do
            local notifobj = notif:getobject()
            if (notifobj~=nil) then
                table.insert(tmplist, notifobj) -- FIRST BIG STEP IS TO FIND THE SORT FUNCTIONALITY FOR TABLES IN LUA
            end
        end
        local tmp = {}
        for idx, notif in ipairs(flyboy.Notifier.Notifications) do
            if (notif:getcharid()~=-99) then
                table.insert(tmp, notif)
            end
        end
        for idx, notif in ipairs(flyboy.Notifier.Notifications) do
        --flyboy.print(idx .. ": " .. table.tostring(notif)) -- Debug message for the individual spotter tables
        end
        flyboy.Notifier.Notifications = tmp
--  flyboy.print("Debug:  " .. table.tostring(tmplist)) --debug message (TRS)
    end
    if (#tmplist>0) then
        flyboy.TCPConn.SendData({ action='playerseen', playerlist=tmplist })
    end
    flyboy.Notifier.UpdateNotifyTimer:SetTimeout(1500, flyboy.Notifier.UpdateNotify)
end

---end extra function

flyboy.Notifier.EventPlayerEnteredSector = function(_, charid)
    local n = flyboy.Notifier.notif.new(charid, 0)
    table.insert(flyboy.Notifier.Notifications, n)
    flyboy.Notifier.UpdateNotify()
end

flyboy.Notifier.EventPlayerLeftSector = function(_, charid)
    local n = flyboy.Notifier.notif.new(charid, 1)
    table.insert(flyboy.Notifier.Notifications, n)
    flyboy.Notifier.UpdateNotify()
end

flyboy.GetWeaponMsg = function(number)
    local message = {[46]="Mega Positron", [173]="Sunflare", [702]="Raven", [44]="AAP", [48]="LENB", [34]="Neutron Blaster Mk II", [42]="Positron Blaster", [183]="Seeker Missile", [91]="Gov't Plasma Cannon", [71]="Charged Cannon", [114]="Plasma Cannon MkII", [116]="Plasma Cannon MkIII", [26]="Phase Blaster MkII", [20]="Ion Blaster MkII", [118]="Plasma Cannon HX", [87]="Fletchette Cannon", [32]="Neutron Blaster", [89]="Fletchette Cannon MkII", [103]="Gauss Cannon", [156]="Rail Gun", [105]="Gauss Cannon MkII", [84]="Iceflare", [158]="Rail Gun MkII", [160]="Rail Gun MkIII", [162]="Advanced Rail Gun",[86]="Starflare",[108]="Gemini Missile", [708]="Plasma Eliminator", [704]="Plasma Eliminator MkII", [97]="Gatling Cannon", [99]="Gatling Turret", [147]="Plasma Devastator MkII", [145]="Plasma Devastator", [121]="Lightning Mine", [136]="Stingray Missile", [175]="Jackhammer Rocket", [177]="Screamer Rocket", [200]="Chaos Swarm Missile", [18]="Ion Blaster", [24]="Phase Blaster", [22]="Ion Blaster MkIII", [124]="Proximity Mine", [198]="Locust Swarm Missile", [28]="Orion Phase Blaster XGX", [36]="Neutron Blaster MkIII", [711]="Gauss Cannon MkIII", [150]="Hive Positron Blaster", [152]="Hive Gatling Cannon", [134]="YellowJacket Missile", [138]="Firefly Missile", [128]="Tellar Ulam Mine", [179]="Avalon Torpedo", [706]="Plasma Annihilator", [30]="TPG Sparrow Phase Blaster", [40]="Corvus Widowmaker", [56]="Capital Gauss", [188]="Capital Gauss", [191]="Hull Explosion", [0]="Self Destruct Protocol"}
    if message[number] ~= nil then
        local theweapon = message[number]
        return theweapon
    else
        return "Hull Explosion"

    end
end

flyboy.Notifier.EventSectorChanged = function(_, data)
    if (#flyboy.Notifier.Notifications>0) then -- Dont report any player_left secor because WE are the one who left
        local tmplist = {}
        for idx, notif in ipairs(flyboy.Notifier.Notifications) do
            if (notif:gettype()==1) then flyboy.Notifier.Notifications[idx]:settype(2) end
        end
    end
    ForEachPlayer(
        function (charid)
            local n = flyboy.Notifier.notif.new(charid, 0)
            if (charid~=0) then table.insert(flyboy.Notifier.Notifications, n) end
        end
    )
    for sectorid, names in pairs(flyboy.Notifier.CurrentState) do --This part deletes a notification if you enter a sector where theres a current notification of that sector
        if sectorid == GetCurrentSectorid() then
        flyboy.Notifier.CurrentState[sectorid] = nil
        end
    end
flyboy.Notifier.UpdateNotifyDisplay()
flyboy.Notifier.UpdateNotify()
end

---This is an example function that sends a fake spot

SendSpot.Command1 = function(_, args)
    local spooflist = {}
    local incstuff1 = { t=0, name="Fake Guy No.1", shipname="Valkryie X-1", health="100", sectorid=4131, faction=1, guildtag="FAMY", reporter="TheReporter" }
    local incstuff2 = { t=0, name="Fake Guy No.3", shipname="IDF Valkryie Vigilant", health="100", sectorid=4131, faction=1, guildtag="FAMY", reporter="TheReporter" }

    table.insert(spooflist, incstuff1)
    table.insert(spooflist, incstuff2)


            flyboy.TCPConn.SendData({ action='playerseen', playerlist=spooflist})
end

SendSpot.Command2 = function()
    local spooflist = {}
    local incstuff2 = { t=2, name="Fake Guy No.1", shipname="Valkryie X-1", health="100", sectorid=5751, faction=1, guildtag="FAMY", reporter="TheReporter" }
    local incstuff3 = { t=2, name="Fake Guy No.3", shipname="Corvus Greyhound", health="100", sectorid=4131, faction=2, guildtag="FAMY", reporter="TheReporter" }
    for i=1,6 do SendSpot2.spots[i] = GetCharacterInfo(i) end
    table.insert(spooflist, SendSpot2)
    flyboy.TCPConn.SendData({ action='announce', playerlist=spooflist})
end

SendSpot.Command3 = function(_, args)
flyboy.print("flyboy.Notifier.NotificationsDisplay: " .. table.tostring(flyboy.Notifier.NotificationsDisplay))
flyboy.print("flyboy.Notifier.CurrentState: " .. table.tostring(flyboy.Notifier.CurrentState))
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


flyboy.Notifier.UpdateNotifyTimer:SetTimeout(1500, flyboy.Notifier.UpdateNotify)
RegisterEvent(flyboy.Notifier.EventPlayerEnteredSector, "PLAYER_ENTERED_SECTOR")
RegisterEvent(flyboy.Notifier.EventPlayerLeftSector, "PLAYER_LEFT_SECTOR")
--RegisterEvent(flyboy.Notifier.EventPlayerEnteredStation, "ENTERED_STATION")
RegisterEvent(flyboy.Notifier.EventSectorChanged, "SECTOR_CHANGED")
RegisterUserCommand('sendspot', SendSpot.Command1)
RegisterUserCommand('sendspot2', SendSpot.Command2)
RegisterUserCommand('show', SendSpot.Command3)
UnregisterEvent(chatreceiver, "CHAT_MSG_DEATH")
