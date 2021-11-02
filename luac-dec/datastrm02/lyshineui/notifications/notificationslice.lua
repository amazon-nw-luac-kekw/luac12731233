local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local NotificationSlice = {
  Properties = {
    Title = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    TextContainer = {
      default = EntityId()
    },
    BgParent = {
      default = EntityId()
    },
    BgMask = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    },
    FrameFlash = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    ButtonAccept = {
      default = EntityId()
    },
    ButtonDecline = {
      default = EntityId()
    },
    TextOffset = {
      default = EntityId()
    },
    IconImage = {
      default = EntityId()
    },
    IconBackground = {
      default = EntityId()
    },
    SingleWarIconImage = {
      default = EntityId()
    },
    MultipleWarsIconImage = {
      default = EntityId()
    },
    FillImage = {
      default = EntityId()
    },
    ProgressBar = {
      default = EntityId()
    },
    ProgressText = {
      default = EntityId()
    },
    ProgressTextIcon = {
      default = EntityId()
    },
    Container = {
      default = EntityId()
    },
    IsCenterNotification = {default = false},
    SequenceFogLoop = {
      default = EntityId()
    },
    LineGlow = {
      default = EntityId()
    },
    ShowLine = {
      default = EntityId()
    }
  },
  acceptKeybinding = "notificationAccept",
  declineKeybinding = "notificationDecline",
  initialContainerHeight = 0,
  initialFrameHeight = 0,
  initialTargetHeight = 0,
  slideInTime = 0.75,
  typeOfNotification = "",
  newBgHeight = 0,
  numericTimerOffset = 30
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(NotificationSlice)
function NotificationSlice:CacheAnimations()
  if not self.anim then
    self.anim = {}
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
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 0,
      textCharacterSpace = 700,
      ease = "QuadOut"
    })
  end
end
function NotificationSlice:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.IconImage, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.IconBackground, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SingleWarIconImage, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MultipleWarsIconImage, false)
  if self.Properties.IconBackground:IsValid() then
    UiDesaturatorBus.Event.SetSaturationValue(self.IconBackground.Image, 1)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.FillImage, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.VitalsEntityId", function(self, vitalsId)
    if vitalsId then
      self.vitalsId = vitalsId
    end
  end)
  self.messageFontSize = UiTextBus.Event.GetFontSize(self.Properties.Text)
  self:SetupButtonHints()
  self.initialContainerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Container)
  self.initialTargetHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.initialTextOffsetHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.TextOffset)
  self.targetHeight = self.initialTargetHeight
  self.initialButtonHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ButtonAccept)
  local initialBodyTextHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Text)
  local initialHeaderTextHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Title)
  self.initialTextHeight = initialBodyTextHeight + initialHeaderTextHeight
  if type(self.ProgressText) == "table" then
    self.ProgressText:SetOmitZeros(true)
  end
  if self.Properties.IsCenterNotification then
    SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_NOTIFICATION_CENTER_TITLE)
    SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_BODY_NEW)
    UiTextBus.Event.SetColor(self.Properties.Text, self.UIStyle.COLOR_WHITE)
  else
    SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_NOTIFICATION_TITLE)
    SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_NOTIFICATION_BODY)
  end
  local forceReset = true
  self:ResetSettings(forceReset)
  self:CacheAnimations()
  UiFaderBus.Event.SetFadeValue(self.Properties.BgParent, 0.6)
end
function NotificationSlice:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
function NotificationSlice:CheckAcceptAllowed()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  local enableAccept = currentState ~= 3901667439 and currentState ~= 921475099 and currentState ~= 3326371288 or self.typeOfNotification == "Revive"
  local isInDeathsDoor = true
  if self.vitalsId then
    isInDeathsDoor = VitalsComponentRequestBus.Event.IsDeathsDoor(self.vitalsId) and self.typeOfNotification ~= "Revive"
  end
  return enableAccept and not isInDeathsDoor
