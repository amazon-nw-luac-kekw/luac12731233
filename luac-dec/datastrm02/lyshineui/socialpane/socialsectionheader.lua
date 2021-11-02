local SocialSectionHeader = {
  Properties = {
    Title = {
      default = EntityId()
    },
    Count = {
      default = EntityId()
    },
    Fill = {
      default = EntityId()
    },
    Button = {
      default = EntityId()
    },
    CountBg = {
      default = EntityId()
    },
    UpArrow = {
      default = EntityId()
    },
    DownArrow = {
      default = EntityId()
    },
    AltCountBg = {
      default = EntityId()
    },
    AltCountText = {
      default = EntityId()
    },
    TopLine = {
      default = EntityId()
    }
  },
  originalPivotX = 0,
  originalPositionX = 0,
  currentStyle = 0,
  bgImagePath = "LyShineUI/Images/socialpane/social_inviteBg.png"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SocialSectionHeader)
function SocialSectionHeader:OnInit()
  self.originalPivotX = UiTransformBus.Event.GetPivotX(self.Properties.UpArrow)
  self.originalPositionX = UiTransformBus.Event.GetLocalPositionX(self.Properties.UpArrow)
  self.styles = {invite = 1, list = 2}
  self.currentStyle = self.styles.invite
end
function SocialSectionHeader:SetCountText(text)
  if self.currentStyle == self.styles.invite then
    UiTextBus.Event.SetText(self.Properties.Count, text)
    if text == "0" then
      UiFaderBus.Event.SetFadeValue(self.Properties.CountBg, 0)
    else
      UiFaderBus.Event.SetFadeValue(self.Properties.CountBg, 1)
      local textSize = UiTextBus.Event.GetTextSize(self.Properties.Count).x
      local textWidth = textSize + 20
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.CountBg, textWidth)
    end
  else
    UiTextBus.Event.SetText(self.Properties.AltCountText, text)
  end
end
function SocialSectionHeader:SetHeaderStyle(style)
  if self.currentStyle == style then
    return
  end
  local show = self.currentStyle == self.styles.list
  UiElementBus.Event.SetIsEnabled(self.Properties.Count, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.CountBg, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.AltCountBg, not show)
  UiElementBus.Event.SetIsEnabled(self.Properties.AltCountText, not show)
  UiElementBus.Event.SetIsEnabled(self.Properties.Fill, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.TopLine, show)
  self.currentStyle = style
  if style == self.styles.invite then
    UiTransformBus.Event.SetPivotX(self.Properties.DownArrow, self.originalPivotX)
    UiTransformBus.Event.SetPivotX(self.Properties.UpArrow, self.originalPivotX)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.UpArrow, self.originalPositionX)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.DownArrow, self.originalPositionX)
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.DownArrow, UiAnchors(1, 0.5, 1, 0.5))
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.UpArrow, UiAnchors(1, 0.5, 1, 0.5))
    UiImageBus.Event.SetSpritePathname(self.entityId, self.bgImagePath)
    UiImageBus.Event.SetColor(self.entityId, ColorRgba(255, 255, 255, 1))
  else
    UiTransformBus.Event.SetPivotX(self.Properties.DownArrow, 0)
    UiTransformBus.Event.SetPivotX(self.Properties.UpArrow, 0)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.UpArrow, 0)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.DownArrow, 0)
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.DownArrow, UiAnchors(0, 0.5, 0, 0.5))
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.UpArrow, UiAnchors(0, 0.5, 0, 0.5))
    UiImageBus.Event.SetSpritePathname(self.entityId, "")
    UiImageBus.Event.SetColor(self.entityId, ColorRgba(0, 0, 0, 0))
  end
end
function SocialSectionHeader:ToggleListButton(buttonEntityId, shouldExpand)
  DynamicBus.SocialMenuBus.Broadcast.ToggleListButton(self.entityId, shouldExpand)
end
return SocialSectionHeader
