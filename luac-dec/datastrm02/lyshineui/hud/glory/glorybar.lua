local GloryBar = {
  Properties = {
    GloryReasonHolder = {
      default = EntityId()
    },
    GloryReason = {
      default = EntityId()
    },
    GloryReasonText = {
      default = EntityId()
    },
    GloryReasonGlowBig = {
      default = EntityId()
    },
    GloryReasonGlowSmall = {
      default = EntityId()
    },
    GloryReasonParticle = {
      default = EntityId()
    },
    GloryReasonTextBg = {
      default = EntityId()
    },
    GloryEffectHolder = {
      default = EntityId()
    },
    GloryBarHolder = {
      default = EntityId()
    },
    GloryBarFill = {
      default = EntityId()
    },
    GloryBarFillDelta = {
      default = EntityId()
    },
    GloryBarRestedXPFill = {
      default = {
        EntityId()
      }
    },
    GloryBarLevelUpEffect = {
      default = EntityId()
    },
    GloryBarFillDeltaEffectHolder = {
      default = EntityId()
    },
    GloryBarFillDeltaEffect = {
      default = EntityId()
    },
    GloryBarLevelCurrentHolder = {
      default = EntityId()
    },
    GloryBarLevelCurrentText = {
      default = EntityId()
    },
    GloryBarDetailsHolder = {
      default = EntityId()
    },
    GloryXpNextLevel = {
      default = EntityId()
    },
    GloryDiamondArcaneInner = {
      default = EntityId()
    },
    GloryDiamondArcaneOuter = {
      default = EntityId()
    },
    GloryDiamondText = {
      default = EntityId()
    },
    NextMilestoneLabel = {
      default = EntityId()
    },
    NextMilestoneDiamond = {
      default = EntityId()
    },
    NextMilestoneText = {
      default = EntityId()
    },
    NextMilestoneContainer = {
      default = EntityId()
    },
    GloryReasonTweenValue = {
      default = EntityId()
    },
    ViewMilestoneButton = {
      default = EntityId()
    },
    MilestoneWindow = {
      default = EntityId()
    },
    MilestoneWindowV2 = {
      default = EntityId()
    }
  },
  requiredGlory = nil,
  previousGlory = nil,
  currentGlory = nil,
  previousGloryPercent = nil,
  currentGloryPercent = nil,
  gloryPercentMeanValue = nil,
  stackedGloryReason = nil,
  currentLevel = nil,
  previousLevel = nil,
  hasLeveled = false,
  delayUpdate = false,
  isGloryReasonShowing = false,
  gloryFillEndCapWidth = 57,
  isFtue = false,
  screenStatesToShowXp = {
    [1101180544] = true
  },
  screenStatesToDisable = {
    [2477632187] = true,
    [3901667439] = true,
    [1634988588] = true
  },
  keyValueTable = {},
  hudState = 2702338936
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(GloryBar)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function GloryBar:OnInit()
  BaseScreen.OnInit(self)
  self:CacheAnimations()
  self.loadScreenHandler = self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-updated-reward-mapping", function(self, isEnabled)
    if isEnabled == nil then
      return
    end
    self.MilestoneWindow:SetEnabled(not isEnabled)
    self.MilestoneWindowV2:SetEnabled(isEnabled)
    self.milestoneWindow = isEnabled and self.MilestoneWindowV2 or self.MilestoneWindow
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.GloryPercent", self.QueueGloryBarPercent)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.RequiredGlory", self.QueueGloryRequired)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.Glory", self.QueueGlory)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.Level", function(self, level)
    if level then
      if self.milestoneWindowIsReady then
        self:QueueGloryLevel(level)
      else
        self.delayedQueueGloryLevel = level
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.RestedRate", function(self, rate)
    if rate then
      self.keyValueTable.restedModifier = string.format("%d%%", rate * 100)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.RestedXPPercentage", self.QueueGloryRestedXPPercentage)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.RestedXP", self.OnTotalRestedXP)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.MilestoneWindowReady", function(self, isReady)
    self.milestoneWindowIsReady = isReady
    if isReady and self.delayedQueueGloryLevel then
      self:QueueGloryLevel(self.delayedQueueGloryLevel)
      self.delayedQueueGloryLevel = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Inventory.SuppressNotificationsWhileCrafting", function(self, data)
    if data ~= nil then
      local executeQueuedUpdates = not data and self.delayUpdate
      self.delayUpdate = data
      if executeQueuedUpdates then
        self:UpdateAll()
      end
    end
  end)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
  end
  self:SetVisualElements()
  self.ViewMilestoneButton:SetCallback(self.ShowMilestones, self)
  self.ViewMilestoneButton:SetText("@ui_view_milestones", false, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ViewMilestoneButton, false)
  DynamicBus.GloryBarBus.Connect(self.entityId, self)