end
function NotificationSlice:SetupButtonHints()
  if self.ButtonAccept and type(self.ButtonAccept) == "table" and self.ButtonDecline and type(self.ButtonDecline) == "table" then
    if self.Properties.IsCenterNotification then
      local acceptAlpha = 0.8
      local declineAlpha = 0.2
      self.ButtonAccept:SetTextAlignment(self.ButtonAccept.TEXT_ALIGN_CENTER)
      self.ButtonAccept:SetBackgroundColor(self.UIStyle.COLOR_YELLOW)
      self.ButtonAccept:SetBackgroundOpacity(acceptAlpha)
      self.ButtonAccept:SetTextColor(self.UIStyle.COLOR_BLACK)
      self.ButtonDecline:SetTextAlignment(self.ButtonDecline.TEXT_ALIGN_CENTER)
      self.ButtonDecline:SetBackgroundOpacity(declineAlpha)
    else
      self.ButtonAccept:SetHintPadding(10)
      self.ButtonAccept:SetTextAlignment(self.ButtonAccept.TEXT_ALIGN_LEFT)
      self.ButtonAccept:SetButtonStyle(self.ButtonAccept.BUTTON_STYLE_CTA)
      self.ButtonDecline:SetHintPadding(10)
      self.ButtonDecline:SetTextAlignment(self.ButtonDecline.TEXT_ALIGN_LEFT)
    end
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
      self.ButtonAccept:SetHint(self.acceptKeybinding, true, "notification")
      self.ButtonDecline:SetHint(self.declineKeybinding, true, "notification")
    end)
  end
end
function NotificationSlice:SelectAccept()
  if self.acceptButtonIsDisabled then
    return false
  elseif self:CheckAcceptAllowed() then
    self:ExecuteCallback(true)
    return true
  else
    UiPopupBus.Broadcast.ShowPopup(ePopupButtons_OK, "@ui_deadnotification_title", "@ui_deadnotification_body", "DeadNotificationPopup")
    return false
  end
end
function NotificationSlice:SelectDecline()
  self:ExecuteCallback(false)
end
function NotificationSlice:SetPoolName(poolName)
  self.poolName = poolName
end
function NotificationSlice:SetContainerName(containerName)
  self.containerName = containerName
end
function NotificationSlice:SetCallback(context, callbackName)
  self.context = context
  self.callbackName = callbackName
  if self.ButtonAccept and type(self.ButtonAccept) == "table" then
    self.ButtonAccept:SetCallback(self.AcceptPressed, self)
  end
  if self.ButtonDecline and type(self.ButtonDecline) == "table" then
    self.ButtonDecline:SetCallback(self.DeclinePressed, self)
  end
end
function NotificationSlice:AcceptPressed()
  if self:CheckAcceptAllowed() then
    self:ExecuteCallback(true)
  else
    UiPopupBus.Broadcast.ShowPopup(ePopupButtons_OK, "@ui_deadnotification_title", "@ui_deadnotification_body", "DeadNotificationPopup")
  end
end
function NotificationSlice:DeclinePressed()
  self:ExecuteCallback(false)
end
function NotificationSlice:ExecuteCallback(isAccept)
  if self.context and self.context[self.callbackName] then
    self.context[self.callbackName](self.context, self.uuid, isAccept)
    self.context = nil
    self.callbackName = nil
  end
  self:ShowTransitionOut()
end
function NotificationSlice:SetUUID(uuid)
  self.uuid = uuid
end
function NotificationSlice:SetTitle(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, value, eUiTextSet_SetLocalized)
end
function NotificationSlice:SetMessage(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, value, eUiTextSet_SetLocalized)
  local newHeaderHeight = UiTextBus.Event.GetTextHeight(self.Properties.Title)
  local newBodyHeight = UiTextBus.Event.GetTextHeight(self.Properties.Text)
  local newTextHeight = newHeaderHeight + newBodyHeight
  local difference = newTextHeight - self.initialTextHeight
  local newTargetHeight = self.initialContainerHeight
  local newTextOffsetHeight = self.initialTextOffsetHeight
  if 0 < difference then
    newTargetHeight = newTargetHeight + difference
    newTextOffsetHeight = newTextOffsetHeight + difference
  end
  self.ScriptedEntityTweener:Set(self.Properties.Container, {h = newTargetHeight})
  if self.Properties.IsCenterNotification then
    self.ScriptedEntityTweener:Set(self.Properties.TextOffset, {h = newTextOffsetHeight})
  end
  self.targetHeight = newTargetHeight
