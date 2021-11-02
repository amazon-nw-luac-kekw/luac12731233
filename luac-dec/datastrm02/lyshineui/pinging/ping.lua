local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local profiler = RequireScript("LyShineUI._Common.Profiler")
local Ping = {
  Properties = {
    OnScreenHolder = {
      default = EntityId()
    },
    OnScreenIcon = {
      default = EntityId()
    },
    OnScreenIconPulse = {
      default = EntityId()
    },
    InFocusIcon = {
      default = EntityId()
    },
    DistanceText = {
      default = EntityId()
    },
    DetailText = {
      default = EntityId()
    },
    DetailTextHint = {
      default = EntityId()
    },
    PingIntroFlash = {
      default = EntityId()
    },
    PingIntroIcon = {
      default = EntityId()
    },
    PingIconTail = {
      default = EntityId()
    },
    PingInfoDivider = {
      default = EntityId()
    }
  },
  PING_IN_FOCUS_ICON = "lyshineui/images/icons/pingtypes/pingInFocusIcon.png",
  PING_STATE_FOCUS_MAX_INFO = 0,
  PING_STATE_FOCUS_MIN_INFO = 1,
  PING_STATE_OUT_OF_FOCUS = 2,
  PING_OFFSET_POS_Y = tweenerCommon.PING_OFFSET_POS_Y,
  PING_TEXT_INIT_POS_X = 35,
  PING_RADAR_BUFFER = 30,
  IN_MAX_INFO_RANGE_SQ = 900,
  IN_MIN_INFO_RANGE_SQ = 122500,
  PING_TIMEOUT = 15,
  isPingClamped = false,
  isPingPulseVisible = false,
  isPingOutroPlaying = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Ping)
function Ping:OnInit()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.offscreenWidthOffset = (UiTransform2dBus.Event.GetLocalWidth(self.Properties.OnScreenHolder) + self.PING_RADAR_BUFFER) / 2
  self.offscreenHeightOffset = (UiTransform2dBus.Event.GetLocalHeight(self.Properties.OnScreenHolder) + self.PING_RADAR_BUFFER) / 2 + -1 * self.PING_OFFSET_POS_Y
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasSizeNotificationBus)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self.onPingTypeCallbacks = {
    [ePingType_Danger] = function()
      self.pingTypeStr = "@ui_ping_type_Danger"
      self.pingColor = self.UIStyle.COLOR_RED_DARK
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeDanger.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_Move] = function()
      self.pingTypeStr = "@ui_ping_type_Move"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeMove.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_Attack] = function()
      self.pingTypeStr = "@ui_ping_type_Attack"
      self.pingColor = self.UIStyle.COLOR_RED_DARK
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeAttack.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_Defend] = function()
      self.pingTypeStr = "@ui_ping_type_Defend"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeDefend.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_Caution] = function()
      self.pingTypeStr = "@ui_ping_type_Caution"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeCaution.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_Someone] = function()
      self.pingTypeStr = "@ui_ping_type_Someone"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeSomeonesHere.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_Loot] = function()
      self.pingTypeStr = "@ui_ping_type_Loot"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeLoot.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_Repair] = function()
      self.pingTypeStr = "@ui_ping_type_Repair"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeRepair.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_NeedHealing] = function()
      self.pingTypeStr = "@ui_ping_type_NeedHealing"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeNeedHeals.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_NeedHelp] = function()
      self.pingTypeStr = "@ui_ping_type_NeedHelp"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeNeedHelp.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end,
    [ePingType_NeedRevive] = function()
      self.pingTypeStr = "@ui_ping_type_NeedRevive"
      self.pingColor = self.UIStyle.COLOR_YELLOW_GOLD
      self.pingIcon = "lyshineui/images/icons/pingtypes/pingTypeNeedRevive.png"
      self.pingInFocusIcon = self.PING_IN_FOCUS_ICON
    end
  }
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Accessibility.TextSizeOption", function(self, textSize)
    self.optionsScale = 1
    if textSize == eAccessibilityTextOptions_Bigger then
      self.optionsScale = 1.25
    end
  end)
  self.DetailTextHint:SetKeybindMapping("target_tag")
  self.DetailTextHint:SetMouseIconScale(0.75)
