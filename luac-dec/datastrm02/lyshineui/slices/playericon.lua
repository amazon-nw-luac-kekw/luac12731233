local PlayerIcon = {
  Properties = {
    BackgroundCover = {
      default = EntityId()
    },
    BackgroundLayer = {
      default = EntityId()
    },
    MidgroundLayer = {
      default = EntityId()
    },
    ForegroundLayer = {
      default = EntityId()
    },
    AnimationSpinner = {
      default = EntityId()
    },
    LoadingCover = {
      default = EntityId()
    },
    LocalPlayerColor = {
      default = Color(1, 0.5, 0)
    },
    DefaultPlayerColor = {
      default = Color(1, 0.5, 0)
    },
    Selected = {
      default = EntityId()
    },
    ListSelect = {
      default = EntityId()
    }
  },
  isSpectatable = false,
  flyoutEnabled = true,
  socialComponentReady = false,
  darkenerOpacity = 0.5,
  isUsingDarkener = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PlayerIcon)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local PlayerFlyoutHandler = RequireScript("LyShineUI.FlyoutMenu.PlayerFlyoutHandler")
PlayerFlyoutHandler:AttachPlayerFlyoutHandler(PlayerIcon)
function PlayerIcon:OnInit()
  BaseElement.OnInit(self)
  self:InitPlayerFlyoutHandler(true)
  self.ScriptedEntityTweener:Set(self.Properties.AnimationSpinner, {rotation = 0, opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.LoadingCover, {opacity = 0})
  self:PFH_SetPlayerIconDataCallbacks(self, self.OnPlayerIconDataReceived, self.OnPlayerIconDataFailed)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.JavSocialComponentBus.IsReady", function(self, isReady)
    self.socialComponentReady = isReady
    self:PFH_SocialComponentBusIsReady(isReady)
    if not isReady then
      return
    end
    if not self.playerFaction and self.playerId then
      self:StartSpinner()
      self:GetPlayerFaction(self.playerId)
    end
  end)
