local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local OWGuildShopItemList = {
  Properties = {
    ShopItem = {
      default = EntityId()
    },
    SimpleGridItemList = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWGuildShopItemList)
function OWGuildShopItemList:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.rowTypes = {
    header = {
      name = "header",
      maxItems = 1,
      jumpable = true
    },
    rankLock = {
      name = "rankLock",
      maxItems = 1,
      jumpable = false
    },
    shopItem = {
      name = "shopItem",
      maxItems = 100,
      jumpable = false
    }
  }
  self.SimpleGridItemList:Initialize(self.ShopItem, self.rowTypes)
end
function OWGuildShopItemList:OnShutdown()
end
function OWGuildShopItemList:OnListFilterSelected(entityId, data)
end
function OWGuildShopItemList:SetAvailableItems(shopRanks, availableItems, callbackData)
  local ranksToItems = {}
  for i = 1, #shopRanks do
    if not ranksToItems[shopRanks[i].rank] then
      ranksToItems[shopRanks[i].rank] = {}
    end
  end
  for i = 1, #availableItems do
    local availableItem = availableItems[i]
    if ranksToItems[availableItem.rank] then
      table.insert(ranksToItems[availableItem.rank], availableItem)
    else
      Debug.Log("Error, item doesn't have a shop rank " .. tostring(availableItem.rank))
    end
  end
  local warDetails
  local localPlayerRaidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  if localPlayerRaidId and localPlayerRaidId:IsValid() then
    warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(localPlayerRaidId)
  end
  local isWarActive = warDetails and warDetails:IsValid() and warDetails:IsWarActive()
  local isPvP = isWarActive and warDetails:IsPvp()
  local isAttackers = false
  if isWarActive and localPlayerRaidId and localPlayerRaidId:IsValid() then
    isAttackers = warDetails:IsAttackingRaid(localPlayerRaidId)
  end
  local isInvasionActive = false
  local isOutpostRush = false
  local localPlayerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  if localPlayerEntityId ~= nil then
    isOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(localPlayerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  end
  self.listData = {}
  if isWarActive or isOutpostRush then
    table.insert(self.listData, {
      rowType = self.rowTypes.header,
      rankData = nil,
      onShowCallback = callbackData,
      isSiegeArmory = isWarActive,
      isOutpostRush = isOutpostRush
    })
  end
  for i = 1, #shopRanks do
    local items = ranksToItems[shopRanks[i].rank]
    if not isWarActive and not isOutpostRush then
      table.insert(self.listData, {
        rowType = self.rowTypes.header,
        rankData = shopRanks[i],
        onShowCallback = callbackData,
        isSiegeArmory = false
      })
    end
    for j = 1, #items do
      local insertItem = true
      if (items[j].itemDescriptor:HasItemClass(eItemClass_SiegeWarOnly) or items[j].itemDescriptor:HasItemClass(eItemClass_SiegeWarAttackersOnly) or items[j].itemDescriptor:HasItemClass(eItemClass_SiegeWarDefendersOnly)) and (not isWarActive or isAttackers and items[j].itemDescriptor:HasItemClass(eItemClass_SiegeWarDefendersOnly) or not isAttackers and items[j].itemDescriptor:HasItemClass(eItemClass_SiegeWarAttackersOnly)) then
        insertItem = false
      end
      if items[j].itemDescriptor:HasItemClass(eItemClass_InvasionOnly) and not isInvasionActive then
        insertItem = false
      end
      if items[j].itemDescriptor:HasItemClass(eItemClass_PvPOnly) and not isPvP then
        insertItem = false
      end
      if items[j].itemDescriptor:HasItemClass(eItemClass_OutpostRushOnly) and not isOutpostRush then
        insertItem = false
      end
      if insertItem then
        table.insert(self.listData, {
          rowType = self.rowTypes.shopItem,
          itemData = items[j],
          isSiegeArmory = isWarActive,
          isOutpostRush = isOutpostRush
        })
      end
    end
  end
  self.SimpleGridItemList:OnListDataSet(self.listData)
end
function OWGuildShopItemList:GoToHeader(shopRank)
  for i = 1, #self.SimpleGridItemList.listData do
    local rankData = self.SimpleGridItemList.listData[i][1].rankData
    if rankData and rankData.rank == shopRank then
      self.SimpleGridItemList:JumpToItem(i)
      return
    end
  end
end
function OWGuildShopItemList:GetTopHeaderData()
  local topHeaderData = self.SimpleGridItemList:GetTopHeaderData()
  if topHeaderData then
    return topHeaderData.rankData
  end
end
function OWGuildShopItemList:RequestRefreshContent()
  self.SimpleGridItemList:RequestRefreshContent()
end
return OWGuildShopItemList
