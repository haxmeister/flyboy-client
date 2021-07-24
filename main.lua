--[[
flyboy 1.0
By Haxmeister
Using orignal Voce code By TheRedSpy
]]

-- Helper function
local function get_args(str)
    local quotechar
    local i=0
    local args,argn,rest={},1,{}
    while true do
        local found,nexti,arg = string.find(str, '^"(.-)"%s*', i+1)
        if not found then found,nexti,arg = string.find(str, "^'(.-)'%s*", i+1) end
        if not found then found,nexti,arg = string.find(str, "^(%S+)%s*", i+1) end
        if not found then break end
        table.insert(rest, string.sub(str, nexti+1))
        table.insert(args, arg)
        i = nexti
    end
    return args,rest
end


flyboy = flyboy or {}

dofile("tcpstuff.lua") -- Socket stuff
dofile("notifier.lua") -- Notifier
dofile("roid.lua") -- roids
dofile("ui.lua") -- UI windows
--dofile("roidnotifier.lua") -- roid notifier

flyboy.server = "damona.liguros.net"
--flyboy.server = "185.148.129.108"
--flyboy.server = "0.0.0.0"
flyboy.port = 6736

flyboy.print = function(str)
    pcall(function() HUD:PrintSecondaryMsg("\1278e5151[\1270000aaflyboy\1278e5151] \127dddddd" .. str) end)
end

flyboy.printerror = function(str)
    pcall(function() HUD:PrintSecondaryMsg("\1278e5151[\1270000aaflyboy\1278e5151] \127ff3333" .. str) end)
end

flyboy.PlayerEnteredGame = function()
    flyboy.print("flyboy loaded...")
    flyboy.UI.Init()
    flyboy.TCPConn.connect()
end

flyboy.ShowHelp = function()
    flyboy.print("flyboy help")
    flyboy.print("flyboy accepts the following commands:")
    flyboy.print("/flyboy help - Display this help")
    flyboy.print("/flyboy connect - Manually connect to server")
    flyboy.print("/flyboy disconnect - Disconnect from server")
    flyboy.print("/flyboy clearspots - Clears all the spots on the HUD")
    flyboy.print("/flyboy findore Carbonic - list known locations of carbonic ore (case sensitive)")
    flyboy.print("You will be notified when other players using flyboy meet players around the verse")
end

flyboy.Command = function(_, args)
    if (args~=nil) then

        if (args[1]=="connect") then
            flyboy.TCPConn.connect()
        elseif (args[1]=="disconnect") then
            flyboy.TCPConn.Disconnect()
        elseif (args[1]=="sendspot") then
            flyboy.TCPConn.SendData({ t=2, name="Fake Guy No.1", shipname="Valkryie X-1", health="100", sectorid=5751, faction=1, guildtag="FAMY", reporter="TheReporter" })
        elseif (args[1]=="clearspots") then
                flyboy.ClearSpots()
        elseif (args[1]=="help") then
            flyboy.ShowHelp()
        elseif (args[1]=="findore")then
            if (args[2]==nil) then
                flyboy.printerror("Missing parameters for command - " .. args[1])
                return
            end
            flyboy.TCPConn.SendData({action="findore", oretype=args[2]})
        end
    else
        flyboy.print("For available commands use /flyboy help")
    end
end



RegisterEvent(flyboy.PlayerEnteredGame, "PLAYER_ENTERED_GAME")
RegisterEvent(TargetScanned, "TARGET_SCANNED")
RegisterUserCommand('flyboy', flyboy.Command)
