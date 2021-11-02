local FactionScreenListItem = {
  Properties = {
    Title = {
      default = EntityId()
    },
    BulletPointContainer = {
      default = EntityId()
    },
    BulletPoint = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FactionScreenListItem)
function FactionScreenListItem:OnInit()
  BaseElement.OnInit(self)
end
function FactionScreenListItem:SetTitle(title)
  UiElementBus.Event.SetIsEnabled(self.Properties.Title, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.BulletPointContainer, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetLocalized)
  self.bulletPointHeight = UiTextBus.Event.GetTextHeight(self.Properties.Title)
end
function FactionScreenListItem:SetBulletPoint(text)
  UiElementBus.Event.SetIsEnabled(self.Properties.BulletPointContainer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.Title, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BulletPoint, text, eUiTextSet_SetLocalized)
  self.bulletPointHeight = UiTextBus.Event.GetTextHeight(self.Properties.BulletPoint)
end
function FactionScreenListItem:GetTextHeight()
  return self.bulletPointHeight
end
return FactionScreenListItem