end
function GloryBar:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.gloryBarDetailsIn = self.ScriptedEntityTweener:CacheAnimation(0.25, {
      y = -52,
      x = 52,
      w = 1561,
      ease = "QuadOut"
    })
    self.anim.gloryBarDetailsOut = self.ScriptedEntityTweener:CacheAnimation(0.25, {
      y = 50,
      x = -72,
      w = 1809,
      opacity = 0,
      ease = "QuadOut"
    })
  end
end
function GloryBar:OnShutdown()
  DynamicBus.GloryBarBus.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
end
function GloryBar:OnLoadingScreenDismissed()
  if self.restedXP and self.restedXP > 0 then
    local notificationData = NotificationData()
    notificationData.type = "Generic"
    notificationData.title = "@ui_rested_xp_notification_title"
    notificationData.allowDuplicates = false
    notificationData.text = "@ui_rested_xp_notification_body"
    notificationData.maximumDuration = 12
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self:BusDisconnect(self.loadScreenHandler)
  self.loadScreenHandler = nil
end
function GloryBar:SetVisualElements()
  local GloryReasonTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 40,
    fontColor = self.UIStyle.COLOR_WHITE,
    textCasing = self.UIStyle.TEXT_CASING_UPPER,
    characterSpacing = 0
  }
  local GloryBarLevelCurrentTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 26,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local GloryXpNextLevelStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = 20,
    fontColor = self.UIStyle.COLOR_TAN,
    textCasing = self.UIStyle.TEXT_CASING_NORMAL
  }
  SetTextStyle(self.GloryReasonText, GloryReasonTextStyle)
  SetTextStyle(self.GloryBarLevelCurrentText, GloryBarLevelCurrentTextStyle)
  SetTextStyle(self.GloryXpNextLevel, GloryXpNextLevelStyle)
  local fillColor = self.UIStyle.COLOR_WHITE
  local fillDeltaColor = self.UIStyle.COLOR_WHITE
  UiImageBus.Event.SetColor(self.GloryBarFill, fillColor)
  UiImageBus.Event.SetColor(self.GloryBarFillDelta, fillDeltaColor)
  UiImageBus.Event.SetColor(self.GloryBarFillDeltaEffect, fillDeltaColor)
end
function GloryBar:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasWidth(self.entityId, self.canvasId)
    AdjustElementToCanvasWidth(self.Properties.GloryBarHolder, self.canvasId)
    AdjustElementToCanvasWidth(self.GloryReasonHolder, self.canvasId)
    AdjustElementToCanvasWidth(self.GloryBarFillDeltaEffectHolder, self.canvasId)
    local currentBarWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.GloryBarHolder)
    local endCapsWidth = self.gloryFillEndCapWidth
    self.newWidth = currentBarWidth - endCapsWidth
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.GloryBarHolder, self.newWidth)
    UiTransform2dBus.Event.SetLocalWidth(self.GloryReasonHolder, self.newWidth)
    UiTransform2dBus.Event.SetLocalWidth(self.GloryBarFillDeltaEffectHolder, self.newWidth)
    local scalePercent = currentBarWidth / 1920 * 2
    UiTransformBus.Event.SetScaleX(self.GloryBarLevelUpEffect, scalePercent)
  end
end
function GloryBar:UpdateAll()
  if self.queuedLevel ~= self.currentLevel then
    self:SetGloryLevel(self.queuedLevel)
  end
  if self.queuedRequiredGlory ~= self.requiredGlory then
    self:SetGloryRequired(self.queuedGloryRequired)
  end
  if self.queuedGloryPercent ~= self.currentGloryPercent then
    self:SetGloryBarPercent(self.queuedGloryPercent)
  end
  if self.queuedGlory ~= self.currentGlory then
    self:SetGlory(self.queuedGlory)
  end
  if self.queuedRestedXPPercentage ~= self.restedXPPercentage then
    self:SetGloryRestedXPPercentage(self.queuedRestedXPPercentage)
  end