end
function NotificationSlice:SetDuration(duration, showProgress, declineOnTimeout)
  local bgPadding = 20
  if duration == nil or duration == 0 then
    self:ShowTransitionOut()
    return
  end
  if duration < 0 then
    self.maximumDuration = duration
    UiElementBus.Event.SetIsEnabled(self.Properties.ProgressBar, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProgressText, false)
    return
  end
  self.maximumDuration = duration
  local function completeFn()
    if self.Properties.IsCenterNotification then
      self.newBgHeight = self.newBgHeight - bgPadding
      self.ScriptedEntityTweener:Play(self.Properties.Bg, 0.2, {
        h = self.newBgHeight,
        ease = "QuadOut"
      })
    end
    if declineOnTimeout then
      self:ExecuteCallback(false)
    else
      self:ShowTransitionOut()
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ProgressBar, showProgress)
  UiElementBus.Event.SetIsEnabled(self.Properties.ProgressText, showProgress)
  if showProgress then
    if self.Properties.IsCenterNotification then
      self.newBgHeight = self.newBgHeight + bgPadding
      self.ScriptedEntityTweener:Set(self.Properties.Bg, {
        h = self.newBgHeight
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ProgressBar, self.maximumDuration, {imgFill = 1}, {
      imgFill = 0,
      ease = "Linear",
      onComplete = completeFn
    })
    if self.ProgressText then
      self.ProgressText:SetCurrentCountdownTime(self.maximumDuration)
    end
  else
    TimingUtils:Delay(self.maximumDuration, self, completeFn)
  end
  if self.typeOfNotification == "DungeonInvite" then
    UiElementBus.Event.SetIsEnabled(self.Properties.ProgressText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProgressBar, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProgressTextIcon, false)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ProgressText, 100)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ProgressText, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressText, -65)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonContainer, self.numericTimerOffset)
    SetTextStyle(self.Properties.ProgressText, {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
      fontSize = 24
    })
    SetTextStyle(self.Properties.Text, {
      fontColor = self.UIStyle.COLOR_BRIGHT_YELLOW
    })
    self.ScriptedEntityTweener:Set(self.Properties.ProgressText, {opacity = 1})
    self.ScriptedEntityTweener:Stop(self.Properties.ProgressBar)
    self.ProgressText:SetFormat(self.ProgressText.FORMAT_SHORTHAND)
    self.ProgressText:SetCurrentCountdownTime(duration)
  end
end
function NotificationSlice:SetNotificationManager(entity)
  self.notificationManager = entity
end
function NotificationSlice:SetIcon(iconData)
  if type(iconData) == "string" then
    if self.Properties.MultipleWarsIconImage:IsValid() then
      self.MultipleWarsIconImage:SetIcon(iconData)
      UiElementBus.Event.SetIsEnabled(self.Properties.MultipleWarsIconImage, true)
    else
      Log("NotificationSlice:SetIcon Warning: Trying to set icon when self.Properties.MultipleWarsIconImage is not set")
    end
  elseif self.IconImage and type(self.IconImage) == "table" then
    if self.IconImage.SetSmallIcon then
      self.IconImage:SetSmallIcon(iconData)
    else
      self.IconImage:SetIcon(iconData)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.IconImage, true)
  end
  if not self.Properties.IsCenterNotification then
    self:SetTextOffsetForIcon()
  end
end
function NotificationSlice:HideIcon()
  UiElementBus.Event.SetIsEnabled(self.Properties.IconImage, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.IconBackground, false)
end
function NotificationSlice:SetTextOffsetForIcon()
  if self.Properties.TextOffset then
    self.ScriptedEntityTweener:Set(self.Properties.TextOffset, {x = 77})
    self.ScriptedEntityTweener:Set(self.Properties.TextContainer, {w = 400})
  end
  if self.ButtonAccept and type(self.ButtonAccept) == "table" then
    self.ButtonAccept:SetSize(200, 40)
  end
  if self.ButtonDecline and type(self.ButtonDecline) == "table" then
    self.ButtonDecline:SetSize(200, 40)
  end
