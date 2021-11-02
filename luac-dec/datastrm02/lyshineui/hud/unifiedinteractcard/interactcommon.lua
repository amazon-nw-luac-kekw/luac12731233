local InteractCommon = {}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function InteractCommon:GetLocalPlayerComponentData()
  if not self.playerComponentData then
    self.playerComponentData = LocalPlayerComponentData()
  end
  local craftingEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.CraftingEntityId")
  if not self.playerComponentData.craftingEntityId:IsValid() or self.playerComponentData.craftingEntityId ~= craftingEntityId then
    self.playerComponentData.craftingEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.CraftingEntityId")
    self.playerComponentData.inventoryEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    self.playerComponentData.itemRepairEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ItemRepairEntityId")
    self.playerComponentData.paperdollEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
    self.playerComponentData.vitalsEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.VitalsEntityId")
    self.playerComponentData.staminaEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.StaminaEntityId")
    self.playerComponentData.interactorEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
    self.playerComponentData.socialEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.SocialEntityId")
    self.playerComponentData.currencyConversionEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.CurrencyConversionEntityId")
    self.playerComponentData.gatheringEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GatheringEntityId")
    self.playerComponentData.playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  end
  return self.playerComponentData
end
function InteractCommon:OnInteractExecute(onExecute, interactOptionsElement)
  local shouldClosePrompt = UiDataManagerBus.Broadcast.ShouldClosePromptOnInteraction(onExecute.interactOptionEntry)
  if shouldClosePrompt then
    UnifiedInteractOptionsComponentRequestsBus.Event.RemoveAllInteractOptions(interactOptionsElement)
    if onExecute.markerId and onExecute.markerId ~= "" then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Markers." .. onExecute.markerId .. ".FocusState", false)
    end
  end
  return shouldClosePrompt
end
function InteractCommon:OnOwnershipChanged(params)
  local guildData = UiGuildRequestsBus.Event.GetGuildUiData(params.playerComponentData.socialEntityId)
  return OwnershipRequestBus.Event.PlayerHasPermissions(params.boundOwnershipEntityId, params.playerComponentData.playerEntityId, guildData.guildId)
end
function InteractCommon:SetPlayerHasPermission(params)
  local unifiedInteractOptions = params.unifiedInteractOptions
  if not unifiedInteractOptions then
    UiElementBus.Event.SetIsEnabled(params.interactOptionsElement, params.playerHasPermission)
  else
    UiElementBus.Event.SetIsEnabled(params.interactOptionsElement, true)
    if params.playerHasPermission then
      if params.lastPlayerHasPermissionState == params.playerHasPermission then
        UnifiedInteractOptionsComponentRequestsBus.Event.RemoveAllInteractOptions(params.interactOptionsElement)
      end
      UnifiedInteractOptionsComponentRequestsBus.Event.PopulateInteractOptions(params.interactOptionsElement, params.playerComponentData, unifiedInteractOptions)
    else
      UnifiedInteractOptionsComponentRequestsBus.Event.RemoveAllInteractOptions(params.interactOptionsElement)
    end
  end
end
return InteractCommon
