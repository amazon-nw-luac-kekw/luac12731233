local HousingEnter_ListItem = {
  Properties = {
    EnterPrimaryHomeButton = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    },
    HousingPointsText = {
      default = EntityId()
    },
    HouseOwnerText = {
      default = EntityId()
    },
    PointIcon = {
      default = EntityId()
    },
    RankText = {
      default = EntityId()
    },
    RankBg = {
      default = EntityId()
    },
    PeacockedText = {
      default = EntityId()
    },
    PeacockedRing = {
      default = EntityId()
    },
    PointContainer = {
      default = EntityId()
    },
    OwnerTextContainer = {
      default = EntityId()
    }
  }
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
BaseElement:CreateNewElement(HousingEnter_ListItem)
function HousingEnter_ListItem:OnInit()
  BaseElement.OnInit(self)
  self.EnterPrimaryHomeButton:SetText("@ui_enter")
  self.EnterPrimaryHomeButton:SetCallback(self.OnListItemClick, self)
  self.EnterPrimaryHomeButton:SetButtonStyle(self.EnterPrimaryHomeButton.BUTTON_STYLE_CTA)
end
function HousingEnter_ListItem:OnShutdown()
end
function HousingEnter_ListItem:GetElementWidth()
  return UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function HousingEnter_ListItem:GetElementHeight()
  return UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function HousingEnter_ListItem:GetHorizontalSpacing()
  return 0
end
function HousingEnter_ListItem:ShowPlayerIcon(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {x = 128})
  else
    self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {x = 58})
  end
end
function HousingEnter_ListItem:ShowRank(isVisible, isPlayerIconVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.RankBg, isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Set(self.Properties.PlayerIcon, {x = 44})
    self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {x = 124})
  else
    self.ScriptedEntityTweener:Set(self.Properties.PlayerIcon, {x = 14})
    if isPlayerIconVisible then
      self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {x = 102})
    else
      self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {x = 30})
    end
  end
end
function HousingEnter_ListItem:SetGridItemData(housingItemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, housingItemData ~= nil)
  self.housingItemData = housingItemData
  if housingItemData then
    self.callbackSelf = housingItemData.callbackSelf
    self.callbackFn = housingItemData.callbackFn
    if not housingItemData.peacockingCharacterId or housingItemData.peacockingCharacterId == "" then
      UiTextBus.Event.SetTextWithFlags(self.Properties.HouseOwnerText, housingItemData.ownerName, eUiTextSet_SetLocalized)
      self.EnterPrimaryHomeButton:SetButtonStyle(self.EnterPrimaryHomeButton.BUTTON_STYLE_CTA)
      self:ShowPlayerIcon(false)
      self:ShowRank(false, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PointIcon, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.HousingPointsText, false)
      UiTextBus.Event.SetColor(self.Properties.HouseOwnerText, self.UIStyle.COLOR_TAN)
      UiElementBus.Event.SetIsEnabled(self.Properties.PeacockedText, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PeacockedRing, false)
    else
      UiTextBus.Event.SetText(self.Properties.HouseOwnerText, "")
      UiElementBus.Event.SetIsEnabled(self.Properties.PointIcon, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.HousingPointsText, true)
      SocialDataHandler:GetPlayerIdentification_ServerCall(self, function(self, result)
        if 0 < #result then
          local playerName = result[1].playerId.playerName
          if housingItemData.rankNumber then
            UiTextBus.Event.SetText(self.Properties.RankText, housingItemData.rankNumber)
            if housingItemData.rankNumber == 1 then
              UiElementBus.Event.SetIsEnabled(self.Properties.PeacockedText, true)
              UiElementBus.Event.SetIsEnabled(self.Properties.PeacockedRing, true)
              self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {y = 8})
            else
              UiElementBus.Event.SetIsEnabled(self.Properties.PeacockedText, false)
              UiElementBus.Event.SetIsEnabled(self.Properties.PeacockedRing, false)
              self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {y = 0})
            end
          end
          local simpleId = SimplePlayerIdentification()
          simpleId.characterIdString = housingItemData.peacockingCharacterId
          simpleId.playerName = playerName
          self.PlayerIcon:SetPlayerId(simpleId)
          local ownerText = GetLocalizedReplacementText("@ui_residence", {playerName = playerName})
          UiTextBus.Event.SetTextWithFlags(self.Properties.HouseOwnerText, ownerText, eUiTextSet_SetLocalized)
          self:ShowPlayerIcon(true)
          if housingItemData.primaryButton == true then
            self.EnterPrimaryHomeButton:SetButtonStyle(self.EnterPrimaryHomeButton.BUTTON_STYLE_CTA)
            UiTextBus.Event.SetColor(self.Properties.HouseOwnerText, self.UIStyle.COLOR_YELLOW_GOLD)
          elseif housingItemData.primaryButton == false then
            self.EnterPrimaryHomeButton:SetButtonStyle(self.EnterPrimaryHomeButton.BUTTON_STYLE_DEFAULT)
            self:ShowRank(true, true)
            UiTextBus.Event.SetColor(self.Properties.HouseOwnerText, self.UIStyle.COLOR_TAN)
          end
          self.housingItemData.playerName = playerName
        end
      end, function(self)
      end, housingItemData.peacockingCharacterId)
      if housingItemData.isGroupHouse then
        UiElementBus.Event.SetIsEnabled(self.Properties.PointContainer, false)
        self.ScriptedEntityTweener:Set(self.Properties.HouseOwnerText, {y = 0})
        self:ShowRank(false, true)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.PointContainer, true)
        self:ShowRank(not housingItemData.isMyHouse or not housingItemData.primaryButton, true)
      end
    end
    local text = GetLocalizedReplacementText("@ui_num_housing_points", {
      points = GetFormattedNumber(housingItemData.housingPoints)
    })
    UiTextBus.Event.SetText(self.Properties.HousingPointsText, text)
  else
    self.callbackSelf = nil
    self.callbackFn = nil
  end
end
function HousingEnter_ListItem:OnListItemFocus()
end
function HousingEnter_ListItem:OnListItemUnfocus()
end
function HousingEnter_ListItem:OnListItemClick()
  if self.callbackSelf then
    self.callbackFn(self.callbackSelf, self.housingItemData)
  end
end
function HousingEnter_ListItem:ShowPoints(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.PointContainer, isVisible)
end
return HousingEnter_ListItem
