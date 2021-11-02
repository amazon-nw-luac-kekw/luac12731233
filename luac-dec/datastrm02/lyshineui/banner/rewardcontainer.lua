local RewardContainer = {
  Properties = {
    Rewards = {
      default = {
        EntityId()
      }
    },
    RewardLabel = {
      default = EntityId()
    },
    RewardsPositioner = {
      default = EntityId()
    },
    RewardItem = {
      default = EntityId()
    },
    RewardItemText = {
      default = EntityId()
    },
    ItemRarityBg = {
      default = EntityId()
    },
    ItemIcon = {
      default = EntityId()
    },
    ItemIconBg = {
      default = EntityId()
    },
    ItemIconBgMask = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RewardContainer)
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function RewardContainer:OnInit()
  BaseElement.OnInit(self)
end
function RewardContainer:SetRewards(rewards)
  local validRewards = rewards and 0 < #rewards
  if validRewards then
    local isItemShowing = false
    local rewardsShowing = 0
    local rewardWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Rewards[1])
    local rewardMargin = 24
    local layoutIndex = 0
    SetTextStyle(self.Properties.RewardLabel, self.UIStyle.FONT_STYLE_REWARDSCREEN_REWARD_LABEL)
    SetTextStyle(self.Properties.RewardItemText, self.UIStyle.FONT_STYLE_REWARDSCREEN_REWARD_ITEM)
    local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local levelCap = ProgressionRequestBus.Event.GetMaxLevel(rootEntityId) + 1
    for i = 1, #rewards do
      local rewardData = rewards[i]
      if rewardData.type ~= ObjectiveDataHelper.REWARD_TYPES.ITEM then
        local showReward = true
        if rewardData.type == ObjectiveDataHelper.REWARD_TYPES.XP and playerLevel >= levelCap then
          showReward = false
        end
        local rewardLayoutId = self.Properties.Rewards[layoutIndex]
        local rewardLayout = self.registrar:GetEntityTable(rewardLayoutId)
        self.ScriptedEntityTweener:Set(rewardLayoutId, {opacity = 0})
        UiElementBus.Event.SetIsEnabled(rewardLayoutId, showReward)
        rewardLayout:SetRewardType(rewardData.type)
        rewardLayout:SetRewardValue(rewardData.value)
        if showReward then
          rewardsShowing = rewardsShowing + 1
          layoutIndex = layoutIndex + 1
        end
      elseif rewardData.value and 0 < #rewardData.value then
        if 1 < #rewardData.value then
          Log("Warning: reward includes more than 1 item")
        end
        local itemDescriptor = rewardData.value[1]
        isItemShowing = true
        local itemName = itemDescriptor:GetDisplayName()
        local staticItem = StaticItemDataManager:GetItem(itemDescriptor.itemId)
        local iconPath = "lyshineui/images/icons/items_hires/" .. staticItem.icon .. ".dds"
        UiImageBus.Event.SetSpritePathname(self.Properties.ItemIcon, iconPath)
        UiElementBus.Event.SetIsEnabled(self.Properties.RewardItem, isItemShowing)
        UiTextBus.Event.SetTextWithFlags(self.Properties.RewardItemText, itemName, eUiTextSet_SetLocalized)
      end
    end
    for i = layoutIndex, #self.Properties.Rewards do
      UiElementBus.Event.SetIsEnabled(self.Properties.Rewards[i], false)
    end
    local totalRewardsWidth = rewardsShowing * (rewardWidth + rewardMargin)
    totalRewardsWidth = totalRewardsWidth - rewardMargin
    local positionerOffset = -1 * totalRewardsWidth / 2
    UiTransformBus.Event.SetLocalPositionX(self.Properties.RewardsPositioner, positionerOffset)
    local labelText = "@objective_reward"
    if 1 < rewardsShowing or rewardsShowing == 1 and isItemShowing then
      labelText = "@objective_rewards"
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.RewardLabel, labelText, eUiTextSet_SetLocalized)
    return rewardsShowing, isItemShowing
  end
end
function RewardContainer:TriggerAnimations(initialDelay)
  local rewardDelay = 0.15
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardLabel, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardItemText, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemIcon, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.ItemIconBgMask, 0)
  self.ScriptedEntityTweener:Set(self.Properties.RewardLabel, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RewardItemText, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ItemIcon, {opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.RewardLabel, 0.25, tweenerCommon.fadeInQuadIn, 0.1)
  self.ScriptedEntityTweener:PlayC(self.Properties.RewardItemText, 0.25, tweenerCommon.fadeInQuadIn, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.ItemIcon, 0.25, tweenerCommon.fadeInQuadIn, 0.3, function()
    UiFlipbookAnimationBus.Event.Start(self.Properties.ItemIconBgMask)
  end)
  if self.Properties.Rewards then
    for i = 0, #self.Properties.Rewards do
      self.ScriptedEntityTweener:PlayC(self.Properties.Rewards[i], 0.5, tweenerCommon.fadeInQuadIn, rewardDelay * i + 0.4)
    end
  end
end
return RewardContainer
