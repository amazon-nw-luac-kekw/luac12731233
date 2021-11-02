local ReportPlayer = {
  Properties = {
    PlayerIcon = {
      default = EntityId()
    },
    PlayerBackground = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    Dropdown = {
      default = EntityId()
    },
    ReasonTip = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    },
    SubmitButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    SubmitResponse = {
      default = EntityId()
    },
    ChatMessagePreview = {
      default = EntityId()
    },
    ChatMessageText = {
      default = EntityId()
    }
  },
  STATE_NAME_REPORTPLAYER = 943559040,
  dropdownOptions = {},
  currentReasonData = {},
  currentReasonEnum = nil
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ReportPlayer)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function ReportPlayer:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.ReportPlayerBus.Connect(self.entityId, self)
  self.SubmitButton:SetText("@ui_submit")
  UiElementBus.Event.SetIsEnabled(self.Properties.SubmitButton, false)
  self.CancelButton:SetText("@ui_cancel")
  self.SubmitButton:SetCallback(self.OnSubmit, self)
  self.SubmitButton:SetButtonStyle(self.SubmitButton.BUTTON_STYLE_CTA)
  self.CancelButton:SetCallback(self.ExitScreen, self)
  self.ButtonClose:SetCallback(self.ExitScreen, self)
  self.reasonListData = {
    {
      text = "@ui_reportreason_abusive_chat",
      description = "@ui_reportreason_abusive_chat_description",
      enum = eHeatEventType_ReportAbusiveChat
    },
    {
      text = "@ui_reportreason_cheating",
      description = "@ui_reportreason_cheating_description",
      enum = eHeatEventType_ReportCheating
    },
    {
      text = "@ui_reportreason_griefing",
      description = "@ui_reportreason_griefing_description",
      enum = eHeatEventType_ReportGriefing
    },
    {
      text = "@ui_reportreason_offensive_name",
      description = "@ui_reportreason_offensive_name_description",
      enum = eHeatEventType_ReportOffensiveName
    },
    {
      text = "@ui_reportreason_offensive_guild_name",
      description = "@ui_reportreason_offensive_guild_description",
      enum = eHeatEventType_ReportOffensiveGuildName
    },
    {
      text = "@ui_reportreason_spam",
      description = "@ui_reportreason_spam_description",
      enum = eHeatEventType_ReportSpam
    }
  }
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableCoinSellingReport") then
    table.insert(self.reasonListData, {
      text = "@ui_reportreason_coinselling",
      description = "@ui_reportreason_coinselling_description",
      enum = eHeatEventType_ReportCoinSelling
    })
  end
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableBotBehaviorReport") then
    table.insert(self.reasonListData, {
      text = "@ui_reportreason_botbehavior",
      description = "@ui_reportreason_botbehavior_description",
      enum = eHeatEventType_ReportBotBehavior
    })
  end
  self.Dropdown:SetDropdownScreenCanvasId(self.entityId)
  self.Dropdown:SetListData(self.reasonListData)
  self.Dropdown:SetCallback("ReasonSelected", self)
  self.Dropdown:SetText("@ui_reportreason_select")
  self.Dropdown:SetCloseCallback(self.OnDropdownClose, self)
  self.Dropdown:SetItemFocusCallback(self.OnReasonFocused, self)
  self.Dropdown:SetDropdownListHeightByRows(5)
end
function ReportPlayer:OnTransitionIn(stateName, levelName, toState, toLevel)
  self.cryActionNotificationHandler = self:BusConnect(CryActionNotificationsBus, "ui_cancel")
  self.ScriptedEntityTweener:Play(self.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.7, ease = "QuadOut"})
end
function ReportPlayer:OnTransitionOut(stateName, levelName, toState, toLevel)
  self:BusDisconnect(self.cryActionNotificationHandler)
end
function ReportPlayer:OnCryAction(actionName)
  self:ExitScreen()
end
function ReportPlayer:OnShutdown()
  DynamicBus.ReportPlayerBus.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
