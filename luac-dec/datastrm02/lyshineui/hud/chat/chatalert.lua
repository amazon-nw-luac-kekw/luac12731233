local ChatAlert = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Texture = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    ButtonCloseContainer = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    ChatMessage = {
      default = EntityId()
    }
  },
  isVisible = false,
  SHOW_TIME = 5
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChatAlert)
function ChatAlert:OnInit()
  self.ButtonClose:SetCallback(self.OnCloseClicked, self)
end
function ChatAlert:SetMessageData(messageData)
  self.ChatMessage:SetText(messageData.chatMessage)
  self.ChatMessage:SetupChatElement(messageData)
  local padding = 12
  local messageHeight = self.ChatMessage:GetHeight()
  self.targetHeight = messageHeight + padding
end
function ChatAlert:SetAlertIsVisible(isVisible)
  self.ScriptedEntityTweener:Stop(self.Properties.Background)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.Properties.Background, 0.01, {
      x = 0,
      delay = self.SHOW_TIME,
      onComplete = function()
        self:SetAlertIsVisible(false)
      end
    })
    local cellSizeTime = 0.2
    self.ScriptedEntityTweener:Play(self.entityId, cellSizeTime, {layoutTargetHeight = 0}, {
      layoutTargetHeight = self.targetHeight,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = cellSizeTime
    })
    self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.4, {
      imgColor = self.UIStyle.COLOR_WHITE,
      opacity = 1
    }, {
      imgColor = self.UIStyle.COLOR_TAN,
      opacity = 0.7,
      ease = "QuadOut",
      delay = cellSizeTime
    })
    self.ScriptedEntityTweener:Play(self.Properties.Texture, 0.3, {imgFill = 0}, {
      imgFill = 1,
      ease = "QuadOut",
      delay = cellSizeTime
    })
    self.ScriptedEntityTweener:Play(self.Properties.Texture, 0.5, {opacity = 1}, {
      opacity = 0.25,
      ease = "QuadOut",
      delay = cellSizeTime
    })
    self.ScriptedEntityTweener:Play(self.Properties.ChatMessage, 0.3, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = cellSizeTime + 0.3
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonCloseContainer, 0.3, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = cellSizeTime + 0.2
    })
  else
    self.ScriptedEntityTweener:Play(self.entityId, 1, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    if self.hideCallbackTable and type(self.hideCallback) == "function" then
      self.hideCallback(self.hideCallbackTable)
    end
  end
  self.isVisible = isVisible
end
function ChatAlert:OnCloseClicked()
  self:SetAlertIsVisible(false)
end
function ChatAlert:SetHideCallback(command, table)
  self.hideCallback = command
  self.hideCallbackTable = table
end
function ChatAlert:GetIsVisible()
  return self.isVisible
end
return ChatAlert
