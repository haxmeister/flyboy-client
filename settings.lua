Flyboy.Settings = Flyboy.Settings or {}

function Flyboy.Settings:Save()
    SaveSystemNotes(spickle(self), self.fileID)
end

function Flyboy.Settings:Load()
    local set = unspickle(LoadSystemNotes(self.fileID))
    if(set)then
        for k, v in ipairs(set)do
            if (tostring(k) ~= "fileID")then
                self.k = v
            end
        end
    end
end

return Flyboy.Settings