end
function Ping:OnTick(deltaTime, timePoint)
  self.timeSinceLastPing = self.timeSinceLastPing + deltaTime
  if self.timeSinceLastPing > self.PING_TIMEOUT then
    self:OnHidePing()
  end
end
function Ping:OnCrySystemPostViewSystemUpdate()
  local screenPosition = LyShineManagerBus.Broadcast.ProjectToScreen(self.worldPosition, false, false)
  self.isOnScreen = screenPosition.z == 1
  if self.isOnScreen then
    local screenPositionSq = screenPosition:GetDistanceSq(self.canvasCenter)
    local screenPositionSqOffsetY = screenPosition:GetDistanceSq(Vector3(self.canvasCenter.x, self.canvasCenter.y - self.PING_OFFSET_POS_Y, 0))
    local isInMinInfoRange = screenPositionSq < self.IN_MIN_INFO_RANGE_SQ
    local isInMaxInfoRange = screenPositionSqOffsetY < self.IN_MAX_INFO_RANGE_SQ
    if isInMaxInfoRange then
      self:SetDisplayState(self.PING_STATE_FOCUS_MAX_INFO)
    elseif isInMinInfoRange then
      self:SetDisplayState(self.PING_STATE_FOCUS_MIN_INFO)
    else
      self:SetDisplayState(self.PING_STATE_OUT_OF_FOCUS)
    end
    if self.isPingClamped ~= false then
      self.isPingClamped = false
      self:SetPingTailVisible(true)
    end
  else
    screenPosition.x = Clamp(screenPosition.x, self.offscreenWidthOffset, self.canvasSize.x - self.offscreenWidthOffset)
    screenPosition.y = Clamp(screenPosition.y, self.offscreenHeightOffset, self.canvasSize.y - self.offscreenHeightOffset - self.PING_OFFSET_POS_Y)
    if self.isPingClamped ~= true then
      self.isPingClamped = true
      self:SetPingTailVisible(false)
    end
  end
  if self.lastDisplayState == self.PING_STATE_OUT_OF_FOCUS or not self.isOnScreen then
    self:SetPingTextAlignment(screenPosition)
  end
  local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  local distanceText = GetLocalizedDistance(playerPosition, self.worldPosition)
  if self.lastDisplayState == self.PING_STATE_FOCUS_MAX_INFO then
    distanceText = GetLocalizedReplacementText("@ui_pingTypeDistance", {
      pingType = self.pingTypeStr,
      distance = distanceText
    })
  end
  UiTextBus.Event.SetText(self.Properties.DistanceText, distanceText)
  UiTransformBus.Event.SetViewportPosition(self.entityId, Vector2(screenPosition.x, screenPosition.y))
end
function Ping:OnShowPing(worldPosition, pingSourceId, pingType, isShout, playerName)
  self.isOwnPing = pingSourceId == ePingSource_Self
  self.worldPosition = worldPosition
  self.timeSinceLastPing = 0
  self.lastDisplayState = nil
  UiTextBus.Event.SetTextWithFlags(self.Properties.DetailText, self.isOwnPing and "@ui_cancel" or playerName, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.DetailTextHint, self.isOwnPing)
  self:OnUpdatePing(pingType)
  local scale = (isShout and 1.25 or 1) * self.optionsScale
  UiTransformBus.Event.SetScale(self.entityId, Vector2(scale, scale))
  self:TogglePositionUpdates(true)
  local screenPosition = LyShineManagerBus.Broadcast.ProjectToScreen(self.worldPosition, false, false)
  self.isOnScreen = screenPosition.z == 1
  if self.isOnScreen then
    self:SetDisplayState(self.PING_STATE_FOCUS_MIN_INFO)
    if self.isPingClamped ~= false then
      self.isPingClamped = false
      self:SetPingTailVisible(true)
    end
  elseif self.isPingClamped ~= true then
    self.isPingClamped = true
    self:SetPingTailVisible(false)
  end
  if self.isPingClamped then
    self:SetPingVisible(true, true)
    self:SetDisplayState(self.PING_STATE_OUT_OF_FOCUS)
  else
    self:SetPingVisible(true)
  end
  local currentSound = isShout and self.audioHelper.Ping_ShoutDrop or self.audioHelper.Ping_Drop
  self.audioHelper:PlaySound(currentSound)
