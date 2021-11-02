local TextCard = {
  Properties = {
    Title = {
      default = EntityId()
    },
    TitleLabel = {
      default = EntityId()
    },
    TitleBg = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    },
    HintText = {
      default = EntityId()
    },
    HintGlow = {
      default = EntityId()
    },
    ShowLine = {
      default = EntityId()
    },
    LineGlow = {
      default = EntityId()
    },
    Header1 = {
      default = EntityId()
    },
    Point1 = {
      default = EntityId()
    },
    Header2 = {
      default = EntityId()
    },
    Point2 = {
      default = EntityId()
    },
    Point1Glow = {
      default = EntityId()
    },
    Point2Glow = {
      default = EntityId()
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    BgContainer = {
      default = EntityId()
    }
  },
  playedAnimation = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TextCard)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function TextCard:OnInit()
  BaseElement.OnInit(self)
  self:CacheAnimations()
  UiImageBus.Event.SetSpritePathname(self.Properties.LineGlow, "lyShineUI/images/banner/banner_achievement_lineGlow.dds")
end
function TextCard:OnShutdown()
  timingUtils:StopDelay(self)
end
function TextCard:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.opacityAndScaleTo1QuadInOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadInOut"
    })
    self.anim.showLineIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      scaleX = 1,
      opacity = 1,
      ease = "QuadIn"
    })
    self.anim.lineGlowIn = self.anim.opacityAndScaleTo1QuadInOut
    self.anim.lineGlowOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      scaleX = 0.6,
      scaleY = 0,
      opacity = 0,
      imgColor = self.UIStyle.COLOR_YELLOW,
      ease = "QuadInOut"
    })
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 0,
      textCharacterSpace = 700,
      ease = "QuadOut"
    })
  end
end
function TextCard:TransitionIn()
  UiElementBus.Event.SetIsEnabled(self.Properties.LineGlow, true)
  self.ScriptedEntityTweener:Set(self.Properties.LineGlow, {
    scaleX = 0,
    scaleY = 0,
    opacity = 0.6,
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 0.2, self.anim.lineGlowIn, 0.15)
  self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 1.2, self.anim.lineGlowOut, 0.35)
  self.ScriptedEntityTweener:Set(self.Properties.ShowLine, {scaleX = 0, opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.15, self.anim.showLineIn)
  self.ScriptedEntityTweener:Play(self.Properties.Hint, 0.2, {opacity = 0}, {
    delay = 0,
    opacity = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Set(self.Properties.Title, {opacity = 0, textCharacterSpace = 100})
  self.ScriptedEntityTweener:Set(self.Properties.TitleLabel, {opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.Title, 1, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Title, 5, self.anim.textCharacterSpaceTo300)
  self.ScriptedEntityTweener:PlayC(self.Properties.TitleLabel, 1, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point1, 0.3, tweenerCommon.fadeInQuadOut, 0.6)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point2, 0.3, tweenerCommon.fadeInQuadOut, 0.6)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point1Glow, 0.7, tweenerCommon.opacityTo50)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point2Glow, 0.7, tweenerCommon.opacityTo50)
  UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
  if self.sound then
    self.audioHelper:PlaySound(self.sound)
  end
  if self.musicSwitch and self.musicState then
    self.audioHelper:SwitchMusicDB(self.musicSwitch, self.musicState)
  end
  self.playedAnimation = true
end
function TextCard:TransitionOut()
  if self.playedAnimation then
    self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.3, self.anim.textCharacterSpaceTo700, nil, function()
      self.playedAnimation = false
    end)
  end
end
function TextCard:UpdateRow(rowStyle, overrideData)
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, overrideData.icon ~= nil)
  if overrideData.icon then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, overrideData.icon)
    UiElementBus.Event.SetIsEnabled(self.Properties.Hint, false)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Point1, overrideData.header1 ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.Point2, overrideData.header2 ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.ShowLine, overrideData.header1 ~= nil or overrideData.showLine)
  UiElementBus.Event.SetIsEnabled(self.Properties.BgContainer, overrideData.header1 ~= nil or overrideData.showBg)
  if overrideData.header1 and overrideData.header2 then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point1, -100)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point2, 100)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point1Glow, -100)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point2Glow, 100)
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point1, 0)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point2, 0)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point1Glow, 0)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Point2Glow, 0)
  end
  if overrideData.header1 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Header1, overrideData.header1, eUiTextSet_SetLocalized)
  end
  if overrideData.header2 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Header2, overrideData.header2, eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Point1Glow, overrideData.point1 ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.Point2Glow, overrideData.point2 ~= nil)
  if overrideData.point1 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Point1, overrideData.point1, eUiTextSet_SetAsIs)
  end
  if overrideData.point2 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Point2, overrideData.point2, eUiTextSet_SetAsIs)
  end
  if overrideData.color1 then
    UiTextBus.Event.SetColor(self.Properties.Header1, overrideData.color1)
    UiTextBus.Event.SetColor(self.Properties.Point1, overrideData.color1)
    UiImageBus.Event.SetColor(self.Properties.Point1Glow, overrideData.color1)
  end
  if overrideData.color2 then
    UiTextBus.Event.SetColor(self.Properties.Header2, overrideData.color2)
    UiTextBus.Event.SetColor(self.Properties.Point2, overrideData.color2)
    UiImageBus.Event.SetColor(self.Properties.Point2Glow, overrideData.color2)
  end
  if overrideData.title then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title, overrideData.title, eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.TitleLabel, overrideData.titleLabel ~= nil)
  if overrideData.titleLabel then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleLabel, overrideData.titleLabel, eUiTextSet_SetLocalized)
  end
  local titleTextSize = UiTextBus.Event.GetTextSize(self.Properties.Title).x
  local paddingX = 150
  local titleTextWidth = titleTextSize + paddingX
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TitleBg, titleTextWidth)
  if overrideData.hintText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.HintText, overrideData.hintText, eUiTextSet_SetLocalized)
  end
  self.sound = overrideData.sound or self.audioHelper.Banner_Achievement
  self.musicSwitch = overrideData.musicSwitch
  self.musicState = overrideData.musicState
  if overrideData.titleRefresh then
    timingUtils:Delay(1, self, function(self)
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local timeRemaining = math.max(overrideData.titleWallClock:Subtract(now):ToSeconds(), 0)
      local timeBeforeRecall = timeHelpers:ConvertSecondsToHrsMinSecString(timeRemaining)
      local timeText = GetLocalizedReplacementText(overrideData.titleLocTag, {time = timeBeforeRecall})
      UiTextBus.Event.SetTextWithFlags(self.Properties.Title, timeText, eUiTextSet_SetLocalized)
      local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
      local canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
      local isStillEnabled = UiElementBus.Event.GetAreElementAndAncestorsEnabled(self.entityId)
      if not isStillEnabled or not canvasEnabled then
        timingUtils:StopDelay(self)
      end
    end, true)
  end
end
function TextCard:AnimateOut()
  local duration = 1
  self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.5, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.TitleLabel, 0.5, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Hint, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point1, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point2, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point1Glow, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Point2Glow, 0.3, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.SequenceFogLoop, duration, tweenerCommon.fadeOutQuadOut, 0.5, function()
    UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.playedAnimation = false
  end)
end
return TextCard
