local FullScreenVideo = {
  Properties = {
    FullscreenBackground = {
      default = EntityId()
    },
    RenderTarget = {
      default = EntityId()
    },
    Subtitles = {
      default = EntityId()
    },
    BG = {
      default = EntityId()
    }
  },
  animDurationShow = 0.3,
  animDurationHide = 0.3,
  frameBufferShow = 0,
  frameBufferHide = 0,
  videoFPS = 60,
  transitionOutFrame = 6650,
  transitionOutMusicFrame = 6830
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(FullScreenVideo)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function FullScreenVideo:OnInit()
  self.subtitleData = {
    {
      beginFrame = 2550,
      endFrame = 2880,
      id = "@cutscene_line1"
    },
    {
      beginFrame = 2920,
      endFrame = 3140,
      id = "@cutscene_line2"
    },
    {
      beginFrame = 3180,
      endFrame = 3380,
      id = "@cutscene_line3"
    },
    {
      beginFrame = 3400,
      endFrame = 3750,
      id = "@cutscene_line4"
    },
    {
      beginFrame = 3786,
      endFrame = 4110,
      id = "@cutscene_line5"
    },
    {
      beginFrame = 4240,
      endFrame = 4490,
      id = "@cutscene_line6"
    },
    {
      beginFrame = 4668,
      endFrame = 4950,
      id = "@cutscene_line7"
    },
    {
      beginFrame = 5430,
      endFrame = 5680,
      id = "@cutscene_line8"
    },
    {
      beginFrame = 5790,
      endFrame = 6120,
      id = "@cutscene_line9"
    },
    {
      beginFrame = 6380,
      endFrame = 6450,
      id = "@cutscene_line10"
    },
    {
      beginFrame = 6475,
      endFrame = 6610,
      id = "@cutscene_line11"
    },
    {
      beginFrame = 6660,
      endFrame = 6900,
      id = "@cutscene_line12"
    }
  }
  self:BusConnect(BinkEventBus)
  self.frameBufferShow = self:GetFrameBuffer(self.animDurationShow)
  self.frameBufferHide = self:GetFrameBuffer(self.animDurationHide)
  local subtitlesTextStle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 34,
    fontColor = self.UIStyle.COLOR_TAN_LIGHT
  }
  SetTextStyle(self.Properties.Subtitles, subtitlesTextStle)
  OptionsDataBus.Broadcast.InitializeSerializedOptions()
  self.prevMusicVol = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Audio.MusicVolume")
end
function FullScreenVideo:OnPlaybackStarted()
  local pathname = BinkRequestBus.Broadcast.GetVideoPathname()
  local startIndex = 1
  local found = string.find(pathname, "/", startIndex)
  while found ~= nil do
    startIndex = found + 1
    found = string.find(pathname, "/", startIndex)
  end
  local dot = string.find(pathname, ".", -5)
  local name = string.sub(pathname, startIndex, dot)
  UiImageBus.Event.SetRenderTargetName(self.Properties.RenderTarget, "$" .. name)
  UiElementBus.Event.SetIsEnabled(self.Properties.RenderTarget, true)
  self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  self.prevFrame = 1
  self.currentSubtitleIndex = 1
  self:SetElementsVisible(true)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.RenderTarget, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadIn)
  AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Option_MX", 0)
end
function FullScreenVideo:OnPlaybackStopped()
  self:BusDisconnect(self.tickBusHandler)
  self.tickBusHandler = nil
  self:SetElementsVisible(false)
end
function FullScreenVideo:SetElementsVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.RenderTarget, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.BG, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Subtitles, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.FullscreenBackground, isVisible)
end
function FullScreenVideo:OnTick(delta, timepoint)
  local currentFrame = BinkRequestBus.Broadcast.GetCurrentFrame()
  if currentFrame == self.prevFrame then
    return
  end
  if currentFrame >= self.transitionOutFrame and self.prevFrame < self.transitionOutFrame then
    CinematicRequestBus.Broadcast.PlaySequenceByName("EstabShip_Sequence")
    self.ScriptedEntityTweener:PlayC(self.Properties.RenderTarget, 5, tweenerCommon.fadeOutQuadIn, nil, nil)
    self.ScriptedEntityTweener:PlayC(self.Properties.FullscreenBackground, 5, tweenerCommon.fadeOutQuadIn, nil, nil)
  end
  if currentFrame >= self.transitionOutMusicFrame and self.prevFrame < self.transitionOutMusicFrame then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Music_Shell", "Mx_Shell_FTUE")
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Music_FTUE", "Mx_FTUE_Intro")
    AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Option_MX", self.prevMusicVol)
  end
  local subtitlesEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Accessibility.Subtitles")
  if subtitlesEnabled and self.currentSubtitleIndex <= #self.subtitleData then
    local beginFrame = self.subtitleData[self.currentSubtitleIndex].beginFrame - self.frameBufferShow
    local endFrame = self.subtitleData[self.currentSubtitleIndex].endFrame - self.frameBufferHide
    if currentFrame >= endFrame and endFrame > self.prevFrame then
      self:SetSubtitleVisible(false)
      self.currentSubtitleIndex = self.currentSubtitleIndex + 1
      if self.currentSubtitleIndex <= #self.subtitleData then
        beginFrame = self.subtitleData[self.currentSubtitleIndex].beginFrame
        endFrame = self.subtitleData[self.currentSubtitleIndex].endFrame
      end
    end
    if currentFrame >= beginFrame and beginFrame > self.prevFrame then
      UiTextBus.Event.SetTextWithFlags(self.Properties.Subtitles, self.subtitleData[self.currentSubtitleIndex].id, eUiTextSet_SetLocalized)
      local size = UiTextBus.Event.GetTextSize(self.Properties.Subtitles)
      local isTwoLines = size.y > 40
      local bgWidthPadding = isTwoLines and 110 or 90
      local bgHeightPadding = isTwoLines and 18 or 6
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.BG, size.x + bgWidthPadding)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.BG, size.y + bgHeightPadding)
      self:SetSubtitleVisible(true)
    end
  end
  self.prevFrame = currentFrame
end
function FullScreenVideo:GetFrameBuffer(duration)
  return self.videoFPS * duration
end
function FullScreenVideo:SetSubtitleVisible(isVisible)
  if self.isVisible ~= isVisible then
    self.isVisible = isVisible
    local animToPlay = isVisible and tweenerCommon.fadeInQuadIn or tweenerCommon.fadeOutQuadOut
    local animDuration = isVisible and self.animDurationShow or self.animDurationHide
    self.ScriptedEntityTweener:Stop(self.Properties.BG)
    self.ScriptedEntityTweener:Stop(self.Properties.Subtitles)
    self.ScriptedEntityTweener:PlayC(self.Properties.BG, animDuration, animToPlay)
    self.ScriptedEntityTweener:PlayC(self.Properties.Subtitles, animDuration, animToPlay)
  end
end
return FullScreenVideo
