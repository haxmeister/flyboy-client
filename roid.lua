--[[
flyboy 1.0
By Haxmeister
Using orignal Voce code By TheRedSpy
]]

dofile("roidobject.lua")

function TargetScanned(event, data)
    local name = tostring (GetTargetInfo())
    local sector = GetCurrentSectorid()
    local nodeid, objectid = radar.GetRadarSelectionID()

    if (name == "Asteroid" or name == "Ice Crystal")then
        if( flyboy.roid:IsNewRoid(sector, objectid) )then
            flyboy.roid:UpdateRoid(sector, objectid, data)
            if( flyboy.roid:OreIsDetected() ) then
                flyboy.roid:SendRoid()
            end
        end
    end
end



