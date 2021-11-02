local OWGuildShopLevelItem = {
  Properties = {
    Name = {
      default = EntityId()
    },
    NameSelected = {
      default = EntityId()
    },
    LevelLockIndicator = {
      default = EntityId()
    },
    Selected = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    IconSelected = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWGuildShopLevelItem)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function OWGuildShopLevelItem:OnInit()
  BaseElement.OnInit(self)
  DynamicBus.OWGDynamicRequestBus.Connect(self.entityId, self)
  self.factionInfoTable = FactionCommon.factionInfoTable
end
function OWGuildShopLevelItem:OnShutdown()
  DynamicBus.OWGDynamicRequestBus.Disconnect(self.entityId, self)
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function OWGuildShopLevelItem:SetRank(rankInfo)
  self.rankInfo = rankInfo
  local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  local name = ""
  if self.factionInfoTable[faction].rankNames then
    name = self.factionInfoTable[faction].rankNames[rankInfo.rank + 1]
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Name, name, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.NameSelected, name, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.LevelLockIndicator, self.rankInfo.isLocked)
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, not self.rankInfo.isLocked)
  UiElementBus.Event.SetIsEnabled(self.Properties.IconSelected, not self.rankInfo.isLocked)
  UiElementBus.Event.SetIsEnabled(self.Properties.Selected, false)
  self.textColor = self.UIStyle.COLOR_TAN
  if self.rankInfo.isLocked then
    self.textColor = self.UIStyle.COLOR_GRAY_50
  else
    self.textColor = self.UIStyle.COLOR_TAN
  end
  self.ScriptedEntityTweener:Set(self.Properties.Name, {
    textColor = self.textColor
  })
end
function OWGuildShopLevelItem:SetRankVisible(visible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Selected, visible)
end
function OWGuildShopLevelItem:SetCallback(fn, t)
  self.callback = fn
  self.context = t
end
function OWGuildShopLevelItem:OnPressed()
  if self.callback then
    self.callback(self.context, self)
    self.audioHelper:PlaySound(self.audioHelper.OWG_GuildShopLevel_Level_Select)
  end
end
function OWGuildShopLevelItem:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OWG_GuildShopLevel_OnHover)
  self.ScriptedEntityTweener:Play(self.Properties.Name, self.UIStyle.DURATION_BUTTON_FADE_IN, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.Hover, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.timeline:Add(self.Properties.Hover, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.Properties.Hover, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hover, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Hover, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
end
function OWGuildShopLevelItem:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.Name, self.UIStyle.DURATION_BUTTON_FADE_OUT, {
    textColor = self.textColor
  })
  self.ScriptedEntityTweener:Play(self.Properties.Hover, self.UIStyle.DURATION_BUTTON_FADE_OUT, {opacity = 0, ease = "QuadIn"})
end
function OWGuildShopLevelItem:OnWalletChange()
  if self.rankInfo then
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelLockIndicator, self.rankInfo.isLocked)
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, not self.rankInfo.isLocked)
    UiElementBus.Event.SetIsEnabled(self.Properties.IconSelected, not self.rankInfo.isLocked)
  end
end
return OWGuildShopLevelItem
