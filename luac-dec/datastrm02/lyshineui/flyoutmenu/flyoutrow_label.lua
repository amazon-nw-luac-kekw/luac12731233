local FlyoutRow_Label = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_Label)
function FlyoutRow_Label:OnInit()
  BaseElement.OnInit(self)
  self.initialHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Icon)
  self.iconPadding = -12
  self.initialTextWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Text)
end
function FlyoutRow_Label:SetData(data)
  if not data or not data.text then
    Log("[FlyoutRow_Label] Error: invalid data passed to SetData")
    return
  end
  local locFlag = eUiTextSet_SetLocalized
  if data.skipLocalization then
    locFlag = eUiTextSet_SetAsIs
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, data.text, locFlag)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, data.backgroundPath ~= nil)
  if data.backgroundPath then
    UiImageBus.Event.SetSpritePathname(self.Properties.Background, data.backgroundPath)
    UiImageBus.Event.SetColor(self.Properties.Background, data.backgroundColor or self.UIStyle.COLOR_WHITE)
  end
  if data.textColor then
    UiTextBus.Event.SetColor(self.Text, data.textColor)
  else
    UiTextBus.Event.SetColor(self.Text, self.UIStyle.COLOR_TAN)
  end
  local textWidth = self.initialTextWidth
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, data.iconPath ~= nil)
  if data.iconPath then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, data.iconPath)
    UiImageBus.Event.SetColor(self.Properties.Icon, data.iconColor or self.UIStyle.COLOR_WHITE)
  else
    textWidth = textWidth + self.iconWidth + self.iconPadding
  end
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Text, textWidth)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.Text, data.topPadding or 12)
  local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.Text)
  local topPadding = data.topPadding or 12
  local bottomPadding = data.bottomPadding or 16
  local totalHeight = topPadding + textHeight + bottomPadding
  local height = totalHeight
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
  return height
end
return FlyoutRow_Label
