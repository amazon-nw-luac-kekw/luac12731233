local ChooseSidePrompt = {
  Properties = {
    Left = {
      default = EntityId()
    },
    LeftBG = {
      default = EntityId()
    },
    LeftCompanyName = {
      default = EntityId()
    },
    LeftEmblem = {
      default = EntityId()
    },
    LeftButton = {
      default = EntityId()
    },
    LeftBannerMask = {
      default = EntityId()
    },
    LeftBannerImage = {
      default = EntityId()
    },
    LeftCrestGlow = {
      default = EntityId()
    },
    LeftFactionName = {
      default = EntityId()
    },
    Right = {
      default = EntityId()
    },
    RightBG = {
      default = EntityId()
    },
    RightCompanyName = {
      default = EntityId()
    },
    RightEmblem = {
      default = EntityId()
    },
    RightButton = {
      default = EntityId()
    },
    RightBannerMask = {
      default = EntityId()
    },
    RightBannerImage = {
      default = EntityId()
    },
    RightCrestGlow = {
      default = EntityId()
    },
    RightFactionName = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
BaseElement:CreateNewElement(ChooseSidePrompt)
function ChooseSidePrompt:OnInit()
  self.LeftButton:SetText("@ui_select")
  self.LeftButton:SetCallback(self.OnLeftButton, self)
  self.RightButton:SetText("@ui_select")
  self.RightButton:SetCallback(self.OnRightButton, self)
end
function ChooseSidePrompt:SetGuildData(leftGuildData, rightGuildData)
  if leftGuildData then
    UiTextBus.Event.SetText(self.Properties.LeftCompanyName, leftGuildData.guildName)
    self.LeftEmblem:SetIcon(leftGuildData.crestData)
    local factionData = leftGuildData.faction
    local factionBgColor = self.UIStyle["COLOR_FACTION_BG_" .. tostring(factionData)]
    UiImageBus.Event.SetColor(self.Properties.LeftBannerImage, factionBgColor)
    UiImageBus.Event.SetColor(self.Properties.LeftCrestGlow, factionBgColor)
    UiTextBus.Event.SetColor(self.Properties.LeftFactionName, factionBgColor)
    local factionName = FactionCommon.factionInfoTable[factionData].factionName
    UiTextBus.Event.SetTextWithFlags(self.Properties.LeftFactionName, factionName, eUiTextSet_SetLocalized)
  end
  if rightGuildData then
    UiTextBus.Event.SetText(self.Properties.RightCompanyName, rightGuildData.guildName)
    self.RightEmblem:SetIcon(rightGuildData.crestData)
    local factionData = rightGuildData.faction
    local factionBgColor = self.UIStyle["COLOR_FACTION_BG_" .. tostring(factionData)]
    UiImageBus.Event.SetColor(self.Properties.RightBannerImage, factionBgColor)
    UiImageBus.Event.SetColor(self.Properties.RightCrestGlow, factionBgColor)
    UiTextBus.Event.SetColor(self.Properties.RightFactionName, factionBgColor)
    local factionName = FactionCommon.factionInfoTable[factionData].factionName
    UiTextBus.Event.SetTextWithFlags(self.Properties.RightFactionName, factionName, eUiTextSet_SetLocalized)
  end
end
function ChooseSidePrompt:SetCallbacks(leftCallback, rightCallback, callbackTable)
  self.leftCallback = leftCallback
  self.rightCallback = rightCallback
  self.callbackTable = callbackTable
end
function ChooseSidePrompt:ExecuteCallback(callback)
  if callback then
    callback(self.callbackTable)
  end
end
function ChooseSidePrompt:OnLeftButton()
  self:ExecuteCallback(self.leftCallback)
end
function ChooseSidePrompt:OnRightButton()
  self:ExecuteCallback(self.rightCallback)
end
function ChooseSidePrompt:OnTransitionIn()
  self.ScriptedEntityTweener:Play(self.Properties.Left, 0.6, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Right, 0.6, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  UiMaskBus.Event.SetIsMaskingEnabled(self.Properties.LeftBannerMask, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.LeftBannerMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.LeftBannerMask)
  UiMaskBus.Event.SetIsMaskingEnabled(self.Properties.RightBannerMask, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.RightBannerMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.RightBannerMask)
end
return ChooseSidePrompt
