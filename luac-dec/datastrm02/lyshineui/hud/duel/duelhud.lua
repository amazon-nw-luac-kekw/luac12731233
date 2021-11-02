local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local bitHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local DuelHud = {
  Properties = {
    BannerContainer = {
      default = EntityId()
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    SequenceRed = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    DuelStartsIn = {
      default = EntityId()
    },
    Countdown = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    ResultText = {
      default = EntityId()
    },
    VictoryIcon = {
      default = EntityId()
    },
    EnemyList = {
      default = EntityId()
    },
    FriendList = {
      default = EntityId()
    },
    UnusedList = {
      default = EntityId()
    },
    Enemy1 = {
      default = EntityId()
    },
    Enemy2 = {
      default = EntityId()
    },
    Enemy3 = {
      default = EntityId()
    },
    Enemy4 = {
      default = EntityId()
    },
    Enemy5 = {
      default = EntityId()
    },
    Friend1 = {
      default = EntityId()
    },
    Friend2 = {
      default = EntityId()
    },
    Friend3 = {
      default = EntityId()
    },
    Friend4 = {
      default = EntityId()
    },
    Friend5 = {
      default = EntityId()
    },
    ForfeitButton = {
      default = EntityId()
    },
    DuelingText = {
      default = EntityId()
    },
    DuelingContainer = {
      default = EntityId()
    }
  },
  activeGameModes = {},
  dataLayer_stateId = "State",
  dataLayer_winningTeamIdxId = tostring(1116393986),
  dataLayer_countdownTimerId = "Timer_" .. tostring(4179687204),
  dataLayer_participantCount = "ParticipantCount",
  dataLayer_participantStatusBits = "Participant%d.statusBits",
  dataLayer_participantCharacterIdString = "Participant%d.characterIdString",
  dataLayer_participantTeamIdx = "Participant%d.teamIdx",
  dataLayer_gameModeStarted = "GameModeStarted",
  DuelState_PreDuel = 742071280,
  DuelState_Dueling = 100786477,
  DuelState_Interference = 1354945726,
  DuelState_Draw = 3123439228,
  DuelState_Finished = 2489790695,
  DuelRequest_Forfeit = 3166465118,
  forfeitDuelKeybinding = "ui_duel_forfeit",
  forfeitDuelModKeybinding = "ui_duel_forfeit_mod"
}
BaseScreen:CreateNewScreen(DuelHud)
function DuelHud:OnInit()
  BaseScreen.OnInit(self)
  self.enemies = {
    {
      plate = self.Properties.Enemy1
    },
    {
      plate = self.Properties.Enemy2
    },
    {
      plate = self.Properties.Enemy3
    },
    {
      plate = self.Properties.Enemy4
    },
    {
      plate = self.Properties.Enemy5
    }
  }
  self.friends = {
    {
      plate = self.Properties.Friend1
    },
    {
      plate = self.Properties.Friend2
    },
    {
      plate = self.Properties.Friend3
    },
    {
      plate = self.Properties.Friend4
    },
    {
      plate = self.Properties.Friend5
    }
  }
  for i = 1, 5 do
    for j = 1, 2 do
      local t = j == 1 and self.enemies[i] or self.friends[i]
      t.statusIcon = UiElementBus.Event.FindChildByName(t.plate, "StatusIcon")
      t.name = UiElementBus.Event.FindChildByName(t.plate, "Name")
    end
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.localPlayerEntityId = rootEntityId
      if self.participantBusHandler then
        self.participantBusHandler:Disconnect()
        self.participantBusHandler = nil
      end
      self.participantBusHandler = GameModeParticipantComponentNotificationBus.Connect(self, rootEntityId)
    end
  end)
  SetTextStyle(self.Properties.DuelingText, self.UIStyle.FONT_STYLE_NOTIFICATION_CENTER_TITLE)
  SetTextStyle(self.Properties.DuelStartsIn, self.UIStyle.FONT_STYLE_DUEL_TITLE_SMALL)
  SetTextStyle(self.Properties.Countdown, self.UIStyle.FONT_STYLE_DUEL_COUNTDOWN)
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_DUEL_TITLE_MEDIUM)
  SetTextStyle(self.Properties.ResultText, self.UIStyle.FONT_STYLE_DUEL_RESULT)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DuelingText, "@ui_duel_group_popup_title", eUiTextSet_SetLocalized)
  self.socialDataHandler = SocialDataHandler
  local forfeitButtonPadding = 80
  self.ForfeitButton:SetText("@ui_duel_forfeit_title", false, true, forfeitButtonPadding)
  self.ForfeitButton:SetCallback(self.OnForfeitButtonClicked, self)
  self.ForfeitButton:SetHint("duel_forfeit", true)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SequenceRed, false)
  self.ScriptedEntityTweener:Set(self.Properties.DuelingContainer, {opacity = 0, y = 73})
  self.ScriptedEntityTweener:Set(self.Properties.VictoryIcon, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ResultText, {opacity = 0})
