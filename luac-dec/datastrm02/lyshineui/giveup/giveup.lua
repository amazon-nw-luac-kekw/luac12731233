local GiveUp = {
  Properties = {
    Header = {
      default = EntityId()
    },
    RespawnPrompt = {
      default = EntityId()
    },
    RevivePrompt = {
      default = EntityId()
    },
    ReviveHint = {
      default = EntityId()
    },
    AbilityPrompt = {
      default = EntityId()
    },
    AbilityHint = {
      default = EntityId()
    },
    DeathsDoorContainer = {
      default = EntityId()
    },
    Scrim = {
      default = EntityId()
    },
    Meter = {
      default = EntityId()
    },
    MeterIcon = {
      default = EntityId()
    },
    MeterBg = {
      default = EntityId()
    },
    MeterFill = {
      default = EntityId()
    },
    DungeonReviveHeader = {
      default = EntityId()
    },
    DungeonReviveCount = {
      default = EntityId()
    },
    RespawnTimerHolder = {
      default = EntityId()
    },
    RespawnTimerPrimaryTitle = {
      default = EntityId()
    },
    RespawnTimer = {
      default = EntityId()
    }
  },
  dataLayer_stateId = "State",
  isEnabled = false,
  bleedOutTime = 7,
  DuelState_Finished = 2489790695,
  fillAtFull = 0.71
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(GiveUp)
local objectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function GiveUp:OnInit()
  BaseScreen.OnInit(self)
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, vitalsId)
    if vitalsId then
      self:BusDisconnect(self.vitalsNotificationHandler)
      self.vitalsNotificationHandler = self:BusConnect(VitalsComponentNotificationBus, vitalsId)
      self.vitalsId = vitalsId
      local isInDeathsDoor = VitalsComponentRequestBus.Event.IsDeathsDoor(vitalsId)
      if isInDeathsDoor then
        self:OnDeathsDoorChanged(isInDeathsDoor, VitalsComponentRequestBus.Event.GetRemainingDeathsDoorTime(vitalsId))
      end
    end
  end)
  self.ReviveHint:SetActionMap("player")
  self.ReviveHint:SetKeybindMapping("give_up")
  self.AbilityHint:SetActionMap("player")
  self.AbilityHint:SetKeybindMapping("attack_primary")
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnTimerHolder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DungeonReviveHeader, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DungeonReviveCount, false)
  self.revivePromptYPos = UiTransformBus.Event.GetLocalPositionY(self.Properties.RevivePrompt)
  self.abilityPromptYPos = UiTransformBus.Event.GetLocalPositionY(self.Properties.AbilityPrompt)
  local respawnPrimaryTitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_TAN,
    characterSpacing = 100
  }
  local respawnTimerStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 88,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.RespawnTimerPrimaryTitle, respawnPrimaryTitleStyle)
  SetTextStyle(self.RespawnTimer, respawnTimerStyle)
  UiTextBus.Event.SetTextWithFlags(self.RespawnTimerPrimaryTitle, "@ui_respawn_available_in", eUiTextSet_SetLocalized)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead == false then
      self:OnRespawn()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsInfiniteDeathsDoor", function(self, isInfiniteDeathsDeoor)
    if self.isEnabled then
      self:SetDisplayElements()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.DeathDoorCount", function(self, deathDoorCount)
    if deathDoorCount then
      self.remainingRevives = deathDoorCount
      UiTextBus.Event.SetText(self.Properties.DungeonReviveCount, self.remainingRevives + 1)
    end
  end)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RevivePrompt, "@ui_giveup", eUiTextSet_SetLocalized)
end
function GiveUp:OnShutdown()
  self:SetIsTicking(false)
  self.timeToRespawn = nil
