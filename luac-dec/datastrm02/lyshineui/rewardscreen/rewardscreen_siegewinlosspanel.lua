local RewardScreen_SiegeWinLossPanel = {
  Properties = {
    RewardsContainerBg = {
      default = EntityId()
    },
    RewardsContainer = {
      default = EntityId()
    },
    NoRewardMessage = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    RewardsTitleContainer = {
      default = EntityId()
    },
    MilestoneTitle = {
      default = EntityId()
    },
    ShowLine = {
      default = EntityId()
    },
    LineGlow = {
      default = EntityId()
    },
    SiegeResultsContainer = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    ReasonText = {
      default = EntityId()
    },
    InnerRunes = {
      default = EntityId()
    },
    SmRuneA = {
      default = EntityId()
    },
    SmRuneB = {
      default = EntityId()
    },
    SmRuneC = {
      default = EntityId()
    },
    LargeBgRunes = {
      default = EntityId()
    },
    LgRuneA = {
      default = EntityId()
    },
    LgRuneB = {
      default = EntityId()
    },
    LgRuneC = {
      default = EntityId()
    },
    LogoContainer = {
      default = EntityId()
    },
    NWLogo = {
      default = EntityId()
    },
    HatchPattern = {
      default = EntityId()
    },
    ColorGlow = {
      default = EntityId()
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    SequenceRed = {
      default = EntityId()
    },
    SequenceBlue = {
      default = EntityId()
    },
    FlameGlowRed = {
      default = EntityId()
    },
    FlameGlowBlue = {
      default = EntityId()
    },
    TimerContainer = {
      default = EntityId()
    },
    TimerRemaining = {
      default = EntityId()
    },
    ProgressBarWithGlow = {
      default = EntityId()
    }
  },
  isWinner = false,
  sequenceToPlay = nil,
  flameGlowToPlay = nil,
  colorToUse = nil,
  endTimePoint = nil,
  hasValidRewards = false,
  hasMilestoneText = false,
  timer = 0,
  second = 1,
  endDuration = 0,
  percOfDurationForReward = 0.16667,
  rewardsContainerDelay = 0,
  rewardsContainerBgSizeFull = 590,
  rewardsContainerBgSizeNarrow = 490
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RewardScreen_SiegeWinLossPanel)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function RewardScreen_SiegeWinLossPanel:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      textCharacterSpace = 700,
      opacity = 0,
      ease = "QuadOut"
    })
    self.anim.showLineIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      scaleX = 1,
      opacity = 1,
      ease = "QuadIn"
    })
    self.anim.lineGlowIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadInOut"
    })
    self.anim.lineGlowOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      scaleX = 0.6,
      scaleY = 0,
      opacity = 0,
      imgColor = self.UIStyle.COLOR_YELLOW,
      ease = "QuadInOut"
    })
    self.anim.flameGlowAnimIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      scaleX = 1,
      ease = "QuadIn"
    })
    self.anim.HatchLinesIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {opacity = 0.25, ease = "QuadIn"})
    self.anim.rewardsBackgroundIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      y = -75,
      ease = "QuadOut"
    })
  end
end
function RewardScreen_SiegeWinLossPanel:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(GameEventUiNotificationBus)
  self:CacheAnimations()
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
end
function RewardScreen_SiegeWinLossPanel:OnShutdown()
end
function RewardScreen_SiegeWinLossPanel:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasWidth(self.Properties.RewardsContainerBg, self.canvasId)
  end
end
function RewardScreen_SiegeWinLossPanel:ClearRewards()
  self.rewardsToShow = false
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardsContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoRewardMessage, true)
  self.ScriptedEntityTweener:Set(self.Properties.NoRewardMessage, {opacity = 0})
  self:Reset()
end
function RewardScreen_SiegeWinLossPanel:OnTypedUiGameEvent(gameEventType, progressionReward, currencyReward, itemReward, categoricalProgressionId, categoricalProgressionReward, territoryStandingReward, factionRepReward, factionTokensReward, azothReward)
  if gameEventType == eGameEventType_Invasion or gameEventType == eGameEventType_OutpostRush or gameEventType == eGameEventType_War then
    local rewards = ObjectiveDataHelper:GetRewardDataFromGameEventData({
      progressionReward = progressionReward,
      currencyRewardRange = currencyReward,
      categoricalProgressionId = categoricalProgressionId,
      categoricalProgressionReward = categoricalProgressionReward,
      factionReputation = factionRepReward,
      factionTokens = factionTokensReward,
      territoryStanding = territoryStandingReward,
      itemReward = itemReward,
      azothReward = azothReward
    })
    local validRewards = rewards and 0 < #rewards
    self.hasValidRewards = validRewards
    UiElementBus.Event.SetIsEnabled(self.Properties.NoRewardMessage, not validRewards)
    if validRewards then
      self.rewardsToShow = true
      self.RewardsContainer:SetRewards(rewards)
    else
      self.rewardsToShow = false
    end
  end
