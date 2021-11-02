local WarCard = {
  Properties = {
    ShowLine = {
      default = EntityId()
    },
    WarTitleText = {
      default = EntityId()
    },
    WarGuildsText = {
      default = EntityId()
    },
    WarGuildsTextContainer = {
      default = EntityId()
    },
    WarDetailText = {
      default = EntityId()
    },
    WarDurationText = {
      default = EntityId()
    },
    MessageText = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    SequenceLight = {
      default = EntityId()
    },
    SequenceLightBlue = {
      default = EntityId()
    },
    GuildCrestsContainer = {
      default = EntityId()
    },
    AttackerCrest = {
      default = EntityId()
    },
    DefenderCrest = {
      default = EntityId()
    },
    IconContainer = {
      default = EntityId()
    },
    InvasionIcon = {
      default = EntityId()
    },
    AttackerIcon = {
      default = EntityId()
    },
    DefenderIcon = {
      default = EntityId()
    },
    CustomIcon = {
      default = EntityId()
    }
  },
  playedAnimation = false,
  timer = 0,
  timerTick = 1,
  warTimeRemainingSeconds = 0,
  swapTimerFont = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WarCard)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function WarCard:OnInit()
  BaseElement.OnInit(self)
  self.propertyReset = {
    opacity = 1,
    scaleX = 1,
    scaleY = 1
  }
  self.defaultY = UiTransformBus.Event.GetLocalPositionY(self.entityId)
  self.timeHelpers = timeHelpers
  self:CacheAnimations()
end
function WarCard:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.opacityAndScaleTo1QuadInOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadInOut"
    })
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      textCharacterSpace = 700,
      opacity = 0,
      ease = "QuadOut"
    })
  end
end
function WarCard:UpdateRow(rowStyle, overrideData)
  if overrideData.warTitleText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WarTitleText, overrideData.warTitleText, eUiTextSet_SetLocalized)
  end
  if overrideData.warDetailText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WarDetailText, overrideData.warDetailText, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.WarDetailText, "@owg_time_remaining", eUiTextSet_SetLocalized)
  end
  if self.swapTimerFont then
    UiTextBus.Event.SetFont(self.Properties.WarDurationText, self.UIStyle.FONT_FAMILY_CASLON)
  end
  self.isAttacking = overrideData.isAttacking
  self.bannerColor = overrideData.bannerColor
  self.phaseEndTime = overrideData.phaseEndTime
  self.isInvasion = overrideData.isInvasion
  self.isSiegeState = overrideData.isSiegeState or false
  UiElementBus.Event.SetIsEnabled(self.Properties.WarDurationText, self.phaseEndTime ~= nil)
  if self.isInvasion then
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestsContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionIcon, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionIcon, false)
    if overrideData.offsetY then
      UiTransformBus.Event.SetLocalPositionY(self.entityId, overrideData.offsetY)
    else
      UiTransformBus.Event.SetLocalPositionY(self.entityId, self.defaultY)
    end
    if overrideData.noIcons then
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestsContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, false)
    elseif overrideData.customIcon then
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestsContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.AttackerIcon, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.DefenderIcon, false)
      UiImageBus.Event.SetSpritePathname(self.Properties.CustomIcon, overrideData.customIcon)
      UiElementBus.Event.SetIsEnabled(self.Properties.CustomIcon, true)
    else
      self.AttackerCrest:SetIcon(overrideData.attackingGuildCrest)
      self.DefenderCrest:SetIcon(overrideData.defendingGuildCrest)
      if self.isSiegeState then
        UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestsContainer, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.AttackerIcon, self.isAttacking)
        UiElementBus.Event.SetIsEnabled(self.Properties.DefenderIcon, not self.isAttacking)
        UiElementBus.Event.SetIsEnabled(self.Properties.CustomIcon, false)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestsContainer, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.AttackerCrest, self.isAttacking)
        UiElementBus.Event.SetIsEnabled(self.Properties.DefenderCrest, not self.isAttacking)
      end
    end
  end
