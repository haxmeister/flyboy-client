--[[
flyboy 1.0
By Haxmeister
Using orignal Voce code By TheRedSpy
]]

flyboy.Notifier.notif = {
    new = function(charid, t)
        local obj = {
            charid = -1,
            ts = -1,
            name = "",
            guildtag = "",
            shipname = "",
            health = -1,
            faction = -1,
            -- Nation standings
            fitani = -1,
            fserco = -1,
            fuit = -1,
            flocal = -1,
            numchk = 0,
            reporter = "",
            reporterfaction = -1,
            reporterhealth = -1,
            reporterguild = "",
            sector = -1,
            t = "" -- Report type: 0='ENTER', 1='LEFT', 2='LOST', 3='We killed Somebody. 4='somebody killed us'
        }

        function obj:getcharid()
            return self.charid
        end

        function obj:gettype()
            return self.t
        end

        function obj:settype(t)
            self.t = t
        end

        function obj:update()
            if (self.name=="") then
                self.name = GetPlayerName(self.charid) or ""
                if (self.name~="") then
                    self.guildtag = GetGuildTag(self.charid) or ""
                end
            end
            if (self.health<0) then
                self.health = GetPlayerHealth(self.charid) or -1
            end
            if (self.shipname=="") then
                self.shipname = GetPrimaryShipNameOfPlayer(self.charid) or ""
            end
            if (self.faction<0) then
                self.faction = GetPlayerFaction(self.charid) or -1
            end
            if (self.fitani<0) then
                self.fitani = GetPlayerFactionStanding(1, self.charid) or -1
            end
            if (self.fserco<0) then
                self.fserco = GetPlayerFactionStanding(2, self.charid) or -1
            end
            if (self.fuit<0) then
                self.fuit = GetPlayerFactionStanding(3, self.charid) or -1
            end
            if (self.flocal<1) then
                if ((GetSectorAlignment() or 0)>0) then -- This sector are monitored in some sort
                    self.flocal = GetPlayerFactionStanding("sector", self.charid) or -1
                else
                    self.flocal = -1
                end
            end
        end

        function obj:getobject()
            local now = os.time()
            local lifetime = now - self.ts
            self:update()
            if (self.name=="" or string.find(self.name, "reading transponder")~=nil) then -- We need the name...
                if (lifetime>5) then -- we checked for 5 seconds... we just give up
                    self.charid = -99
                end
                return nil
            end
            if (string.sub(self.name, 1, 1)=="*" or self.name==GetPlayerName()) then -- NPC or ourself..
                self.charid = -99
                return nil
            end
            if (self.shipname=="" or self.health<0) then
                if (lifetime<5) then -- We check some more to get the info
                    return nil
                end
            end
            self.charid = -99
            return { t=self.t, name=self.name, shipname=self.shipname, health=self.health, sectorid=self.sector, faction=self.faction, guildtag=self.guildtag, reporter=self.reporter, reporterfaction=self.reporterfaction, reporterhealth=self.reporterhealth, reporterguild=self.reporterguild, fitani=self.fitani, fserco=self.fserco, fuit=self.fuit, flocal=self.flocal }
        end

        obj.ts = os.time()
        obj.charid = charid
        obj.reporter = GetPlayerName()
        obj.t = t
        obj.sector = GetCurrentSectorid()
        obj.reporterfaction = GetPlayerFaction()
        obj.reporterhealth = GetPlayerHealth(GetCharacterID())
        obj.reporterguild = GetGuildTag()

        obj:update()

        return obj
    end
}
