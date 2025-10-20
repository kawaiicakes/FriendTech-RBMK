local flux = require("flux")
local depletion = require("depletion")

  -- Module for static properties regarding fuel rods.
local fuel = {}

fuel.types = {}

  -- Returns the fuel(s) with the passed meltdown temp.
function fuel.findByTemp(maxHeat)
  toReturn = {}
  
  for k, v in pairs(fuel.types) do
    if v.maxHeat == maxHeat then
      table.insert(toReturn, k)
    end
  end
  
  return toReturn
end

function fuel.isValid(name)
  for k, v in pairs(fuel.types) do
    if k == name then return true end
  end

  return false
end
  -- Helper function intended for use in this file ONLY
local function createFuel(name, maxHeat, fluxCurve, depletionCurve, selfRate, reactivity, yield)
  fuelData = {}
  fuelData.maxHeat = maxHeat
  fuelData.fluxCurve = fluxCurve
  fuelData.depletionCurve = depletionCurve
  fuelData.selfRate = selfRate
  fuelData.reactivity = reactivity
  fuelData.yield = yield
    -- Takes the fuel depletion and desired flux as an argument. Returns the average control rod extraction 
    --  necessary (in a 4 reflector setup) to produce the passed flux.
  function fuelData.calculate(d, f)
    return f / (4 * fuelData.fluxCurve((f + fuelData.selfRate) * fuelData.depletionCurve(d)))
  end
  
  fuel.types[name] = fuelData
end

createFuel("flashlead", 2050.0, flux.arch, depletion.linear, 50, 40)

return fuel