end
function WarCard:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer >= self.timerTick then
    self.timer = self.timer - self.timerTick
    if self.phaseEndTime ~= nil then
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local warTimeRemaining = self.phaseEndTime:SubtractSeconds(now):ToSeconds()
      if self.warTimeRemainingSeconds ~= warTimeRemaining then
        self.warTimeRemainingSeconds = warTimeRemaining
        if self.warTimeRemainingSeconds < self.timeHelpers.secondsInHour then
          local _, _, minutes, seconds = self.timeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(warTimeRemaining)
          local timeText = string.format("%d:%02d", minutes, seconds)
          if not self.swapTimerFont then
            self.swapTimerFont = true
          end
          UiTextBus.Event.SetTextWithFlags(self.Properties.WarDurationText, timeText, eUiTextSet_SetAsIs)
        else
          local phaseEndTimeSeconds = self.phaseEndTime:SubtractSeconds(WallClockTimePoint()):ToSecondsRoundedUp()
          local dateTimeString = GetLocalizedReplacementText("@ui_date_time_format", {
            date = timeHelpers:GetLocalizedLongDate(phaseEndTimeSeconds),
            time = timeHelpers:GetLocalizedServerTime(phaseEndTimeSeconds)
          })
          self.swapTimerFont = false
          UiTextBus.Event.SetTextWithFlags(self.Properties.WarDurationText, dateTimeString, eUiTextSet_SetAsIs)
        end
      end
    end
  end
end
function WarCard:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function WarCard:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function WarCard:TransitionIn()
  if self.bannerColor == 1 then
    UiImageBus.Event.SetColor(self.Glow, self.UIStyle.COLOR_BANNER_GLOW_RED)
  elseif self.bannerColor == 2 then
    UiImageBus.Event.SetColor(self.Glow, self.UIStyle.COLOR_BANNER_GLOW_RED)
  elseif self.bannerColor == 3 then
    UiImageBus.Event.SetColor(self.Properties.Glow, self.UIStyle.COLOR_BANNER_GLOW_BLUE)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
  if self.bannerColor == 3 then
    self.ScriptedEntityTweener:Set(self.Properties.SequenceLightBlue, self.propertyReset)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceLight, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceLightBlue, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceLightBlue, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceLightBlue)
    self.ScriptedEntityTweener:PlayC(self.Properties.SequenceLightBlue, 1, tweenerCommon.fadeOutLinear, 0.5)
  else
    self.ScriptedEntityTweener:Set(self.Properties.SequenceLight, self.propertyReset)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceLight, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceLightBlue, false)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceLight, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceLight)
    self.ScriptedEntityTweener:PlayC(self.Properties.SequenceLight, 1, tweenerCommon.fadeOutLinear, 0.5)
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.Glow, 1, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Glow, 2.5, tweenerCommon.fadeOutQuadOut, 3)
  self.ScriptedEntityTweener:Set(self.Properties.ShowLine, {opacity = 0, scaleX = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.2, self.anim.opacityAndScaleTo1QuadInOut, 0.5)
  self.ScriptedEntityTweener:Set(self.Properties.WarTitleText, {opacity = 0, textCharacterSpace = 100})
  self.ScriptedEntityTweener:PlayC(self.Properties.WarTitleText, 1, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.WarTitleText, 2.5, self.anim.textCharacterSpaceTo300)
  self.audioHelper:PlaySound(self.audioHelper.Banner_LevelUp)
  self.ScriptedEntityTweener:Play(self.Properties.WarDurationText, 0.5, {opacity = 0}, {opacity = 1, delay = 1.5})
  self.ScriptedEntityTweener:Play(self.Properties.WarDetailText, 0.5, {opacity = 0}, {opacity = 1, delay = 1.5})
  self:StartTick()
  self.playedAnimation = true
end
function WarCard:TransitionOut()
  if self.playedAnimation then
    self:StopTick()
    self.ScriptedEntityTweener:PlayC(self.Properties.WarTitleText, 0.3, self.anim.textCharacterSpaceTo700, nil, function()
      self.playedAnimation = false
    end)
  end
end
function WarCard:AnimateOut()
  self.ScriptedEntityTweener:Play(self.Properties.MessageText, 1, {opacity = 1}, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.WarDurationText, 1, {opacity = 1}, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.WarDetailText, 1, {opacity = 1}, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.GuildCrestsContainer, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.WarGuildsText, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.WarTitleText, 0.3, {opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.SequenceFogLoop, 1, tweenerCommon.fadeOutQuadOut, 0.5, function()
    UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.playedAnimation = false
  end)
end
return WarCard
