local PlayerStatListItem = {
  Properties = {
    StatName = {
      default = EntityId()
    },
    StatValue = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PlayerStatListItem)
function PlayerStatListItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.StatName, self.UIStyle.FONT_STYLE_WARBOARD_PLAYERSTAT_STATNAME)
  SetTextStyle(self.Properties.StatValue, self.UIStyle.FONT_STYLE_WARBOARD_PLAYERSTAT_VALUE)
end
function PlayerStatListItem:OnShutdown()
end
function PlayerStatListItem:SetData(data)
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatName, data.statName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.StatValue, data.statValue)
  if data.color then
    UiTextBus.Event.SetColor(self.Properties.StatValue, data.color)
  end
end
return PlayerStatListItem
