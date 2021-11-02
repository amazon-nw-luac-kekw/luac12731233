local ChangeFaction = {
  Properties = {
    CancelButton = {
      default = EntityId()
    },
    ChangeButton = {
      default = EntityId()
    },
    FactionSelection1 = {
      default = EntityId()
    },
    FactionSelection2 = {
      default = EntityId()
    },
    CurrentFactionText = {
      default = EntityId()
    }
  },
  factionChangeConfirmationId = "factionChangeConfirmationId"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ChangeFaction)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function ChangeFaction:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, faction)
    if faction and faction ~= eFactionType_None then
      self.faction = faction
      local factionIndex = 1
      for i = eFactionType_Faction1, eFactionType_Faction3 do
        if self.faction ~= i then
          self["FactionSelection" .. factionIndex]:SetupFactionOption(i, self.OnFactionSelected, self)
          factionIndex = factionIndex + 1
        end
      end
    end
  end)
  self.CancelButton:SetCallback(self.OnCancelPressed, self)
  self.CancelButton:SetText("@ui_cancel")
  self.ChangeButton:SetCallback(self.OnChangePressed, self)
  self.ChangeButton:SetEnabled(false)
  UiTextBus.Event.SetIsMarkupEnabled(self.ChangeButton.Properties.ButtonText, true)
end
function ChangeFaction:OnCancelPressed()
  LyShineManagerBus.Broadcast.ExitState(1913028995)
  self.FactionSelection1:ClearSelected()
  self.FactionSelection2:ClearSelected()
end
function ChangeFaction:OnFactionSelected(factionId)
  self.factionId = factionId
  if FactionRequestBus.Event.CanSetFactionWithResults(self.playerEntityId, self.factionId) == eCanSetFactionResults_Success then
    self.ChangeButton:SetEnabled(true, 0)
    self.ChangeButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE)
  end
  if self.FactionSelection1.factionId == factionId then
    self.FactionSelection2:ClearSelected()
  else
    self.FactionSelection1:ClearSelected()
  end
end
function ChangeFaction:OnChangePressed()
  PopupWrapper:RequestPopupWithParams({
    title = "@ui_change_faction",
    message = GetLocalizedReplacementText("@ui_change_faction_desc", {
      FactionCommon.factionInfoTable[self.factionId].factionName
    }),
    eventId = self.factionChangeConfirmationId,
    callerSelf = self,
    callback = function(self, result, eventId)
      if eventId == self.factionChangeConfirmationId and result == ePopupResult_Yes then
        FactionRequestBus.Event.RequestSetFaction(self.playerEntityId, self.factionId)
        LyShineManagerBus.Broadcast.ExitState(1913028995)
      end
    end,
    buttonsYesNo = true,
    yesButtonText = "@ui_yes",
    noButtonText = "@ui_no"
  })
end
function ChangeFaction:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.FactionSelection1:ClearSelected()
  self.FactionSelection2:ClearSelected()
  self.factionId = nil
  self.ChangeButton:SetEnabled(false, 0)
  self.FactionSelection1:SetDisabled(FactionRequestBus.Event.CanSetFactionWithResults(self.playerEntityId, self.FactionSelection1.factionId))
  self.FactionSelection2:SetDisabled(FactionRequestBus.Event.CanSetFactionWithResults(self.playerEntityId, self.FactionSelection2.factionId))
  local azoth = FactionRequestBus.Event.GetFactionChangeAzothCost(self.playerEntityId)
  local azothString = 0 < azoth and GetLocalizedReplacementText("@ui_change_faction_azoth", {azoth}) or ""
  self.ChangeButton:SetText(GetLocalizedReplacementText("@ui_change_faction_azoth_cost", {azothString}))
  local curAzoth = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
  if azoth > curAzoth then
    self.ChangeButton:SetTooltip("@ui_weapon_mastery_insufficient_azoth")
  else
    self.ChangeButton:SetTooltip("")
  end
  UiTextBus.Event.SetText(self.Properties.CurrentFactionText, GetLocalizedReplacementText("@ui_current_faction", {
    FactionCommon.factionInfoTable[self.faction].factionName
  }))
end
function ChangeFaction:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
return ChangeFaction
