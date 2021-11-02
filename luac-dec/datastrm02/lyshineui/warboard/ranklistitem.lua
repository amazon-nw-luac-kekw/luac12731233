local RankListItem = {
  Properties = {
    Backdrop = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    },
    Stats = {
      default = {
        EntityId()
      }
    },
    Highlight = {
      default = EntityId()
    },
    Name = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RankListItem)
function RankListItem:OnInit()
  BaseElement.OnInit(self)
end
function RankListItem:OnShutdown()
end
function RankListItem:SetData(data)
  if data.values then
    for i = 1, #data.values do
      if self.Properties.Stats[i - 1] then
        UiTextBus.Event.SetText(self.Properties.Stats[i - 1], data.values[i])
      end
    end
  end
  if data.isConnected then
    UiDesaturatorBus.Event.SetSaturationValue(self.Properties.PlayerIcon, 1)
    UiTextBus.Event.SetColor(self.Properties.Name, self.UIStyle.COLOR_WHITE)
    self.PlayerIcon:SetDarkener(false)
  else
    UiDesaturatorBus.Event.SetSaturationValue(self.Properties.PlayerIcon, 0)
    UiTextBus.Event.SetColor(self.Properties.Name, self.UIStyle.COLOR_GRAY_50)
    self.PlayerIcon:SetDarkener(true)
  end
  if data.color then
    UiImageBus.Event.SetColor(self.Properties.Backdrop, data.color)
  end
  if data.statIndex then
    local opacity = 0.3
    if data.statIndex % 2 == 0 then
      opacity = 0.15
    end
    UiFaderBus.Event.SetFadeValue(self.Properties.Backdrop, opacity)
  end
  if data.highlight then
    UiFaderBus.Event.SetFadeValue(self.Properties.Highlight, 1)
    UiImageBus.Event.SetColor(self.Properties.Highlight, data.color)
  else
    UiFaderBus.Event.SetFadeValue(self.Properties.Highlight, 0)
  end
  if data.playerId then
    self.PlayerIcon:SetPlayerId(data.playerId)
  end
end
return RankListItem
