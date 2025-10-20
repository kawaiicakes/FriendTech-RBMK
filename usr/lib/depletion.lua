  -- Simple lookup table returning depletion curves for the fuels
local depletion = {}

function depletion.linear(d)
  return d
end

function depletion.static(d)
  return 1
end

function depletion.boosted(d)
  return d * (d + math.sin(math.pi * (d - 1)^2))
end

function depletion.raising(d)
  return d * (d + math.sin(math.pi * d / 2))
end

function depletion.gentle(d)
  return d * (d + math.sin(math.pi * d / 3))
end

return depletion