end
function DuelHud:OnShutdown()
  if self.participantBusHandler then
    self.participantBusHandler:Disconnect()
    self.participantBusHandler = nil
  end
end
function DuelHud:OnCryAction(actionName)
  self:OnForfeitButtonClicked()
end
function DuelHud:GetGameModeDataPath(gameModeEntityId, valueName)
  return "GameMode." .. tostring(gameModeEntityId) .. "." .. valueName
end
function DuelHud:OnForfeitButtonClicked()
  local ForfeitDuelConfimationId = "ForfeitDuelConfirmation"
  PopupWrapper:RequestPopupWithParams({
    title = "@ui_duel_forfeit_title",
    message = "@ui_duel_forfeit_confirm",
    eventId = ForfeitDuelConfimationId,
    callerSelf = self,
    callback = function(self, result, eventId)
      if eventId == ForfeitDuelConfimationId and result == ePopupResult_Yes then
        GameModeParticipantComponentRequestsBus.Event.SendClientEvent(self.localPlayerEntityId, self.DuelRequest_Forfeit)
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Lose)
        self:BusDisconnect(self.actionHandler)
        self.actionHandler = nil
      end
    end,
    buttonsYesNo = true,
    yesButtonText = "@ui_duel_forfeit_yes",
    noButtonText = "@ui_duel_forfeit_no"
  })