end
function GloryBar:QueueGloryLevel(data)
  if data == nil then
    return
  end
  self.queuedLevel = data
  if not self.delayUpdate then
    self:SetGloryLevel(data)
  end
end
function GloryBar:QueueGloryRequired(data)
  if data == nil then
    return
  end
  self.queuedRequiredGlory = data
  if not self.delayUpdate then
    self:SetGloryRequired(data)
  end
end
function GloryBar:QueueGloryRestedXPPercentage(data)
  if data == nil then
    return
  end
  self.queuedRestedXPPercentage = data
  if not self.delayUpdate then
    self:SetGloryRestedXPPercentage(data)
  end
end
function GloryBar:QueueGloryBarPercent(data)
  if data == nil then
    return
  end
  self.queuedGloryPercent = data
  if not self.delayUpdate then
    self:SetGloryBarPercent(data)
  end
end
function GloryBar:OnTotalRestedXP(restedXP)
  self.restedXP = restedXP
  self:UpdateToolTip()
end
function GloryBar:QueueGlory(data)
  if data == nil then
    return
  end
  self.queuedGlory = data
  if not self.delayUpdate then
    self:SetGlory(data)
  end
end
function GloryBar:SetGloryLevel(data)
  if data == nil then
    return
  end
  if self.previousLevel ~= self.currentLevel then
    self.previousLevel = self.currentLevel
    self.hasLeveled = true
  end
  self.currentLevel = data
  UiTextBus.Event.SetText(self.Properties.GloryBarLevelCurrentText, self.currentLevel)
  UiTextBus.Event.SetText(self.Properties.GloryDiamondText, self.currentLevel)
  self:UpdateToolTip()
  local nextMilestone = self.milestoneWindow:SetCurrentLevel(data)
  UiElementBus.Event.SetIsEnabled(self.Properties.NextMilestoneContainer, 0 < nextMilestone)
  if 60 < nextMilestone then
    UiTextBus.Event.SetTextWithFlags(self.Properties.NextMilestoneLabel, "@ui_max_level", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.NextMilestoneDiamond, false)
  elseif 0 < nextMilestone then
    UiTextBus.Event.SetTextWithFlags(self.Properties.NextMilestoneLabel, "@ui_next_milestone", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.NextMilestoneDiamond, true)
    UiTextBus.Event.SetText(self.Properties.NextMilestoneText, nextMilestone)
  end
  if self.hasLeveled then
    local isMilestoneLevel = self.milestoneWindow:IsMilestoneLevel(self.currentLevel)
    if isMilestoneLevel then
      OptionsDataBus.Broadcast.SetHasViewedNewMilestoneReward(false)
      if self.isVisible then
        self:UpdateViewMilestoneButtonStyle()
      end
    end
  end
end
function GloryBar:SetGloryRequired(data)
  if data == nil then
    return
  end
  self.requiredGlory = data
  self:SetGloryAmount()
end
function GloryBar:SetGloryRestedXPPercentage(data)
  if data == nil then
    return
  end
  self.restedXPPercentage = data
  self:SetRestedXPPercentage()
end
function GloryBar:SetGloryAmount()
  self:UpdateToolTip()
end
function GloryBar:SetRestedXPPercentage()
  if self.currentGlory and self.requiredGlory and self.restedXPPercentage then
    local restedPercentageLeft = 0
    if self.restedXPPercentage > 0 then
      restedPercentageLeft = self.restedXPPercentage + self.currentGloryPercent
    end
    for i = 0, #self.Properties.GloryBarRestedXPFill do
      UiImageBus.Event.SetFillAmount(self.Properties.GloryBarRestedXPFill[i], Math.Clamp(restedPercentageLeft, 0, 1))
      restedPercentageLeft = restedPercentageLeft - 1
    end
  end