end
function ReportPlayer:ExitScreen()
  self:EnableGameInput(false)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function ReportPlayer:OpenReport(playerId, chatText)
  if not playerId or playerId:GetCharacterIdString() == "" then
    Debug.Log("ReportPlayer: Attempted to report player with invalid playerId: " .. tostring(playerId))
    return
  end
  self.playerId = playerId
  SocialDataHandler:GetRemotePlayerFaction_ServerCall(self, function(self, result)
    if 0 < #result then
      self.playerFaction = result[1].playerFaction
      local factionBg = self.playerFaction and FactionCommon.factionInfoTable[self.playerFaction].crestBgColor or self.UIStyle.COLOR_GRAY_70
      UiImageBus.Event.SetColor(self.Properties.PlayerBackground, factionBg)
    else
      Log("ERR ReportPlayer.lua - Could not retrieve faction info from playerId")
      return
    end
  end, function()
    Log("ERR ReportPlayer.lua - Could not retrieve faction info from playerId")
  end, self.playerId:GetCharacterIdString())
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerBackground, false)
  SocialDataHandler:GetRemotePlayerIconData_ServerCall(self, function(self, result)
    if #result == 0 then
      return
    end
    local playerIcon = result[1].playerIcon:Clone()
    self.PlayerIcon:SetIcon(playerIcon)
    UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PlayerBackground, true)
  end, function()
  end, self.playerId:GetCharacterIdString())
  SocialDataHandler:GetRemotePlayerGuildId_ServerCall(self, self.OnRemotePlayerGuildIdReady, self.EnableSubmitButton, self.playerId:GetCharacterIdString())
  local headerText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_report_header", self.playerId.playerName)
  self.FrameHeader:SetText(headerText)
  if chatText and chatText ~= "" then
    self.chatText = chatText
    UiTextBus.Event.SetText(self.ChatMessageText, chatText)
    UiElementBus.Event.SetIsEnabled(self.ChatMessagePreview, true)
    self.currentReasonData = self.reasonListData[1]
    self.Dropdown:SetText(self.currentReasonData.text)
    self:UpdateReasonDescription(self.currentReasonData.description)
  else
    self.chatText = nil
    self.currentReasonData = {}
    self.Dropdown:SetText("@ui_reportreason_select")
    self:UpdateReasonDescription("")
    UiElementBus.Event.SetIsEnabled(self.ChatMessagePreview, false)
  end
  UiTextBus.Event.SetText(self.SubmitResponse, "")
  LyShineManagerBus.Broadcast.SetState(943559040)
end
function ReportPlayer:OnRemotePlayerGuildIdReady(result)
  if #result == 0 then
    self:EnableSubmitButton()
    return
  end
  local guildId = result[1].playerGuildId
  if guildId and guildId:IsValid() then
    SocialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
      local guildData
      if 0 < #result then
        guildData = type(result[1]) == "table" and result[1].guildData or result[1]
      else
        Log("ERR - ReportPlayer.lua: GuildData request returned with no data")
      end
      if guildData and guildData:IsValid() then
        self.guildName = guildData.guildName
      end
      self:EnableSubmitButton()
    end, self.EnableSubmitButton, guildId)
  else
    self:EnableSubmitButton()
  end
end
function ReportPlayer:EnableSubmitButton()
  UiElementBus.Event.SetIsEnabled(self.Properties.SubmitButton, true)
end
function ReportPlayer:ReasonSelected(entityId, data)
  self.currentReasonData = data
  self:UpdateReasonDescription(data.description)
end
function ReportPlayer:OnReasonFocused(data)
  self:UpdateReasonDescription(data.description)
end
function ReportPlayer:OnDropdownClose()
  self:UpdateReasonDescription(self.currentReasonData.description)
end
function ReportPlayer:UpdateReasonDescription(description)
  UiTextBus.Event.SetTextWithFlags(self.ReasonTip, description, eUiTextSet_SetLocalized)
end
function ReportPlayer:OnSubmit()
  local isReasonReady = true
  local isDescriptionReady = true
  if not self.currentReasonData or not self.currentReasonData.enum then
    isReasonReady = false
  end
  local description = UiTextInputBus.Event.GetText(self.DescriptionText)
  if not description or description:len() <= 0 then
    isDescriptionReady = false
  end
  if isReasonReady and isDescriptionReady then
    JavSocialComponentBus.Broadcast.ReportPlayer(self.currentReasonData.enum, self.playerId:GetCharacterIdString(), self.guildName, description, self.chatText)
    self:ShowClosingThanks()
    local event = UiAnalyticsEvent("PlayerReportSource")
    event:AddAttribute("InvokedFrom", self.chatText and "Chat" or "SocialMenu")
    event:Send()
  elseif not isReasonReady and not isDescriptionReady then
    UiTextBus.Event.SetTextWithFlags(self.SubmitResponse, "@ui_missing_reason_and_description", eUiTextSet_SetLocalized)
  elseif not isReasonReady then
    UiTextBus.Event.SetTextWithFlags(self.SubmitResponse, "@ui_missing_reason", eUiTextSet_SetLocalized)
  elseif not isDescriptionReady then
    UiTextBus.Event.SetTextWithFlags(self.SubmitResponse, "@ui_missing_description", eUiTextSet_SetLocalized)
  end
end
function ReportPlayer:EnterDescriptionField()
  self:EnableGameInput(true)
end
function ReportPlayer:ExitDescriptionField()
  self:EnableGameInput(false)
end
function ReportPlayer:EnableGameInput(isEnabled)
  SetActionmapsForTextInput(self.canvasId, isEnabled)
end
function ReportPlayer:ShowClosingThanks()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_report_thanks"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  self:ExitScreen()
end
return ReportPlayer