end
function NotificationSlice:SetAcceptText(text)
  if self.ButtonAccept and type(self.ButtonAccept) == "table" then
    self.ButtonAccept:SetText(text)
    self.usingCustomAccept = true
  end
end
function NotificationSlice:SetDeclineText(text)
  if self.ButtonDecline and type(self.ButtonDecline) == "table" then
    self.ButtonDecline:SetText(text)
    self.usingCustomDecline = true
  end
end
function NotificationSlice:SetCanAccept(canAccept)
  if self.ButtonAccept and type(self.ButtonAccept) == "table" then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonAccept, canAccept)
    self.acceptButtonIsDisabled = not canAccept
    self.ButtonAccept:SetEnabled(canAccept)
  end
end
function NotificationSlice:ResetSettings(forceReset)
  if self.usingCustomAccept or forceReset then
    self:SetAcceptText("@ui_accept")
    self.usingCustomAccept = false
  end
  if self.usingCustomDecline or forceReset then
    self:SetDeclineText("@ui_decline")
    self.usingCustomDecline = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.IconImage, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.IconBackground, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SingleWarIconImage, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MultipleWarsIconImage, false)
  if self.Properties.IconBackground:IsValid() then
    UiDesaturatorBus.Event.SetSaturationValue(self.IconBackground.Image, 1)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.FillImage, false)
  if self.acceptButtonIsDisabled then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonAccept, true)
    self.acceptButtonIsDisabled = false
  end
  if self.Properties.IsCenterNotification then
    self.ScriptedEntityTweener:Set(self.Properties.TextOffset, {y = 0})
    self.newBgHeight = 0
  elseif self.Properties.TextOffset then
    self.ScriptedEntityTweener:Set(self.Properties.TextOffset, {x = 0})
    self.ScriptedEntityTweener:Set(self.Properties.TextContainer, {w = 480})
  end
end
function NotificationSlice:ApplyCustomTypeSettings(type)
  if not self.Properties.IsCenterNotification then
    if type == "WarSingle" then
      UiElementBus.Event.SetIsEnabled(self.Properties.SingleWarIconImage, true)
      self:SetTextOffsetForIcon()
    elseif type == "WarMultiple" then
      self.MultipleWarsIconImage:SetIcon("LyShineUI/Images/Icons/Misc/icon_warBigDiamond.png")
      UiElementBus.Event.SetIsEnabled(self.Properties.MultipleWarsIconImage, true)
      self:SetTextOffsetForIcon()
    elseif type == "FillMetaAchievement" then
      UiElementBus.Event.SetIsEnabled(self.Properties.FillImage, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.FillImage, self.context.notificationFillImage)
      UiImageBus.Event.SetFillAmount(self.Properties.FillImage, self.context.notificationFillPercent)
      if self.Properties.IconBackground and self.Properties.IconBackground:IsValid() then
        UiDesaturatorBus.Event.SetSaturationValue(self.IconBackground.Image, 0.1)
        UiElementBus.Event.SetIsEnabled(self.Properties.IconBackground, true)
        self.IconBackground:SetIcon(self.context.notificationBackgroundImage)
      end
    elseif type == "MetaAchievementCompleted" and self.Properties.IconBackground and self.Properties.IconBackground:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.IconBackground, true)
      self.IconBackground:SetIcon(self.context.notificationBackgroundImage)
    end
  end
  self.typeOfNotification = type
