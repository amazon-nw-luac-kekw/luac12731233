local ChatMessage = {
  Properties = {
    PaintBg = {
      default = EntityId()
    },
    OpaqueBg = {
      default = EntityId()
    },
    TextBg = {
      default = EntityId()
    },
    MessageField = {
      default = EntityId()
    },
    ChatDetails = {
      default = EntityId()
    },
    SpeakerNameEntityId = {
      default = EntityId()
    },
    ChannelIcon = {
      default = EntityId()
    },
    DetailsText = {
      default = EntityId()
    }
  },
  isNormalText = nil,
  textScale = 1,
  originalSpeakerFontSize = 18,
  originalChannelFontSize = 16,
  originalMessageFontSize = 20,
  layoutMargin = 6,
  detailsHeight = 22,
  textBgPaddingX = 36,
  textBgPaddingY = 12,
  backgroundOpacity = 0,
  CURSOR_HOVER_DELAY = 0.1,
  MOUSE_VELOCITY_THRESHOLD = 10000,
  GM_BADGE_ICON_PATH = "lyshineui/images/icons/chat/badgeGM.png"
}
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChatMessage)
local PlayerFlyoutHandler = RequireScript("LyShineUI.FlyoutMenu.PlayerFlyoutHandler")
PlayerFlyoutHandler:AttachPlayerFlyoutHandler(ChatMessage)
local ChatData = RequireScript("LyShineUI.HUD.Chat.ChatData")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function ChatMessage:OnInit()
  BaseElement.OnInit(self)
  self:InitPlayerFlyoutHandler(false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatAlwaysShowTimestamps", function(self, showTimestamps)
    self.alwaysShowTimestamps = showTimestamps
  end)
  self:BusConnect(UiMarkupButtonNotificationsBus, self.Properties.MessageField)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatColorMessageToChannel", function(self, colorMessages)
    self.colorMessageBodies = colorMessages
  end)
  self.enableReportFlag = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableReportPlayer", function(self, data)
    self.enableReportFlag = data
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_chatSettings", function(self, isEnabled)
    if isEnabled ~= nil then
      if isEnabled then
        self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatFontSize", function(self, fontSize)
          if fontSize then
            self.textScale = fontSize / self.originalMessageFontSize
            UiTextBus.Event.SetFontSize(self.Properties.MessageField, self.originalMessageFontSize * self.textScale)
            UiTextBus.Event.SetFontSize(self.Properties.SpeakerNameEntityId, self.originalSpeakerFontSize * self.textScale)
            UiTextBus.Event.SetFontSize(self.Properties.DetailsText, self.originalChannelFontSize * self.textScale)
            UiTransformBus.Event.SetScale(self.Properties.ChannelIcon, Vector2(self.textScale, self.textScale))
          end
        end)
      else
        self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Accessibility.TextSizeOption", function(self, textSize)
          self.textScale = 1
          if textSize == eAccessibilityTextOptions_Bigger then
            self.textScale = 1.25
          end
        end)
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatMessageBackgroundOpacity", function(self, opacity)
    if not opacity then
      return
    end
    self.useOpaqueBg = 0 < opacity
    UiElementBus.Event.SetIsEnabled(self.Properties.OpaqueBg, self.useOpaqueBg)
    if self.useOpaqueBg then
      self.backgroundOpacity = opacity / 100
      self.ScriptedEntityTweener:Set(self.Properties.OpaqueBg, {
        opacity = self.backgroundOpacity
      })
    end
  end)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.reportData = {}
end
function ChatMessage:OnShutdown()
end
function ChatMessage:OnFocus(isMouseOver, isInstant)
  if isMouseOver then
    self:SetAdditionalMessageOptionsVisibility(true)
  end
end
function ChatMessage:OnUnfocus(isInstant)
  self:SetAdditionalMessageOptionsVisibility(false)
end
function ChatMessage:IsDefaultView()
  return self.chatDisplayState == 0
end
function ChatMessage:IsCondensedView()
  return self.chatDisplayState == 1
end
function ChatMessage:IsCompactView()
  return self.chatDisplayState == 2
end
function ChatMessage:GetMessageField()
  return self.Properties.MessageField
