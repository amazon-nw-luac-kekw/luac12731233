local AbilitySelection = {
  Properties = {
    SimpleGridItemList = {
      default = EntityId()
    },
    AbilityDisplayButtonPrototype = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AbilitySelection)
function AbilitySelection:OnInit()
  self.SimpleGridItemList:Initialize(self.AbilityDisplayButtonPrototype)
  self.SimpleGridItemList:OnListDataSet(nil)
  self.SimpleGridItemList:SetHeaderText("@ui_select_ability")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    self.rootEntityId = rootEntityId
  end)
end
function AbilitySelection:SetAbilitySource(itemSlot, abilityIndex, abilityTableId)
  local itemDataList = {}
  local activeAbilities
  if itemSlot then
    activeAbilities = CharacterAbilityRequestBus.Event.GetAvailableAbilitiesDataByItemSlot(self.rootEntityId, itemSlot)
    self.abilityTableCrc = CharacterAbilityRequestBus.Event.GetAbilityTableFromItemSlot(self.rootEntityId, itemSlot)
  elseif abilityTableId then
    activeAbilities = CharacterAbilityRequestBus.Event.GetAvailableAbilityDataByAbilityTableId(self.rootEntityId, abilityTableId)
    self.abilityTableCrc = abilityTableId
  else
    return
  end
  for i = 1, #activeAbilities do
    local activeAbility = activeAbilities[i]
    if activeAbility then
      local abilityId = activeAbility.id
      local spentPointsOnAbility = CharacterAbilityRequestBus.Event.GetSpentPointsOnAbility(self.rootEntityId, abilityId)
      local isAbilityUnlocked = 0 < spentPointsOnAbility
      local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
      local cooldownTime = CharacterAbilityRequestBus.Event.GetTotalCooldownTime(rootEntityId, abilityId)
      table.insert(itemDataList, {
        displayName = activeAbility.displayName,
        displayIcon = activeAbility.displayIcon,
        uiCategory = activeAbility.uiCategory,
        displayDescription = activeAbility.displayDescription,
        cooldownTime = string.format("%.1f", cooldownTime),
        isAbilityUnlocked = isAbilityUnlocked,
        callbackSelf = self,
        onClickCallback = self.OnSelectAbility,
        abilityId = abilityId
      })
    end
  end
  self.SimpleGridItemList:OnListDataSet(itemDataList)
  self.abilityIndex = abilityIndex
  self:SetVisibility(true)
end
function AbilitySelection:SetVisibility(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
function AbilitySelection:SetSelectionCallback(callbackTable, callbackFunc)
  self.callbackTable = callbackTable
  self.callbackFunc = callbackFunc
end
function AbilitySelection:OnSelectAbility(itemData)
  local abilityId = itemData.abilityId
  if itemData.isAbilityUnlocked then
    if CooldownTimersComponentBus.Event.AnyCooldownTimer(self.rootEntityId) then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_ability_cooldown_error"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    else
      local selectedTableIndex = CharacterAbilityRequestBus.Event.GetSelectedTableIndexFromTableName(self.rootEntityId, self.abilityTableCrc)
      CharacterAbilityRequestBus.Event.RequestChangeMappedAbility(self.rootEntityId, selectedTableIndex, self.abilityIndex, abilityId)
      if self.callbackFunc then
        self.callbackFunc(self.callbackTable, abilityId, self.abilityIndex)
      end
    end
  else
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_ability_locked_error"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self:SetVisibility(false)
end
function AbilitySelection:OnClickOut()
  self:SetVisibility(false)
end
return AbilitySelection
