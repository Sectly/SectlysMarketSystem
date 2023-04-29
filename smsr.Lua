local tSha = {}
local Sectly = "Sectly"

local basalt = require("SMSFiles/basalt")

local main = basalt.createFrame()

local button = main:addButton()
button:setPosition(4, 4)
button:setSize(16, 3)
button:setText("Click me!")

local function buttonClick()
    basalt.debug("I got clicked!")
end

button:onClick(buttonClick)

basalt.autoUpdate()