end
function ChatMessage:GetChatOptions()
  return self.Properties.ChatOptions
end
function ChatMessage:GetTextBg()
  return self.Properties.TextBg
end
function ChatMessage:GetChannelIcon()
  return self.Properties.ChannelIcon
end
function ChatMessage:GetDetailsText()
  return self.Properties.DetailsText
end
function ChatMessage:SetText(value, enableMarkup)
  self.detailsHeight = self.originalSpeakerFontSize * self.textScale
  self.isNormalText = true
  self:UpdateTotalSize(self:GetMessageField(), value, enableMarkup)
end
function ChatMessage:SetPingMessage(value)
  UiTextBus.Event.SetText(self:GetMessageField(), value)
  self.detailsHeight = 0
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ChatDetails, 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.ChatDetails, false)
  self.isNormalText = false
  self:UpdateTotalSize(self:GetMessageField(), value, false)
end
function ChatMessage:RemoveMarkup(text)
  return text:gsub("<a[%a%d%s=\"]*>", ""):gsub("</a>", ""):gsub("<font[%a%d%s#=/\"._]*>", ""):gsub("</font>", "")
end
function ChatMessage:SetupChatElement(messageData)
  local chatChannelData = ChatData:GetChannelData(messageData.chatType)
  local messageField = self:GetMessageField()
  local itemDescriptors = messageData.itemDescriptors
  local numDescriptors = itemDescriptors and #itemDescriptors or 0
  local textWidth, textHeight
  UiTextBus.Event.SetIsMarkupEnabled(messageField, messageData.enableMarkup)
  local cleanText
  if messageData.enableMarkup then
    cleanText = self:RemoveMarkup(messageData.chatMessage)
    UiTextBus.Event.SetWrapText(messageField, eUiTextWrapTextSetting_Wrap)
  else
    cleanText = messageData.chatMessage
    UiTextBus.Event.SetWrapText(messageField, eUiTextWrapTextSetting_NoWrap)
  end
  local wrappedText
  wrappedText, textWidth, textHeight = self:GetWrappedText(cleanText)
  UiTextBus.Event.SetText(messageField, messageData.enableMarkup and messageData.chatMessage or wrappedText)
  local paintColor
  local isSystemMessage = messageData.chatType == eChatMessageType_System
  local isWhisper = messageData.chatType == eChatMessageType_Whisper
  if isSystemMessage then
    paintColor = self.UIStyle.COLOR_RED
  elseif messageData.alertOnReceive == true or messageData.isOwnMessage then
    paintColor = self.UIStyle.COLOR_WHITE
  elseif messageData.isGameMasterClientMsg == true then
    paintColor = self.UIStyle.COLOR_CHAT_GM
  elseif chatChannelData.backgroundColor then
    paintColor = chatChannelData.backgroundColor
  end
  local textBg = self:GetTextBg()
  UiTransform2dBus.Event.SetLocalWidth(textBg, textWidth + self.textBgPaddingX)
  UiTransform2dBus.Event.SetLocalHeight(textBg, textHeight + self.textBgPaddingY)
  UiElementBus.Event.SetIsEnabled(self.Properties.PaintBg, paintColor ~= nil)
  if paintColor then
    UiImageBus.Event.SetColor(self.Properties.PaintBg, paintColor)
  end
  local hadDescriptors = self.itemDescriptors and #self.itemDescriptors > 0
  if hadDescriptors then
    UiMarkupButtonBus.Event.ClearOverrideLinkColors(messageField)
  end
  self.itemDescriptors = itemDescriptors
  if 0 < numDescriptors then
    for i = 1, numDescriptors do
      local descriptor = self.itemDescriptors[i]
      local levelColor = self.UIStyle["COLOR_RARITY_LEVEL_" .. descriptor:GetRarityLevel()]
      if levelColor then
        UiMarkupButtonBus.Event.SetOverrideLinkColor(messageField, levelColor, i - 1)
      end
    end
  end
  local senderColor = self.UIStyle.COLOR_WHITE
  local playerName
  if messageData.isGameMasterClientMsg == true then
    playerName = LyShineScriptBindRequestBus.Broadcast.LocalizeText("[@ui_chat_GameMasterTag] ") .. (messageData.chatSender.playerName or messageData.chatSender)
    senderColor = self.UIStyle.COLOR_CHAT_GM
  elseif isSystemMessage then
    playerName = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_error_systemname")
  else
    playerName = messageData.chatSender.playerName or messageData.chatSender
  end
  UiTextBus.Event.SetText(self.Properties.SpeakerNameEntityId, playerName)
  UiTextBus.Event.SetColor(self.Properties.SpeakerNameEntityId, senderColor)
  local channelIcon = self:GetChannelIcon()
  local detailsText = self:GetDetailsText()
  UiImageBus.Event.SetSpritePathname(channelIcon, chatChannelData.messageIcon)
  UiImageBus.Event.SetColor(channelIcon, chatChannelData.color)
  local detailsString = LyShineScriptBindRequestBus.Broadcast.LocalizeText(chatChannelData.displayNameUpper)
  if isWhisper then
    local whisperName
    if messageData.isOwnMessage then
      whisperName = messageData.chatRecipient
    else
      whisperName = playerName
    end
    detailsString = detailsString .. " \226\128\148 " .. whisperName
  end
  if self.alwaysShowTimestamps then
    detailsString = detailsString .. "      " .. messageData.time
  end
  UiTextBus.Event.SetText(detailsText, detailsString)
  UiTextBus.Event.SetColor(detailsText, chatChannelData.color)
  local desiredColor = self.UIStyle.COLOR_WHITE
  if messageData.isPingMessage then
    desiredColor = ChatData.colorPing
  elseif self.colorMessageBodies then
    desiredColor = chatChannelData.color
  end
  UiTextBus.Event.SetColor(messageField, desiredColor)
  self.isWhisper = isWhisper
  if not messageData.isPingMessage then
    self.enableReport = self.enableReportFlag and not isSystemMessage and not messageData.isOwnMessage
    if self.enableReport then
      self.reportData.chatMessage = messageData.chatMessage
      self.reportData.playerId = messageData.chatSender
    else
      self.reportData.chatMessage = nil
    end
    self.speakerPlayerId = messageData.chatSender
  else
    self.speakerPlayerId = nil
  end
  self:PositionRelativeToX(self.Properties.ChatDetails, self.Properties.SpeakerNameEntityId, 9, true)
