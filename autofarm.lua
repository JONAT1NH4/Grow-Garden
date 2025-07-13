--[[
    @author depso (depthso)
    @description Grow a Garden - Monitoramento e envio de dados para Discord via Webhook
    Adaptado para enviar informações do jogo para o Discord, sem autofarm ou automações.
]]

--// Serviços
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui

--// ReGui (UI)
local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local PrefabsId = "rbxassetid://" .. ReGui.PrefabsId
ReGui:Init({
    Prefabs = game:GetService("InsertService"):LoadLocalAsset(PrefabsId)
})

--// Tema
local Accent = {
    DarkGreen = Color3.fromRGB(45, 95, 25),
    Green = Color3.fromRGB(69, 142, 40),
    Brown = Color3.fromRGB(26, 20, 8),
}
ReGui:DefineTheme("GardenTheme", {
    WindowBg = Accent.Brown,
    TitleBarBg = Accent.DarkGreen,
    TitleBarBgActive = Accent.Green,
    ResizeGrab = Accent.DarkGreen,
    FrameBg = Accent.DarkGreen,
    FrameBgActive = Accent.Green,
    CollapsingHeaderBg = Accent.Green,
    ButtonsBg = Accent.Green,
    CheckMark = Accent.Green,
    SliderGrab = Accent.Green,
})

--// Função para criar janela
local function CreateWindow()
    local Window = ReGui:Window({
        Title = "Grow a Garden | Webhook Monitor",
        Theme = "GardenTheme",
        Size = UDim2.fromOffset(300, 200)
    })
    return Window
end

--// Janela principal
local Window = CreateWindow()

--// Configurações (Webhook Discord)
local ConfigNode = Window:TreeNode({Title="Configurações ⚙️"})
local WebhookURL = ""
ConfigNode:Input({
    Label = "Webhook Discord",
    Text = "",
    Placeholder = "Cole aqui o link do webhook",
    Callback = function(_, value)
        WebhookURL = value
    end
})

-- Função para enviar dados para o Discord
local function SendToWebhook(content)
    if WebhookURL == "" then return end
    local data = {
        ["content"] = content
    }
    local json = game:GetService("HttpService"):JSONEncode(data)
    if syn and syn.request then
        syn.request({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = json
        })
    elseif http_request then
        http_request({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = json
        })
    elseif request then
        request({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = json
        })
    end
end

--// Funções utilitárias para monitoramento
local function GetOwnedSeeds()
    local OwnedSeeds = {}
    local function CollectSeedsFromParent(Parent, Seeds)
        for _, Tool in next, Parent:GetChildren() do
            local PlantName = Tool:FindFirstChild("Plant_Name")
            local Count = Tool:FindFirstChild("Numbers")
            if PlantName then
                Seeds[PlantName.Value] = {
                    Count = Count and Count.Value or 0,
                    Tool = Tool
                }
            end
        end
    end
    local Character = LocalPlayer.Character
    if Character then
        CollectSeedsFromParent(Backpack, OwnedSeeds)
        CollectSeedsFromParent(Character, OwnedSeeds)
    end
    return OwnedSeeds
end

-- Monitorar novos itens na loja
local LastStock = {}
RunService.RenderStepped:Connect(function()
    local SeedShop = PlayerGui:FindFirstChild("Seed_Shop")
    if SeedShop then
        local Items = SeedShop:FindFirstChild("Blueberry", true)
        if Items then
            Items = Items.Parent
            for _, Item in pairs(Items:GetChildren()) do
                if not LastStock[Item.Name] then
                    local MainFrame = Item:FindFirstChild("Main_Frame")
                    local StockText = MainFrame and MainFrame.Stock_Text and MainFrame.Stock_Text.Text or "?"
                    SendToWebhook("🛒 **Novo item na loja:** "..Item.Name.." | Estoque: "..StockText)
                    LastStock[Item.Name] = true
                end
            end
        end
    end
end)

-- Monitorar novas seeds adquiridas
local LastSeeds = {}
RunService.RenderStepped:Connect(function()
    for name, data in pairs(GetOwnedSeeds()) do
        if not LastSeeds[name] then
            local count = data.Count or 0
            SendToWebhook("🌱 **Nova seed adquirida:** "..name.." | Quantidade: "..count)
            LastSeeds[name] = true
        end
    end
end)

-- Monitorar novos pets adquiridos
local LastPets = {}
RunService.RenderStepped:Connect(function()
    local Character = LocalPlayer.Character
    if Character then
        for _, obj in pairs(Character:GetChildren()) do
            if obj:IsA("Tool") and obj:FindFirstChild("Pet_Name") then
                local petName = obj.Pet_Name.Value
                if not LastPets[petName] then
                    SendToWebhook("🐾 **Novo pet adquirido:** "..petName)
                    LastPets[petName] = true
                end
            end
        end
    end
end)

-- Monitorar eventos especiais (exemplo: eventos no ReplicatedStorage)
local LastEvents = {}
local function MonitorEvents()
    local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if EventsFolder then
        for _, event in pairs(EventsFolder:GetChildren()) do
            if not LastEvents[event.Name] then
                SendToWebhook("🎉 **Novo evento detectado:** "..event.Name)
                LastEvents[event.Name] = true
            end
        end
    end
end
RunService.RenderStepped:Connect(MonitorEvents)