end
function GloryBar:SetGloryBarPercent(data)
  if self.isFtue then
    return
  end
  if data == nil then
    return
  end
  self.currentGloryPercent = Math.Clamp(data, 0, 1)
  if self.previousGloryPercent == nil then
    self.previousGloryPercent = self.currentGloryPercent
  end
  self.gloryPercentMeanValue = (self.currentGloryPercent + self.previousGloryPercent) / 2
  local gloryBarFillWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.GloryBarHolder)
  local gloryReasonPosX = gloryBarFillWidth * self.previousGloryPercent
  local gloryIncrease = self.currentGloryPercent - self.previousGloryPercent
  self.ScriptedEntityTweener:Set(self.GloryBarFillDeltaEffect, {
    x = gloryReasonPosX,
    w = gloryBarFillWidth,
    opacity = 1,
    imgFill = gloryIncrease
  })
  local deltaFillWidth = gloryBarFillWidth * gloryIncrease
  local centerOfDelta = deltaFillWidth / 2
  self.ScriptedEntityTweener:Set(self.Properties.GloryEffectHolder, {
    x = gloryReasonPosX + centerOfDelta
  })
  self.ScriptedEntityTweener:Set(self.Properties.GloryReason, {
    x = gloryReasonPosX + centerOfDelta
  })
  local defaultWidth = 70
  local minwidth = 15
  if deltaFillWidth > minwidth then
    local multiplier = deltaFillWidth / defaultWidth
    self.ScriptedEntityTweener:Set(self.Properties.GloryEffectHolder, {scaleX = multiplier})
  else
    self.ScriptedEntityTweener:Set(self.Properties.GloryEffectHolder, {scaleX = 0.3})
  end
  local animDuration = 0.4
  local animDelay = 0.4
  if self.hasLeveled == true then
    UiFlipbookAnimationBus.Event.Start(self.GloryBarLevelUpEffect)
    self.ScriptedEntityTweener:Set(self.GloryBarFillDelta, {imgFill = 1})
    self.ScriptedEntityTweener:Play(self.GloryBarFill, animDuration, {
      scaleX = 1,
      ease = "QuadOut",
      onComplete = function()
        self.hasLeveled = false
        self.ScriptedEntityTweener:Set(self.GloryBarFillDelta, {
          imgFill = self.currentGloryPercent
        })
        self.ScriptedEntityTweener:Play(self.GloryBarFill, animDuration, {scaleX = 0}, {
          scaleX = self.currentGloryPercent,
          ease = "QuadOut",
          delay = animDelay
        })
        self.ScriptedEntityTweener:Set(self.GloryBarFillDeltaEffect, {
          x = 0,
          opacity = 1,
          imgFill = self.currentGloryPercent
        })
        self.ScriptedEntityTweener:Play(self.GloryBarFillDeltaEffect, animDuration, {
          opacity = 0,
          ease = "QuadOut",
          delay = 0.2
        })
      end
    })
  else
    self.ScriptedEntityTweener:Set(self.GloryBarFillDelta, {
      imgFill = self.currentGloryPercent
    })
    self.ScriptedEntityTweener:Play(self.GloryBarFillDeltaEffect, animDuration, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.GloryBarFill, animDuration, {
      scaleX = self.currentGloryPercent,
      ease = "QuadOut",
      delay = animDelay
    })
  end
  self.previousGloryPercent = self.currentGloryPercent
end
function GloryBar:SetGlory(data)
  if self.isFtue then
    return
  end
  if data == nil then
    return
  end
  self.previousGlory = self.currentGlory
  self.currentGlory = data
  self:SetGloryAmount()
  if self.previousGlory ~= nil and self.previousGlory ~= self.currentGlory then
    local gloryDelta = self.currentGlory - self.previousGlory
    if self.stackedGloryReason then
      gloryDelta = gloryDelta + self.stackedGloryReason
    end
    self.stackedGloryReason = gloryDelta
    UiTextBus.Event.SetText(self.GloryReasonText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_glory_update", gloryDelta))
    local textSize = UiTextBus.Event.GetTextSize(self.Properties.GloryReasonText).x
    local textWidth = textSize + 40
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.GloryReasonTextBg, textWidth)
    self.ScriptedEntityTweener:Stop(self.GloryReasonTweenValue)
    self.ScriptedEntityTweener:Play(self.GloryReasonTweenValue, 0.01, {
      x = 0,
      onComplete = function()
        self:SetGloryReasonVisible(true)
      end
    })
  end
  self:UpdateToolTip()
