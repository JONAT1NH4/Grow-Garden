local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- URL do seu webhook (substitua pelo seu próprio)
local webhookUrl = "https://discord.com/api/webhooks/1297478655362072657/51VmtfRpujUi1WYGN0XKqnAsestI7zqdV0yTUeYQfK-kkLliRnpgysuAsXUHykiLRvnh"

-- Função para enviar a mensagem ao Discord via webhook
local function SendMessageToDiscord(content)
    -- Corpo da mensagem a ser enviada
    local messageData = {
        username = "Roblox Bot",  -- Nome do bot
        avatar_url = "https://i.imgur.com/AfFp7pu.png",  -- Ícone do bot
        content = content  -- Conteúdo da mensagem
    }

    -- Codificando a tabela de dados para JSON
    local jsonData = HttpService:JSONEncode(messageData)

    -- Enviar o POST para o webhook do Discord
    local success, response = pcall(function()
        HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    -- Verificando o status da requisição
    if success then
        print("Mensagem enviada com sucesso!")
    else
        warn("Erro ao enviar a mensagem: " .. response)
    end
end

-- Quando o jogador entra no jogo, envia uma mensagem ao Discord
Players.PlayerAdded:Connect(function(player)
    -- Envia a mensagem para o Discord
    SendMessageToDiscord(player.Name .. " entrou no servidor!")  -- Mensagem personalizada com o nome do jogador
end)

-- Aqui, você pode adicionar código para enviar mensagem quando uma compra for feita, por exemplo.
