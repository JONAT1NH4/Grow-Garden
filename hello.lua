-- Este é um exemplo simples de um script Roblox para enviar uma mensagem "Olá Mundo" via webhook para Discord.

local HttpService = game:GetService("HttpService")

-- URL do seu webhook do Discord (substitua pelo seu próprio)
local webhookUrl = "https://discord.com/api/webhooks/https://discordapp.com/api/webhooks/1297478655362072657/51VmtfRpujUi1WYGN0XKqnAsestI7zqdV0yTUeYQfK-kkLliRnpgysuAsXUHykiLRvnh"

-- Corpo da mensagem a ser enviada
local messageData = {
    username = "Roblox Bot",  -- Nome do bot no Discord
    avatar_url = "https://i.imgur.com/AfFp7pu.png",  -- Ícone do bot no Discord
    content = "Olá Mundo"  -- Mensagem que será enviada
}

-- Codificando a tabela de dados para JSON
local jsonData = HttpService:JSONEncode(messageData)

-- Enviar o POST para o webhook do Discord
local headers = {
    ["Content-Type"] = "application/json"
}

-- Enviando a requisição HTTP para o Discord
local success, response = pcall(function()
    HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson, false, headers)
end)

-- Verificando o status da requisição
if success then
    print("Mensagem enviada com sucesso!")
else
    warn("Erro ao enviar a mensagem: " .. response)
end
