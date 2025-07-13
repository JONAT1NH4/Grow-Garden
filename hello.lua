-- ✅ Configuração da Webhook do Discord
local webhookURL = "https://discord.com/api/webhooks/1297478655362072657/51VmtfRpujUi1WYGN0XKqnAsestI7zqdV0yTUeYQfK-kkLliRnpgysuAsXUHykiLRvnh"
-- Serviços
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local username = player.Name
local userid = player.UserId

-- Envio de webhook
local function sendWebhook(data)
    local req = syn and syn.request or http and http.request or http_request or request
    if not req then return warn("Executor não suportado") end
    req({
        Url = webhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

-- Webhook inicial
sendWebhook({
    content = "**Grow Garden** - Script Iniciado",
    embeds = {{
        title = "🎯 Script Iniciado",
        description = "Monitorando eventos e dados do jogo.",
        color = 65280,
        fields = {
            {name="👤 Jogador", value=username, inline=true},
            {name="🆔 ID", value=tostring(userid), inline=true},
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
})

-- Função comum para embeds
local function mkEmbed(title, color, fields)
    return {
        content = "**Grow a Garden** — Evento",
        embeds = {{
            title = title,
            color = color,
            fields = fields,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
end

-- Monitorar compras e habilidades (mesmo que antes)
-- ... [mantém os mesmos loops de possíveis eventos]

-- Monitorar dinheiro do jogador
local leaderstats = player:WaitForChild("leaderstats", 5)
if leaderstats and leaderstats:FindFirstChild("Sheckles") then
    local lastMoney = leaderstats.Sheckles.Value
    leaderstats.Sheckles:GetPropertyChangedSignal("Value"):Connect(function()
        local novo = leaderstats.Sheckles.Value
        local diff = novo - lastMoney
        local emoji = diff>=0 and "➕" or "➖"
        sendWebhook(mkEmbed(
            "💰 Saldo Atualizado",
            diff>=0 and 3066993 or 15158332,
            {
                {name="Saldo Anterior", value=tostring(lastMoney), inline=true},
                {name="Novo Saldo", value=tostring(novo), inline=true},
                {name="Variação", value=emoji..tostring(diff), inline=true}
            }
        ))
        lastMoney = novo
    end)
end

-- Monitorar progresso de sementes / pets (exemplo genérico encontrando GUI/Data)
RunService.Heartbeat:Connect(function()
    -- Verifica expansão de seeds/pets no workspace ou UI (exemplo hipotético):
    local stats = player:FindFirstChild("GameStats")
    if stats and stats:FindFirstChild("SeedsCollected") then
        local collected = stats.SeedsCollected.Value
        -- enviar webhook se algo mudou
        -- armazene valor anterior em uma variável similar
    end
end)

-- Executa script original
loadstring(game:HttpGet("https://raw.githubusercontent.com/JONAT1NH4/Grow-Garden/main/hello.lua"))()
