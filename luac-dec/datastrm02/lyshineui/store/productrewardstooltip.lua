local ProductRewardsTooltip = {
  Properties = {
    Title = {
      default = EntityId()
    },
    FilterText = {
      default = EntityId()
    },
    RewardsList = {
      default = EntityId()
    },
    RewardPrototype = {
      default = EntityId()
    },
    ScrollBoxDividerTop = {
      default = EntityId()
    },
    ScrollBoxDividerBottom = {
      default = EntityId()
    }
  },
  MAX_VISIBLE_REWARDS = 6
}
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ProductRewardsTooltip)
function ProductRewardsTooltip:OnInit()
  BaseElement.OnInit(self)
  self.RewardsList:Initialize(self.RewardPrototype)
  self.RewardsList:OnListDataSet(nil)
end
function ProductRewardsTooltip:SetProductData(storeProductData, filter)
  local rewards = EntitlementsDataHandler:GetRewardsForOffer(storeProductData.offer)
  self.rewards = {}
  local includedItems = 0
  for i, reward in ipairs(rewards) do
    table.insert(self.rewards, {
      originalIdx = i,
      rewardInfo = reward,
      isSelected = filter ~= nil and reward.searchText:find(filter) ~= nil
    })
    if self.rewards[#self.rewards].isSelected then
      includedItems = includedItems + 1
    end
  end
  table.sort(self.rewards, function(a, b)
    if a.isSelected and not b.isSelected then
      return true
    elseif b.isSelected and not a.isSelected then
      return false
    end
    return a.originalIdx < b.originalIdx
  end)
  local total = #self.rewards
  local filterText = ""
  local locText = 0 < includedItems and "@ui_reward_filtered_info" or "@ui_reward_package_info"
  filterText = GetLocalizedReplacementText(locText, {
    total = total,
    included = includedItems,
    filter = filter
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.FilterText, filterText, eUiTextSet_SetAsIs)
  self.RewardsList:OnListDataSet(self.rewards)
end
function ProductRewardsTooltip:SetDividers(isVisible)
  self.ScrollBoxDividerTop:SetVisible(isVisible)
  self.ScrollBoxDividerBottom:SetVisible(isVisible)
end
return ProductRewardsTooltip
