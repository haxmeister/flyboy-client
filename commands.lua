--[[

Author: Joshua S. Day (haxmeister)

Purpose: This file provides /flyboy commands that
         can be executed from the chat window during game play

--]]

--[[

Flyboy.Commands is the table that will hold our commands
any command here can be executed in game using /flyboy [function name]
to add a command simply add a function with the corresponding name
to this table

--]]
Flyboy.Commands = {

    help = function()
        print ("help function called")
    end,

    connect = function()
        Flyboy.Conn:Connect(Flyboy.server, Flyboy.port)
    end,

    disconnect = function()
        Flyboy.Conn:Disconnect()
    end,
}

--[[

This dispatch function is the only registered command in flyboy
and has the purpose of finding the appropriate function to
execute in the Flyboy.Commands table seen above

it accepts 2 arguments that are sent by the game system. The
first is "flyboy" which we dispose of because it's known already.
The second is a table containing all the words the player entered
in order and are used to choose the function from the table.
--]]
local function Dispatch(_, args)
    if(args ~= nil)then                       -- if there are argumets to the command
        local commName = table.remove(args,1) -- capture the first argument
        if (Flyboy.Commands[commName]) then   -- check to see the function is provided in the table
            Flyboy.Commands[commName](args)   -- execute the found function and give it the remaining arguments
        else                                  -- if an argument did not have a corresponding function
            ProcessEvent("FB_CHATBOX_MSG", {  -- send a message to the chatbox through the event system
                    type = "error",           -- using "error" type so the message is in red
                    str  = "Command not known ("..commName..")"})
        end
    else                                      -- if no arguments are given
        Flyboy.Commands.help()                -- execute the help command (they need help)
    end
end


RegisterUserCommand('flyboy', Dispatch, "") -- register the dispatch function to execute when the command is given

return Flyboy.Commands