end
function ChatMessage:SetAdditionalMessageOptionsVisibility(isVisible)
  if not self.additionalOptions then
    self.additionalOptions = UiCanvasBus.Event.FindElementByName(self.canvasId, "ChatMessageAdditionalOptions")
    local replyEntityId = UiElementBus.Event.FindChildByName(self.additionalOptions, "ReplyButton")
    local reportEntityId = UiElementBus.Event.FindChildByName(self.additionalOptions, "ReportButton")
    self.reportButton = self.registrar:GetEntityTable(reportEntityId)
    self.replyButton = self.registrar:GetEntityTable(replyEntityId)
  end
  UiElementBus.Event.SetIsEnabled(self.additionalOptions, isVisible)
  if isVisible then
    local marginRight = 35
    local thisPos = UiTransformBus.Event.GetViewportPosition(self.entityId)
    thisPos.x = thisPos.x - marginRight
    UiTransformBus.Event.SetViewportPosition(self.additionalOptions, thisPos)
    UiElementBus.Event.SetIsEnabled(self.reportButton.entityId, self.enableReport)
    UiElementBus.Event.SetIsEnabled(self.replyButton.entityId, self.enableReport and self.isWhisper)
    if self.enableReport then
      self.reportButton:SetChatData(self.reportData)
      self.replyButton:SetChatData(self.reportData)
    end
  end
end
function ChatMessage:PositionRelativeToX(toPositionEntity, anchorEntity, paddingValue, useTextWidth, widthOverride, positionFromRight)
  local anchorXPos = UiTransformBus.Event.GetLocalPositionX(anchorEntity)
  local anchorWidth = 0
  local finalPosition = anchorXPos
  if UiElementBus.Event.IsEnabled(anchorEntity) then
    if not widthOverride then
      if useTextWidth then
        anchorWidth = UiTextBus.Event.GetTextWidth(anchorEntity)
      else
        anchorWidth = UiTransform2dBus.Event.GetLocalWidth(anchorEntity)
      end
    else
      anchorWidth = widthOverride
    end
    if positionFromRight then
      finalPosition = anchorXPos + -1 * (anchorWidth + paddingValue)
    else
      finalPosition = anchorXPos + anchorWidth + paddingValue
    end
  end
  UiTransformBus.Event.SetLocalPositionX(toPositionEntity, finalPosition)
  return finalPosition