end
function Ping:OnHidePing()
  if self:IsPingActive() and not self.isPingOutroPlaying then
    self:SetPingVisible(false)
  end
end
function Ping:OnUpdatePing(newPingType)
  self.onPingTypeCallbacks[newPingType]()
  if self.pingIcon and self.pingColor and self.pingInFocusIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.OnScreenIcon, self.pingIcon)
    UiImageBus.Event.SetSpritePathname(self.Properties.PingIntroIcon, self.pingIcon)
    UiImageBus.Event.SetSpritePathname(self.Properties.InFocusIcon, self.pingInFocusIcon)
    UiImageBus.Event.SetColor(self.Properties.InFocusIcon, self.pingColor)
    UiImageBus.Event.SetColor(self.Properties.PingIconTail, self.pingColor)
    UiImageBus.Event.SetColor(self.Properties.OnScreenIconPulse, self.pingColor)
  end
end
function Ping:SetPingVisible(isVisible, isImmediate)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Stop(self.entityId)
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
    if isImmediate then
      self.ScriptedEntityTweener:Set(self.Properties.PingIntroFlash, {opacity = 0})
      self.ScriptedEntityTweener:Set(self.Properties.PingIntroIcon, {
        opacity = 0,
        y = self.PING_OFFSET_POS_Y
      })
      self.ScriptedEntityTweener:Set(self.Properties.InFocusIcon, {
        opacity = 1,
        scaleY = 0.4,
        scaleX = 0.4,
        y = self.PING_OFFSET_POS_Y
      })
      self.ScriptedEntityTweener:Set(self.Properties.OnScreenIcon, {
        y = self.PING_OFFSET_POS_Y
      })
      self.ScriptedEntityTweener:Set(self.Properties.OnScreenIconPulse, {
        y = self.PING_OFFSET_POS_Y
      })
      self.ScriptedEntityTweener:Set(self.Properties.PingIconTail, {opacity = 0, h = 75})
    else
      self.ScriptedEntityTweener:PlayFromC(self.Properties.PingIntroFlash, 0.4, {
        opacity = 0.1,
        scaleY = 0.7,
        scaleX = 0.7
      }, tweenerCommon.pingIntroFlash)
      self.ScriptedEntityTweener:Stop(self.Properties.PingIntroIcon)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.PingIntroIcon, 0.8, {
        opacity = 1,
        scaleY = 0.8,
        scaleX = 0.8
      }, tweenerCommon.pingIntroIcon1, 0.2)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.PingIntroIcon, 0.5, {y = 0}, tweenerCommon.pingIntroIcon2)
      self.ScriptedEntityTweener:Stop(self.Properties.InFocusIcon)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.InFocusIcon, 0.5, {
        scaleY = 0.1,
        scaleX = 0.1,
        y = 0
      }, tweenerCommon.pingInFocus1)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.InFocusIcon, 0.5, {opacity = 0}, tweenerCommon.pingInFocus2, 0.4)
      self.ScriptedEntityTweener:Set(self.Properties.DistanceText, {
        y = 0,
        x = self.PING_TEXT_INIT_POS_X
      })
      self.ScriptedEntityTweener:PlayFromC(self.Properties.DistanceText, 0.5, {opacity = 1}, tweenerCommon.distanceTextFlashOut)
      UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.DistanceText, eUiHAlign_Left)
      UiElementBus.Event.SetIsEnabled(self.Properties.OnScreenHolder, false)
      self.ScriptedEntityTweener:Set(self.Properties.OnScreenIcon, {
        y = self.PING_OFFSET_POS_Y
      })
      self.ScriptedEntityTweener:Set(self.Properties.OnScreenIconPulse, {
        y = self.PING_OFFSET_POS_Y
      })
      self.ScriptedEntityTweener:PlayFromC(self.Properties.PingIconTail, 0.5, {opacity = 0, h = 10}, tweenerCommon.pingTailDrawIn)
    end
  else
    self.isPingOutroPlaying = true
    if not self.isPingPulseVisible then
      self:SetIconPulseVisible(true)
    end
    self.ScriptedEntityTweener:Play(self.entityId, 0.18, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        self.isPingOutroPlaying = false
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        self:TogglePositionUpdates(false)
      end
    })
  end
