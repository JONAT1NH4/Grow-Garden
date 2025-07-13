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

-- 🌟 Formatar números abreviados
local function formatAbbreviated(n)
	if n >= 1e12 then
		return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.2fK", n / 1e3)
	else
		return tostring(n)
	end
end

-- 🚀 Enviar webhook
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

-- 🎨 Criador de embed
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

-- ✅ Webhook de início
sendWebhook(mkEmbed("🎯 Script Iniciado", 65280, {
	{name = "👤 Jogador", value = username, inline = true},
	{name = "🆔 ID", value = tostring(userid), inline = true},
}))

-- 💸 Monitorar saldo com antispam e formato bonito
local leaderstats = player:WaitForChild("leaderstats", 5)
if leaderstats and leaderstats:FindFirstChild("Sheckles") then
	local sheckles = leaderstats.Sheckles
	local lastMoney = sheckles.Value
	local lastReport = 0

	sheckles:GetPropertyChangedSignal("Value"):Connect(function()
		local now = tick()
		local novo = sheckles.Value
		local diff = novo - lastMoney
		if math.abs(diff) < 100 or now - lastReport < 2 then return end

		local emoji = diff >= 0 and "➕" or "➖"
		sendWebhook(mkEmbed("💰 Saldo Atualizado", diff >= 0 and 3066993 or 15158332, {
			{name = "Saldo Anterior", value = formatAbbreviated(lastMoney), inline = true},
			{name = "Novo Saldo", value = formatAbbreviated(novo), inline = true},
			{name = "Variação", value = emoji .. formatAbbreviated(math.abs(diff)), inline = true}
		}))

		lastMoney = novo
		lastReport = now
	end)
end

-- 🍎 Monitorar frutas/sementes na mochila
local backpack = player:WaitForChild("Backpack", 5)
if backpack then
	local known = {}
	for _, it in ipairs(backpack:GetChildren()) do
		known[it.Name] = true
	end

	backpack.ChildAdded:Connect(function(item)
		if item:IsA("Tool") and (item.Name:lower():find("fruit") or item.Name:lower():find("seed") or item.Name:lower():find("rare")) then
			if not known[item.Name] then
				sendWebhook(mkEmbed("🎁 Novo Item", 15844367, {
					{name = "Item", value = item.Name, inline = true},
					{name = "👤 Jogador", value = username, inline = true}
				}))
				known[item.Name] = true
			end
		end
	end)
end

-- 🐾 Monitorar pets adquiridos
local function trackPets()
	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return end
	local seen = {}
	for _, pet in ipairs(petsFolder:GetChildren()) do
		seen[pet.Name] = true
	end
	petsFolder.ChildAdded:Connect(function(pet)
		if not seen[pet.Name] then
			sendWebhook(mkEmbed("🐾 Novo Pet", 39423, {
				{name = "Pet", value = pet.Name, inline = true},
				{name = "👤 Jogador", value = username, inline = true}
			}))
			seen[pet.Name] = true
		end
	end)

	-- 👑 Evolução dos pets (detecta aumento de nível)
	for _, pet in ipairs(petsFolder:GetChildren()) do
		local level = pet:FindFirstChild("Level")
		if level then
			local lastLvl = level.Value
			level:GetPropertyChangedSignal("Value"):Connect(function()
				if level.Value > lastLvl then
					sendWebhook(mkEmbed("⬆️ Pet Evoluído", 10181046, {
						{name = "Pet", value = pet.Name, inline = true},
						{name = "Novo Nível", value = tostring(level.Value), inline = true},
						{name = "👤 Jogador", value = username, inline = true}
					}))
					lastLvl = level.Value
				end
			end)
		end
	end
end
trackPets()

-- 🧪 Detectar habilidades de pets sendo ativadas
local possibleAbilities = {"UsePetAbility", "PetAbility", "PetSkillUsed"}
for _, evt in ipairs(possibleAbilities) do
	local success, remote = pcall(function()
		return ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild(evt)
	end)
	if success and remote and remote:IsA("RemoteEvent") then
		remote.OnClientEvent:Connect(function(petName, abilityName)
			sendWebhook(mkEmbed("🧪 Habilidade Usada", 3447003, {
				{name = "Pet", value = petName or "Desconhecido", inline = true},
				{name = "Habilidade", value = abilityName or "Desconhecida", inline = true},
				{name = "👤 Jogador", value = username, inline = true}
			}))
		end)
	end
end

-- Executa o script original do Grow Garden
loadstring(game:HttpGet("https://raw.githubusercontent.com/JONAT1NH4/Grow-Garden/main/hello.lua"))()
