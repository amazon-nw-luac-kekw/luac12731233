local SelectionItem = {
  Properties = {
    PlayerIcon = {
      default = EntityId()
    },
    TwitchNameLabel = {
      default = EntityId()
    },
    PlayerNameLabel = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    FactionText = {
      default = EntityId()
    },
    FactionIconTextDivider = {
      default = EntityId()
    },
    StatusText = {
      default = EntityId()
    },
    SelectionCheckbox = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    IconSelected = {
      default = EntityId()
    },
    CheckHover = {
      default = EntityId()
    },
    InvitedSpinner = {
      default = EntityId()
    }
  },
  playerFaction = eFactionType_None,
  groupInviteSent = false,
  guildInviteSent = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SelectionItem)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function SelectionItem:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiCheckboxNotificationBus, self.SelectionCheckbox)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvitedSpinner, false)
end
function SelectionItem:SetPlayerName(playerName)
  self.playerName = playerName
  UiTextBus.Event.SetTextWithFlags(self.PlayerNameLabel, self.playerName, eUiTextSet_SetLocalized)
  self.PlayerIcon:StartSpinner()
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      self.playerId = result[1].playerId
      self.PlayerIcon:SetPlayerId(self.playerId)
      self.PlayerIcon:RequestPlayerIconData()
      SocialDataHandler:GetRemotePlayerFaction_ServerCall(self, function(self, result)
        if 0 < #result then
          self.playerFaction = result[1].playerFaction
        end
        self:SetPlayerFaction()
      end, function(self)
        Log("ERR - SelectionItem:SetPlayerName: Failed to set player faction")
      end, self.playerId:GetCharacterIdString())
      SocialDataHandler:GetRemotePlayerGuildId_ServerCall(self, function(self, result)
        if 0 < #result then
          self.guildId = result[1].playerGuildId
        end
        self:UpdateStatus()
      end, nil, self.playerId:GetCharacterIdString())
    end
  end, function(self)
    Log("ERR - SelectionItem:SetPlayerName: Failed to get playerId")
  end, playerName)
end
function SelectionItem:GetPlayerName()
  return self.playerName or ""
end
function SelectionItem:GetPlayerFaction()
  return self.playerFaction or eFactionType_None
end
function SelectionItem:GetCharacterIdString()
  local characterIdString = ""
  if self.playerId then
    characterIdString = self.playerId:GetCharacterIdString()
  end
  return characterIdString
end
function SelectionItem:SetPlayerFaction()
  local faction = self:GetPlayerFaction()
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, faction ~= eFactionType_None)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIconTextDivider, faction ~= eFactionType_None)
  UiTextBus.Event.SetText(self.Properties.FactionText, "")
  local twitchNamePosition = faction ~= eFactionType_None and 16 or -16
  UiTransformBus.Event.SetLocalPositionX(self.Properties.TwitchNameLabel, twitchNamePosition)
  if faction ~= eFactionType_None then
    local factionIcon = FactionCommon.factionInfoTable[faction].crestFgSmall
    local factionName = FactionCommon.factionInfoTable[faction].factionName
    local factionColor = FactionCommon.factionInfoTable[faction].crestBgColor
    UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, factionIcon)
    UiImageBus.Event.SetColor(self.Properties.FactionIcon, factionColor)
    UiTextBus.Event.SetTextWithFlags(self.Properties.FactionText, factionName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.FactionText, factionColor)
  end
end
function SelectionItem:SetTwitchName(twitchName)
  self.twitchName = twitchName
  UiTextBus.Event.SetTextWithFlags(self.TwitchNameLabel, self.twitchName, eUiTextSet_SetAsIs)
end
function SelectionItem:SetInviteStatus(inviteStatus)
  self.inviteStatus = inviteStatus
  self:UpdateStatus()
end
function SelectionItem:UpdateStatus()
  if not self.playerId then
    return
  end
  local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  self.inCompany = playerGuildId and playerGuildId:IsValid() and self.guildId and playerGuildId == self.guildId
  self.inGroup = LocalGroupRequestBus.Broadcast.IsGroupMate(self.playerId:GetCharacterIdString())
  local statusText
  if self.inviteStatus == eSubArmyInviteStatus_Accepted then
    if self.guildInviteSent and self.inCompany and self.groupInviteSent and self.inGroup then
      self:StopSpinner()
      statusText = "@ui_subarmy_joined_company_and_group"
    elseif self.guildInviteSent and self.inCompany and not self.groupInviteSent then
      self:StopSpinner()
      statusText = "@ui_subarmy_joined_company"
    elseif self.groupInviteSent and self.inGroup and not self.guildInviteSent then
      self:StopSpinner()
      statusText = "@ui_subarmy_joined_group"
    else
      self:StartSpinner()
      statusText = "@ui_subarmy_invite_sent"
    end
  else
    self:StopSpinner()
    if self.inGroup and self.inCompany then
      statusText = "@ui_subarmy_same_company_and_group"
    elseif self.inCompany then
      statusText = "@ui_subarmy_same_company"
    elseif self.inGroup then
      statusText = "@ui_subarmy_same_group"
    end
  end
  if statusText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, statusText, eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.StatusText, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.StatusText, false)
  end
end
function SelectionItem:StartSpinner()
  if not UiElementBus.Event.IsEnabled(self.Properties.InvitedSpinner) then
    UiElementBus.Event.SetIsEnabled(self.Properties.InvitedSpinner, true)
    self.ScriptedEntityTweener:Set(self.Properties.InvitedSpinner, {rotation = 0})
    self.ScriptedEntityTweener:Play(self.Properties.InvitedSpinner, 2, {timesToPlay = -1, rotation = 359})
  end
end
function SelectionItem:StopSpinner()
  self.ScriptedEntityTweener:Stop(self.Properties.InvitedSpinner)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvitedSpinner, false)
end
function SelectionItem:GetTwitchName()
  return self.twitchName or ""
end
function SelectionItem:SetCallback(context, callback)
  self.context = context
  self.callback = callback
end
function SelectionItem:IsSelected()
  return UiCheckboxBus.Event.GetState(self.SelectionCheckbox)
end
function SelectionItem:OnCheckboxStateChange(checked)
  if self.context and self.callback then
    self.callback(self.context, self, checked)
  end
end
function SelectionItem:OnHover()
  self.ScriptedEntityTweener:Play(self.Highlight, 0.2, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.IconSelected, 0.2, {
    opacity = 0,
    scaleX = 1.25,
    scaleY = 1.25
  }, {
    opacity = 1,
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.PlayerNameLabel, 0.2, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.FactionText, 0.2, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.FactionIcon, 0.2, {opacity = 1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Item_Hover)
end
function SelectionItem:OnUnhover()
  self.ScriptedEntityTweener:Play(self.Highlight, 0.15, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.IconSelected, 0.15, {opacity = 1}, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.PlayerNameLabel, 0.15, {opacity = 0.6, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.FactionText, 0.15, {opacity = 0.6, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.FactionIcon, 0.15, {opacity = 0.6, ease = "QuadIn"})
end
return SelectionItem