end
function GiveUp:OnDeathsDoorChanged(isInDeathsDoor, timeRemaining, deathsDoorCooldownRemaining)
  local localPlayerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local localPlayerGameModeEntityId = GameModeParticipantComponentRequestBus.Event.GetGameModeEntityId(localPlayerRootEntityId, 2612307810)
  if localPlayerGameModeEntityId:IsValid() then
    local entityTeamId = GameModeComponentRequestBus.Event.GetParticipantTeamIdx(localPlayerGameModeEntityId, localPlayerRootEntityId)
    self.isInSoloDuel = GameModeComponentRequestBus.Event.GetNumParticipantsByTeam(localPlayerGameModeEntityId, entityTeamId) == 1
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(localPlayerGameModeEntityId, self.dataLayer_stateId), function(self, stateCrc)
    if stateCrc == self.DuelState_Finished then
      self:FadeoutGiveUp()
    end
  end)
  local dungeonGameModeId = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(localPlayerRootEntityId)
  self.isInDungeon = dungeonGameModeId ~= 0
  self.isEnabled = isInDeathsDoor
  if self.isEnabled and not self.isInSoloDuel then
    local isAtWar = WarDataClientRequestBus.Broadcast.IsInSiegeWarfare()
    if isAtWar then
      self.timeToRespawn = nil
      self:SetIsTicking(true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.RespawnTimerHolder, false)
    end
    local hasAbility = 0 < CharacterAbilityRequestBus.Event.GetSpentPointsOnAbility(self.vitalsId, 273312652)
    if hasAbility then
      local wieldingMusket = false
      local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
      local activeWeaponSlotId = PaperdollRequestBus.Event.GetActiveSlot(paperdollId, ePaperdollSlotAlias_ActiveWeapon)
      local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, activeWeaponSlotId)
      if slot then
        local itemData = ItemDataManagerBus.Broadcast.GetItemData(slot:GetItemId())
        if itemData.group == "Muskets" then
          wieldingMusket = true
        end
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.AbilityPrompt, wieldingMusket)
      self.showAbilityPrompt = wieldingMusket
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.AbilityPrompt, false)
      self.showAbilityPrompt = false
    end
    self:FadeinGiveUp()
  else
    self:FadeoutGiveUp()
    self.isInSoloDuel = nil
  end
end
function GiveUp:OnDeath()
  if self.isEnabled then
    self:FadeoutGiveUp()
    self.isEnabled = false
  end
end
function GiveUp:OnRespawn()
  if self.isEnabled then
    self:FadeoutGiveUp()
    self.isEnabled = false
  end
end
function GiveUp:FadeinGiveUp()
  self:SetDisplayElements()
  LyShineDataLayerBus.Broadcast.SetData("Hud.GiveUp.IsVisible", true)
end
function GiveUp:FadeoutGiveUp()
  self.ScriptedEntityTweener:Play(self.DeathsDoorContainer, 0.34, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Scrim, 0.36, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      self.ScriptedEntityTweener:Stop(self.MeterFill)
      UiCanvasBus.Event.SetEnabled(self.canvasId, false)
      LyShineDataLayerBus.Broadcast.SetData("Hud.GiveUp.IsVisible", false)
    end
  })
  self:SetIsTicking(false)
  self.timeToRespawn = nil
end
function GiveUp:SetIsTicking(isEnabled)
  if isEnabled then
    if self.tickBusHandler == nil then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  elseif self.tickBusHandler ~= nil then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function GiveUp:OnTick(deltaTime, timePoint)
  if self.timeToRespawn == nil then
    local timeToRespawn = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.WaveRespawnTimeRemaining")
    if timeToRespawn ~= nil and 0 <= timeToRespawn then
      UiElementBus.Event.SetIsEnabled(self.Properties.RespawnTimerHolder, true)
      self.timeToRespawn = timeToRespawn
      local curtime = math.ceil(self.timeToRespawn)
      UiTextBus.Event.SetText(self.RespawnTimer, string.format("%02.f", curtime))
    end
  end
  if self.timeToRespawn ~= nil and self.timeToRespawn >= 0 then
    local prevtime = math.ceil(self.timeToRespawn)
    self.timeToRespawn = self.timeToRespawn - deltaTime
    local curtime = math.ceil(self.timeToRespawn)
    if prevtime ~= curtime then
      UiTextBus.Event.SetText(self.RespawnTimer, string.format("%02.f", curtime))
      if self.timeToRespawn < 0 then
        self:SetIsTicking(false)
        self.timeToRespawn = nil
      end
    end
  end
