local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local DifficultyColors = {
  colorThresholds = {
    {
      levelThresh = -3,
      textColor = UIStyle.COLOR_GRAY_70,
      textColorLight = UIStyle.COLOR_GRAY_80,
      color = UIStyle.COLOR_RED
    },
    {
      levelThresh = 0,
      textColor = UIStyle.COLOR_WHITE,
      textColorLight = UIStyle.COLOR_WHITE,
      color = UIStyle.COLOR_RED
    },
    {
      levelThresh = 3,
      textColor = UIStyle.COLOR_YELLOW_ORANGE,
      textColorLight = MixColors(UIStyle.COLOR_YELLOW_ORANGE, UIStyle.COLOR_WHITE, 0.2),
      color = UIStyle.COLOR_RED
    },
    {
      levelThresh = 5,
      textColor = UIStyle.COLOR_ORANGE_BRIGHT,
      textColorLight = MixColors(UIStyle.COLOR_ORANGE_BRIGHT, UIStyle.COLOR_WHITE, 0.2),
      color = UIStyle.COLOR_RED
    },
    {
      levelThresh = GetMaxNum(),
      textColor = UIStyle.COLOR_RED,
      textColorLight = UIStyle.COLOR_RED_LIGHT,
      color = UIStyle.COLOR_RED
    }
  }
}
function DifficultyColors:GetColor(level, useLightColor)
  local playerLevel = dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
  if not playerLevel then
    return UIStyle.COLOR_WHITE
  end
  local levelDiff = level - playerLevel
  for i = 1, #self.colorThresholds do
    if levelDiff <= self.colorThresholds[i].levelThresh then
      return useLightColor and self.colorThresholds[i].textColorLight or self.colorThresholds[i].textColor
    end
  end
  return UIStyle.COLOR_WHITE
end
function DifficultyColors:GetColorRange(lowLevel, highLevel, useLightColor)
  local playerLevel = dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
  local effectiveDifficultyLevel = playerLevel
  if highLevel < playerLevel then
    effectiveDifficultyLevel = highLevel
  elseif lowLevel > playerLevel then
    effectiveDifficultyLevel = lowLevel
  end
  return DifficultyColors:GetColor(effectiveDifficultyLevel, useLightColor)
end
return DifficultyColors
