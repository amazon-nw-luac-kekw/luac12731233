local FrameHeader = {
  Properties = {
    FrameHeaderText = {
      default = EntityId()
    },
    FrameHeaderSecondary = {
      default = EntityId()
    },
    FrameHeaderHint = {
      default = EntityId()
    },
    FrameHeaderBg = {
      default = EntityId()
    }
  },
  HEADER_STYLE_DEFAULT = 1,
  HEADER_STYLE_DEFAULT_NO_OUTLINE = 2,
  HEADER_STYLE_LARGE_WITH_SUBTITLE = 3,
  HEADER_STYLE_DEFAULT_PATH = "lyshineui/images/slices/frameHeader/headerbg.dds",
  HEADER_STYLE_DEFAULT_NO_OUTLINE_PATH = "lyshineui/images/slices/frameHeader/headerbgnooutline.dds",
  TEXT_ALIGN_LEFT = eUiHAlign_Left,
  TEXT_ALIGN_CENTER = eUiHAlign_Center,
  TEXT_ALIGN_RIGHT = eUiHAlign_Right,
  width = 0,
  height = 0,
  textPadding = 10,
  hintMargin = 10
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FrameHeader)
function FrameHeader:OnInit()
  BaseElement.OnInit(self)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.width, self.height)
  self:SetVisualElements()
end
function FrameHeader:SetVisualElements()
  self:SetTextStyle(self.UIStyle.FONT_STYLE_FRAME_HEADER)
end
function FrameHeader:SetHeaderStyle(style)
  self.headerStyle = style
  if self.headerStyle == self.HEADER_STYLE_DEFAULT then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameHeaderBg, self.HEADER_STYLE_DEFAULT_PATH)
  elseif self.headerStyle == self.HEADER_STYLE_DEFAULT_NO_OUTLINE then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameHeaderBg, self.HEADER_STYLE_DEFAULT_NO_OUTLINE_PATH)
  elseif self.headerStyle == self.HEADER_STYLE_LARGE_WITH_SUBTITLE then
    SetTextStyle(self.Properties.FrameHeaderText, self.UIStyle.FONT_STYLE_FRAME_HEADER_LARGE)
    SetTextStyle(self.Properties.FrameHeaderSecondary, self.UIStyle.FONT_STYLE_FRAME_SUBHEADER)
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.FrameHeaderText, self.TEXT_ALIGN_CENTER)
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.FrameHeaderSecondary, self.TEXT_ALIGN_CENTER)
    self.ScriptedEntityTweener:Set(self.Properties.FrameHeaderText, {h = 80, y = -5})
    self.ScriptedEntityTweener:Set(self.Properties.FrameHeaderSecondary, {y = 70})
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameHeaderBg, self.HEADER_STYLE_DEFAULT_PATH)
    self:SetHeight(120)
  end
end
function FrameHeader:SetWidth(width)
  self:SetSize(width, self.height)
end
function FrameHeader:GetWidth()
  return self.width
end
function FrameHeader:SetHeight(height)
  self:SetSize(self.width, height)
end
function FrameHeader:GetHeight()
  return self.height
end
function FrameHeader:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.FrameHeaderText, self.width - self.textPadding)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.FrameHeaderSecondary, self.width - self.textPadding)
end
function FrameHeader:SetText(value, skipLocalization)
  self:SetTextVisible(true)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.FrameHeaderText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.FrameHeaderText, value, eUiTextSet_SetLocalized)
  end
end
function FrameHeader:GetText()
  return UiTextBus.Event.GetText(self.Properties.FrameHeaderText)
end
function FrameHeader:SetTextStyle(textStyle)
  SetTextStyle(self.Properties.FrameHeaderText, textStyle)
end
function FrameHeader:SetTextAlignment(value)
  UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.FrameHeaderText, value)
end
function FrameHeader:SetTextVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.FrameHeaderText, isVisible)
end
function FrameHeader:SetTextMarkupEnabled(value)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.FrameHeaderText, value)
end
function FrameHeader:SetTextShrinkToFit(value)
  UiTextBus.Event.SetShrinkToFit(self.Properties.FrameHeaderText, value)
end
function FrameHeader:SetTextSecondary(value, skipLocalization)
  self:SetTextSecondaryVisible(true)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.FrameHeaderSecondary, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.FrameHeaderSecondary, value, eUiTextSet_SetLocalized)
  end
end
function FrameHeader:GetTextSecondary()
  return UiTextBus.Event.GetText(self.Properties.FrameHeaderSecondary)
end
function FrameHeader:SetTextSecondaryVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.FrameHeaderSecondary, isVisible)
end
function FrameHeader:SetHintCallback(callback, table)
  self.FrameHeaderHint:SetCallback(callback, table)
end
function FrameHeader:SetHintKeybindMapping(value)
  UiElementBus.Event.SetIsEnabled(self.Properties.FrameHeaderHint, true)
  self.FrameHeaderHint:SetKeybindMapping(value)
  local hintWidth = self.FrameHeaderHint:GetWidth()
  local newTextWidth = self.width - (hintWidth + self.textPadding + self.hintMargin) * 2
  self.ScriptedEntityTweener:Set(self.Properties.FrameHeaderText, {
    w = newTextWidth,
    x = hintWidth + self.hintMargin
  })
end
function FrameHeader:SetBgVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.FrameHeaderBg, isVisible)
end
function FrameHeader:SetBgAlpha(alpha)
  self.ScriptedEntityTweener:Set(self.Properties.FrameHeaderBg, {opacity = alpha})
end
function FrameHeader:OnShutdown()
end
return FrameHeader
