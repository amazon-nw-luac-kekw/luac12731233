local UnreadBadge = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    },
    Ring = {
      default = EntityId()
    },
    Number = {
      default = EntityId()
    },
    TextShadow = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    }
  },
  isShowingNumber = false,
  isShowingText = false,
  STYLE_DEFAULT = 0,
  STYLE_MASTERY = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(UnreadBadge)
function UnreadBadge:OnInit()
  local numberStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 40,
    characterSpacing = 0,
    fontColor = self.UIStyle.COLOR_TAN_LIGHT
  }
  SetTextStyle(self.Properties.Number, numberStyle)
  local textStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA_ITALIC,
    fontSize = 18,
    characterSpacing = 0,
    fontColor = self.UIStyle.COLOR_TAN_LIGHT
  }
  SetTextStyle(self.Properties.Text, textStyle)
  local textW = UiTextBus.Event.GetTextWidth(self.Properties.Text)
  if textW then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.TextShadow, textW)
  end
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, canvasId)
end
function UnreadBadge:OnShutdown()
  self:StopAnimation()
  if self.glowPulseTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.glowPulseTimeline)
  end
end
function UnreadBadge:SetStyle(style)
  if style == self.STYLE_MASTERY then
    UiImageBus.Event.SetSpritePathname(self.Properties.Background, "lyshineui/images/objectives/journal/unreadBadgeBgMastery.dds")
    UiImageBus.Event.SetSpritePathname(self.Properties.Glow, "lyshineui/images/objectives/journal/unreadBadgeGlowMastery.dds")
    UiImageBus.Event.SetSpritePathname(self.Properties.Ring, "lyshineui/images/objectives/journal/unreadBadgeRingMastery.dds")
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.Background, "lyshineui/images/objectives/journal/unreadBadgeBg.dds")
    UiImageBus.Event.SetSpritePathname(self.Properties.Glow, "lyshineui/images/objectives/journal/unreadBadgeGlow.dds")
    UiImageBus.Event.SetSpritePathname(self.Properties.Ring, "lyshineui/images/objectives/journal/unreadBadgeRing.dds")
  end
end
function UnreadBadge:StartAnimation(randomizeStart)
  if self.isAnimating then
    return
  end
  if not self.glowPulseTimeline then
    self.glowPulseTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.glowPulseTimeline:Add(self.Properties.Glow, 0.35, {opacity = 0.6, ease = "QuadOut"})
    self.glowPulseTimeline:Add(self.Properties.Glow, 0.05, {opacity = 0.6})
    self.glowPulseTimeline:Add(self.Properties.Glow, 0.6, {
      opacity = 0.2,
      ease = "QuadOut",
      onComplete = function()
        self.glowPulseTimeline:Play()
      end
    })
  end
  self.glowPulseTimeline:Play()
  local startingRotation = randomizeStart and math.random(359) or 0
  self.ScriptedEntityTweener:Play(self.Properties.Ring, 10, {rotation = startingRotation}, {
    rotation = startingRotation - 359,
    ease = "Linear",
    timesToPlay = -1
  })
  self.isAnimating = true
end
function UnreadBadge:StopAnimation()
  if self.glowPulseTimeline then
    self.glowPulseTimeline:Stop()
  end
  self.ScriptedEntityTweener:Stop(self.Properties.Ring)
  self.isAnimating = false
end
function UnreadBadge:SetNumber(number)
  if number ~= nil then
    UiTextBus.Event.SetText(self.Properties.Number, tostring(number))
    UiElementBus.Event.SetIsEnabled(self.Properties.Number, true)
    self.isShowingNumber = true
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Number, false)
    self.isShowingNumber = false
  end
  self:UpdateLayout()
end
function UnreadBadge:SetIsShowingText(showText)
  self.isShowingText = showText
  UiElementBus.Event.SetIsEnabled(self.Properties.Text, showText)
  UiElementBus.Event.SetIsEnabled(self.Properties.TextShadow, showText)
  self:UpdateLayout()
end
function UnreadBadge:UpdateLayout()
  if self.isShowingText then
    local textY = self.isShowingNumber and 20 or 0
    self.ScriptedEntityTweener:Set(self.Properties.Text, {y = textY})
    self.ScriptedEntityTweener:Set(self.Properties.TextShadow, {y = textY})
  end
end
function UnreadBadge:OnCanvasEnabledChanged(isEnabled)
  if not isEnabled then
    self:StopAnimation()
  end
end
return UnreadBadge
