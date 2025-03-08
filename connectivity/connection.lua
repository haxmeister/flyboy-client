

dofile("connectivity/json.lua")   -- json.encode and json.decode
dofile("connectivity/socket.lua") -- Socket stuff

Flyboy.Conn = {
    IP          = false,
    Port        = false,
    Socket      = false,
    Timer       = Timer(),
    MaxAttempts = 5,
    Attempts    = 0,
    PlayerWantsConnection = false,

    OnConnect = function(sock, errmsg)
        Flyboy.Conn.Socket = sock
        if (Flyboy.Conn.Socket) then
            if (Flyboy.Conn.Socket.tcp:GetPeerName() ~= nil) then -- We are connected
                ProcessEvent("FB_CONNECTED", {type = "clear", str = "Connected.." })
                Flyboy.Conn.Attempts = 0
                if Flyboy.Conn.Timer:IsActive() then
                    Flyboy.Conn.Timer:Kill()
                end
            end
        end
    end,

    OnDisconnect = function()
        ProcessEvent("FB_DISCONNECTED", {type = "error", str ="Disconnected.." })
        if (not Flyboy.Conn.PlayerWantsConnection) then
            return
        end
        if (Flyboy.Conn.Attempts < Flyboy.Conn.MaxAttempts)then
            if Flyboy.Conn.Timer:IsActive() then
                Flyboy.Conn.Timer:Kill()
            end
                Flyboy.Conn.Timer:SetTimeout(10000, function() Flyboy.Conn:Connect(Flyboy.server, Flyboy.port) end)
        else
            Flyboy.Conn.Attempts = 0
        end
    end,

    OnData = function(socket, data)
        local data = string.gsub(data, "[\r\n]", "")
        --print(input)
        data = json.decode(data)
        ProcessEvent(tostring(data.event), data.data)
    end,

}

function Flyboy.Conn:Connect(ip, port)
    self.IP = ip
    self.Port = port
    self.Attempts = self.Attempts + 1
    self.PlayerWantsConnection = true
    ProcessEvent("FB_HUD_MSG", {type = "clear", str ="Attempting to connect.." })
    TCP.make_client(
        self.IP,
        self.Port,
        self.OnConnect,
        self.OnData,
        self.OnDisconnect
    )
end

function Flyboy.Conn:Disconnect(playerstopped)
    ProcessEvent("FB_HUD_MSG", {type = "clear", str ="Disconnecting.." })
    if (self.Socket)then
        self.Socket.tcp:Disconnect()
        self.Socket = nil
    end
end

function Flyboy.Conn:isConnected()
    if (self.Socket == false) then
        return false
    end
    if (self.Socket.tcp:GetPeerName()~=nil) then -- We are connected
        return true
    else
        return false
    end
end

function Flyboy.Conn:Send(data)
    if (Flyboy.Conn:isConnected()) then
        self.Socket:Send(json.encode(data) .. "\r\n")
    end
end

return Flyboy.Conn
