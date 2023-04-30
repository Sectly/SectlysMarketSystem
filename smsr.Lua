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
  local shopFrameText = shopFrame:addLabel():setText("Please Choose Your Product: ")
  local amountFrameText = amountFrame:addLabel():setText("Please Choose Your Product Amount: ")

  local purchaseFrameText = purchaseFrame:addLabel():setPosition(8,8):setSize("parent.w-10","3"):setText("Please Input X ?(s) And Then Click Finish To Receive Your Product!")

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

  function calculatePrice(id, amount)
    local priceData = math.floor(tonumber(priceTable[id]) * tonumber(amount)) or 64

    if priceData < 1 then
      priceData = 1
    end

    return priceData or 64
  end

  function handlePayment(itemSlot, idString, amount)
    function loopPayment()
      local cost = calculatePrice(idString, math.floor(amount))

      purchaseFrame:show()
      purchaseFrameText:setText("Please Input "..cost.." "..paymentType.."(s) And Then Click Finish To Receive Your Product!")

      purchaseFrame:addButton()
          :setPosition("parent.w-10","parent.h-1")
          :setSize(10,1)
          :setText("Finish")
          :setBackground(colors.green)
          :setForeground(colors.white)
          :onClick(function()
            turtle.select(1)

            if turtle.getItemDetail(1, false) and turtle.getItemDetail(1, false) ~= nil and turtle.getItemDetail(1, false).name == paymentType then
              if turtle.getItemCount(1) >= cost then
                local getBack = (turtle.getItemCount(1) - cost)

                if getBack >= 1 then
                  turtle.select(1)
                  turtle.drop(getBack)
                end

                turtle.select(1)
                turtle.dropDown()

                turtle.select(itemSlot)
                turtle.dropDown(amount)

                purchaseFrameText:setText("Thanks For Shopping And Come Again!")

                sleep(4)

                basalt.stopUpdate()

                Loop()
              else
                purchaseFrameText:setText("Error: More Payment Is Required!")

                sleep(2)

                loopPayment()
              end
            else
              purchaseFrameText:setText("Error: Wrong Payment Type/No Payment Input!")

              turtle.select(1)
              turtle.drop()

              sleep(2)

              loopPayment()
            end
          end)
        purchaseFrame:addButton()
          :setPosition("parent.w-48","parent.h-1")
          :setSize(10,1)
          :setText("Cancel")
          :setBackground(colors.yellow)
          :setForeground(colors.white)
          :onClick(function()
            turtle.select(1)
            turtle.drop()

            basalt.stopUpdate()

            Loop()
          end)
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
          textFrame:show()
          
          sleep(2)

          amountFrame:show()

          local amountList = amountFrame:addList("amountList"):setPosition(2,2):setSize(48,16):setScrollable(true)

          local maxItemAmount = turtle.getItemCount(scanData[idString].slot)

          amountList:addItem(" Amount: 1 | Price: "..calculatePrice(idString, 1))

          if maxItemAmount == 16 and turtle.getItemSpace(scanData[idString].slot) <= 0 then
              maxItemAmount = 16

              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 8).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 8)))
              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 4).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 4)))
              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 2).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 2)))
          else
              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 32).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 32)))
              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 16).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 16)))
              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 8).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 8)))
              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 4).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 4)))
              amountList:addItem(" Amount: "..math.floor(maxItemAmount / 2).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount / 2)))
          end

          amountList:addItem(" Amount: "..math.floor(maxItemAmount).." | Price: "..calculatePrice(idString, math.floor(maxItemAmount)))
          amountList:show()

          amountFrame:addButton()
            :setPosition("parent.w-10","parent.h-1")
            :setSize(10,1)
            :setText("Buy")
            :setBackground(colors.green)
            :setForeground(colors.white)
            :onClick(function()
              local amountListText = amountList:getItem(amountList:getItemIndex()).text
              amountListText = splitstring(amountListText, "|")
              amountListText = string.gsub(amountListText[1], " ", "")
              amountListText = string.gsub(amountListText, "Amount:", "")

              handlePayment(scanData[idString].slot, idString, tonumber(amountListText))
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
