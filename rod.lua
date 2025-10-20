local component = require("component")
local console = component.rbmk_console
local fuel = require("fuel")
-- local crane = component.rbmk_crane

local abLookup = {
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"
}

  -- Two-dimensional array whose non-nil elements are strings indicating to inserted fuel type.
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
      if fuelRods[abLookup[col + 1]] == nil then fuelRods[abLookup[col + 1]] = {} end
        fuelRods[abLookup[col + 1]][row] = data.moderated
      end
    end
  end
end

  -- Determines what fuel is loaded into fuel rods. Prompts user input if ambiguity exists.
local pollControlRods = coroutine.create(
  function()
    for k, v in pairs(fuelRods) do
	  if fuel.findByTemp() 
	
      coroutine.yield(k, v)
    end
  end
)

initialize()

