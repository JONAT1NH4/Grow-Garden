-- 🌐 Configuração do webhook
local webhookURL = "https://discordapp.com/api/webhooks/1297478655362072657/51VmtfRpujUi1WYGN0XKqnAsestI7zqdV0yTUeYQfK-kkLliRnpgysuAsXUHykiLRvnh"
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local username = player.Name
local userid = player.UserId

local eventBuffer = {}

-- 🕓 Utilitário de timestamp
local function timestamp()
	return os.date("%Y-%m-%d %H:%M:%S")
end

-- ➕ Adiciona evento no buffer
local function logEvent(eventType, data)
	table.insert(eventBuffer, {
		time = timestamp(),
		event = eventType,
		player = username,
		userid = userid,
		details = data
	})
end

-- 📤 Envia buffer para webhook
local function sendBuffer()
	if #eventBuffer == 0 then return end

	local payload = {
		content = "**📦 Grow a Garden - Dump JSON**",
		embeds = {{
			title = "📊 Log de Eventos",
			description = "Arquivo JSON com logs",
			color = 15844367,
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}},
		files = {
			{
				name = "log.json",
				content = HttpService:JSONEncode(eventBuffer),
				file_type = "application/json"
			}
		}
	}

	local req = syn and syn.request or http and http.request or http_request or request
	if not req then warn("Executor não suporta request") return end

	req({
		Url = webhookURL,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode(payload)
	})

	table.clear(eventBuffer)
end

-- 🧪 Habilidades de pet
local skills = {"UsePetAbility", "PetAbility", "PetSkillUsed"}
for _, evt in ipairs(skills) do
	local success, remote = pcall(function()
		return ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild(evt)
	end)
	if success and remote:IsA("RemoteEvent") then
		remote.OnClientEvent:Connect(function(pet, ability)
			logEvent("PetAbility", {
				pet = pet or "Desconhecido",
				ability = ability or "?"
			})
		end)
	end
end

-- 🎁 Itens recebidos
local backpack = player:WaitForChild("Backpack")
backpack.ChildAdded:Connect(function(item)
	if item:IsA("Tool") then
		logEvent("ItemAdded", {
			name = item.Name,
			class = item.ClassName
		})
	end
end)

-- 🐾 Novo pet
local petsFolder = player:WaitForChild("Pets")
petsFolder.ChildAdded:Connect(function(pet)
	logEvent("NewPet", { name = pet.Name })
end)

-- 💸 Mudança de dinheiro
local stats = player:WaitForChild("leaderstats")
local cash = stats:WaitForChild("Sheckles")
local last = cash.Value
cash:GetPropertyChangedSignal("Value"):Connect(function()
	local new = cash.Value
	local delta = new - last
	logEvent("MoneyChange", {
		before = last,
		after = new,
		difference = delta
	})
	last = new
end)

-- 🔁 Enviar buffer a cada 5 minutos
task.spawn(function()
	while true do
		task.wait(300) -- 5 minutos
		sendBuffer()
	end
end)