end
function DuelHud:OnEnteredGameMode(gameModeEntityId, gameModeId)
  if gameModeId ~= 2612307810 then
    return
  end
  self.gameModeEntityId = gameModeEntityId
  self.gameModeStarted = false
  self.maxEnemyCount = 0
  self.maxFriendCount = 0
  self.hasSentChatMessage = false
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, "", eUiTextSet_SetAsIs)
  UiTextBus.Event.SetColor(self.Properties.Title, self.UIStyle.COLOR_WHITE)
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_DUEL_TITLE_MEDIUM)
  self.ScriptedEntityTweener:Set(self.Properties.Title, {
    opacity = 0,
    y = 19,
    textCharacterSpace = 150
  })
  self.ScriptedEntityTweener:Set(self.Properties.VictoryIcon, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ResultText, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Divider, {y = -35})
  self.Divider:SetVisible(false)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiFaderBus.Event.SetFadeValue(self.entityId, 1)
  UiElementBus.Event.SetIsEnabled(self.Properties.SequenceRed, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.gameModeEntityId, self.dataLayer_gameModeStarted), function(self, gameModeStarted)
    if gameModeStarted then
      self.gameModeStarted = true
      self:CheckReadyToGo()
    end
  end)
  self.pendingCharacterRequests = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_participantCount), function(self, participantCount)
    if not participantCount then
      return
    end
    self.participantCount = participantCount
    self.participants = {}
    for i = 1, participantCount do
      self.participants[i] = {
        characterIdString = "",
        teamIdx = -1,
        statusBits = 0
      }
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, string.format(self.dataLayer_participantTeamIdx, i)), function(self, teamIdx)
        if teamIdx then
          self.participants[i].teamIdx = teamIdx
        end
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, string.format(self.dataLayer_participantStatusBits, i)), function(self, statusBits)
        if statusBits then
          self:OnStatusBitsChanged(i, statusBits)
        end
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, string.format(self.dataLayer_participantCharacterIdString, i)), function(self, characterIdString)
        if characterIdString then
          self.pendingCharacterRequests[characterIdString] = true
          self.participants[i].characterIdString = characterIdString
          self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnPlayerIdReady, self.OnPlayerIdFailed, characterIdString)
        end
      end)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_stateId), function(self, stateCrc)
    self.currentDuelState = stateCrc
    if stateCrc == self.DuelState_Dueling then
      self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_countdownTimerId))
    elseif stateCrc == self.DuelState_Interference then
      self:EndDuelMessage("@ui_duel_resolution_interference", "@ui_duel_ended", false, true)
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Lose)
    elseif stateCrc == self.DuelState_Draw then
      self:EndDuelMessage("@ui_duel_resolution_draw", "@ui_duel_ended", false, true)
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Lose)
    end
  end)
  self.dataLayer:RegisterDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_winningTeamIdxId), function(self, winningTeamIdx)
    SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_DUEL_TITLE_LARGE)
    if GameModeComponentRequestBus.Event.GetParticipantTeamIdx(gameModeEntityId, self.localPlayerEntityId) == winningTeamIdx then
      self:EndDuelMessage("@ui_duel_victory", "@ui_duel_victory_message", true)
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Win)
    else
      self:EndDuelMessage("@ui_duel_defeat", "@ui_duel_defeat_message", false)
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Lose)
    end
  end)
  self.secondsRemaining = -1
  self.bannerShown = false
  self.dataLayer:RegisterDataObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_countdownTimerId), function(self, timeRemaining)
    local secondsRemaining = math.ceil(timeRemaining / 1000)
    if secondsRemaining ~= self.secondsRemaining then
      if not self.bannerShown then
        self.ScriptedEntityTweener:Set(self.Properties.DuelingContainer, {y = 73, opacity = 0})
        UiElementBus.Event.SetIsEnabled(self.Properties.BannerContainer, true)
        UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
        UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
        self.ScriptedEntityTweener:Set(self.Properties.BannerContainer, {opacity = 0})
        self.ScriptedEntityTweener:PlayC(self.Properties.BannerContainer, 0.2, tweenerCommon.fadeInQuadOut)
        UiElementBus.Event.SetIsEnabled(self.Properties.ForfeitButton, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.DuelStartsIn, false)
        self.Divider:SetVisible(false)
        UiElementBus.Event.SetIsEnabled(self.Properties.Countdown, false)
        UiTextBus.Event.SetTextWithFlags(self.Properties.Title, "@ui_duel_accepted", eUiTextSet_SetLocalized)
        self.ScriptedEntityTweener:Set(self.Properties.Title, {textCharacterSpace = 150, opacity = 0})
        self.ScriptedEntityTweener:PlayC(self.Properties.Title, 3, tweenerCommon.textCharacterTo250)
        self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.2, tweenerCommon.fadeInQuadOut)
        self.bannerShown = true
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Countdown)
      elseif 0 < secondsRemaining and secondsRemaining < 4 then
        self.ScriptedEntityTweener:Set(self.Properties.DuelingContainer, {y = 73, opacity = 0})
        self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.1, tweenerCommon.fadeOutQuadIn, nil, function()
          self.ScriptedEntityTweener:Set(self.Properties.Title, {textCharacterSpace = 150})
        end)
        UiElementBus.Event.SetIsEnabled(self.Properties.DuelStartsIn, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.Countdown, true)
        UiTextBus.Event.SetTextWithFlags(self.Properties.DuelStartsIn, "@ui_duel_starts_in", eUiTextSet_SetLocalized)
        self.Divider:SetVisible(true)
        UiTextBus.Event.SetTextWithFlags(self.Properties.Countdown, tostring(secondsRemaining), eUiTextSet_SetAsIs)
        UiElementBus.Event.SetIsEnabled(self.Properties.Countdown, true)
        self.ScriptedEntityTweener:Stop(self.Properties.Countdown)
        self.ScriptedEntityTweener:PlayFromC(self.Properties.Countdown, 0.7, {
          opacity = 1,
          scaleX = 1,
          scaleY = 1
        }, tweenerCommon.countdownDuel, 0.3)
        if secondsRemaining == 4 then
          self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Count_3)
        elseif secondsRemaining == 3 then
          self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Count_2)
        elseif secondsRemaining == 2 then
          self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Count_1)
        end
      elseif secondsRemaining == 0 then
        self.actionHandler = self:BusConnect(CryActionNotificationsBus, "duel_forfeit")
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Duel, self.audioHelper.MusicState_Duel_Start)
        UiElementBus.Event.SetIsEnabled(self.Properties.DuelStartsIn, false)
        self.Divider:SetVisible(false)
        UiElementBus.Event.SetIsEnabled(self.Properties.Countdown, false)
        SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_DUEL_TITLE_LARGE)
        self.ScriptedEntityTweener:Set(self.Properties.Title, {textCharacterSpace = 150})
        UiTextBus.Event.SetTextWithFlags(self.Properties.Title, "@ui_duel_start", eUiTextSet_SetLocalized)
        self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.2, tweenerCommon.fadeInQuadOut)
        UiElementBus.Event.SetIsEnabled(self.Properties.SequenceRed, true)
        self.ScriptedEntityTweener:Set(self.Properties.SequenceRed, {opacity = 1})
        UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceRed)
        self.ScriptedEntityTweener:PlayC(self.Properties.SequenceRed, 0.3, tweenerCommon.fadeOutQuadIn, 0.8)
        UiElementBus.Event.SetIsEnabled(self.Properties.ForfeitButton, true)
        self.ScriptedEntityTweener:PlayC(self.Properties.BannerContainer, 0.2, tweenerCommon.fadeOutQuadIn, 1, function()
          UiElementBus.Event.SetIsEnabled(self.Properties.BannerContainer, false)
          UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
        end)
        self.ScriptedEntityTweener:PlayC(self.Properties.DuelingContainer, 0.3, tweenerCommon.duelSlideIn, 1)
      end
      self.secondsRemaining = secondsRemaining
    end
  end)
