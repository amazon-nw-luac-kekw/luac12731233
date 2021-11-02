local Chat_ChannelPane = {
  Properties = {
    ChannelList = {
      default = EntityId()
    },
    BG = {
      default = EntityId()
    }
  },
  totalWhisperChannels = 0,
  activeChannelButton = nil,
  viewedChannelName = nil,
  isFocused = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Chat_ChannelPane)
function Chat_ChannelPane:OnInit()
  self:SetIsFocused(false)
  self.ChannelList:SetContainingChannelPane(self)
end
function Chat_ChannelPane:SetIsFocused(isFocused)
  if isFocused == self.isFocused then
    return
  end
  local paneWidth = isFocused and 284 or 67
  self.ChannelList:SetScrollBarVisible(isFocused)
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {w = paneWidth, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BG, 0.3, {
    opacity = isFocused and 0.8 or 0,
    ease = "QuadOut"
  })
  self.ChannelList:SetChannelFocused(isFocused)
  self.isFocused = isFocused
  LyShineDataLayerBus.Broadcast.SetData("Chat.ChannelPaneFocused", isFocused)
end
function Chat_ChannelPane:OnFocus()
  self:SetIsFocused(true)
end
function Chat_ChannelPane:OnUnfocus()
  self:SetIsFocused(false)
end
return Chat_ChannelPane