end
function PlayerIcon:OnShutdown()
end
function PlayerIcon:StartSpinner()
  if not self.isSpinning then
    self.ScriptedEntityTweener:Set(self.Properties.LoadingCover, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.AnimationSpinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
    self.isSpinning = true
  end
end
function PlayerIcon:StopSpinner()
  if self.isSpinning then
    self.ScriptedEntityTweener:Set(self.Properties.LoadingCover, {
      opacity = self.isUsingDarkener and self.darkenerOpacity or 0
    })
    self.ScriptedEntityTweener:Stop(self.Properties.AnimationSpinner)
    self.ScriptedEntityTweener:Set(self.Properties.AnimationSpinner, {rotation = 0, opacity = 0})
    self.isSpinning = false
  end
end
function PlayerIcon:SetPlayerFactionOverride(faction)
  self:PFH_SetPlayerFaction(faction)
  self.playerFaction = faction
  local playerIconBg = self.UIStyle.COLOR_GRAY_70
  if self.PFH.playerFaction and FactionCommon.factionInfoTable[self.PFH.playerFaction] then
    playerIconBg = FactionCommon.factionInfoTable[self.PFH.playerFaction].crestBgColor
  end
  UiImageBus.Event.SetColor(self.Properties.BackgroundCover, playerIconBg)
end
function PlayerIcon:SetPlayerLevelOverride(level)
  self:PFH_SetPlayerLevel(level)
end
function PlayerIcon:SetPlayerIcon(playerIcon)
  self.playerIconOverride = playerIcon:Clone()
  self:PFH_SetPlayerIcon(playerIcon)
  self.playerIcon = self.playerIconOverride
  self:SetIcon()
end
function PlayerIcon:RequestPlayerIconData()
  self:PFH_SetPlayerIconDataCallbacks(self, self.OnPlayerIconDataReceived, self.OnPlayerIconDataFailed)
  local ready = self:PFH_RequestPlayerIconData()
  if not ready then
    self:StartSpinner()
  else
    self:StopSpinner()
  end
end
function PlayerIcon:SetPlayerId(playerId)
  if not playerId or not playerId.playerName then
    Debug.Log("[PlayerIcon:SetData] Failed to set player icon due to invalid playerId")
    return
  end
  self.playerId = playerId
  self.flyoutEnabled = true
  if self.playerIconOverride then
    self.playerIcon = self.playerIconOverride
    self:SetIcon()
  end
  self:PFH_SetPlayerIconDataCallbacks(self, self.OnPlayerIconDataReceived, self.OnPlayerIconDataFailed)
  self:PFH_SetPlayerId(playerId)
end
function PlayerIcon:OnPlayerIconDataReceived()
  self.playerIcon = self:PFH_GetPlayerIcon()
  self:SetIcon()
end
function PlayerIcon:OnPlayerIconDataFailed()
  self:StopSpinner()
end
function PlayerIcon:GetPlayerFaction(playerId)
  SocialDataHandler:GetRemotePlayerFaction_ServerCall(self, function(self, result)
    if 0 < #result then
      self.playerFaction = result[1].playerFaction
      local playerIconBg = self.playerFaction and FactionCommon.factionInfoTable[self.playerFaction].crestBgColor or self.UIStyle.COLOR_GRAY_70
      UiImageBus.Event.SetColor(self.Properties.BackgroundCover, playerIconBg)
      self:StopSpinner()
    else
      Log("ERR PlayerIcon.lua - Could not retrieve faction info from playerId")
      self:StopSpinner()
      return
    end
  end, function()
    Log("ERR PlayerIcon.lua - Could not retrieve faction info from playerId")
    self:StopSpinner()
  end, playerId:GetCharacterIdString())
end
function PlayerIcon:SetIcon()
  UiElementBus.Event.SetIsEnabled(self.Properties.BackgroundLayer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.MidgroundLayer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.BackgroundCover, true)
  UiImageBus.Event.SetSpritePathname(self.Properties.BackgroundLayer, self.playerIcon.backgroundImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.MidgroundLayer, self.playerIcon.midgroundImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.ForegroundLayer, self.playerIcon.foregroundImagePath)
  if self.playerId then
    if self.socialComponentReady then
      self:StartSpinner()
      self:GetPlayerFaction(self.playerId)
    else
      self.playerFaction = nil
    end
  else
    self:StopSpinner()
  end
  self.iconLoaded = true
end
function PlayerIcon:SetSimpleIcon(iconPath)
  UiElementBus.Event.SetIsEnabled(self.Properties.BackgroundLayer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MidgroundLayer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BackgroundCover, false)
  UiImageBus.Event.SetSpritePathname(self.Properties.ForegroundLayer, iconPath)
  self.iconLoaded = true
end
function PlayerIcon:SetIsStreaming(isStreaming)
  self.isStreaming = isStreaming or false
end
function PlayerIcon:SetFlyoutEnabled(enabled)
  self.flyoutEnabled = enabled
end
function PlayerIcon:HoverEnd()
  self.ScriptedEntityTweener:Play(self.Properties.Selected, 0.1, {opacity = 0})
  if self.ListSelect then
    self.ScriptedEntityTweener:Play(self.Properties.ListSelect, 0.1, {opacity = 0})
  end
end
function PlayerIcon:SetRefreshDataOnFlyout(refreshOnFlyout)
  self.refreshOnFlyout = refreshOnFlyout
end
function PlayerIcon:SetDarkener(shouldDarken)
  self.isUsingDarkener = shouldDarken
  if shouldDarken then
    self.ScriptedEntityTweener:Set(self.Properties.LoadingCover, {
      opacity = self.darkenerOpacity
    })
  else
    self.ScriptedEntityTweener:Set(self.Properties.LoadingCover, {opacity = 0})
  end
end
function PlayerIcon:OpenFlyoutMenu(entityId, actionName)
  if not self.playerId or not self.flyoutEnabled then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.Selected, 0.1, {opacity = 1})
  if self.ListSelect then
    self.ScriptedEntityTweener:Play(self.Properties.ListSelect, 0.1, {opacity = 1})
  end
  if self.refreshOnFlyout then
    self:PFH_ShowFlyoutForPlayerId(self.playerId, entityId, true)
  else
    self:PFH_ShowFlyout(entityId)
  end
end
return PlayerIcon
