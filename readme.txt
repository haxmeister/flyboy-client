Author: Joshua S. Day (haxmeister)

Purpose: This plugin provides event hooks to simplify a private chat plugin
         as well as graphical components and commands to display it

METHODS:
    1.

EVENTS: The following events are registered or listened for by this plugin and are used to
        move messages back and forth to your echo server (you must provide the server)

    1. ALLIANCE_CHAT_RECV

        The AllianceChat plugin listens for this event and will use it's data to generate a
        formatted message in the game's chat window. Use ProcessEvent("ALLIANCE_CHAT_RECV", data)
        in your plugin to have AllianceChat format and print the provided table in the chat window.

    2. ALLIANCE_CHAT_SEND

        The AllianceChat plugin will generate this event when the user sends a message via
        the prompt or other ui. Use RegisterEvent(your.function, "ALLIANCE_CHAT_SEND") to listen
        for this event and add code to send it's data to your echo server

MESSAGES: The table structure that will be consumed and sent by AllianceChat has a
          structure like the following sample:

{
    name      = "John Wayne",
    guild     = "ITO",
    factionColor = "\12737c8ab",
    msg       = "hello chat friends!",
}

        ETC:

        When this table is recieved by the ALLIANCE_CHAT_RECV event,
        the plugin would display <Ally> [ITO]John Wayne: hello chat friends!
        into the games chat window. The <Ally> portion is referred to as the "channelName" and
        it can be changed in settings.lua or via function calls in your own plugin (details elsewhere)

            1. "name" will be the name that is displayed as the one who sent the message
                defaults to the name of the current char from running GetPlayerName()

            2. "guild" will be the guild tag that is wrapped in brackets before the player's name ie.. [ITO]
                defaults to the guild tag of the current char from running GetGuildTag()

            3. "factionColor" will be a valid hex color code and will be used to set the display color of the name and guild
                defaults to the color of the current chars faction using rgbtohex(FactionColor_RGB[tonumber(GetPlayerFaction(id))]) or '127FFFFFF'

            4. "msg" will contain a string that is the text that was meant to be sent


