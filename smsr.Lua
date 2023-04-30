local tSha = {}
local Sectly = "Sectly"

local basalt = require("SMSFiles/basalt")

local welcomeFrame = basalt.createFrame():setMonitor("right")
local shopFrame = basalt.createFrame():setMonitor("right")
local amountFrame = basalt.createFrame():setMonitor("right")
local purchaseFrame = basalt.createFrame():setMonitor("right")
local textFrame = basalt.createFrame():setMonitor("right")

welcomeFrame:show()

function scanInventory()
  local items = {}

  for i = 1, 16 do
    if i ~= 1 then
      turtle.select(i)

      if (turtle.getItemCount(i) > 1) then
        local item = turtle.getItemDetail(i, true)

        if (item) then
          local displayName = item.displayName or item.name

          if items[item.name] and items[item.name] ~= nil then
            items[item.name].displayName = displayName

            if items[item.name].stock and items[item.name].stock ~= nil then
              items[item.name].stock = (items[item.name].stock + item.count)
            else
              items[item.name].stock = item.count
            end
          else
              items[item.name] = { ["displayName"] = displayName, ["stock"] =  item.count}
          end
        end
      end
    end
  end

  return items
end

function refreshStock()
  local scanData = scanInventory()

  local shopData = shopFrame:addList("productList"):setPosition(20,2)

  for Id, Item in pairs(scanData) do
    shopData:addItem(Item.display.." (Stock: "..Item.count..") | Price: N/A")
  end

  sleep(14)
end

local textFrameText = textFrame:addLabel():setText("Error: No Input Text")

welcomeFrame:addLabel()
    :setPosition(1,1)
    :setSize("parent.w-2","4")
    :setText("Welcome To TEC_NO's Shop, This Automated Shop Will Help You Buy Items With Ease!")
welcomeFrame:addLabel()
    :setPosition(1,5)
    :setSize("parent.w-10","3")
    :setText("To Get Started, Click On \"Start\".")
  -- Next page
welcomeFrame:addButton()
    :setPosition("parent.w-9","parent.h-1")
    :setSize(10,1)
    :setText("Start")
    :setBackground(colors.green)
    :setForeground(colors.white)
    :onClick(function()
      textFrameText:setText("Loading...")
      textFrame:show()
      refreshStock()
      shopFrame:show()
    end)

basalt.autoUpdate()