end
function ChatMessage:GetTextHeightFast(textField, text)
  local _, _, height = self:GetWrappedText(text)
  return height
end
function ChatMessage:GetWrappedText(originalText)
  local elementWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  local fontSize = self.originalMessageFontSize * self.textScale
  local messageField = self:GetMessageField()
  local wrappedStr = UiTextBus.Event.GetWrappedTextFromCache(messageField, originalText, math.ceil(elementWidth))
  local _, numLines = wrappedStr:gsub("\n", "\n")
  numLines = numLines + 1
  local textWidth = 1 < numLines and elementWidth or UiTextBus.Event.GetTextWidthFromCache(messageField, wrappedStr)
  return wrappedStr, textWidth, numLines * fontSize
end
function ChatMessage:UpdateTotalSize(textField, text, enableMarkup)
  local textHeight
  UiTextBus.Event.SetIsMarkupEnabled(textField, enableMarkup)
  if enableMarkup then
    UiTextBus.Event.SetWrapText(textField, eUiTextWrapTextSetting_Wrap)
    UiTextBus.Event.SetText(textField, text)
    textHeight = UiTextBus.Event.GetTextHeight(textField)
  else
    textHeight = self:GetTextHeightFast(textField, text)
    UiTextBus.Event.SetWrapText(textField, eUiTextWrapTextSetting_NoWrap)
  end
  self:UpdateTotalSizeWithTextHeight(textHeight)
end
function ChatMessage:UpdateTotalSizeWithTextHeight(textHeight)
  local totalHeight = self.detailsHeight + textHeight + self.layoutMargin * 2
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, totalHeight)
  self.height = totalHeight
end
function ChatMessage:GetHeight()
  return self.height
end
function ChatMessage:OnHoverStart(clickableId, action, data)
  if self.itemDescriptors == nil then
    return
  end
  local channelPaneFocused = self.dataLayer:GetDataFromNode("Chat.ChannelPaneFocused")
  if channelPaneFocused then
    return
  end
  local descriptor = self.itemDescriptors[tonumber(data) + 1]
  if descriptor then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    local tdi = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(tdi, self, nil)
  end
end
function ChatMessage:OnHoverEnd(clickableId, action, data)
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function ChatMessage:OnHoverSpeakerNameStart()
  if self.speakerPlayerId and type(self.speakerPlayerId) ~= "string" and self.speakerPlayerId:IsValid() then
    self.isHoveringOverSpeaker = true
    self.lastCursorPos = CursorBus.Broadcast.GetCursorPosition()
    TimingUtils:Delay(self.CURSOR_HOVER_DELAY, self, self.OnHoveringTimer)
  end
end
function ChatMessage:OnHoveringTimer()
  if not self.isHoveringOverSpeaker then
    return
  end
  local currentCursorPos = CursorBus.Broadcast.GetCursorPosition()
  local distSq = (currentCursorPos.x - self.lastCursorPos.x) ^ 2 + (currentCursorPos.y - self.lastCursorPos.y) ^ 2
  local velocitySq = distSq / self.CURSOR_HOVER_DELAY ^ 2
  if velocitySq < self.MOUSE_VELOCITY_THRESHOLD then
    self:PFH_ShowFlyoutForPlayerId(self.speakerPlayerId, self.Properties.SpeakerNameEntityId)
    self:PFH_SetChatMessage(self.reportData.chatMessage)
  else
    self.lastCursorPos = currentCursorPos
    TimingUtils:Delay(self.CURSOR_HOVER_DELAY, self, self.OnHoveringTimer)
  end
end
function ChatMessage:OnHoverSpeakerNameEnd()
  self.isHoveringOverSpeaker = false
end
return ChatMessage
