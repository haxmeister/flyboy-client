--HUD.chatcontainer.vbox
--HUD.Reload()
 AllianceChat.UI = AllianceChat.UI or {}

 AllianceChat.UI.chatPrompt = iup.dialog {
     iup.vbox{
        iup.fill{size = "%17x%100"},
        iup.pdarootframebg {
            iup.hbox {

                iup.label{
                    title = AllianceChat.Settings.promptName,
                },

                iup.text{
                    --title = "send",
                    expand = "HORIZONTAL",
                    action = function (self,key, string)
                        local parent = iup.GetDialog(self)
                        if (key == 13)then -- enter key
                            HideDialog(parent)
                            AllianceChat.send(self.value)
                            self.value = ""
                        end
                        if (key == 27)then -- escape
                            HideDialog(parent)
                            self.value = ""
                        end
                    end,
                },
                iup.fill{
                    expand = "YES",
                },
            },
        },

        iup.fill{EXPAND =   "YES"},
    },
    border="NO",menubox="NO",resize="NO",
    topmost="YES",
    modal="YES",
    alignment="ACENTER",
    bgcolor="0 0 0 0 *",
    fullscreen="YES",
}
 AllianceChat.UI.chatPrompt:map()
return AllianceChat.UI
