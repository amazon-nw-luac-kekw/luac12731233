local PerformanceStatListItem = {
  Properties = {
    Background = {
      default = EntityId()
    },
    StatName = {
      default = EntityId()
    },
    StatValue = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PerformanceStatListItem)
function PerformanceStatListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.StatName, self.UIStyle.FONT_STYLE_WARBOARD_PERFORMANCE_STATNAME)
  SetTextStyle(self.Properties.StatValue, self.UIStyle.FONT_STYLE_WARBOARD_PERFORMANCE_VALUE)
end
function PerformanceStatListItem:OnShutdown()
end
function PerformanceStatListItem:SetData(data)
  self.data = data
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatName, data.statName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.StatValue, data.statValue)
  if data.color then
    UiImageBus.Event.SetColor(self.Properties.Background, data.color)
    local opacity = 0.3
    if data.statIndex % 2 == 0 then
      opacity = 0.15
    end
    UiFaderBus.Event.SetFadeValue(self.Properties.Background, opacity)
  end
end
return PerformanceStatListItem