end
function DuelHud:OnStatusBitsChanged(participantIdx, statusBits)
  local participant = self.participants[participantIdx]
  participant.statusBits = statusBits
  local playerElement = self.enemies[participant.enemyIdx] or self.friends[participant.friendIdx]
  local isFriend = playerElement == self.friends[participant.friendIdx]
  if not playerElement then
    return
  end
  local clr
  local iconPath = "LyShineUI/Images/DuelHUD/duelHeadIcon.dds"
  if bitHelpers:TestFlag(statusBits, eGameModeParticipantStatus_ActiveFlag) then
    if bitHelpers:TestFlag(statusBits, eGameModeParticipantStatus_DeadFlag) or bitHelpers:TestFlag(statusBits, eGameModeParticipantStatus_DeathsDoorFlag) then
      clr = self.UIStyle.COLOR_GRAY_70
      iconPath = "LyShineUI/Images/DuelHUD/duelSkullIcon.dds"
    else
      clr = isFriend and self.UIStyle.COLOR_DUEL_BLUE or self.UIStyle.COLOR_DUEL_RED
    end
  else
    clr = self.UIStyle.COLOR_GRAY_50
  end
  if clr then
    UiImageBus.Event.SetColor(playerElement.statusIcon, clr)
  end
  UiImageBus.Event.SetSpritePathname(playerElement.statusIcon, iconPath)
end
function DuelHud:OnExitedGameMode(gameModeEntityId)
  if gameModeEntityId ~= self.gameModeEntityId then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.gameModeEntityId = nil
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_stateId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_winningTeamIdxId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_countdownTimerId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, self.dataLayer_gameModeStarted))
  for i = 1, #self.participants do
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, string.format(self.dataLayer_participantCharacterIdString, i)))
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, string.format(self.dataLayer_participantTeamIdx, i)))
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(gameModeEntityId, string.format(self.dataLayer_participantStatusBits, i)))
  end
  self.participants = nil
end
function DuelHud:OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - DuelHud:OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - DuelHud:OnPlayerIdFailed: Timed Out.")
  end
end
function DuelHud:OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - DuelHud:OnPlayerIdReady: Player not found.")
    return
  end
  if playerId then
    for index, data in ipairs(self.participants) do
      if data.characterIdString == playerId:GetCharacterIdString() then
        data.playerName = playerId.playerName
        self.pendingCharacterRequests[data.characterIdString] = nil
        self:CheckReadyToGo()
        return
      end
    end
  end
