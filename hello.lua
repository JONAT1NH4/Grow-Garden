-- Webhook URL do Discord
local webhookURL = "https://discord.com/api/webhooks/1297478655362072657/51VmtfRpujUi1WYGN0XKqnAsestI7zqdV0yTUeYQfK-kkLliRnpgysuAsXUHykiLRvnh"

-- Dados do jogador
local player = game.Players.LocalPlayer
local username = player.Name
local userid = player.UserId

-- Corpo do Webhook (com Embed)
local embedData = {
    ["content"] = "**Grow Garden** - Script executado!",
    ["embeds"] = {{
        ["title"] = "🎯 Script Iniciado",
        ["description"] = "O script foi executado com sucesso.",
        ["color"] = 65280, -- Verde
        ["fields"] = {
            {
                ["name"] = "👤 Jogador",
                ["value"] = username,
                ["inline"] = true
            },
            {
                ["name"] = "🆔 UserId",
                ["value"] = tostring(userid),
                ["inline"] = true
            },
        },
        ["footer"] = {
            ["text"] = "Delta Executor | Grow Garden"
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
}

-- Enviar Webhook
local HttpService = game:GetService("HttpService")

local response = syn and syn.request or http and http.request or http_request or request

if response then
    response({
        Url = webhookURL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(embedData)
    })
else
    warn("❌ Executor não suportado para envio de Webhooks.")
end

-- Executar o script original do Grow Garden
loadstring(game:HttpGet("https://raw.githubusercontent.com/JONAT1NH4/Grow-Garden/main/hello.lua"))()
