--[[
flyboy 1.0
roid locator
By Haxmeister

]]

flyboy.roid = {
    action = "roid",
    charid = charid,
    reporter = GetPlayerName(),
    reporterguild = GetGuildTag(),
    sector = GetCurrentSectorid(),
    objectid = "",
    data = "",
}


function flyboy.roid:UpdateRoid(sector, objectid, data)

    self.data = data
    self.objectid = objectid
    self.sector = sector

end

function flyboy.roid:SendRoid()
    print("Sending roid data")
    flyboy.TCPConn.SendData({action = 'roid',
                             charid = self.charid,
                             reporter = self.reporter,
                             reporterguild = self.reporterguild,
                             sector = self.sector,
                             objectid = self.objectid,
                             data = self.data,
                             })
end

function flyboy.roid:IsNewRoid(sector, objectid)

    if(self.sector == sector and self.objectid == objectid)then
        return false
    else
        return true
    end

end

function flyboy.roid:OreIsDetected()
    local firstWord = self.data:match("^(%S+)")
    if(firstWord == "Minerals:") then
        return true
    end
    if(firstWord == "Temperature:") then
        return true
    end

    return false
end


function flyboy.roid:getobject()
    self:update()
    return { sectorid=self.sector, reporter=self.reporter, reporterfaction=self.reporterfaction, reporterhealth=self.reporterhealth, reporterguild=self.reporterguild}
end