end
function Ping:SetPingTailVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.Properties.PingIconTail, 0.1, tweenerCommon.pingTailIn)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.PingIconTail, 0.05, tweenerCommon.pingTailOut)
  end
end
function Ping:SetIconPulseVisible(isVisible)
  if self.isPingPulseVisible ~= isVisible then
    self.isPingPulseVisible = isVisible
    if isVisible then
      if not self.timelinePulse then
        self.timelinePulse = self.ScriptedEntityTweener:TimelineCreate()
        self.timelinePulse:Add(self.Properties.OnScreenIconPulse, 0.8, {
          opacity = 0,
          scaleY = 2,
          scaleX = 2
        })
        self.timelinePulse:Add(self.Properties.OnScreenIconPulse, 0.5, {opacity = 0})
        self.timelinePulse:Add(self.Properties.OnScreenIconPulse, 0.01, {
          opacity = 1,
          scaleY = 1,
          scaleX = 1,
          onComplete = function()
            self.timelinePulse:Play()
          end
        })
      end
      self.timelinePulse:Play()
      self.ScriptedEntityTweener:Stop(self.Properties.OnScreenHolder)
      UiElementBus.Event.SetIsEnabled(self.Properties.OnScreenHolder, true)
      self.ScriptedEntityTweener:PlayC(self.Properties.OnScreenHolder, 0.5, tweenerCommon.fadeInQuadOutHalfSec)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.OnScreenIcon, 0.5, {scaleY = 0.5, scaleX = 0.5}, tweenerCommon.pingScaleFull)
      self.ScriptedEntityTweener:PlayC(self.Properties.InFocusIcon, 0.5, tweenerCommon.fadeOutQuadOutHalfSec)
    else
      self.ScriptedEntityTweener:Play(self.Properties.OnScreenIconPulse, 0.5, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          self.ScriptedEntityTweener:Set(self.Properties.OnScreenIconPulse, {
            opacity = 1,
            scaleY = 1,
            scaleX = 1
          })
          if self.timelinePulse then
            self.timelinePulse:Stop()
          end
        end
      })
      self.ScriptedEntityTweener:Play(self.Properties.OnScreenHolder, 0.5, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.OnScreenHolder, false)
        end
      })
      self.ScriptedEntityTweener:PlayC(self.Properties.OnScreenIcon, 0.5, tweenerCommon.pingScaleHalf)
      self.ScriptedEntityTweener:PlayC(self.Properties.InFocusIcon, 0.5, tweenerCommon.fadeInQuadOutHalfSec)
    end
  end
end
function Ping:IsPingActive()
  return self.tickHandler ~= nil
end
function Ping:IsOwnPing()
  return self.isOwnPing