end
function GloryBar:SetGloryReasonVisible(isVisible)
  if self.isFtue then
    return
  end
  if isVisible then
    if self.isGloryReasonShowing == false then
      self.ScriptedEntityTweener:Stop(self.GloryReason)
      self.ScriptedEntityTweener:Play(self.GloryReasonText, 0.3, {y = 4}, {y = -24, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.GloryReason, 0.4, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
      UiElementBus.Event.SetIsEnabled(self.Properties.GloryReasonGlowBig, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.GloryReasonGlowSmall, true)
      self.ScriptedEntityTweener:Play(self.Properties.GloryReasonGlowSmall, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.GloryReasonGlowBig, 0.1, {opacity = 0, scaleY = 0.6}, {
        opacity = 1,
        scaleY = 1,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.GloryReasonGlowSmall, 1, {opacity = 1}, {
        opacity = 0,
        ease = "QuadOut",
        delay = 0.1
      })
      self.ScriptedEntityTweener:Play(self.Properties.GloryReasonGlowBig, 1, {opacity = 1}, {
        opacity = 0,
        ease = "QuadOut",
        delay = 0.1,
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.GloryReasonGlowBig, false)
          UiElementBus.Event.SetIsEnabled(self.Properties.GloryReasonGlowSmall, false)
        end
      })
      UiElementBus.Event.SetIsEnabled(self.Properties.GloryReasonParticle, true)
      UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.GloryReasonParticle, 0)
      UiFlipbookAnimationBus.Event.Start(self.Properties.GloryReasonParticle)
      self.isGloryReasonShowing = true
    end
    if self.hasLeveled == true then
      self.gloryPercentMeanValue = 1
    end
    local gloryBarFillWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.GloryBarHolder)
    local gloryReasonWidth = UiTransform2dBus.Event.GetLocalWidth(self.GloryReason)
    local gloryReasonPosX = math.max(100, gloryBarFillWidth * self.currentGloryPercent)
    local duration = 2.8
    self.ScriptedEntityTweener:Stop(self.GloryReasonTweenValue)
    self.ScriptedEntityTweener:Play(self.GloryReasonTweenValue, duration, {
      x = 0,
      onComplete = function()
        self:SetGloryReasonVisible(false)
      end
    })
  else
    self.stackedGloryReason = nil
    self.isGloryReasonShowing = false
    self.ScriptedEntityTweener:Play(self.GloryReason, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function GloryBar:SetXpVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible == true then
    UiElementBus.Event.SetIsEnabled(self.Properties.GloryBarDetailsHolder, true)
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local maxDisplayLevel = ProgressionRequestBus.Event.GetMaxLevel(rootEntityId) + 1
    local isAtMaxLevel = maxDisplayLevel <= self.currentLevel
    UiElementBus.Event.SetIsEnabled(self.Properties.GloryXpNextLevel, not isAtMaxLevel)
    if not isAtMaxLevel then
      local nextLevel = self.currentLevel + 1
      local nextLevelText = GetLocalizedReplacementText("@ui_glory_to_level", {
        level = nextLevel,
        xp = GetLocalizedNumber(self.requiredGlory - self.currentGlory)
      })
      UiTextBus.Event.SetText(self.Properties.GloryXpNextLevel, nextLevelText)
    end
    self.ScriptedEntityTweener:PlayFromC(self.Properties.GloryBarDetailsHolder, 0.3, {
      y = 50,
      x = -72,
      w = 1809,
      opacity = 0
    }, self.anim.gloryBarDetailsIn)
    self.ScriptedEntityTweener:PlayC(self.Properties.GloryBarDetailsHolder, 0.15, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:Play(self.Properties.GloryBarHolder, 0.3, {
      y = -88,
      x = 76,
      w = 1400,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:PlayFromC(self.Properties.GloryDiamondArcaneInner, 0.3, {scaleX = 1.3, scaleY = 1.3}, tweenerCommon.scaleTo1, 0.15)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.GloryDiamondArcaneInner, 0.3, {
      imgColor = self.UIStyle.COLOR_WHITE
    }, tweenerCommon.imgToGray50, 0.15)
    self.ScriptedEntityTweener:PlayC(self.Properties.GloryDiamondArcaneInner, 0.2, tweenerCommon.opacityTo40, 0.15)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.GloryDiamondArcaneInner, 20, {rotation = 0}, tweenerCommon.rotateCCWInfinite)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.GloryDiamondArcaneOuter, 0.5, {scaleX = 1.5, scaleY = 1.5}, tweenerCommon.scaleTo1, 0.15)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.GloryDiamondArcaneOuter, 0.5, {
      imgColor = self.UIStyle.COLOR_WHITE
    }, tweenerCommon.imgToGray50, 0.15)
    self.ScriptedEntityTweener:PlayC(self.Properties.GloryDiamondArcaneOuter, 0.3, tweenerCommon.opacityTo40, 0.15)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.GloryDiamondArcaneOuter, 30, {rotation = 0}, tweenerCommon.rotateCWInfinite)
    self.ScriptedEntityTweener:PlayC(self.Properties.GloryBarLevelCurrentHolder, 0.15, tweenerCommon.fadeOutQuadIn)
  else
    self.milestoneWindow:SetVisible(false)
    self.ScriptedEntityTweener:PlayC(self.Properties.GloryBarDetailsHolder, 0.15, self.anim.gloryBarDetailsOut, nil, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.GloryBarDetailsHolder, false)
      self.ScriptedEntityTweener:Stop(self.Properties.GloryDiamondArcaneInner)
      self.ScriptedEntityTweener:Stop(self.Properties.GloryDiamondArcaneOuter)
    end)
    self.ScriptedEntityTweener:Play(self.Properties.GloryBarHolder, 0.1, {
      y = -2,
      x = 26,
      w = self.newWidth,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:PlayC(self.Properties.GloryBarLevelCurrentHolder, 0.15, tweenerCommon.fadeInQuadOut)
  end
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ViewMilestoneButton, isVisible)
  if isVisible then
    self:UpdateViewMilestoneButtonStyle()
  end
end
function GloryBar:ShowMilestoneWindow()
  OptionsDataBus.Broadcast.SetHasViewedNewMilestoneReward(true)
  LyShineManagerBus.Broadcast.SetState(3576764016)
  self.milestoneWindow:SetVisible(true)
  self:UpdateViewMilestoneButtonStyle()
end
function GloryBar:UpdateViewMilestoneButtonStyle()
  local hasViewedNewMilestoneReward = OptionsDataBus.Broadcast.GetHasViewedNewMilestoneReward()
  if self.lastHasViewedNewMilestoneReward == hasViewedNewMilestoneReward then
    return
  end
  self.lastHasViewedNewMilestoneReward = hasViewedNewMilestoneReward
  if hasViewedNewMilestoneReward then
    self.ViewMilestoneButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE)
    self.ViewMilestoneButton:SetBackgroundOpacity(0.1)
    self.ViewMilestoneButton:SetBackgroundColor(self.UIStyle.COLOR_WHITE)
  else
    self.ViewMilestoneButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
    self.ViewMilestoneButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
    self.ViewMilestoneButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  end
