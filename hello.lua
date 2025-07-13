-- ✅ Configuração da Webhook do Discord
local webhookURL = "https://discord.com/api/webhooks/1297478655362072657/51VmtfRpujUi1WYGN0XKqnAsestI7zqdV0yTUeYQfK-kkLliRnpgysuAsXUHykiLRvnh"

-- ✅ Serviços necessários
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local username = player.Name
local userid = player.UserId

-- ✅ Função para enviar Webhook
local function sendWebhook(data)
    local request = syn and syn.request or http and http.request or http_request or request
    if request then
        request({
            Url = webhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    else
        warn("❌ Executor não suportado para envio de Webhooks.")
    end
end

-- ✅ Webhook inicial ao executar script
sendWebhook({
    content = "**Grow Garden** - Script executado!",
    embeds = {{
        title = "🎯 Script Iniciado",
        description = "O script foi executado com sucesso.",
        color = 65280,
        fields = {
            { name = "👤 Jogador", value = username, inline = true },
            { name = "🆔 UserId", value = tostring(userid), inline = true },
        },
        footer = {
            text = "Delta Executor | Grow Garden"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
})

-- ✅ Monitorar eventos de compra
local possibleBuyEvents = {"BuySeed", "BuyPet", "BuyGear", "PurchaseItem"}
for _, eventName in ipairs(possibleBuyEvents) do
    local success, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild(eventName)
    end)

    if success and remote and remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(itemId, price, quantity)
            sendWebhook({
                content = "**🛒 Compra na Loja**",
                embeds = {{
                    title = "Nova Compra Realizada",
                    color = 3447003,
                    fields = {
                        {name = "🧩 Item", value = tostring(itemId), inline = true},
                        {name = "💰 Preço", value = tostring(price), inline = true},
                        {name = "🔢 Quantidade", value = tostring(quantity), inline = true},
                        {name = "👤 Jogador", value = username, inline = false},
                    },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            })
        end)
    end
end

-- ✅ Monitorar habilidades dos pets
local possiblePetEvents = {"PetAbilityUsed", "UsePetAbility", "PetAbility"}
for _, eventName in ipairs(possiblePetEvents) do
    local success, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild(eventName)
    end)

    if success and remote and remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(petId, abilityName)
            sendWebhook({
                content = "**✨ Pet Usou Habilidade**",
                embeds = {{
                    title = "Habilidade Ativada",
                    color = 10181046,
                    fields = {
                        {name = "🐾 Pet ID", value = tostring(petId), inline = true},
                        {name = "🧠 Habilidade", value = abilityName, inline = true},
                        {name = "👤 Jogador", value = username, inline = false},
                    },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            })
        end)
    end
end

-- ✅ Executar o script original do Grow Garden
loadstring(game:HttpGet("https://raw.githubusercontent.com/JONAT1NH4/Grow-Garden/main/hello.lua"))()
