-- 🌐 Configuração do webhook
local webhookURL = "https://discord.com/api/webhooks/1297478655362072657/51VmtfRpujUi1WYGN0XKqnAsXUHykiLRvnh"

-- Serviços
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local username = player.Name
local userid = player.UserId

-- Função para enviar Webhook
local function sendWebhook(data)
    local req = syn and syn.request or http and http.request or http_request or request
    if not req then return warn("Executor não suportado") end
    req({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

-- Formatar números grandes
local function formatNumber(n)
    local s = tostring(n)
    local pos = #s % 3
    if pos == 0 then pos = 3 end
    local formatted = s:sub(1, pos)
    for i = pos+1, #s, 3 do
        formatted = formatted .. "," .. s:sub(i, i+2)
    end
    return formatted
end

-- Criador de embed genérico
local function mkEmbed(title, color, fields)
    return {
        content = "**Grow a Garden — Evento**",
        embeds = {{
            title = title,
            color = color,
            fields = fields,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
end

-- Webhook inicial
sendWebhook(mkEmbed(
    "🎯 Script Iniciado",
    65280,
    {
        {name = "👤 Jogador", value = username, inline = true},
        {name = "🆔 ID", value = tostring(userid), inline = true},
    }
))

-- Monitorar compras (Mesmo que antes; não repetido aqui por brevidade)

-- Monitorar mudanças no saldo
local leaderstats = player:WaitForChild("leaderstats", 5)
if leaderstats and leaderstats:FindFirstChild("Sheckles") then
    local lastMoney = leaderstats.Sheckles.Value
    leaderstats.Sheckles:GetPropertyChangedSignal("Value"):Connect(function()
        local novo = leaderstats.Sheckles.Value
        local diff = novo - lastMoney
        local emoji = diff >= 0 and "➕" or "➖"
        sendWebhook(mkEmbed(
            "💰 Saldo Atualizado",
            diff >= 0 and 3066993 or 15158332,
            {
                {name = "Saldo Anterior", value = formatNumber(lastMoney), inline = true},
                {name = "Novo Saldo", value = formatNumber(novo), inline = true},
                {name = "Variação", value = emoji .. formatNumber(math.abs(diff)), inline = true}
            }
        ))
        lastMoney = novo
    end)
end

-- Monitorar entrada de frutas no inventário
local backpack = player:WaitForChild("Backpack", 5)
if backpack then
    local known = {}
    -- registra frutas já existentes
    for _, it in ipairs(backpack:GetChildren()) do known[it.Name] = true end

    backpack.ChildAdded:Connect(function(item)
        if item:IsA("Tool") and (item.Name:find("Fruit") or item.Name:find("Seed")) then
            if not known[item.Name] then
                sendWebhook(mkEmbed(
                    "🍎 Nova Fruta/Seed",
                    15844367,
                    {
                        {name = "Item", value = item.Name, inline = true},
                        {name = "👤 Jogador", value = username, inline = true},
                    }
                ))
                known[item.Name] = true
            end
        end
    end)
end

-- Monitorar dados de pets (exemplo genérico — adapte conforme estrutura real)
local function trackPets()
    local petsFolder = player:FindFirstChild("Pets")
    if not petsFolder then return end
    local seen = {}
    for _, pet in ipairs(petsFolder:GetChildren()) do
        seen[pet.Name] = true
    end
    petsFolder.ChildAdded:Connect(function(pet)
        if not seen[pet.Name] then
            sendWebhook(mkEmbed(
                "🐾 Pet Adquirido",
                39423,
                {
                    {name = "Pet", value = pet.Name, inline = true},
                    {name = "👤 Jogador", value = username, inline = true}
                }
            ))
            seen[pet.Name] = true
        end
    end)
    -- também pode monitorar evolução, atributos, etc.
end
trackPets()

-- Executar script original
loadstring(game:HttpGet("https://raw.githubusercontent.com/JONAT1NH4/Grow-Garden/main/hello.lua"))()