end
function RewardScreen_SiegeWinLossPanel:SetRewardData(titleText, reasonText, milestoneText, isInvasion, isDungeon, endTimePoint, exitButton)
  SetTextStyle(self.Properties.TitleText, self.UIStyle.FONT_STYLE_REWARDSCREEN_HEADING)
  SetTextStyle(self.Properties.ReasonText, self.UIStyle.FONT_STYLE_REWARDSCREEN_SUBHEADING)
  SetTextStyle(self.Properties.MilestoneTitle, self.UIStyle.FONT_STYLE_REWARDSCREEN_REWARD_MILESTONE)
  SetTextStyle(self.Properties.NoRewardMessage, self.UIStyle.FONT_STYLE_REWARDSCREEN_NO_REWARDS)
  UiElementBus.Event.SetIsEnabled(self.Properties.TitleText, titleText ~= nil)
  if titleText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, titleText, eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ReasonText, reasonText ~= nil)
  if reasonText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ReasonText, reasonText, eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.MilestoneTitle, milestoneText ~= nil)
  if milestoneText then
    self.hasMilestoneText = true
    UiTextBus.Event.SetTextWithFlags(self.Properties.MilestoneTitle, milestoneText, eUiTextSet_SetLocalized)
  end
  if titleText == "@ui_siege_win" then
    self.isWinner = true
    self.sequenceToPlay = self.Properties.SequenceBlue
    self.flameGlowToPlay = self.Properties.FlameGlowBlue
    self.colorToUse = self.UIStyle.COLOR_BLUE
  else
    self.isWinner = false
    self.sequenceToPlay = self.Properties.SequenceRed
    self.flameGlowToPlay = self.Properties.FlameGlowRed
    self.colorToUse = self.UIStyle.COLOR_RED
  end
  UiImageBus.Event.SetColor(self.Properties.NWLogo, self.colorToUse)
  UiImageBus.Event.SetColor(self.Properties.ColorGlow, self.colorToUse)
  UiImageBus.Event.SetColor(self.Properties.HatchPattern, self.colorToUse)
  if isDungeon then
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardsContainer, false)
  end
  self:SetRewardPanelVisible(true)
  self.endTimePoint = endTimePoint
  self.isDungeon = isDungeon
  if self.endTimePoint then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
    self.endDuration = self.endTimePoint:Subtract(now):ToSeconds() * self.percOfDurationForReward
    self.endTimePoint = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime():AddDuration(Duration.FromSecondsUnrounded(self.endDuration))
    self.timer = self.second
  end
  UiElementBus.Event.SetIsEnabled(exitButton, self.rewardsToShow)
end
function RewardScreen_SiegeWinLossPanel:OnTick(deltaTime, timePoint)
  if self.endTimePoint then
    if self.timer >= self.second then
      self.timer = self.timer - self.second
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local secondsLeft = self.endTimePoint:Subtract(now):ToSeconds()
      if secondsLeft <= 0 then
        secondsLeft = 0
        self:BusDisconnect(self.tickBusHandler)
        self.tickBusHandler = nil
        self:ContinueToWarboard()
      end
      UiTextBus.Event.SetText(self.Properties.TimerRemaining, timeHelpers:ConvertSecondsToHrsMinSecString(secondsLeft, false, true))
      local progress = secondsLeft / self.endDuration
      self.ProgressBarWithGlow:SetProgressPercent(progress)
    end
    self.timer = self.timer + deltaTime
  end