end
function NotificationSlice:ShowTransitionIn()
  local posX = 100
  local bgAlpha = 1
  if self.Properties.IsCenterNotification then
    local posY = -25
    posX = 0
    bgAlpha = 0.6
    UiFaderBus.Event.SetFadeValue(self.entityId, 1)
    DynamicBus.SocialPaneBus.Broadcast.FadeDownAlarmEffect(true)
    self.ScriptedEntityTweener:Set(self.Properties.Container, {opacity = 1})
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
    self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.15, self.anim.showLineIn, 0.2)
    self.ScriptedEntityTweener:Set(self.Properties.Title, {opacity = 0, textCharacterSpace = 100})
    self.ScriptedEntityTweener:Set(self.Properties.Text, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.Properties.Title, 1, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Title, 5, self.anim.textCharacterSpaceTo300)
    self.ScriptedEntityTweener:PlayC(self.Properties.Text, 1, tweenerCommon.fadeInQuadOut, 0.5)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
  end
  if not self.Properties.IsCenterNotification then
    self.ScriptedEntityTweener:Play(self.Properties.Container, 0.6, {x = posX, opacity = 0}, {
      x = 0,
      opacity = 1,
      delay = self.slideInTime,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:PlayC(self.Properties.Container, self.slideInTime, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.entityId, 1, tweenerCommon.fadeInQuadOut, self.slideInTime)
    self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.25, tweenerCommon.fadeInQuadOut, 0.45 + self.slideInTime)
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.Text, 0.25, tweenerCommon.fadeInQuadOut, 0.5 + self.slideInTime)
  if self.Properties.FrameFlash and self.Properties.FrameFlash:IsValid() then
    self.ScriptedEntityTweener:Play(self.Properties.FrameFlash, 0.25, {opacity = 0}, {
      opacity = 1,
      delay = 0.25 + self.slideInTime,
      onComplete = function()
        self.ScriptedEntityTweener:Play(self.Properties.FrameFlash, 0.2, {opacity = 1}, {opacity = 0, delay = 0.15})
      end
    })
  end
  if self.Properties.BgMask and self.Properties.BgMask:IsValid() then
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.BgMask, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.BgMask)
  end
  if self.Properties.IconImage and self.Properties.IconImage:IsValid() then
    self.ScriptedEntityTweener:PlayC(self.Properties.IconImage, 0.2, tweenerCommon.fadeInQuadOut, 0.4 + self.slideInTime)
  end
  if self.Properties.IconBackground and self.Properties.IconBackground:IsValid() then
    self.ScriptedEntityTweener:PlayC(self.Properties.IconBackground, 0.2, tweenerCommon.fadeInQuadOut, 0.4 + self.slideInTime)
  end
  if self.typeOfNotification == "MetaAchievementCompleted" or self.typeOfNotification == "RewardPendingMetaAchievements" then
    self.audioHelper:PlaySound(self.audioHelper.MetaAchievements_Unlock)
  elseif self.typeOfNotification == "FillMetaAchievement" then
    self.audioHelper:PlaySound(self.audioHelper.MetaAchievements_Partial_Milestone)
  end
end
function NotificationSlice:ShowTransitionOut()
  local posX = 100
  if self.Properties.IsCenterNotification then
    posX = 0
    local posY = -25
    DynamicBus.SocialPaneBus.Broadcast.FadeDownAlarmEffect(false)
    self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.3, self.anim.textCharacterSpaceTo700)
    self.ScriptedEntityTweener:Play(self.Properties.Container, 0.6, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.3
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Container, 0.6, {x = 0, opacity = 1}, {
    x = posX,
    opacity = 0,
    ease = "QuadOut"
  })
  local opacityFadeDuration = 1
  self.ScriptedEntityTweener:Play(self.entityId, opacityFadeDuration, {opacity = 0, ease = "QuadOut"})
  TimingUtils:Delay(opacityFadeDuration, self, function(self)
    self.notificationManager:RemoveVisibleNotification(self.containerName, self.uuid, self.poolName)
  end)
  self.ScriptedEntityTweener:Stop(self.Properties.ProgressBar)
  self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.25, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.Text, 0.25, tweenerCommon.fadeOutQuadOut, 0.1)
  self.ScriptedEntityTweener:PlayC(self.Properties.Bg, 0.2, tweenerCommon.fadeOutQuadOut, 0.1)
  if self.Properties.IconImage and self.Properties.IconImage:IsValid() then
    self.ScriptedEntityTweener:PlayC(self.Properties.IconImage, 0.2, tweenerCommon.fadeOutQuadOut)
  end
  if self.Properties.IconBackground and self.Properties.IconBackground:IsValid() then
    self.ScriptedEntityTweener:PlayC(self.Properties.IconBackground, 0.2, tweenerCommon.fadeOutQuadOut)
  end
end
function NotificationSlice:GetTargetHeight()
  return self.targetHeight
end
return NotificationSlice
