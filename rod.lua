local component = require("component")
local fuel = require("fuel")
local prompter = require("prompter")
  -- adjust as needed. full program won't need this scuffed way of doing it lol
local fluxCap = 244.0

local console = component.rbmk_console
-- local crane = component.rbmk_crane

local abLookup = {
  [0]="A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"
}

  -- Two-dimensional array whose non-nil elements are strings indicating the inserted fuel type.
local fuelRods = {}

  -- Sets control rod level on all rods
function level(extraction)
  if type(extraction) ~= "number" then
    return false
  end
  console.setLevel(extraction)
  return true
end

  -- Caches all relevant RBMK components for quick lookup.
function cacheComponents()
  for col = 0, 14 do
    for row = 0, 14 do
      data = console.getColumnData(col, row)
      if data ~= nil and data.type == "FUEL" then
      if fuelRods[col] == nil then fuelRods[col] = {} end
        fuelRods[col][row] = "none"
      end
    end
  end
end

  -- Determines what fuel is loaded into fuel rods. Prompts user input if ambiguity exists.
function pollControlRods()
  cacheComponents()

  co = coroutine.create(
    function()
      for col, rowArr in pairs(fuelRods) do
        for row, fuelType in pairs(rowArr) do
          temporaryType = "I'm illegal!!!"
          maxHeat = console.getColumnData(col, row).coreMaxTemp
          location = localCoordsToLocation(col, row)
          
          nameByTemp = fuel.findByTemp(maxHeat)

          if maxHeat == nil or maxHeat == 0 or nameByTemp == nil then
            temporaryType = coroutine.yield("none", location)
          elseif #nameByTemp > 1 then
            temporaryType = coroutine.yield("ambiguous", location)
          else
            temporaryType = nameByTemp[1]
          end

          while not fuel.isValid(temporaryType) do
            temporaryType = coroutine.yield("illegal", temporaryType)
          end

          fuelRods[col][row] = temporaryType
        end
      end
    end
  )

  executed, result, result2 = coroutine.resume(co)
  if not executed then 
    print("Unable to poll rods on initial coroutine loop - " .. result)
    return false
  end

  while coroutine.status(co) ~= "dead" do
    if result == "none" then
      executed, result, result2 = coroutine.resume(co, prompter.getTextInput("No fuel rod detected in " .. result2 .. " - manual specification required"))
    elseif result == "ambiguous" then 
      executed, result, result2 = coroutine.resume(co, prompter.getTextInput("Max rod temperature shared by multiple fuel types in " .. result2 .. " - manual specification required"))
    elseif result == "illegal" then
      executed, result, result2 = coroutine.resume(co, prompter.getTextInput("Unknown fuel rod type '" .. result2 .. "', please try again."))
    else
      print("Illegal coroutine yield argument! Terminating!")
      return false
    end

    if not executed then
      print("Unable to poll rods - " .. result)
      return false
    end
  end

  print("Fuel rod polling completed successfully.")
  printComponents()
  return true
end

function printComponents()
  print("ROD DUMP:")
  print()
  for k1, v1 in pairs(fuelRods) do
    for k2, v2 in pairs(v1) do
      print(localCoordsToLocation(k1, k2) .. " - " .. v2)
    end
  end
end

function localCoordsToLocation(x, z)
  return abLookup[x] .. z
end

  -- Ad-hoc implementation here and below just so we can get the reactor online, WE NEED POWER NOW

print("Initiating automatic control rod protocols")

local scrammed = false
local maxTemp = 1845.00
local maxColumnTemp = 1350

function executeMainLoop()
  rodReader = coroutine.create(
    function()
      while not scrammed do
        locationColTemp = ""
        locationTemp = ""
        locationDep = ""
        highestColTemp = 20
        highestTemp = 20
        lowestDepletion = 100

        for k1, v1 in pairs(fuelRods) do
          for k2, v2 in pairs(v1) do
            data = console.getColumnData(k1, k2)

            if data.coreSkinTemp >= maxTemp or data.hullTemp >= maxColumnTemp then
              coroutine.yield(localCoordsToLocation(k1, k2), true, data.coreSkinTemp, data.hullTemp)
            end

            if data.coreSkinTemp > highestTemp then
              highestTemp = data.coreSkinTemp
              locationTemp = localCoordsToLocation(k1, k2)
            end

            if data.coreSkinTemp > highestTemp then
              highestTemp = data.coreSkinTemp
              locationTemp = localCoordsToLocation(k1, k2)
            end

            if data.enrichment < lowestDepletion then 
              lowestDepletion = data.enrichment 
              locationDep = localCoordsToLocation(k1, k2)
            end
          end
        end

        coroutine.yield(locationColTemp, false, highestColTemp, locationTemp, highestTemp, locationDep, lowestDepletion)
      end
    end
  )

  while not scrammed and coroutine.status(rodReader) ~= "dead" do
    rodReaderExecuted, result, result2, result3, result4, result5, result6, result7 = coroutine.resume(rodReader)

    if not rodReaderExecuted then
      SCRAM("Rod data polling unable to execute - " .. result)
    elseif result2 and result3 >= maxTemp then 
      SCRAM("MAXIMUM PERMISSIBLE CORE TEMPERATURE EXCEEDED IN " .. result .. " - " .. result3)
    elseif result2 and result4 >= maxColumnTemp then
      SCRAM("MAXIMUM PERMISSIBLE COLUMN TEMPERATURE EXCEEDED IN " .. result .. " - " .. result4)
    else
      -- do stats handoff here
      x = (fluxCap + 50) * result7
      newLevel = fluxCap / (4 * ((x - (x^2 / 10000)) / 100 * 40))
      level(newLevel)
      print(newLevel)
    end

    os.sleep(0.05)
  end
end

function SCRAM(msg)
  console.pressAZ5()
  scrammed = true
  print("-- REACTOR EMERGENCY SHUTDOWN INITIATED --")
  print(msg)
end
      
pollControlRods()
executeMainLoop()