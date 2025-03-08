--[[

Author: Joshua S. Day (haxmeister)

Purpose: This plugin provides access to the flyboy server API. Using this
         Connection, it provides shared data between players using
         the plugin.

Flyboy plugin enables sharing of the follow types of data, assuming it
has been provided by one of it's users:

    1. Location of other players you and others have seen in real time.
    2. Locations asteroids with ore data that has been scanned by you or others.
    3. Location of unrats and unrat dent that has been seen by you or others.
    4. Location of queens that have been seen by you or others.
    5. Location of Leviathon that has been seen by you or others.
    6. A private chat channel that is NOT monitored by other players or game
       administrators.

--]]

-- The table that will contain the flyboy plugin
Flyboy = Flyboy or {}

-- The IP address or url of the server
Flyboy.server = "192.168.0.30"

-- The port to use on the server
Flyboy.port = 3000

-- Functions to load and save settings and update the running table
Flyboy.Settings = dofile "settings.lua"

-- The name of the system notes file that will store your settings
Flyboy.Settings.fileID = "flyboy"

-- Loading previous flyboy settings from the fileID given
Flyboy.Settings:Load()

-- Functions to manage the TCP connection to the server
Flyboy.Conn = dofile "connectivity/connection.lua"

-- Game events to watch and FB (flyboy) custom events to trigger and watch,
-- all events are registered in this file as well
Flyboy.Events = dofile "events.lua"

-- Commands that can be executed in the VO chat window during gameplay
Flyboy.Commands = dofile "commands.lua"

-- Load MDI-targetlist integrations
Flyboy.MDItargetlist = dofile "integrations/targetlist.lua"

--Flyboy.ui       = dofile "ui/spots.lua"







