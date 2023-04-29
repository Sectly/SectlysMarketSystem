local tSha = {}
local Sectly = "Sectly"

local basalt = require("SMSFiles/basalt")

local base = basalt.createFrame():setMonitor("right")

local title = base:addLabel("_title")
    :setText("Sectly's Market System")
    :setPosition(2,2)
    :setFontSize(2)
local page = base:addLabel("_page")
    :setText("1/4")
    :setPosition("parent.w-self.w-1",4)
base:addPane()
    :setPosition(2,5)
    :setSize("parent.w-2",1)
    :setBackground(false, '\140', colors.gray)
local content = base:addFrame("_content")
    :setPosition(2,6)
    :setSize("parent.w-2","parent.h-5")
    :setBackground(colors.lightGray)

local welcome,licence,destination,install,done = 
    content:addFrame("_welcome")    :setBackground(colors.lightGray):show(),
    content:addFrame("_licence")    :setBackground(colors.lightGray):hide(),
    content:addFrame("_destination"):setBackground(colors.lightGray):hide(),
    content:addFrame("_install")    :setBackground(colors.lightGray):hide(),
    content:addFrame("_done")       :setBackground(colors.lightGray):hide()

welcome:addLabel()
    :setPosition(1,1)
    :setSize("parent.w-2","4")
    :setText("Welcome To TEC_NO's Shop, This Automated Shop Will Help You Buy Items With Ease!")
  welcome:addLabel()
    :setPosition(1,5)
    :setSize("parent.w-10","3")
    :setText("To Get Started, Click On \"Start\".")
  -- Next page
    welcome:addButton()
    :setPosition("parent.w-9","parent.h-1")
    :setSize(10,1)
    :setText("Start")
    :setBackground(colors.green)
    :setForeground(colors.white)
    :onClick(function()
      welcome:hide()
      title:setText("Licence")
      page:setText("2/4")
      licence:show()
      blockInput = true
    end)
