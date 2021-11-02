local minorNotificationSlice = {
  Properties = {
    MinorNotificationText = {
      default = EntityId(),
      order = 1
    },
    BG = {
      default = EntityId(),
      order = 2
    },
    Container = {
      default = EntityId(),
      order = 3
    },
    BgMask = {
      default = EntityId(),
      order = 4
    }
  },
  subtitleSpeakerColor = "\"#ffffff\"",
  maxTextWidth = 650,
  minorBgPath = "lyshineui/images/notifications/notification_minor.dds",
  subtitleBgPath = "lyshineui/images/notifications/notification_subtitle.dds",
  minorBgWidth = 808
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(minorNotificationSlice)
function minorNotificationSlice:OnInit()
  BaseElement.OnInit(self)
  self.subtitleSpeakerColor = ColorRgbaToHexString(self.UIStyle.COLOR_TAN_LIGHT)
end
function minorNotificationSlice:OnTick(deltaTime, timePoint)
  self.currentDuration = self.currentDuration - deltaTime
  if self.currentDuration <= 0 and not self.isFadingOut then
    self.isFadingOut = true
    self:ShowTransitionOut()
  end
end
function minorNotificationSlice:SetPoolName(poolName)
  self.poolName = poolName
end
function minorNotificationSlice:SetContainerName(containerName)
  self.containerName = containerName
end
function minorNotificationSlice:SetUUID(uuid)
  self.uuid = uuid
end
function minorNotificationSlice:SetType(type)
  self.type = type
end
function minorNotificationSlice:SetTitle(title)
  self.title = title
end
function minorNotificationSlice:SetMessage(value)
  local textWidth = 0
  if self.type == "Subtitle" then
    SetTextStyle(self.MinorNotificationText, self.UIStyle.FONT_STYLE_NOTIFICATION_SUBTITLE)
    if self.title ~= nil and self.title ~= "" then
      UiTextBus.Event.SetTextWithFlags(self.MinorNotificationText, "<font color=" .. self.subtitleSpeakerColor .. ">" .. self.title .. ":</font> " .. value, eUiTextSet_SetLocalized)
    else
      UiTextBus.Event.SetTextWithFlags(self.MinorNotificationText, value, eUiTextSet_SetLocalized)
    end
    local bgMargin = 42
    textWidth = UiTextBus.Event.GetTextWidth(self.MinorNotificationText)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.BG, textWidth + bgMargin)
    UiImageBus.Event.SetSpritePathname(self.Properties.BG, self.subtitleBgPath)
  else
    SetTextStyle(self.MinorNotificationText, self.UIStyle.FONT_STYLE_NOTIFICATION_MINOR_SHORT)
    UiTextBus.Event.SetTextWithFlags(self.MinorNotificationText, value, eUiTextSet_SetLocalized)
    textWidth = UiTextBus.Event.GetTextWidth(self.MinorNotificationText)
    if textWidth > self.maxTextWidth then
      SetTextStyle(self.MinorNotificationText, self.UIStyle.FONT_STYLE_NOTIFICATION_MINOR_LONG)
    else
      SetTextStyle(self.MinorNotificationText, self.UIStyle.FONT_STYLE_NOTIFICATION_MINOR_SHORT)
    end
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.BG, self.minorBgWidth)
    UiImageBus.Event.SetSpritePathname(self.Properties.BG, self.minorBgPath)
  end
end
function minorNotificationSlice:SetDuration(duration)
  if duration == nil or duration == 0 then
    self:ShowTransitionOut()
    return
  end
  self.maximumDuration = duration
  self.currentDuration = duration
  self.isFadingOut = false
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function minorNotificationSlice:SetNotificationManager(entity)
  self.notificationManager = entity
end
function minorNotificationSlice:SetCallback(context, callbackName)
  self.context = context
  self.callbackName = callbackName
end
function minorNotificationSlice:ExecuteCallback()
  if self.context and self.context[self.callbackName] then
    self.context[self.callbackName](self.context, self.uuid)
    self.context = nil
    self.callbackName = nil
  end
end
function minorNotificationSlice:ShowTransitionIn()
  local targetHeight = UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
  self.ScriptedEntityTweener:Play(self.entityId, 0.23, {layoutTargetHeight = 0}, {layoutTargetHeight = targetHeight, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.entityId, 0.4, {opacity = 0}, {
    opacity = 1,
    delay = 0.25,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.MinorNotificationText, 0.4, {opacity = 0}, {
    opacity = 1,
    delay = 0.2,
    ease = "QuadIn"
  })
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.BgMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.BgMask)
end
function minorNotificationSlice:ShowTransitionOut()
  self.ScriptedEntityTweener:Play(self.entityId, 1, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      self:ExecuteCallback()
      self.notificationManager:RemoveVisibleNotification(self.containerName, self.uuid, self.poolName)
    end
  })
  if self.tickBusHandler ~= nil then
    self.tickBusHandler = nil
    self:BusDisconnect(self.tickBusHandler)
  end
end
return minorNotificationSlice
