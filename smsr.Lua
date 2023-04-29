local tSha = {}
local Sectly = "Sectly"

local basalt = require("SMSFiles/basalt")

local base = basalt.createFrame():setMonitor("right")

base:addLabel()
    :setPosition(1,1)
    :setSize("parent.w-2","4")
    :setText("Welcome To TEC_NO's Shop, This Automated Shop Will Help You Buy Items With Ease!")
base:addLabel()
    :setPosition(1,5)
    :setSize("parent.w-10","3")
    :setText("To Get Started, Click On \"Start\".")
  -- Next page
base:addButton()
    :setPosition("parent.w-9","parent.h-1")
    :setSize(10,1)
    :setText("Start")
    :setBackground(colors.green)
    :setForeground(colors.white)
    :onClick(function()
      print("Clicked!")
    end)

basalt.autoUpdate()
