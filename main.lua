--[[

Author: Joshua S. Day (haxmeister)

Purpose: This plugin provides event hooks to simplify a private chat plugin
         See the readme file that should have accompanied this plugin for details


--]]

-- The table that will contain the AllianceChat plugin
AllianceChat = AllianceChat or {}

AllianceChat.Settings = dofile "settings.lua"
AllianceChat.Commands = dofile "commands.lua"
AllianceChat.UI = dofile "ui.lua"

-- event hooks
function AllianceChat.recv (_,data)
    local msg = AllianceChat.Settings.promptColor
    msg = msg..AllianceChat.Settings.channelName
    msg = msg..data.factionColor
    if (data.guild ~= "")then
        msg = msg.."["..data.guild.."] "
    end
    msg = msg..data.name..": "
    msg = msg..AllianceChat.Settings.msgColor
    msg = msg..data.msg

    print (msg)
end

-- send the user's message to the event for other plugins to process
function AllianceChat.send(msg)
    local data = {
        name = GetPlayerName(),
        guild = GetGuildTag() or "",
        factionColor = rgbtohex(FactionColor_RGB[tonumber(GetPlayerFaction())]) or '127FFFFFF',
        msg = msg,
    }
    ProcessEvent("ALLIANCE_CHAT_SEND", data)
end

RegisterEvent(AllianceChat.recv, "ALLIANCE_CHAT_RECV")
