local FactionReputationBarRankIcon = {
  Properties = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FactionReputationBarRankIcon)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function FactionReputationBarRankIcon:OnInit()
  BaseElement.OnInit(self)
end
function FactionReputationBarRankIcon:OnFocus()
  self:ShowFlyoutMenu()
end
function FactionReputationBarRankIcon:SetFlyoutData(rankName, rankNameColor, rankIcon, rankIconColor, numShopItems, reputationCost)
  self.flyoutData = {
    rankName = rankName,
    rankNameColor = rankNameColor,
    rankIcon = rankIcon,
    rankIconColor = rankIconColor,
    numShopItems = numShopItems,
    reputationCost = reputationCost
  }
  self:SetIconPath(rankIcon)
end
function FactionReputationBarRankIcon:ShowFlyoutMenu()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return
  end
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  local rows = {}
  local styledData = {
    type = flyoutMenu.ROW_TYPE_FactionReputationBarRankIcon,
    rankName = self.flyoutData.rankName,
    rankNameColor = self.isUnlocked and self.flyoutData.rankNameColor or self.UIStyle.COLOR_GRAY_60,
    rankIcon = self.flyoutData.rankIcon,
    rankIconColor = self.isUnlocked and self.flyoutData.rankIconColor or self.UIStyle.COLOR_GRAY_40,
    numShopItems = self.flyoutData.numShopItems,
    reputationCost = self.flyoutData.reputationCost,
    isUnlocked = self.isUnlocked
  }
  table.insert(rows, styledData)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:SetSoundOnShow(self.audioHelper.MapFlyout_OnShow)
  flyoutMenu:SetSoundOnHide(self.audioHelper.MapFlyout_OnHide)
  flyoutMenu:EnableFlyoutDelay(false)
  flyoutMenu:SetFadeInTime(0.1)
  flyoutMenu:SetOpenLocation(self.entityId)
  flyoutMenu:Unlock()
  flyoutMenu:SetRowData(rows)
  flyoutMenu:SetSourceHoverOnly(true)
  flyoutMenu.openingContext = nil
end
function FactionReputationBarRankIcon:SetIconPath(path)
  UiImageBus.Event.SetSpritePathname(self.entityId, path)
end
function FactionReputationBarRankIcon:SetIsUnlocked(isUnlocked)
  if self.isUnlocked ~= isUnlocked then
    self.isUnlocked = isUnlocked
    if self.isUnlocked then
      self.ScriptedEntityTweener:Play(self.entityId, 0.6, {
        scaleX = 1.25,
        scaleY = 1.25,
        imgColor = self.UIStyle.COLOR_WHITE
      }, {
        scaleX = 1,
        scaleY = 1,
        imgColor = self.flyoutData.rankIconColor,
        ease = "CubicIn"
      })
      self.ScriptedEntityTweener:PlayC(self.entityId, 0.15, tweenerCommon.fadeInQuadOut)
    else
      UiImageBus.Event.SetColor(self.entityId, self.UIStyle.COLOR_GRAY_40)
      UiFaderBus.Event.SetFadeValue(self.entityId, 0.8)
    end
    self.flyoutData.isUnlocked = self.isUnlocked
  end
end
return FactionReputationBarRankIcon
