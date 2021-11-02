local SectionHeader = {
  Properties = {
    Text = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    }
  },
  TEXT_ALIGN_LEFT = eUiHAlign_Left,
  TEXT_ALIGN_CENTER = eUiHAlign_Center,
  TEXT_ALIGN_RIGHT = eUiHAlign_Right
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SectionHeader)
function SectionHeader:OnInit()
  BaseElement.OnInit(self)
  self:SetTextAlignment(self.TEXT_ALIGN_LEFT)
  self:SetTextStyle(self.UIStyle.FONT_STYLE_TOOLTIP_STATS_HEADER)
  self:SetDividerColor(self.UIStyle.COLOR_GRAY_20)
end
function SectionHeader:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.Text, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, value, eUiTextSet_SetLocalized)
  end
end
function SectionHeader:GetText()
  return UiTextBus.Event.GetText(self.Properties.Text)
end
function SectionHeader:SetTextAlignment(value)
  UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.Text, value)
end
function SectionHeader:SetTextVAlignment(value)
  UiTextBus.Event.SetVerticalTextAlignment(self.Properties.Text, value)
end
function SectionHeader:SetTextStyle(style)
  SetTextStyle(self.Properties.Text, style)
end
function SectionHeader:SetTextColor(color)
  UiTextBus.Event.SetColor(self.Properties.Text, color)
end
function SectionHeader:GetTextColor()
  return UiTextBus.Event.GetColor(self.Properties.Text)
end
function SectionHeader:SetDividerColor(color)
  UiImageBus.Event.SetColor(self.Properties.Divider, color)
end
function SectionHeader:GetDividerColor()
  return UiImageBus.Event.GetColor(self.Properties.Divider)
end
function SectionHeader:SetWidth(width)
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, width)
end
function SectionHeader:GetWidth()
  return UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function SectionHeader:SetTextVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Text, isVisible)
end
function SectionHeader:SetDividerVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Divider, isVisible)
end
function SectionHeader:ShowBlueBackground(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, isVisible)
end
function SectionHeader:OnShutdown()
end
return SectionHeader