end
function Ping:CanInteractWithPing()
  return self:IsPingActive() and self.lastDisplayState == self.PING_STATE_FOCUS_MAX_INFO
end
function Ping:GetWorldPosition()
  return self.worldPosition
end
function Ping:TogglePositionUpdates(isEnabled)
  if isEnabled then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  elseif self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function Ping:SetDisplayState(displayState)
  if self.lastDisplayState ~= displayState then
    if displayState == self.PING_STATE_FOCUS_MAX_INFO then
      local detailTextOffsetPosY = 15
      local distanceTextOffsetPosY = 10
      self.ScriptedEntityTweener:Set(self.Properties.DetailText, {
        y = self.PING_OFFSET_POS_Y - detailTextOffsetPosY,
        x = self.PING_TEXT_INIT_POS_X
      })
      self.ScriptedEntityTweener:PlayC(self.Properties.DetailText, 0.25, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:Set(self.Properties.DistanceText, {
        y = self.PING_OFFSET_POS_Y + distanceTextOffsetPosY,
        x = self.PING_TEXT_INIT_POS_X
      })
      self.ScriptedEntityTweener:PlayC(self.Properties.DistanceText, 0.25, tweenerCommon.fadeInQuadOut)
      UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.DistanceText, eUiHAlign_Left)
      self.ScriptedEntityTweener:PlayC(self.Properties.PingInfoDivider, 0.25, tweenerCommon.fadeInQuadOut)
      self:SetIconPulseVisible(true)
    elseif displayState == self.PING_STATE_FOCUS_MIN_INFO then
      if self.lastDisplayState == self.PING_STATE_FOCUS_MAX_INFO then
        self.ScriptedEntityTweener:Stop(self.Properties.DetailText)
        self.ScriptedEntityTweener:Stop(self.Properties.DistanceText)
        self.ScriptedEntityTweener:Stop(self.Properties.PingInfoDivider)
      end
      self.ScriptedEntityTweener:Set(self.Properties.DetailText, {opacity = 0})
      self.ScriptedEntityTweener:Set(self.Properties.DistanceText, {opacity = 0})
      self.ScriptedEntityTweener:Set(self.Properties.PingInfoDivider, {opacity = 0})
      self:SetIconPulseVisible(false)
    elseif displayState == self.PING_STATE_OUT_OF_FOCUS then
      if self.lastDisplayState == self.PING_STATE_FOCUS_MIN_INFO then
        self.ScriptedEntityTweener:Play(self.Properties.InFocusIcon, 0.05, {opacity = 0, ease = "QuadOut"})
      end
      self.ScriptedEntityTweener:Set(self.Properties.DetailText, {opacity = 0})
      self.ScriptedEntityTweener:Set(self.Properties.DistanceText, {
        y = self.PING_OFFSET_POS_Y
      })
      self.ScriptedEntityTweener:Set(self.Properties.PingInfoDivider, {opacity = 0})
      self.ScriptedEntityTweener:PlayC(self.Properties.DistanceText, 0.25, tweenerCommon.fadeInQuadOut)
      self:SetIconPulseVisible(true)
    end
    self.lastDisplayState = displayState
  end
end
function Ping:SetPingTextAlignment(screenPosition)
  local distanceXPos, textAlignment
  if screenPosition.x > self.canvasCenter.x then
    local textWidth = 210
    distanceXPos = -textWidth
    textAlignment = eUiHAlign_Right
  else
    distanceXPos = self.PING_TEXT_INIT_POS_X
    textAlignment = eUiHAlign_Left
  end
  UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.DistanceText, textAlignment)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.DistanceText, distanceXPos)
end
function Ping:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    self.canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
    self.canvasCenter = Vector3(self.canvasSize.x / 2, self.canvasSize.y / 2, 0)
  end
end
function Ping:OnShutdown()
  if self.timelinePulse ~= nil then
    self.timelinePulse:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timelinePulse)
  end
end
return Ping
