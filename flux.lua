  -- Simple lookup table returning outflux curves for the fuels
local flux = {}

function flux.passive(x, reactivity)
  return 0
end

function flux.log(x, reactivity)
  return 0.5 * math.log10(x + 1) * reactivity
end

function flux.euler(x, reactivity)
  return (1 - math.exp(-x/25)) * reactivity
end

function flux.arch(x, reactivity)
  return (x - (x^2 / 10000)) / 100 * reactivity
end

function flux.sigmoid(x, reactivity)
  return reactivity / (1 + math.exp(-(x - 50) / 10))
end

function flux.sqrt(x, reactivity)
  return math.sqrt(x) / 10 * reactivity
end

function flux.linear(x, reactivity)
  return x / 100 * reactivity
end

function flux.quadratic(x, reactivity)
  return x^2 / 10000 * reactivity
end

function flux.voices(x, reactivity)
  return x * (math.sin(x) + 1) * reactivity
end

return flux