local ChatReplyButton = {
  Properties = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChatReplyButton)
function ChatReplyButton:OnInit()
  BaseElement.OnInit(self)
end
function ChatReplyButton:OnReplyHover()
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1, ease = "QuadIn"})
end
function ChatReplyButton:OnReplyUnhover()
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 0.8, ease = "QuadIn"})
end
function ChatReplyButton:OnReply()
  if self.playerId then
    DynamicBus.ChatBus.Broadcast.ReplyToWhisper(self.playerId.playerName)
  end
end
function ChatReplyButton:SetChatData(data)
  self.playerId = data.playerId
end
return ChatReplyButton