end
function DuelHud:CheckReadyToGo()
  if not self.participants or #self.participants ~= self.participantCount then
    return
  end
  if not self.gameModeStarted or next(self.pendingCharacterRequests) then
    return
  end
  if not self.youString then
    self.youString = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_duel_message_you")
    self.nameKeys = vector_basic_string_char_char_traits_char()
    for i = 1, 5 do
      self.nameKeys:push_back("name" .. tostring(i))
    end
  end
  local localPlayerName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName")
  local localPlayerNameFound = false
  local myTeamIdx = GameModeComponentRequestBus.Event.GetParticipantTeamIdx(self.gameModeEntityId, self.localPlayerEntityId)
  if myTeamIdx == -1 then
    return
  end
  local enemyCount = 0
  local friendCount = 0
  local enemyNames = vector_basic_string_char_char_traits_char()
  local friendNames = vector_basic_string_char_char_traits_char()
  for i, participant in ipairs(self.participants) do
    if participant.teamIdx ~= -1 then
      if participant.teamIdx ~= myTeamIdx then
        enemyCount = enemyCount + 1
        participant.enemyIdx = enemyCount
        participant.friendIdx = 0
        enemyNames:push_back(participant.playerName)
        UiElementBus.Event.Reparent(self.enemies[enemyCount].plate, self.Properties.EnemyList, EntityId())
        UiTextBus.Event.SetTextWithFlags(self.enemies[enemyCount].name, participant.playerName, eUiTextSet_SetAsIs)
        self:OnStatusBitsChanged(i, participant.statusBits)
      else
        friendCount = friendCount + 1
        participant.enemyIdx = 0
        participant.friendIdx = friendCount
        if participant.playerName == localPlayerName then
          localPlayerNameFound = true
        else
          friendNames:push_back(participant.playerName)
        end
        UiElementBus.Event.Reparent(self.friends[friendCount].plate, self.Properties.FriendList, EntityId())
        UiTextBus.Event.SetTextWithFlags(self.friends[friendCount].name, participant.playerName, eUiTextSet_SetAsIs)
        self:OnStatusBitsChanged(i, participant.statusBits)
      end
    end
  end
  if localPlayerNameFound then
    friendNames:push_back(self.youString)
  end
  self.maxEnemyCount = math.max(self.maxEnemyCount, enemyCount)
  self.maxFriendCount = math.max(self.maxFriendCount, friendCount)
  for i = enemyCount + 1, 5 do
    if i <= self.maxEnemyCount then
      UiElementBus.Event.Reparent(self.enemies[i].plate, self.Properties.EnemyList, EntityId())
      UiImageBus.Event.SetColor(self.enemies[i].statusIcon, self.UIStyle.COLOR_GRAY_50)
    else
      UiElementBus.Event.Reparent(self.enemies[i].plate, self.Properties.UnusedList, EntityId())
    end
  end
  for i = friendCount + 1, 5 do
    if i <= self.maxFriendCount then
      UiElementBus.Event.Reparent(self.friends[i].plate, self.Properties.FriendList, EntityId())
      UiImageBus.Event.SetColor(self.friends[i].statusIcon, self.UIStyle.COLOR_GRAY_50)
    else
      UiElementBus.Event.Reparent(self.friends[i].plate, self.Properties.UnusedList, EntityId())
    end
  end
  if not self.hasSentChatMessage then
    local body1 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_duel_begin_message_" .. enemyCount, self.nameKeys, enemyNames)
    local body2 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_duel_with_message_" .. friendCount, self.nameKeys, friendNames)
    local chatMessage = BaseGameChatMessage()
    chatMessage.type = eChatMessageType_System
    chatMessage.body = body1 .. body2
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    self.hasSentChatMessage = true
  end
end
function DuelHud:EndDuelMessage(title, resultText, victorySequence, drawOrInterference)
  self:BusDisconnect(self.actionHandler)
  self.actionHandler = nil
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_DUEL_TITLE_LARGE)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ResultText, resultText, eUiTextSet_SetLocalized)
  if victorySequence then
    UiTextBus.Event.SetColor(self.Properties.Title, self.UIStyle.COLOR_GREEN)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceRed, true)
    self.ScriptedEntityTweener:Set(self.Properties.SequenceRed, {opacity = 1})
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceRed)
    self.ScriptedEntityTweener:PlayC(self.Properties.SequenceRed, 0.3, tweenerCommon.fadeOutQuadIn, 0.8)
  elseif drawOrInterference then
    UiTextBus.Event.SetColor(self.Properties.Title, self.UIStyle.COLOR_YELLOW)
  else
    UiTextBus.Event.SetColor(self.Properties.Title, self.UIStyle.COLOR_RED)
  end
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
  self.ScriptedEntityTweener:Set(self.Properties.VictoryIcon, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.ResultText, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.Title, {
    textCharacterSpace = 150,
    y = 5,
    opacity = 0
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.Title, 0.2, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:Set(self.Properties.Divider, {y = -5})
  self.Divider:SetVisible(true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ForfeitButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BannerContainer, true)
  self.ScriptedEntityTweener:PlayC(self.Properties.DuelingContainer, 0.1, tweenerCommon.fadeOutQuadIn)
  self.ScriptedEntityTweener:PlayC(self.Properties.BannerContainer, 0.2, tweenerCommon.fadeInQuadOut, nil, function()
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.5, tweenerCommon.duelFadeOut, 2.5, function()
      UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
    end)
  end)
end
return DuelHud
