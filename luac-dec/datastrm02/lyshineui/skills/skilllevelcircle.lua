local SkillLevelCircle = {
  Properties = {
    LevelText = {
      default = EntityId()
    },
    Ring = {
      default = EntityId()
    }
  },
  displayType = 0,
  DISPLAY_TYPE_NORMAL = 0,
  DISPLAY_TYPE_WARNING = 1,
  DISPLAY_TYPE_DIM = 2
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SkillLevelCircle)
function SkillLevelCircle:OnInit()
  BaseElement.OnInit(self)
end
function SkillLevelCircle:SetLevel(currentLevel)
  UiTextBus.Event.SetText(self.Properties.LevelText, currentLevel)
end
function SkillLevelCircle:SetDisplayType(typeEnum)
  if typeEnum == self.displayType then
    return
  end
  self.displayType = typeEnum
  local ringColor = self.UIStyle.COLOR_TAN
  local textColor = self.UIStyle.COLOR_WHITE
  if typeEnum == self.DISPLAY_TYPE_WARNING then
    ringColor = self.UIStyle.COLOR_RED_DARK
    textColor = self.UIStyle.COLOR_RED_LIGHT
  elseif typeEnum == self.DISPLAY_TYPE_DIM then
    ringColor = self.UIStyle.COLOR_TAN_DARKER
    textColor = self.UIStyle.COLOR_TAN
  end
  UiImageBus.Event.SetColor(self.Properties.Ring, ringColor)
  UiTextBus.Event.SetColor(self.Properties.LevelText, textColor)
end
return SkillLevelCircle