end
function RewardScreen_SiegeWinLossPanel:SetRewardPanelVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Set(self.Properties.TitleText, {opacity = 0, textCharacterSpace = 100})
    self.ScriptedEntityTweener:Set(self.Properties.RewardsContainerBg, {opacity = 0, y = -125})
    self.ScriptedEntityTweener:Set(self.flameGlowToPlay, {opacity = 0, scaleX = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ShowLine, {opacity = 0, scaleX = 0})
    self.ScriptedEntityTweener:Set(self.Properties.LineGlow, {opacity = 0, scaleX = 0})
    self.ScriptedEntityTweener:Set(self.Properties.InnerRunes, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.LargeBgRunes, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.HatchPattern, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ReasonText, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.NoRewardMessage, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.TimerContainer, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.MilestoneTitle, {opacity = 0})
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardsContainer, false)
    self.rewardsContainerBgSize = self.hasMilestoneText and self.rewardsContainerBgSizeFull or self.rewardsContainerBgSizeNarrow
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.RewardsContainerBg, self.rewardsContainerBgSize)
    UiElementBus.Event.SetIsEnabled(self.sequenceToPlay, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.sequenceToPlay, 0)
    UiFlipbookAnimationBus.Event.Start(self.sequenceToPlay)
    self.ScriptedEntityTweener:PlayC(self.flameGlowToPlay, 0.5, self.anim.flameGlowAnimIn, nil, function()
      self.ScriptedEntityTweener:PlayC(self.flameGlowToPlay, 1, tweenerCommon.fadeOutLinear, nil)
    end)
    local sequenceFogLoopDelay = 0.1
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
    TimingUtils:Delay(sequenceFogLoopDelay, self, function()
      UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
      self.ScriptedEntityTweener:PlayC(self.Properties.ColorGlow, 0.5, tweenerCommon.fadeInQuadOut, 0.1, function()
        self.ScriptedEntityTweener:PlayC(self.Properties.ColorGlow, 1.25, tweenerCommon.fadeOutQuadOut, nil)
      end)
    end)
    UiElementBus.Event.SetIsEnabled(self.Properties.LogoContainer, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.LogoContainer, 0)
    TimingUtils:Delay(0.6, self, function()
      self.ScriptedEntityTweener:Play(self.Properties.NWLogo, 0.3, {opacity = 0}, {opacity = 0.2, ease = "QuadOut"})
      UiFlipbookAnimationBus.Event.Start(self.Properties.LogoContainer)
      self.ScriptedEntityTweener:PlayC(self.Properties.HatchPattern, 0.2, self.anim.HatchLinesIn, nil, function()
        self.ScriptedEntityTweener:PlayC(self.Properties.HatchPattern, 0.75, tweenerCommon.fadeOutLinear, nil)
      end)
    end)
    self.ScriptedEntityTweener:Play(self.Properties.SmRuneA, 60, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.SmRuneB, 60, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:Play(self.Properties.SmRuneC, 60, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:PlayC(self.Properties.InnerRunes, 0.5, tweenerCommon.fadeInQuadOut, 0.75)
    self.ScriptedEntityTweener:PlayC(self.sequenceToPlay, 0.2, tweenerCommon.fadeOutQuadOut, 1)
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 0.5, tweenerCommon.fadeInQuadOut, 0.5)
    self.ScriptedEntityTweener:PlayC(self.Properties.ReasonText, 0.5, tweenerCommon.fadeInQuadOut, 1.25)
    if not self.rewardsToShow then
      self.ScriptedEntityTweener:PlayC(self.Properties.NoRewardMessage, 0.5, tweenerCommon.fadeInQuadOut, 1.5)
      self.ScriptedEntityTweener:PlayC(self.Properties.TimerContainer, 0.25, tweenerCommon.fadeInQuadOut, 1.6)
      self.ScriptedEntityTweener:PlayC(self.Properties.ButtonContainer, 0.25, tweenerCommon.fadeInQuadOut, 1.7)
    end
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 5, self.anim.textCharacterSpaceTo300, nil, function()
      if self.rewardsToShow or self.isDungeon then
        self.ScriptedEntityTweener:PlayC(self.Properties.InnerRunes, 0.25, tweenerCommon.fadeOutQuadOut, nil)
        self.ScriptedEntityTweener:PlayC(self.Properties.NWLogo, 0.25, tweenerCommon.fadeOutQuadOut, nil)
        self.ScriptedEntityTweener:PlayC(self.Properties.SequenceFogLoop, 0.25, tweenerCommon.fadeOutQuadOut, nil)
        self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 0.5, self.anim.textCharacterSpaceTo700, nil, function()
          if self.rewardsToShow then
            UiElementBus.Event.SetIsEnabled(self.Properties.LogoContainer, false)
            UiElementBus.Event.SetIsEnabled(self.Properties.RewardsContainerBg, true)
            self.ScriptedEntityTweener:PlayC(self.Properties.RewardsContainerBg, 0.4, self.anim.rewardsBackgroundIn, nil, function()
              self.ScriptedEntityTweener:Play(self.Properties.LgRuneA, 120, {rotation = 0}, {timesToPlay = -1, rotation = 359})
              self.ScriptedEntityTweener:Play(self.Properties.LgRuneB, 120, {rotation = 0}, {timesToPlay = -1, rotation = -359})
              self.ScriptedEntityTweener:Play(self.Properties.LgRuneC, 120, {rotation = 0}, {timesToPlay = -1, rotation = 359})
              self.ScriptedEntityTweener:PlayC(self.Properties.LargeBgRunes, 0.5, tweenerCommon.fadeInQuadOut)
              if self.hasMilestoneText then
                self.rewardsContainerDelay = 0.5
                UiElementBus.Event.SetIsEnabled(self.Properties.RewardsTitleContainer, true)
                UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardsContainer, 0)
                UiElementBus.Event.SetIsEnabled(self.Properties.ShowLine, true)
                UiElementBus.Event.SetIsEnabled(self.Properties.LineGlow, true)
                self.ScriptedEntityTweener:Set(self.Properties.ShowLine, {scaleX = 0, opacity = 0})
                self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.15, self.anim.showLineIn, 0.2)
                self.ScriptedEntityTweener:Set(self.Properties.LineGlow, {
                  scaleX = 0,
                  scaleY = 0,
                  opacity = 0.6,
                  imgColor = self.UIStyle.COLOR_WHITE
                })
                self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 0.2, self.anim.lineGlowIn, 0.15, function()
                  self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 1.2, self.anim.lineGlowOut)
                end)
                self.ScriptedEntityTweener:Set(self.Properties.MilestoneTitle, {opacity = 0, textCharacterSpace = 100})
                self.ScriptedEntityTweener:PlayC(self.Properties.MilestoneTitle, 1, tweenerCommon.fadeInQuadOut)
                self.ScriptedEntityTweener:PlayC(self.Properties.MilestoneTitle, 2.5, self.anim.textCharacterSpaceTo300)
              else
                UiElementBus.Event.SetIsEnabled(self.Properties.RewardsTitleContainer, false)
                UiTransformBus.Event.SetLocalPositionY(self.Properties.RewardsContainer, -50)
              end
              UiElementBus.Event.SetIsEnabled(self.Properties.RewardsContainer, self.hasValidRewards)
              TimingUtils:Delay(self.rewardsContainerDelay, self, function()
                self.RewardsContainer:TriggerAnimations()
              end)
              UiElementBus.Event.SetIsEnabled(self.Properties.TimerContainer, true)
              self.ScriptedEntityTweener:PlayC(self.Properties.TimerContainer, 0.25, tweenerCommon.fadeInQuadOut, 0.5 + self.rewardsContainerDelay)
              self.ScriptedEntityTweener:PlayC(self.Properties.ButtonContainer, 0.25, tweenerCommon.fadeInQuadOut, 0.6 + self.rewardsContainerDelay)
            end)
          else
            self:ContinueToWarboard()
          end
        end)
      else
        self:ContinueToWarboard()
      end
    end)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.SmRuneA)
    self.ScriptedEntityTweener:Stop(self.Properties.SmRuneB)
    self.ScriptedEntityTweener:Stop(self.Properties.SmRuneC)
    self.ScriptedEntityTweener:Stop(self.Properties.LgRuneA)
    self.ScriptedEntityTweener:Stop(self.Properties.LgRuneB)
    self.ScriptedEntityTweener:Stop(self.Properties.LgRuneC)
    UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
  end
end
function RewardScreen_SiegeWinLossPanel:ContinueToWarboard()
  LyShineManagerBus.Broadcast.ExitState(849925872)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.siege.enable-warboard") and not self.isDungeon then
    LyShineManagerBus.Broadcast.SetState(921202721)
  end
end
function RewardScreen_SiegeWinLossPanel:Reset()
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  self.timer = 0
  self.endDuration = 0
  self.endTimePoint = nil
  self.ProgressBarWithGlow:SetProgressPercent(1)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimerContainer, false)
end
return RewardScreen_SiegeWinLossPanel