end
function GiveUp:SetDisplayElements()
  SetTextStyle(self.Properties.Header, self.UIStyle.FONT_STYLE_DEATHS_DOOR_HEADER)
  SetTextStyle(self.Properties.RespawnPrompt, self.UIStyle.FONT_STYLE_DEATHS_DOOR_RESPAWN)
  SetTextStyle(self.Properties.RevivePrompt, self.UIStyle.FONT_STYLE_DEATHS_DOOR_REVIVE)
  SetTextStyle(self.Properties.DungeonReviveHeader, self.UIStyle.FONT_STYLE_DEATHS_DOOR_DUNGEON_HEADER)
  SetTextStyle(self.Properties.DungeonReviveCount, self.UIStyle.FONT_STYLE_DEATHS_DOOR_DUNGEON_COUNT)
  local animDelay = 0.6
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.DeathsDoorContainer, 0.2, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Scrim, 0.5, {opacity = 0}, tweenerCommon.opacityTo40)
  self.ScriptedEntityTweener:Play(self.Header, 1, {
    opacity = 0,
    textCharacterSpace = self.UIStyle.FONT_STYLE_DEATHS_DOOR_HEADER.characterSpacing * 2
  }, {
    opacity = 1,
    textCharacterSpace = self.UIStyle.FONT_STYLE_DEATHS_DOOR_HEADER.characterSpacing,
    ease = "QuadOut",
    delay = 0.4
  })
  self.ScriptedEntityTweener:PlayFromC(self.Properties.RespawnPrompt, 0.6, {opacity = 0}, tweenerCommon.fadeInQuadOut, animDelay + 0.5)
  if not self.isInDungeon then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.RevivePrompt, self.revivePromptYPos)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.AbilityPrompt, self.abilityPromptYPos)
    UiElementBus.Event.SetIsEnabled(self.Properties.DungeonReviveHeader, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.DungeonReviveCount, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.DungeonReviveHeader, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DungeonReviveCount, true)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.DungeonReviveHeader, 0.6, {opacity = 0}, tweenerCommon.fadeInQuadOut, animDelay + 0.8)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.DungeonReviveCount, 0.6, {opacity = 0}, tweenerCommon.fadeInQuadOut, animDelay + 0.8)
    local offsetPositionY = 115
    UiTransformBus.Event.SetLocalPositionY(self.Properties.RevivePrompt, self.revivePromptYPos + offsetPositionY)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.AbilityPrompt, self.abilityPromptYPos + offsetPositionY)
  end
  self.ScriptedEntityTweener:PlayFromC(self.Properties.RevivePrompt, 0.6, {opacity = 0}, tweenerCommon.fadeInQuadOut, animDelay + 0.8)
  if self.showAbilityPrompt then
    SetTextStyle(self.Properties.AbilityPrompt, self.UIStyle.FONT_STYLE_DEATHS_DOOR_REVIVE)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.AbilityPrompt, 0.6, {opacity = 0}, tweenerCommon.fadeInQuadOut, animDelay + 0.8)
  end
  local isInfiniteDeathsDoor = false
  if self.vitalsId then
    isInfiniteDeathsDoor = VitalsComponentRequestBus.Event.IsInfiniteDeathsDoor(self.vitalsId)
  end
  local headerText, respawnText
  if isInfiniteDeathsDoor then
    headerText = "@ui_giveup_arena_header"
    respawnText = "@ui_giveup_arena_desc"
    self.ScriptedEntityTweener:Stop(self.MeterFill)
    self.ScriptedEntityTweener:Set(self.MeterFill, {imgFill = 1})
  else
    headerText = "@ui_giveup_deaths_door_header"
    respawnText = "@ui_giveup_wait_for_revive"
    self.bleedOutTime = VitalsComponentRequestBus.Event.GetRemainingDeathsDoorTime(self.vitalsId) / 1000
    self.ScriptedEntityTweener:Play(self.MeterFill, self.bleedOutTime, {
      imgFill = self.fillAtFull
    }, {imgFill = 0, ease = "Linear"})
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Header, headerText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RespawnPrompt, respawnText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.RevivePrompt, not isInfiniteDeathsDoor)
end
function GiveUp:GetGameModeDataPath(gameModeEntityId, valueName)
  return "GameMode." .. tostring(gameModeEntityId) .. "." .. valueName
end
return GiveUp
