local ResolutionManager = {
  defaultResolutions = {
    "1024 x 768",
    "1280 x 960",
    "1400 x 1050",
    "1440 x 1080",
    "1600 x 1200",
    "1856 x 1392",
    "1920 x 1440",
    "2048 x 1536",
    "1280 x 800",
    "1440 x 900",
    "1680 x 1050",
    "1920 x 1200",
    "2560 x 1600",
    "1280 x 720",
    "1366 x 768",
    "1600 x 900",
    "1920 x 1080",
    "2560 x 1440",
    "3840 x 2160",
    "2560 x 1080"
  }
}
function ResolutionManager:GetResolutions(dataLayer, isWindowedMode)
  local useDefaultResolutions = isWindowedMode
  local numSupportedResolutions = dataLayer:GetDataNode("Hud.LocalPlayer.Options.Video.SupportedResolutions.Count"):GetData()
  local resolutionsToShow = {}
  local maxWidth = 800
  local maxHeight = 600
  if numSupportedResolutions ~= nil and 0 < numSupportedResolutions then
    for i = 0, numSupportedResolutions - 1 do
      local dataString = "Hud.LocalPlayer.Options.Video.SupportedResolutions." .. i
      local resolution = dataLayer:GetDataNode(dataString):GetData()
      local resString = resolution.x .. " x " .. resolution.y
      resolutionsToShow[resString] = {
        resolution.x,
        resolution.y
      }
      maxWidth = math.max(maxWidth, resolution.x)
      maxHeight = math.max(maxHeight, resolution.y)
    end
  else
    useDefaultResolutions = true
    maxWidth = math.huge
    maxHeight = math.huge
  end
  if useDefaultResolutions then
    for i = 1, #self.defaultResolutions do
      local resString = self.defaultResolutions[i]
      local resValues = self:SplitResolutionString(resString)
      local width = tonumber(resValues[1])
      local height = tonumber(resValues[2])
      if maxWidth >= width and maxHeight >= height then
        resolutionsToShow[resString] = {width, height}
      end
    end
  end
  local resStrings = {}
  for k, _ in pairs(resolutionsToShow) do
    table.insert(resStrings, {
      text = k,
      width = tonumber(self:SplitResolutionString(k)[1]),
      height = tonumber(self:SplitResolutionString(k)[2])
    })
  end
  table.sort(resStrings, function(a, b)
    local resValuesA = self:SplitResolutionString(a.text)
    local aWidth = tonumber(resValuesA[1])
    local resValuesB = self:SplitResolutionString(b.text)
    local bWidth = tonumber(resValuesB[1])
    if aWidth == bWidth then
      return tonumber(resValuesA[2]) < tonumber(resValuesB[2])
    end
    return aWidth < bWidth
  end)
  return resStrings
end
function ResolutionManager:SplitResolutionString(resString)
  local splitString = {}
  for word in string.gmatch(resString, "([^x]+)") do
    splitString[#splitString + 1] = word
  end
  return splitString
end
return ResolutionManager
