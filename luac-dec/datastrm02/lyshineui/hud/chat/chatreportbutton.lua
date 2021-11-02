local ChatReportButton = {
  Properties = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChatReportButton)
function ChatReportButton:OnInit()
  BaseElement.OnInit(self)
end
function ChatReportButton:OnReportHover()
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1, ease = "QuadIn"})
end
function ChatReportButton:OnReportUnhover()
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 0.8, ease = "QuadIn"})
end
function ChatReportButton:OnReport()
  DynamicBus.ReportPlayerBus.Broadcast.OpenReport(self.playerId, self.chatMessage)
end
function ChatReportButton:SetChatData(data)
  self.chatMessage = data.chatMessage
  self.playerId = data.playerId
end
return ChatReportButton
