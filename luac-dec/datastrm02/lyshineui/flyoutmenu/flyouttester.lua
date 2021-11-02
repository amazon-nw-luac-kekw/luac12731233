local FlyoutTester = {
  Properties = {
    CloseButton = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(FlyoutTester)
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
function FlyoutTester:OnInit()
  BaseScreen.OnInit(self)
  self.CloseButton:SetText("Close")
  self.CloseButton:SetCallback(self.OnClose, self)
  if LyShineScriptBindRequestBus.Broadcast.IsEditor() then
    SlashCommands:RegisterSlashCommand("flyout", self.OnSlashFlyout, self)
  end
end
function FlyoutTester:OpenFlyout(entityId, action)
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local playerIcon = PlayerIconData()
  playerIcon.backgroundImagePath = "lyshineui/images/charactercreation/layered/male/male-european-caucasian-3.png"
  playerIcon.midgroundImagePath = "lyshineui/images/charactercreation/layered/male/male-male-european01.png"
  playerIcon.foregroundImagePath = "lyshineui/images/charactercreation/layered/male/male-male-goatee01.png"
  local guildCrestData = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Crest")
  rows = {}
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PlayerHeader,
    name = "Danimus",
    icon = playerIcon,
    guildName = "Dan Town",
    crest = guildCrestData,
    level = 88
  })
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_SettlementHeader,
    settlementIndex = -1
  })
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Separator
  })
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_WarStatus,
    settlementIndex = -1
  })
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Button,
    buttonText = "Test Button",
    callback = self.OnButtonClick,
    callbackTable = self,
    callbackData = "Test Data",
    color = self.UIStyle.COLOR_RED
  })
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Options,
    context = self,
    options = {
      {
        buttonText = "Option 1",
        callback = self.OnFlyoutAction,
        data = 1,
        enabled = true
      },
      {
        buttonText = "Option 2",
        callback = self.OnFlyoutAction,
        data = 2,
        enabled = true
      },
      {
        buttonText = "Option 3",
        callback = self.OnFlyoutAction,
        data = 3,
        enabled = false
      }
    }
  })
  flyoutMenu:SetOpenLocation(entityId)
  flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
  flyoutMenu:SetRowData(rows)
end
function FlyoutTester:OnButtonClick(data)
  Debug.Log("FlyFlyoutTester:OnButtonClick(): " .. tostring(data))
end
function FlyoutTester:OnFlyoutMenuClosed()
  Debug.Log("FlyoutTester:OnFlyoutMenuClosed()")
end
function FlyoutTester:OnFlyoutAction(data)
  Debug.Log("FlyFlyoutTester:OnFlyoutAction(): " .. tostring(data))
end
function FlyoutTester:OnClose()
  LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
end
function FlyoutTester:OnSlashFlyout()
  LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
end
return FlyoutTester
