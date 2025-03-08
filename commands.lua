
AllianceChat.Commands = AllianceChat.Commands or {
    ['prompt'] = function ()
         ShowDialog(AllianceChat.UI.chatPrompt)
    end,

    help = function()
        print ("help function called in AllianceChat.Commands.lua")
    end,

}


local function Dispatch(_, args)
    if(args ~= nil)then                       -- if there are argumets to the command
        local commName = table.remove(args,1) -- capture the first argument
        if (AllianceChat.Commands[commName]) then   -- check to see the function is provided in the table
            AllianceChat.Commands[commName](args)   -- execute the found function and give it the remaining arguments
        else                                  -- if an argument did not have a corresponding function
            print("command not found")
        end
    else                                      -- if no arguments are given
        AllianceChat.Commands.help()                -- execute the help command (they need help)
    end
end


RegisterUserCommand('ac', Dispatch, "") -- register the dispatch function to execute when the command is given



-- function AllianceChat.Commands.prompt(_, data)
--     if data ~= nil then
--         local message = table.concat(data, " ") or ""
--         AllianceChat.send({
--             name      = GetPlayerName(),
--             guild     = GetGuildTag(),
--             factionColor = rgbtohex(FactionColor_RGB[tonumber(GetPlayerFaction())]) or '127FFFFFF',
--             msg       = message,
--
--         })
--     end
-- end

-- -- to make AllianceChannel provide a prompt via hotkey that appears
-- -- like it is part of the game's regular chat service
-- -- first we create a command, the name of which will unfortunately contain
-- -- the color number of the prompt.. it's dumb but that's what they provided
local command = AllianceChat.Settings.promptName
RegisterUserCommand(command, AllianceChat.Commands.prompt)

-- next we create an alias to the "prompt" command
-- when this alias is called, it will produce a prompt with the colored
-- channel name in place, prompting the user to type a message

gkinterface.GKProcessCommand("alias ".. command.." 'ac prompt'")

-- now we bind a key to the alias we created
gkinterface.GKProcessCommand("bind Y "..command)

return AllianceChat.Commands
