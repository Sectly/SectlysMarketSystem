local tSha = {}
local Sectly = "Sectly"

function splitstring(input, seperator)
  if seperator == nil then
    seperator = "%s"
  end
 
  local matches = {}
 
  for match in string.gmatch(input, "([^"..seperator.."]+)") do
    table.insert(matches, match)
  end
 
  return matches
end

local paymentType = nil
local priceTable = {}

function Loop()
  local basalt = require("SMSFiles/basalt")

  local welcomeFrame = basalt.createFrame():setMonitor("right")
  local shopFrame = basalt.createFrame():setMonitor("right")
  local amountFrame = basalt.createFrame():setMonitor("right")
  local purchaseFrame = basalt.createFrame():setMonitor("right")
  local textFrame = basalt.createFrame():setMonitor("right")

  welcomeFrame:show()

  local textFrameText = textFrame:addLabel():setText("Error: No Input Text")

  local function scanInventory()
    local items = {}

    for i = 1, 16 do
      if i ~= 1 then
        turtle.select(i)

        if (turtle.getItemCount(i) > 1) then
          local item = turtle.getItemDetail(i, false)

          if (item) then
            local displayName = item.name --item.displayName or item.name

            if items[item.name] and items[item.name] ~= nil then
              items[item.name].displayName = displayName

              if items[item.name].stock and items[item.name].stock ~= nil then
                items[item.name].stock = (items[item.name].stock + item.count)
              else
                items[item.name].stock = item.count
              end
            else
                items[item.name] = { ["displayName"] = displayName, ["stock"] =  item.count, ["slot"] = i }
            end
          end
        end
      end
    end

    turtle.select(1)

    return items
  end

  function handlePayment(shopData, scanData, itemAmount)
    function loopPayment()
    
    end

    loopPayment()
  end

  function buyItem(shopData, scanData)
    textFrameText:setText("Loading...")
    textFrame:show()

    local getItem = shopData:getItem(shopData:getItemIndex()).text
    
    local idString = splitstring(getItem, "|")
    idString = string.gsub(idString[1], " ", "")

    if scanData[idString] and scanData[idString] ~= nil then
        turtle.select(scanData[idString].slot)

        if turtle.getItemDetail(scanData[idString].slot, false).name == idString and turtle.getItemDetail(scanData[idString].slot, false).count > 1 then
          textFrameText:setText("Selected Product: "..idString..", Please Wait...")
          
          sleep(1)

          textFrameText:setText("Select How Many "..idString.." You Want: ")

          local amountList = amountFrame:addList("amountList"):setPosition(2,2):setSize(48,16):setScrollable(true)

          local maxItemAmount = getItemCount(scanData[idString].slot)

          amountList:addItem("1")

          if maxItemAmount == 16 and getItemSpace(scanData[idString].slot) <= 0 then
              maxItemAmount = 16

              amountList:addItem(""..maxItemAmount / 2.."")
          else
              amountList:addItem(""..maxItemAmount / 8.."")
              amountList:addItem(""..maxItemAmount / 4.."")
              amountList:addItem(""..maxItemAmount / 2.."")
          end

          amountList:addItem(""..maxItemAmount.."")

          amountFrame:addButton()
            :setPosition("parent.w-10","parent.h-1")
            :setSize(10,1)
            :setText("Buy")
            :setBackground(colors.green)
            :setForeground(colors.white)
            :onClick(function()
              handlePayment(shopData, scanData, amountList:getItem(amountList:getItemIndex()).text)
            end)
          amountFrame:addButton()
            :setPosition("parent.w-48","parent.h-1")
            :setSize(10,1)
            :setText("Cancel")
            :setBackground(colors.yellow)
            :setForeground(colors.white)
            :onClick(function()
              basalt.stopUpdate()

              Loop()
            end)
        else
          textFrameText:setText("ERROR: Product Does Not Exist, Rebooting Shop... [ERR:PM2]")

          sleep(4)

          basalt.stopUpdate()

          Loop()
        end
    else
      textFrameText:setText("ERROR: Product Does Not Exist, Rebooting Shop... [ERR:PM1]")

      sleep(4)

      basalt.stopUpdate()

      Loop()
    end
  end

  local refreshStock = basalt.schedule(function()
    textFrameText:setText("Loading...")
    welcomeFrame:hide()
    textFrame:show()

    local scanData = scanInventory()

    local shopData = shopFrame:addList("productList"):setPosition(2,2):setSize(48,16):setScrollable(true)

    for Id, Item in pairs(scanData) do
      print(Id)
      print(Item)
      shopData:addItem(" "..Item.displayName.." | (Stock: "..Item.stock..")")
    end

    shopFrame:addButton()
      :setPosition("parent.w-10","parent.h-1")
      :setSize(10,1)
      :setText("Buy")
      :setBackground(colors.green)
      :setForeground(colors.white)
      :onClick(function()
        shopFrame:hide()

        buyItem(shopData, scanData)
      end)
    shopFrame:addButton()
      :setPosition("parent.w-48","parent.h-1")
      :setSize(10,1)
      :setText("Cancel")
      :setBackground(colors.yellow)
      :setForeground(colors.white)
      :onClick(function()
        basalt.stopUpdate()

        Loop()
      end)

    textFrameText:setText("Choose A Product: ")
    shopFrame:show()
  end)

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
    :setPosition("parent.w-10","parent.h-1")
    :setSize(10,1)
    :setText("Start")
    :setBackground(colors.green)
    :setForeground(colors.white)
    :onClick(function()
      refreshStock()
   end)

   print("Starting Setup")

   local getInventory = scanInventory()

   print("Checking Data...")

   if fs.exists("SMSFiles/data.txt") then
     local file = fs.open("SMSFiles/data.txt", "r")
     local contents = textutils.unserialize(file.readAll())
     file.close()

     paymentType = contents.payment
     priceTable = contents.prices
   end

   if paymentType == nil then
     print("Payment Type: [Example: minecraft:diamond]")
       
     paymentType = read()
   end

   for Id, Item in pairs(getInventory) do
     if priceTable[Id] and priceTable[Id] ~= nil then
       print("Registered: "..Id..", Price: "..priceTable[Id])
     else
       print("No Price For: "..Id)

       print("Input Price Per Item: [Example: 1 Or 0.2]")

       priceTable[Id] = read()
     end
   end

   local file = fs.open("SMSFiles/data.txt", "w")
   file.write(textutils.serialise({ ["payment"] = paymentType, ["prices"] = priceTable }))
   file.close()

   print("Setup Done!")

   turtle.select(1)
   turtle.drop()

   print("Shop Started!")

   basalt.autoUpdate()
end

Loop()