end
function GloryBar:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function GloryBar:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.fromState = fromState
  self:UpdateToolTip()
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
end
function GloryBar:UpdateToolTip()
  if not (self.requiredGlory and self.currentGlory and self.currentLevel) or self.fromState ~= self.hudState then
    return
  end
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local maxDisplayLevel = ProgressionRequestBus.Event.GetMaxLevel(rootEntityId) + 1
  local isAtMaxLevel = maxDisplayLevel <= self.currentLevel
  if isAtMaxLevel then
    return
  end
  self.keyValueTable.headerColor = ColorRgbaToHexString(self.UIStyle.COLOR_TAN_LIGHT)
  self.keyValueTable.totalXP = GetLocalizedNumber(self.currentGlory)
  self.keyValueTable.xpToLevel = GetLocalizedNumber(self.requiredGlory - self.currentGlory)
  self.keyValueTable.nextLevel = self.currentLevel + 1
  self.keyValueTable.restedXpString = ""
  if self.restedXP and self.restedXP > 0 then
    self.keyValueTable.totalRestedXP = GetLocalizedNumber(self.restedXP)
    self.keyValueTable.restedXpColor = ColorRgbaToHexString(self.UIStyle.COLOR_GREEN_MEDIUM)
    self.keyValueTable.restedXpString = GetLocalizedReplacementText("@ui_xp_rested_tooltip", self.keyValueTable)
  end
  local toolTipText = GetLocalizedReplacementText("@ui_xp_tooltip", self.keyValueTable)
  self.GloryBarHolder:SetSimpleTooltip(toolTipText)
end
function GloryBar:ShowMilestones()
  OptionsDataBus.Broadcast.SetHasViewedNewMilestoneReward(true)
  self:UpdateViewMilestoneButtonStyle()
  self.milestoneWindow:SetVisible(true)
end
return GloryBar
