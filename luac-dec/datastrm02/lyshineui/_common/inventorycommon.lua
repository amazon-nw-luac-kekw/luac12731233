local InventoryCommon = {MAX_REPAIR_PART_CONVERSION_TIER = 4}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function InventoryCommon:GetInventoryItemCount(itemDescriptor)
  local inventoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  if not (inventoryId and inventoryId:IsValid()) or not itemDescriptor then
    return 0
  end
  local count = ContainerRequestBus.Event.GetItemCount(inventoryId, itemDescriptor, true, true, false)
  return count or 0
end
function InventoryCommon:GetRepairPartId(tier)
  return 2817455512
end
function InventoryCommon:GetRepairPartExchangeId(tier)
  if not self.repairPartExchangeIds then
    local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    if not playerEntityId or not playerEntityId:IsValid() then
      return nil
    end
    self.repairPartExchangeIds = {}
    for i = 1, self.MAX_REPAIR_PART_CONVERSION_TIER do
      local fromRepairPartId = self:GetRepairPartId(i)
      local toRepairPartId = self:GetRepairPartId(i + 1)
      local exchangeId = CurrencyConversionRequestBus.Event.GetExchangeId(playerEntityId, fromRepairPartId, toRepairPartId)
      table.insert(self.repairPartExchangeIds, exchangeId)
    end
  end
  return self.repairPartExchangeIds[tier]
end
function InventoryCommon:GetRepairPartExchangeData(tier)
  if not self.repairPartExchangeData then
    local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    if not playerEntityId or not playerEntityId:IsValid() then
      return nil
    end
    self.repairPartExchangeData = {}
    for i = 1, self.MAX_REPAIR_PART_CONVERSION_TIER do
      local exchangeId = self:GetRepairPartExchangeId(i)
      local exchangeData = CurrencyConversionRequestBus.Event.GetCurrencyExchangeData(playerEntityId, exchangeId)
      table.insert(self.repairPartExchangeData, {
        fromCurrencyQuantity = exchangeData.fromCurrencyQuantity,
        toCurrencyQuantity = exchangeData.toCurrencyQuantity
      })
    end
  end
  return self.repairPartExchangeData[tier]
end
return InventoryCommon
