local ChattingMarker = {
  Properties = {
    TalkBubble = {
      default = EntityId()
    },
    TalkBubbleTail = {
      default = EntityId()
    },
    TextChatMessage = {
      default = EntityId()
    }
  },
  typingAnimationTimer = 0,
  typingAnimationSpeed = 0.25
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChattingMarker)
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local markerTypeData = RequireScript("LyShineUI.Markers.MarkerData")
function ChattingMarker:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
end
function ChattingMarker:OnShutdown()
  self:StopChatMessage()
end
function ChattingMarker:SetIsChatting(isChatting, chatMessage, playerEntityId, markerEntityId, isMarkerVisible)
  if isChatting then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
    self.playerEntityId = playerEntityId
    if self.markerHandler then
      self:BusDisconnect(self.markerHandler)
    end
    self.markerHandler = self:BusConnect(MarkerNotificationBus, markerEntityId)
    self.isMarkerVisible = isMarkerVisible
    self:ShowChatMessage(chatMessage)
  else
    self:StopChatMessage()
  end
end
function ChattingMarker:OnVisibilityChanged(isVisible)
  self.isMarkerVisible = isVisible
end
local crySystemScreenPos = Vector2(0, 0)
local zOffset = 2.9
local distScaling = 22
local scaleFactor = 1
function ChattingMarker:OnCrySystemPostViewSystemUpdate()
  local worldPosition = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
  if not worldPosition then
    self:SetIsChatting(false)
    return
  end
  local zOff = zOffset
  local playerPos = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  local dist = playerPos:GetDistance(worldPosition)
  if dist < distScaling then
    zOff = zOff + -0.8 * (distScaling - dist) / distScaling
  end
  worldPosition.z = worldPosition.z + zOff
  local screenPosition = LyShineManagerBus.Broadcast.ProjectToScreen(worldPosition, false, false)
  local isVisible = screenPosition.z > 0 and dist < markerTypeData.playerMarkerFadeDistance and self.isMarkerVisible
  crySystemScreenPos.x = isVisible and screenPosition.x or -1000
  crySystemScreenPos.y = screenPosition.y
  UiTransformBus.Event.SetViewportPosition(self.entityId, crySystemScreenPos)
end
function ChattingMarker:OnTick(deltaTime)
  self:AnimateTypingState(deltaTime)
end
function ChattingMarker:StopChatMessage()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  if self.markerHandler then
    self:BusDisconnect(self.markerHandler)
    self.markerHandler = nil
  end
  self.ScriptedEntityTweener:Stop(self.entityId)
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0.01})
  self.playerEntityId = nil
  self.chatMessage = nil
  self.isMarkerVisible = nil
end
function ChattingMarker:AdjustChatSize(setToMax)
  local maxWidth = 300
  local maxHeight = 130
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, maxWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, maxHeight)
  if setToMax then
    return
  end
  local textSize = UiTextBus.Event.GetTextSize(self.Properties.TextChatMessage)
  local paddingX = 24
  local paddingY = 15
  local minWidth = 15
  local textWidth = textSize.x
  if minWidth > textWidth then
    textWidth = minWidth
  elseif maxWidth < textWidth then
    textWidth = maxWidth
  end
  textWidth = textWidth + paddingX
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, textWidth)
  local textHeight = UiTextBus.Event.GetTextSize(self.Properties.TextChatMessage).y + paddingY
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, textHeight)
end
function ChattingMarker:ShowChatMessage(message)
  if not message then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Stop(self.entityId)
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0.01})
  self.chatMessage = message
  self:AdjustChatSize(true)
  UiTextBus.Event.SetText(self.Properties.TextChatMessage, message)
  self.queueAdjustChatSize = 2
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1, delay = 0.25})
  self.ScriptedEntityTweener:Play(self.entityId, 0.25, {
    opacity = 0.01,
    delay = 6,
    onComplete = function()
      self:StopChatMessage()
    end
  })
end
function ChattingMarker:AnimateTypingState(deltaTime)
  if self.chatMessage then
    if self.queueAdjustChatSize and self.queueAdjustChatSize > 0 then
      self:AdjustChatSize()
      self.queueAdjustChatSize = self.queueAdjustChatSize - 1
    end
    return
  end
  local fade = UiFaderBus.Event.GetFadeValue(self.entityId) or 0
  if fade < 1 then
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
  end
  self.typingAnimationTimer = self.typingAnimationTimer + deltaTime
  if self.typingAnimationTimer > 4 * self.typingAnimationSpeed then
    self.typingAnimationTimer = self.typingAnimationTimer - 4 * self.typingAnimationSpeed
  end
  local animationState = math.floor(self.typingAnimationTimer / self.typingAnimationSpeed)
  local message = ""
  for i = 1, animationState do
    message = message .. ". "
  end
  UiTextBus.Event.SetText(self.Properties.TextChatMessage, ". . .")
  self:AdjustChatSize()
  UiTextBus.Event.SetText(self.Properties.TextChatMessage, message)
end
return ChattingMarker
