local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService = pcall(function() return game:GetService("Stats") end) and game:GetService("Stats") or nil
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")


local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local hubVisivel = false
local shiftLockAtivo = false
local shiftLockConnection = nil
local espAtivo = false
local noclipAtivo = false
local BestLightAtivo = false
local BestLightConnection= nil
local clickTpAtivo = false
local tornadoBodyAtivo = false
local infiniteJumpAtivo = false
local AntiSitAtivo = false
local espInstancias = {}
local posicaoSalva = nil
local colisoesSalvas = {}
local jogadorSelecionado = nil
local conexaoClickTP = nil
local noclipConnection = nil 
local infiniteJumpConnection = nil
local AntiSitConnection = nil
local HeartbeatConn = nil
local SitChangedConn = nil
local SeatedConn = nil
local CharAddedConn = nil
local DescendantAddedConn = nil
local speedAtivo = false
local originalWalkSpeed = 16
local dynamicShadowsAtivo = false
local noclipForceConnection = nil
local viewPlayerAtivo = false
local cameraBackupSubject = nil
local cameraBackupType = nil
local viewConnection = nil
local debugAtivo = false
local debugConnection = nil
local fpsSmoothed = 60
local smoothingAlpha = 0.1
local trackedConnections = {}
local trackedGuis = {}
local trackedBodies = {}
local sofaRunning = false
local killRunning = false

local function trackConnection(conn)
	if conn and typeof(conn) == "RBXScriptConnection" then
		table.insert(trackedConnections, conn)
	end
end

local function trackGui(gui)
	if gui and typeof(gui) == "Instance" then
		table.insert(trackedGuis, gui)
	end
end

local function trackBody(body)
	if body and typeof(body) == "Instance" then
		table.insert(trackedBodies, body)
	end
end

local function safeDisconnect(conn)
	if conn and typeof(conn) == "RBXScriptConnection" then
		pcall(function() conn:Disconnect() end)
	end
end

local function safeDestroy(inst)
	if inst and inst.Parent then
		pcall(function() inst:Destroy() end)
	end
end


local function iniciarHub()

	local loboHubGui = Instance.new("ScreenGui")
	loboHubGui.Name = "LoboHubGui"
	loboHubGui.ResetOnSpawn = false
	loboHubGui.Parent = playerGui
	trackGui(loboHubGui)

	local toggleBotao = Instance.new("ImageButton")
	toggleBotao.Name = "ToggleBotao"
	toggleBotao.Image = "rbxassetid://99792331635156" -- ID da imagem do toggle
	toggleBotao.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	toggleBotao.Size = UDim2.new(0, 50, 0, 50)
	toggleBotao.Position = UDim2.new(0, 10, 0.5, -25)
	toggleBotao.Draggable = true
	toggleBotao.ZIndex = 100
	toggleBotao.Parent = loboHubGui
	trackGui(toggleBotao)

	local cornerToggle = Instance.new("UICorner")
	cornerToggle.CornerRadius = UDim.new(0, 12)
	cornerToggle.Parent = toggleBotao

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 500, 0, 460)
	mainFrame.Position = UDim2.new(0.5, -250, 0.5, -230)
	mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	mainFrame.Visible = false
	mainFrame.Draggable = true
	mainFrame.Parent = loboHubGui
	trackGui(mainFrame)

	local cornerMain = Instance.new("UICorner")
	cornerMain.CornerRadius = UDim.new(0, 12)
	cornerMain.Parent = mainFrame

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	header.Parent = mainFrame
	trackGui(header)
	
	local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12) -- 12 = arredondado suave
headerCorner.Parent = header

	local titulo = Instance.new("TextLabel")
	titulo.Name = "Titulo"
	titulo.Size = UDim2.new(1, 0, 1, 0)
	titulo.Text = "Lobo Hub [DEMO]"
	titulo.TextColor3 = Color3.fromRGB(255, 0, 255)
	titulo.Font = Enum.Font.SourceSansBold
	titulo.TextScaled = true
	titulo.BackgroundTransparency = 1
	titulo.Parent = header
	trackGui(titulo)

	local killGuiButton = Instance.new("TextButton")
	killGuiButton.Name = "KillGuiButton"
	killGuiButton.Size = UDim2.new(0, 30, 0, 30)
	killGuiButton.Position = UDim2.new(1, -35, 0, 5)
	killGuiButton.AnchorPoint = Vector2.new(0, 0)
	killGuiButton.Text = "✖"
	killGuiButton.Font = Enum.Font.SourceSansBold
	killGuiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	killGuiButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	killGuiButton.Parent = header
	trackGui(killGuiButton)

	local killGuiCorner = Instance.new("UICorner")
	killGuiCorner.CornerRadius = UDim.new(0, 6)
	killGuiCorner.Parent = killGuiButton

	local sofaButton = Instance.new("TextButton")
	sofaButton.Name = "SofaButton"
	sofaButton.Size = UDim2.new(0, 70, 0, 30)
	sofaButton.Position = UDim2.new(1, -110, 0, 5)
	sofaButton.AnchorPoint = Vector2.new(0, 0)
	sofaButton.Text = "Couch"
	sofaButton.Font = Enum.Font.SourceSansBold
	sofaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sofaButton.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
	sofaButton.TextScaled = true
	sofaButton.Parent = header
	trackGui(sofaButton)

	local sofaCorner = Instance.new("UICorner")
	sofaCorner.CornerRadius = UDim.new(0, 6)
	sofaCorner.Parent = sofaButton

	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabContainer"
	tabContainer.Size = UDim2.new(0, 140, 1, -40)
	tabContainer.Position = UDim2.new(0, 0, 0, 40)
	tabContainer.BackgroundColor3 = Color3.fromRGB(2, 2, 2)
	tabContainer.Parent = mainFrame
	trackGui(tabContainer)
	
	local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 12)
tabCorner.Parent = tabContainer

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.Parent = tabContainer

	local function makeTab(nameText)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 35)
		btn.Position = UDim2.new(0, 5, 0, 5)
		btn.Text = nameText
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextScaled = true
		btn.Parent = tabContainer
		trackGui(btn)
		return btn
	end

	local tabBemVindo = makeTab("🏠 Bem-vindo")
	local tabPlayer = makeTab("👤 Player")
	local tabTroll = makeTab("🛠️ Troll")
	local tabProtecoes = makeTab("🛡 Proteções")
	local tabClient = makeTab("💻 Client")
	local tabDebug = makeTab("⚙️ Debug")

	local pageContainer = Instance.new("Frame")
	pageContainer.Name = "PageContainer"
	pageContainer.Size = UDim2.new(1, -140, 1, -40)
	pageContainer.Position = UDim2.new(0, 140, 0, 40)
	pageContainer.BackgroundTransparency = 1
	pageContainer.Parent = mainFrame
	trackGui(pageContainer)

	local pageBemVindo = Instance.new("Frame")
	pageBemVindo.Name = "Page_BemVindo"
	pageBemVindo.Size = UDim2.new(1, 0, 1, 0)
	pageBemVindo.BackgroundTransparency = 1
	pageBemVindo.Visible = true
	pageBemVindo.Parent = pageContainer
	trackGui(pageBemVindo)

	local pageBemVindoLayout = Instance.new("UIListLayout")
	pageBemVindoLayout.Padding = UDim.new(0, 5)
	pageBemVindoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageBemVindoLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageBemVindoLayout.Parent = pageBemVindo

	local avatarImg = Instance.new("ImageLabel")
	avatarImg.Size = UDim2.new(0, 100, 0, 100)
	avatarImg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	avatarImg.LayoutOrder = 1
	avatarImg.Parent = pageBemVindo
	trackGui(avatarImg)

	local apelidoLabel = Instance.new("TextLabel")
	apelidoLabel.Size = UDim2.new(1, -10, 0, 35)
	apelidoLabel.Text = "Name: Loading..."
	apelidoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	apelidoLabel.BackgroundTransparency = 1
	apelidoLabel.Font = Enum.Font.SourceSansBold
	apelidoLabel.TextScaled = true
	apelidoLabel.LayoutOrder = 2
	apelidoLabel.Parent = pageBemVindo
	trackGui(apelidoLabel)

	local arrobaLabel = Instance.new("TextLabel")
	arrobaLabel.Size = UDim2.new(1, -10, 0, 35)
	arrobaLabel.Text = "Username: Loading..."
	arrobaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	arrobaLabel.BackgroundTransparency = 1
	arrobaLabel.Font = Enum.Font.SourceSansBold
	arrobaLabel.TextScaled = true
	arrobaLabel.LayoutOrder = 3
	arrobaLabel.Parent = pageBemVindo
	trackGui(arrobaLabel)

	local idadeContaLabel = Instance.new("TextLabel")
	idadeContaLabel.Size = UDim2.new(1, -10, 0, 35)
	idadeContaLabel.Text = "Account Age: Loading..."
	idadeContaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	idadeContaLabel.BackgroundTransparency = 1
	idadeContaLabel.Font = Enum.Font.SourceSansBold
	idadeContaLabel.TextScaled = true
	idadeContaLabel.LayoutOrder = 4
	idadeContaLabel.Parent = pageBemVindo
	trackGui(idadeContaLabel)

	local criadoresLabel = Instance.new("TextLabel")
	criadoresLabel.Size = UDim2.new(1, -10, 0, 35)
	criadoresLabel.Text = "Dev: Ice - Elementar"
	criadoresLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	criadoresLabel.BackgroundTransparency = 1
	criadoresLabel.Font = Enum.Font.SourceSansItalic
	criadoresLabel.TextScaled = true
	criadoresLabel.LayoutOrder = 5
	criadoresLabel.Parent = pageBemVindo
	trackGui(criadoresLabel)

	local discordButton = Instance.new("TextButton")
	discordButton.Size = UDim2.new(1, -10, 0, 35)
	discordButton.Text = "Copiar Discord"
	discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	discordButton.Font = Enum.Font.SourceSansBold
	discordButton.TextScaled = true
	discordButton.LayoutOrder = 6
	discordButton.Parent = pageBemVindo
	trackGui(discordButton)

    -- Página Player
	local pagePlayer = Instance.new("Frame")
	pagePlayer.Name = "Page_Player"
	pagePlayer.Size = UDim2.new(1, 0, 1, 0)
	pagePlayer.BackgroundTransparency = 1
	pagePlayer.Visible = false
	pagePlayer.Parent = pageContainer
	trackGui(pagePlayer)

	local pagePlayerLayout = Instance.new("UIListLayout")
	pagePlayerLayout.Padding = UDim.new(0, 8)
	pagePlayerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pagePlayerLayout.Parent = pagePlayer

	local pageTroll =
 Instance.new("ScrollingFrame")
	pageTroll.Name = "Page_Troll"
	pageTroll.Size = UDim2.new(1, 0, 1, 0)
	pageTroll.BackgroundTransparency = 1
	pageTroll.Visible = false
	pageTroll.Parent = pageContainer
	trackGui(pageTroll)
	
		pageTroll.CanvasSize = UDim2.new(0, 0, 2, 0) -- '2' significa 200% da altura do Frame. Você pode ajustar este valor.
	pageTroll.ScrollBarThickness = 6 -- Ajuste fino
	pageTroll.Active = true -- Garante que aceita cliques

	local pageTrollLayout = Instance.new("UIListLayout")
	pageTrollLayout.Padding = UDim.new(0, 8)
	pageTrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageTrollLayout.Parent = pageTroll

	local pageClient = Instance.new("Frame")
	pageClient.Name = "Page_Client"
	pageClient.Size = UDim2.new(1, 0, 1, 0)
	pageClient.BackgroundTransparency = 1
	pageClient.Visible = false
	pageClient.Parent = pageContainer
	trackGui(pageClient)

	local pageClientLayout = Instance.new("UIListLayout")
	pageClientLayout.Padding = UDim.new(0, 8)
	pageClientLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageClientLayout.Parent = pageClient
	
	-- Página proteções
	local pageProtecoes = Instance.new("Frame")
	pageProtecoes.Name = "Page_Protecoes"
	pageProtecoes.Size = UDim2.new(1, 0, 1, 0)
	pageProtecoes.BackgroundTransparency = 1
	pageProtecoes.Visible = false 
	pageProtecoes.Parent = pageContainer
	trackGui(pageProtecoes)

	local pageProtecoesLayout = Instance.new("UIListLayout")
	pageProtecoesLayout.Padding = UDim.new(0, 8)
	pageProtecoesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageProtecoesLayout.Parent = pageProtecoes
	
    -- Página debug
	local pageDebug = Instance.new("Frame")
	pageDebug.Name = "Page_Debug"
	pageDebug.Size = UDim2.new(1, 0, 1, 0)
	pageDebug.BackgroundTransparency = 1
	pageDebug.Visible = false
	pageDebug.Parent = pageContainer
	trackGui(pageDebug)

	local pageDebugLayout = Instance.new("UIListLayout")
	pageDebugLayout.Padding = UDim.new(0, 8)
	pageDebugLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageDebugLayout.Parent = pageDebug
	
    -- Clique da aba proteções
	tabProtecoes.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pagePlayer.Visible = false
		pageTroll.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = true
	end)

    -- Selecionar player
	local playerSelectButton = Instance.new("TextButton")
	playerSelectButton.Name = "PlayerSelectButton"
	playerSelectButton.Size = UDim2.new(1, -10, 0, 35)
	playerSelectButton.Text = "👥 Select Player..."
	playerSelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playerSelectButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	playerSelectButton.Font = Enum.Font.SourceSansBold
	playerSelectButton.TextScaled = true
	playerSelectButton.Parent = pageTroll
	trackGui(playerSelectButton)

	local playerList = Instance.new("ScrollingFrame")
	playerList.Name = "PlayerList"
	playerList.Size = UDim2.new(1, -10, 0, 180)
	playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
	playerList.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	playerList.BorderSizePixel = 0
	playerList.ScrollBarThickness = 6
	playerList.Visible = false
	playerList.Parent = pageTroll
	trackGui(playerList)

	local playerListLayout = Instance.new("UIListLayout")
	playerListLayout.Padding = UDim.new(0, 4)
	playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	playerListLayout.Parent = playerList

	local function makeFuncButton(parent, text, color)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -10, 0, 35)
		b.Text = text
		b.TextColor3 = Color3.fromRGB(255,255,255)
		b.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
		b.Font = Enum.Font.SourceSansBold
		b.TextScaled = true
		b.Parent = parent
		trackGui(b)
		return b
	end

-- Opções
	local espToggle = makeFuncButton(pagePlayer, "ꙮ ESP [OFF]", Color3.fromRGB(30, 30, 30))
	local clickTPToggle = makeFuncButton(pagePlayer, "👆 Click TP [OFF]", Color3.fromRGB(30, 30, 30))
	local noclipToggle = makeFuncButton(pagePlayer, "⿻ Noclip [OFF]", Color3.fromRGB(30, 30, 30))
	local shiftLockToggle = makeFuncButton(pagePlayer, "🔒 Shift Lock [OFF]", Color3.fromRGB(30, 30, 30))
	local infiniteJumpToggle = makeFuncButton(pagePlayer, "∞ Pulo Infinito [OFF]", Color3.fromRGB(30, 30, 30))
    local BuracoNegroBodyToggle = makeFuncButton(pagePlayer,"🌪 BlackHole (InMe)", Color3.fromRGB(30, 30, 30))
    local puxarPartsToggle = makeFuncButton(pagePlayer,"🌪 BlackHole (Alvo)", Color3.fromRGB(30, 30, 30))
    local AntiSitToggle = makeFuncButton(pageProtecoes,"🪑🚫 AntiSit [OFF]", Color3.fromRGB(30, 30, 30))
	local dynamicShadowsToggle = makeFuncButton(pageClient, "Shadows [ON]", Color3.fromRGB(30, 30, 30))
	local shadersToggle = makeFuncButton(pageClient, "Best Light [OFF]", Color3.fromRGB(30, 30, 30))
	
	
	local flightFrame = Instance.new("Frame")
	flightFrame.Size = UDim2.new(1, -10, 0, 35)
	flightFrame.BackgroundTransparency = 1
	flightFrame.Parent = pagePlayer
	trackGui(flightFrame)

	local flightToggle = Instance.new("TextButton")
	flightToggle.Size = UDim2.new(0, 180, 1, 0)
	flightToggle.Position = UDim2.new(0, 0, 0, 0)
	flightToggle.Text = "Fly"
	flightToggle.Font = Enum.Font.SourceSansBold
	flightToggle.TextColor3 = Color3.fromRGB(255,255,255)
	flightToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	flightToggle.Parent = flightFrame
	trackGui(flightToggle)

	local flightCorner = Instance.new("UICorner")
	flightCorner.CornerRadius = UDim.new(0, 6)
	flightCorner.Parent = flightToggle

	local speedBox = Instance.new("TextBox")
	speedBox.Size = UDim2.new(1,-190, 1, 0)
	speedBox.Position = UDim2.new(0, 190, 0, 0)
	speedBox.Text = "50"
	speedBox.PlaceholderText = "WalkSpeed"
	speedBox.ClearTextOnFocus = false
	speedBox.Font = Enum.Font.SourceSans
	speedBox.TextColor3 = Color3.fromRGB(255,255,255)
	speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
	speedBox.Parent = flightFrame
	trackGui(speedBox)

	local speedCorner = Instance.new("UICorner")
	speedCorner.CornerRadius = UDim.new(0,6)
	speedCorner.Parent = speedBox

	local speedFrame = Instance.new("Frame")
	speedFrame.Size = UDim2.new(1, -10, 0, 35)
	speedFrame.BackgroundTransparency = 1
	speedFrame.Parent = pagePlayer
	trackGui(speedFrame)

	-- Valor de velocidade, textbox
	local speedValueBox = Instance.new("TextBox")
	speedValueBox.Size = UDim2.new(1, 0, 1, 0)
	speedValueBox.Position = UDim2.new(0, 0, 0, 0)
	speedValueBox.Text = "16"
	speedValueBox.PlaceholderText = "WalkSpeed"
	speedValueBox.ClearTextOnFocus = false
	speedValueBox.Font = Enum.Font.SourceSans
	speedValueBox.TextColor3 = Color3.fromRGB(255,255,255)
	speedValueBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
	speedValueBox.Parent = speedFrame
	trackGui(speedValueBox)

	local speedValueCorner = Instance.new("UICorner")
	speedValueCorner.CornerRadius = UDim.new(0,6)
	speedValueCorner.Parent = speedValueBox

	local tpToPlayerButton = makeFuncButton(pageTroll, "➡️ Go to Player")
	local tpBackButton = makeFuncButton(pageTroll, "⬅️ Come Back")
	local viewPlayerButton = makeFuncButton(pageTroll, "🔍View Player [OFF]")
	local killPlayerButton = makeFuncButton(pageTroll, "Kill Player")
    local killAllButton = makeFuncButton(pageTroll, "Kill All")
    local bringPlayerButton = makeFuncButton(pageTroll, "Bring Player")
    local bringAllButton = makeFuncButton(pageTroll, "Bring All")
	local debugToggle = Instance.new("TextButton")
	debugToggle.Name = "DebugToggle"
	debugToggle.Size = UDim2.new(1, -10, 0, 35) -- Ajuste de layout
	debugToggle.Text = "⚙️ Mostrar Debug [OFF]"
	debugToggle.TextColor3 = Color3.fromRGB(200,70,70)
	debugToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
	debugToggle.Font = Enum.Font.SourceSansBold
	debugToggle.TextScaled = true
	debugToggle.Parent = pageDebug
	trackGui(debugToggle)

	local debugOverlay = Instance.new("TextLabel")
	debugOverlay.Name = "DebugOverlay"
	debugOverlay.Size = UDim2.new(0, 340, 0, 160)
	debugOverlay.Position = UDim2.new(0, 10, 0, 10)
	debugOverlay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	debugOverlay.TextColor3 = Color3.fromRGB(255, 255, 255)
	debugOverlay.TextXAlignment = Enum.TextXAlignment.Left
	debugOverlay.TextYAlignment = Enum.TextYAlignment.Top
	debugOverlay.TextWrapped = true
	debugOverlay.Visible = false
	debugOverlay.Font = Enum.Font.SourceSansBold
	debugOverlay.TextScaled = true
	debugOverlay.TextSize = 18
	debugOverlay.Parent = loboHubGui
	trackGui(debugOverlay)

	local debugCorner = Instance.new("UICorner")
	debugCorner.CornerRadius = UDim.new(0,6)
	debugCorner.Parent = debugOverlay


	local function setToggleColor(button, active)
		if not button then return end
		local onColor = Color3.fromRGB(70, 70, 70)
		local offColor = Color3.fromRGB(30, 30, 30)
		pcall(function()
			local tween = TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = active and onColor or offColor})
			tween:Play()
		end)
	end

	local function applyNoclip()
		local char = player.Character
		if not char then return end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	local function restoreNoclip()
		for _, data in ipairs(colisoesSalvas) do
			if data.part and data.part.Parent then data.part.CanCollide = data.collision end
		end
		colisoesSalvas = {}
	end

	local function startNoclipForce()
		if noclipForceConnection then safeDisconnect(noclipForceConnection) end
		noclipForceConnection = RunService.Heartbeat:Connect(function()
			if noclipAtivo then
				applyNoclip()
			else
				safeDisconnect(noclipForceConnection)
			end
		end)
		trackConnection(noclipForceConnection)
	end

	local function stopNoclipForce()
		if noclipForceConnection then safeDisconnect(noclipForceConnection); noclipForceConnection = nil end
	end

	local function applySpeedValue()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local newSpeed = tonumber(speedValueBox.Text)
	if not newSpeed or newSpeed <= 0 then
		newSpeed = 16
	end
	if newSpeed > 500 then newSpeed = 500 end

	if hum.WalkSpeed ~= originalWalkSpeed and hum.WalkSpeed ~= newSpeed then
		originalWalkSpeed = hum.WalkSpeed
	end

	hum.WalkSpeed = newSpeed

	hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		local expectedSpeed = tonumber(speedValueBox.Text)
		if not expectedSpeed or expectedSpeed <= 0 then
			expectedSpeed = 16
		end
		if expectedSpeed > 500 then expectedSpeed = 500 end

		if hum.WalkSpeed ~= expectedSpeed then
			hum.WalkSpeed = expectedSpeed
		end
	end)
end

toggleBotao.MouseButton1Click:Connect(function()
	hubVisivel = not hubVisivel
	mainFrame.Visible = hubVisivel
end)

    -- Clique da págia bem-vindo
	tabBemVindo.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = true
		pagePlayer.Visible = false
		pageTroll.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)

    -- Clique da página Player
	tabPlayer.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pagePlayer.Visible = true
		pageTroll.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)

    -- Clique da página funções
	tabTroll.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pagePlayer.Visible = false
		pageTroll.Visible = true
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)
    
    -- Clique da página client
	tabClient.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pagePlayer.Visible = false
		pageTroll.Visible = false
		pageClient.Visible = true
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)
    
    -- Clique da página debug
	tabDebug.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pagePlayer.Visible = false
		pageTroll.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = true
	    pageProtecoes.Visible = false
	end)
	
	-- Clique da página proteções
	tabProtecoes.MouseButton1Click:Connect(function()
	pageBemVindo.Visible = false
	pagePlayer.Visible = false
	pageTroll.Visible = false
	pageClient.Visible = false
	pageDebug.Visible = false
	pageProtecoes.Visible = true
	end)

    -- Informações da página bem-vindo
	do
		local userId = player.UserId
		local thumbType = Enum.ThumbnailType.HeadShot
		local thumbSize = Enum.ThumbnailSize.Size100x100
		local ok, content = pcall(function() return Players:GetUserThumbnailAsync(userId, thumbType, thumbSize) end)
		avatarImg.Image = (ok and content) and content or ""
		apelidoLabel.Text = "Apelido: " .. (player.DisplayName or "N/A")
		arrobaLabel.Text = "Starter Name: " .. (player.Name or "N/A")
		idadeContaLabel.Text = "Idade da Conta: " .. tostring(player.AccountAge or 0) .. " dias"
	end

	discordButton.MouseButton1Click:Connect(function()
		local link = "https://discord.gg/BfMkzJhZe"
		local copied = false
		local ok1 = pcall(function()
			if TextService and typeof(TextService.SetClipboardAsync) == "function" then
				TextService:SetClipboardAsync(link)
			else
				error("no SetClipboardAsync")
			end
		end)
		if ok1 then copied = true end
		if not copied then
			local ok2 = pcall(function() if setclipboard then setclipboard(link) end end)
			if ok2 then copied = true end
		end
		if copied then
			discordButton.Text = "COPIADO!"
		else
			discordButton.Text = "NÃO COPIADO"
		end
		task.wait(2)
		discordButton.Text = "Copiar Discord"
	end)
	

	local function atualizarListaJogadores()
		for _, child in ipairs(playerList:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				local target = p
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, -10, 0, 34)
				btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				btn.TextColor3 = Color3.fromRGB(255,255,255)
				btn.Font = Enum.Font.SourceSansBold
				btn.TextScaled = false
				btn.TextSize = 14
				btn.Text = target.DisplayName .. " (@" .. target.Name .. ")"
				btn.Parent = playerList
				trackGui(btn)
				
				btn.MouseButton1Click:Connect(function()
					jogadorSelecionado = target
					playerSelectButton.Text = target.DisplayName
					playerList.Visible = false
					if viewPlayerAtivo and type(desligarViewPlayer) == "function" then desligarViewPlayer() end
				end)
			end
		end
		
		task.spawn(function()
			task.wait()
			local layout = playerList:FindFirstChildOfClass("UIListLayout")
			if layout then
				playerList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
			end
		end)
	end
    
    -- Botão de selecionar player
	playerSelectButton.MouseButton1Click:Connect(function()
		if playerList.Visible then
			playerList.Visible = false
		else
			atualizarListaJogadores()
			playerList.Visible = true
		end
	end)

	Players.PlayerAdded:Connect(function() if playerList.Visible then atualizarListaJogadores() end end)
	Players.PlayerRemoving:Connect(function(removed)
		if playerList.Visible then atualizarListaJogadores() end
		if jogadorSelecionado and removed == jogadorSelecionado then
			jogadorSelecionado = nil
			playerSelectButton.Text = "👥️ Select Player..."
			if viewPlayerAtivo and type(desligarViewPlayer) == "function" then desligarViewPlayer() end
		end
	end)

	local espConnection = nil

	local function limparESP()
		for _, instancia in pairs(espInstancias) do
			if instancia and instancia.Parent then instancia:Destroy() end
		end
		table.clear(espInstancias)
	end

	local function criarESP(targetPlayer)
		local char = targetPlayer.Character
		if not char then return end
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		-- Cor e aparência do ESP
		highlight.OutlineColor = Color3.fromRGB(100, 200, 255)
		highlight.OutlineTransparency = 0
		highlight.Parent = char
		table.insert(espInstancias, highlight)

		local head = char:FindFirstChild("Head")    
		if not head then return end    
		local billGui = Instance.new("BillboardGui")    
		billGui.Name = "ESP_Name"    
		billGui.Adornee = head    
		billGui.Size = UDim2.new(0, 200, 0, 50)    
		billGui.StudsOffset = Vector3.new(0, 2.5, 0)    
		billGui.AlwaysOnTop = true    
		billGui.Parent = head    
		local textLabel = Instance.new("TextLabel")    
		textLabel.Text = "" .. targetPlayer.Name    
		textLabel.Size = UDim2.new(1, 0, 1, 0)    
		textLabel.BackgroundTransparency = 1    
		-- Cor do texto do ESP
		textLabel.TextColor3 = Color3.fromRGB(100, 200, 255)    
		textLabel.TextScaled = false
		textLabel.TextSize = 12 
		textLabel.Font = Enum.Font.SourceSansBold    
		textLabel.Parent = billGui    
		table.insert(espInstancias, billGui)
	end

    -- Lógica do ESP
	espToggle.MouseButton1Click:Connect(function()
		espAtivo = not espAtivo
		espToggle.Text = "ꙮ ESP" .. (espAtivo and " [ON]" or " [OFF]")
		setToggleColor(espToggle, espAtivo)
		if espAtivo then
			if espConnection then safeDisconnect(espConnection); espConnection = nil end
			espConnection = RunService.RenderStepped:Connect(function()
				if not espAtivo then return end
				limparESP()
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= player and p.Character then
						criarESP(p)
					end
				end
			end)
			trackConnection(espConnection)
		else
			limparESP()
			if espConnection then safeDisconnect(espConnection); espConnection = nil end
		end
	end)

-- Função que detecta clique ou toque e teleporta
local function onClickToTeleport(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local char = player.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end

		local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
		local rp = RaycastParams.new()
		rp.FilterDescendantsInstances = {char}
		rp.FilterType = Enum.RaycastFilterType.Exclude

		local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
		if res then
			char.HumanoidRootPart.CFrame = CFrame.new(res.Position)
		end
	end
end

-- Função que cria a ferramenta Click TP
local function giveClickTPTool()
	if player.Backpack:FindFirstChild("ClickTPTool") or (player.Character and player.Character:FindFirstChild("ClickTPTool")) then
		return
	end

	local tool = Instance.new("Tool")
	tool.Name = "ClickTPTool"
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.Parent = player.Backpack

	-- Conecta a ativação do TP ao equipar a ferramenta
	tool.Equipped:Connect(function()
		if conexaoClickTP then safeDisconnect(conexaoClickTP); conexaoClickTP = nil end
		conexaoClickTP = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				onClickToTeleport(input, gameProcessed)
			end
		end)
		trackConnection(conexaoClickTP)
	end)

	-- Desconecta ao desequipar a ferramenta
	tool.Unequipped:Connect(function()
		if conexaoClickTP then safeDisconnect(conexaoClickTP); conexaoClickTP = nil end
	end)
end

-- Função que remove a ferramenta Click TP
local function removeClickTPTool()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		pcall(function() humanoid:UnequipTools() end)
	end

	local tool = player.Backpack:FindFirstChild("ClickTPTool") or (player.Character and player.Character:FindFirstChild("ClickTPTool"))
	if tool then
		tool:Destroy()
	end

	if conexaoClickTP then safeDisconnect(conexaoClickTP); conexaoClickTP = nil end
end

-- Toggle do botão original
clickTPToggle.MouseButton1Click:Connect(function()
	clickTpAtivo = not clickTpAtivo
	local base = "👆 Click TP"
	clickTPToggle.Text = base .. (clickTpAtivo and " [ON]" or " [OFF]")
	setToggleColor(clickTPToggle, clickTpAtivo)

	if clickTpAtivo then
		giveClickTPTool()
	else
		removeClickTPTool()
	end
end)
    -- Lógica do noclip
	noclipToggle.MouseButton1Click:Connect(function()
		noclipAtivo = not noclipAtivo
		local base = "⿻ Noclip"
		noclipToggle.Text = base .. (noclipAtivo and " [ON]" or " [OFF]")
		setToggleColor(noclipToggle, noclipAtivo)
		local char = player.Character
		
		if not char then 
			if noclipAtivo then
			end
			noclipAtivo = false
			noclipToggle.Text = base .. " [OFF]"
			setToggleColor(noclipToggle, noclipAtivo)
			stopNoclipForce()
			return 
		end
		
		if noclipAtivo then
			colisoesSalvas = {}
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(colisoesSalvas, {part = part, collision = part.CanCollide})
					part.CanCollide = false
				end
			end
			startNoclipForce()
		else
			stopNoclipForce()
			for _, data in ipairs(colisoesSalvas) do
				if data.part and data.part.Parent then data.part.CanCollide = data.collision end
			end
			colisoesSalvas = {}
		end
	end)
	
	-- Lógica do infinite jump
	infiniteJumpToggle.MouseButton1Click:Connect(function()
		infiniteJumpAtivo = not infiniteJumpAtivo
		infiniteJumpToggle.Text = "∞ Pulo Infinito " .. (infiniteJumpAtivo and "[ON]" or "[OFF]")
		setToggleColor(infiniteJumpToggle, infiniteJumpAtivo)

		if infiniteJumpAtivo then
			infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
			trackConnection(infiniteJumpConnection)
		else
			if infiniteJumpConnection then safeDisconnect(infiniteJumpConnection) end
		end
	end)
	
-- Lógica do AntiSit	
AntiSitToggle.MouseButton1Click:Connect(function()
	AntiSitAtivo = not AntiSitAtivo
	AntiSitToggle.Text = "🪑🚫 AntiSit " .. (AntiSitAtivo and "[ON]" or "[OFF]")
	setToggleColor(AntiSitToggle, AntiSitAtivo)

	if AntiSitAtivo then
		
		local Player = Players.LocalPlayer

		local function disableSeat(seat)
			if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
				seat.Disabled = true
				seat.CanTouch = false
			end
		end
		
		for _, obj in ipairs(Workspace:GetDescendants()) do
			disableSeat(obj)
		end
		
		DescendantAddedConn = Workspace.DescendantAdded:Connect(function(obj)
			task.spawn(function()
				task.wait(0.1)
				disableSeat(obj)
			end)
		end)
		trackConnection(DescendantAddedConn)
		
		local function setupAntiSit(Char)
			local Humanoid = Char:WaitForChild("Humanoid", 5)
			if not Humanoid then return end
			
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			
			if HeartbeatConn then safeDisconnect(HeartbeatConn) end
			if SitChangedConn then safeDisconnect(SitChangedConn) end
			if SeatedConn then safeDisconnect(SeatedConn) end
			
			HeartbeatConn = RunService.Heartbeat:Connect(function()
				if Humanoid.Parent and Humanoid.Sit then
					Humanoid.Sit = false
				end
			end)
			trackConnection(HeartbeatConn)
			
			SitChangedConn = Humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
				if Humanoid.Sit then
					Humanoid.Sit = false
				end
			end)
			trackConnection(SitChangedConn)
			
			SeatedConn = Humanoid.Seated:Connect(function(active)
				if active then
					Humanoid.Sit = false
				end
			end)
			trackConnection(SeatedConn)
		end
		
		if Player.Character then
			setupAntiSit(Player.Character)
		end
		
		CharAddedConn = Player.CharacterAdded:Connect(setupAntiSit)
		trackConnection(CharAddedConn)
		
	else -- Desconecta e reverte o AntiSit
		
		-- Desconecta todas as conexões do AntiSit
		if HeartbeatConn then safeDisconnect(HeartbeatConn) HeartbeatConn = nil end
		if SitChangedConn then safeDisconnect(SitChangedConn) SitChangedConn = nil end
		if SeatedConn then safeDisconnect(SeatedConn) SeatedConn = nil end
		if CharAddedConn then safeDisconnect(CharAddedConn) CharAddedConn = nil end
		if DescendantAddedConn then safeDisconnect(DescendantAddedConn) DescendantAddedConn = nil end

		-- Reativa o estado 'Seated' no Humanoid
		local char = Players.LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		end
		
		-- Tenta reativar a colisão e estado Disabled dos assentos no Workspace
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                obj.Disabled = false
                obj.CanTouch = true
            end
        end
	end
end)

BuracoNegroBodyToggle.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/luauhubs666/Blackhole-BETA/refs/heads/main/.gitignore"))()
end)


	speedValueBox:GetPropertyChangedSignal("Text"):Connect(function()
		applySpeedValue()
	end)

	speedValueBox.FocusLost:Connect(function(enterPressed)
		applySpeedValue()
	end)

	player.CharacterAdded:Connect(function(char)
		if noclipAtivo then
			task.wait(0.5)
			colisoesSalvas = {}
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(colisoesSalvas, {part = part, collision = part.CanCollide})
					part.CanCollide = false
				end
			end
			startNoclipForce()
		else
			stopNoclipForce()
		end
		
		task.wait(0.5)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			originalWalkSpeed = hum.WalkSpeed
			applySpeedValue() -- Aplicar valor de velocidade
		end
	end)

	dynamicShadowsToggle.Text = "Shadows [ON]"
	setToggleColor(dynamicShadowsToggle, false)

	dynamicShadowsToggle.MouseButton1Click:Connect(function()
		dynamicShadowsAtivo = not dynamicShadowsAtivo

		if dynamicShadowsAtivo then
			local Lighting = game:GetService("Lighting")
			Lighting.GlobalShadows = false
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.CastShadow = false
				end
			end
			dynamicShadowsToggle.Text = "Shadows [OFF]"
			setToggleColor(dynamicShadowsToggle, true)
		else
			local Lighting = game:GetService("Lighting")
			Lighting.GlobalShadows = true
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.CastShadow = true
				end
			end
			dynamicShadowsToggle.Text = "Shadows [ON]"
			setToggleColor(dynamicShadowsToggle, false)
		end
	end)

	local flying = false
	local flightBv = nil
	local flightRenderConn = nil

	local function getFlightSpeed()
		local v = tonumber(speedBox.Text)
		if not v or v <= 0 then return 50 end
		if v < 5 then v = 5 end
		if v > 500 then v = 500 end
		return v
	end

-- Iniciar voo
local function startFlight()
	if flying then return end
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return
	end

	-- Limpar forças anteriores
	for _, v in pairs(hrp:GetChildren()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") then
			v:Destroy()
		end
	end

	local bv = Instance.new("BodyVelocity")    
	bv.Name = "LoboFlyBV"    
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
	bv.Velocity = Vector3.new(0,0,0)    
	bv.P = 1250    
	bv.Parent = hrp    
	trackBody(bv)    

	flying = true    
	flightBv = bv    

	humanoid.PlatformStand = true 
	humanoid.AutoRotate = false

	local animateScript = char:FindFirstChild("Animate")
	if animateScript then
		animateScript.Disabled = true
	end
	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop()
	end

	flightRenderConn = RunService.RenderStepped:Connect(function(dt)    
		if not flying or not hrp or not hrp.Parent then return end    

		local speed = getFlightSpeed()

		local camLook = camera.CFrame.LookVector
		local camRight = camera.CFrame.RightVector

		-- A CORREÇÃO ESTÁ AQUI EMBAIXO:
		-- Zeramos a velocidade de rotação física para ela não brigar com o CFrame
		hrp.RotVelocity = Vector3.new(0,0,0)
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + camLook)

		local moveDir = humanoid.MoveDirection 
		local camLookFlat = (camLook * Vector3.new(1,0,1)).Unit
		local camRightFlat = (camRight * Vector3.new(1,0,1)).Unit

		local fwdInput = 0
		local sideInput = 0

		if moveDir.Magnitude > 0 then
			fwdInput = moveDir:Dot(camLookFlat)
			sideInput = moveDir:Dot(camRightFlat)
		end

		local finalVelocity = (camLook * fwdInput + camRight * sideInput) * speed

		pcall(function()    
			if flightBv then flightBv.Velocity = finalVelocity end    
		end)    
	end)    
	trackConnection(flightRenderConn)
end

-- Parar de voar
local function stopFlight()
	if not flying then return end
	flying = false
	if flightRenderConn then safeDisconnect(flightRenderConn); flightRenderConn = nil end
	if flightBv and flightBv.Parent then safeDestroy(flightBv) end
	flightBv = nil

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then 
			hum.PlatformStand = false 
			hum.AutoRotate = true
		end
		-- Ao sair do voo, é bom garantir que não sobrou inércia
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.RotVelocity = Vector3.new(0,0,0) end
		
		local animateScript = char:FindFirstChild("Animate")
		if animateScript then animateScript.Disabled = false end
	end
end

flightToggle.MouseButton1Click:Connect(function()
	if flying then
		stopFlight()
		flightToggle.Text = "Fly"
		setToggleColor(flightToggle, false)
	else
		startFlight()
		flightToggle.Text = "Fly"
		setToggleColor(flightToggle, true)
	end
end)

	tpToPlayerButton.MouseButton1Click:Connect(function()
		if not jogadorSelecionado then return end
		local char = player.Character
		local targetChar = jogadorSelecionado.Character
		if char and targetChar and targetChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
			posicaoSalva = char.HumanoidRootPart.CFrame
			char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame
		else
		end
	end)

	tpBackButton.MouseButton1Click:Connect(function()
		if not posicaoSalva then return end
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = posicaoSalva
			posicaoSalva = nil
		end
	end)

	local function desligarViewPlayer()
		if cameraBackupSubject then pcall(function() camera.CameraSubject = cameraBackupSubject end) end
		if cameraBackupType then pcall(function() camera.CameraType = cameraBackupType end) end
		if not camera.CameraSubject or camera.CameraSubject == nil then
			local localHum = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
			if localHum then pcall(function() camera.CameraSubject = localHum; camera.CameraType = Enum.CameraType.Custom end) end
		end
		viewPlayerAtivo = false
		viewPlayerButton.Text = "🔍 View Player [OFF]"
		setToggleColor(viewPlayerButton, false)
		if viewConnection then safeDisconnect(viewConnection); viewConnection = nil end
	end

	local function ligarViewPlayer()
		if not jogadorSelecionado then return end
		if not jogadorSelecionado.Character then return end
		local targetHumanoid = jogadorSelecionado.Character:FindFirstChildWhichIsA("Humanoid")
		if not targetHumanoid then return end
		cameraBackupSubject = camera.CameraSubject
		cameraBackupType = camera.CameraType
		pcall(function() camera.CameraSubject = targetHumanoid; camera.CameraType = Enum.CameraType.Custom end)
		viewPlayerAtivo = true
		viewPlayerButton.Text = "🔍 View Player [ON]"
		setToggleColor(viewPlayerButton, true)
            -- Reconectar a câmera de view mesmo após a morte do alvo
		viewConnection = RunService.RenderStepped:Connect(function()
			if not viewPlayerAtivo then return end
			
			-- Se o jogador saiu do jogo, desliga o view
			if not jogadorSelecionado or not jogadorSelecionado.Parent then 
				desligarViewPlayer()
				return 
			end
			
			local targChar = jogadorSelecionado.Character
			if targChar then
				local targetHum = targChar:FindFirstChildWhichIsA("Humanoid")
				if targetHum then
					-- Reconecta se a câmera perdeu o foco (ex: respawn)
					if camera.CameraSubject ~= targetHum then
						pcall(function() 
							camera.CameraSubject = targetHum
							camera.CameraType = Enum.CameraType.Custom 
						end)
					end
				end
			end
			-- Se não tiver char, apenas aguarda sem desligar
		end)
		trackConnection(viewConnection)
	end

	viewPlayerButton.MouseButton1Click:Connect(function()
		if not viewPlayerAtivo then ligarViewPlayer() else desligarViewPlayer() end
	end)

	player.CharacterAdded:Connect(function()
		if viewPlayerAtivo then desligarViewPlayer() end
	end)

	local function tryGetPingMs()
		local ok, res = pcall(function()
			if player and player.GetNetworkPing then
				local p = player:GetNetworkPing()
				if type(p) == "number" then return math.floor(p * 1000) end
			end
			return nil
		end)
		if ok then return res else return nil end
	end

	local function detectDevice() return UserInputService.TouchEnabled and "Mobile/Tablet" or "PC/Other" end
	local function formatMemoryMB() local kb = collectgarbage("count") or 0; return string.format("%.2f MB (Lua)", kb / 1024) end
	local function tryGetTotalMemoryMB()
		local ok, res = pcall(function()
			if StatsService and type(StatsService.GetTotalMemoryUsageMb) == "function" then return StatsService:GetTotalMemoryUsageMb() end
			if StatsService and type(StatsService.GetTotalMemoryUsage) == "function" then return StatsService:GetTotalMemoryUsage() end
			return nil
		end)
		if ok then return res else return nil end
	end

	local function computeEstimates(workTime, dt, fps)
		local cpuPct = 0
		if dt and dt > 0 then cpuPct = math.floor(math.clamp((workTime / dt) * 100, 0, 100)) end
		local gpuPct = math.floor(math.clamp((1 - math.min(fps / 60, 1)) * 100, 0, 100))
		return cpuPct, gpuPct
	end

	local function updateDebugOverlay(dt, workTime)
		local fps = 1 / math.max(dt, 0.0001)
		fpsSmoothed = fpsSmoothed * (1 - smoothingAlpha) + fps * smoothingAlpha
		local pingMs = tryGetPingMs()
		local pingText = pingMs and (tostring(pingMs) .. " ms") or "N/D"
		local device = detectDevice()
		local luaMem = formatMemoryMB()
		local totalMem = tryGetTotalMemoryMB()
		local totalMemText = totalMem and (string.format("%.2f MB (total)", totalMem)) or "N/D"
		local cpuPct, gpuPct = computeEstimates(workTime, dt, fpsSmoothed)
		local text = string.format(
			"FPS: %.1f\nPing: %s\nCPU (est): %d%%\nGPU (est): %d%%\nLua RAM: %s\nMemória total: %s\nDispositivo: %s",
			fpsSmoothed, pingText, cpuPct, gpuPct, luaMem, totalMemText, device
		)
		debugOverlay.Text = text
	end

	debugToggle.MouseButton1Click:Connect(function()
		if not debugAtivo then
			debugAtivo = true
			debugToggle.Text = "⚙️ Mostrar Debug [ON]"
			debugOverlay.Visible = true
			if debugConnection then safeDisconnect(debugConnection); debugConnection = nil end
			debugConnection = RunService.RenderStepped:Connect(function(dt)
				local t0 = tick()
				updateDebugOverlay(dt, 0)
				local t1 = tick()
				updateDebugOverlay(dt, t1 - t0)
			end)
			trackConnection(debugConnection)
		else
			debugAtivo = false
			debugToggle.Text = "⚙️ Mostrar Debug [OFF]"
			debugOverlay.Visible = false
			if debugConnection then safeDisconnect(debugConnection); debugConnection = nil end
		end
	end)

sofaButton.MouseButton1Click:Connect(function()
	local args = {
		[1] = "PickingTools",
		[2] = "Couch"
	}

	-- Chama a função do servidor para pegar o item diretamente
	local success, result = pcall(function()
		return game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer(unpack(args))
	end)

	if success and result then
		-- A RE:InvokeServer normalmente retorna algo se deu certo ou nil se não implementado
	elseif not success then
		-- Se InvokeServer falhar (ex: erro no servidor ou não existe)
	else
		-- Se InvokeServer existir mas retornar algo que sugira falha na lógica do servidor
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer


killAllButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    local RunService = game:GetService("RunService")

    local savedCFrame = root.CFrame      
      
    -- Imortalidade total      
    hum.PlatformStand = true      
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do      
        if state ~= Enum.HumanoidStateType.None then      
            hum:SetStateEnabled(state, false)      
        end      
    end      
      
    -- Baseplates de segurança      
    local p1 = Instance.new("Part", workspace)      
    p1.Size = Vector3.new(800,1,800); p1.Anchored = true; p1.CanCollide = true      
    p1.Transparency = 1; p1.CFrame = CFrame.new(0,-195,0)      
      
    local p2 = Instance.new("Part", workspace)      
    p2.Size = Vector3.new(1200,1,1200); p2.Anchored = true; p2.CanCollide = true      
    p2.Transparency = 1; p2.CFrame = CFrame.new(0,-250,0)      
      
    -- Nunca morre      
    local neverDie = RunService.Heartbeat:Connect(function()      
        if root.Position.Y <= -245 then      
            root.CFrame = savedCFrame      
            root.Velocity = Vector3.zero      
        end      
    end)      
      
    -- Giro insano (Mantido separado para manter o caos)
    local spin = RunService.Heartbeat:Connect(function(dt)      
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(3000)*dt, 0)      
    end)      
      
    -- Função pra pegar Couch novo      
    local function equipCouch()      
        local tool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")      
        if not tool then      
            game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "Couch")      
            repeat task.wait()      
                tool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")      
            until tool      
        end      
        hum:EquipTool(tool)      
        task.wait(0.1)      
    end      
      
    -- Primeiro equipa o couch      
    equipCouch()      
      
    -- Coleta alvos vivos, de pé e que ainda estão no jogo      
    local targets = {}      
    for _, plr in ipairs(game.Players:GetPlayers()) do      
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then      
            local tHum = plr.Character.Humanoid      
            if tHum.Health > 0 and tHum.Sit == false then      
                table.insert(targets, plr)      
            end      
        end      
    end      
      
      
    -- MATA TODOS      
    for i, plr in ipairs(targets) do      
        local tChar = plr.Character      
        if not tChar or not tChar:FindFirstChild("HumanoidRootPart") or not plr.Parent then continue end -- desistiu se saiu      
        local tRoot = tChar.HumanoidRootPart      
        local tHum = tChar.Humanoid      
      
        -- Ignora completamente quem está sentado ou já morreu      
        if tHum.Health <= 0 or tHum.Sit then continue end      
      
        -- Couch novo pra cada vítima      
        equipCouch()      
      
        -- Marcador de tempo para o Timeout (10 segundos)
        local startTime = tick()
        local timedOut = false

        -- Persegue até sentar, algo errado acontecer ou dar o tempo limite
        repeat      
            tChar = plr.Character      
            if not tChar or not tChar:FindFirstChild("HumanoidRootPart") or not plr.Parent then break end      
            tRoot = tChar.HumanoidRootPart      
            tHum = tChar.Humanoid      
      
            if tHum.Sit or tHum.Health <= 0 then break end      
            
            -- Timeout check
            if tick() - startTime > 10 then
                timedOut = true
                break 
            end

            -- LÓGICA DO CAOS: ALEATORIEDADE (CIMA/BAIXO)
            -- math.random() retorna entre 0 e 1. Se for maior que 0.5 vai pra cima.
            if math.random() > 0.5 then
                -- CIMA: 4 studs pra cima E rotaciona 180 graus (math.pi) no eixo Z pra ficar de ponta cabeça
                root.CFrame = tRoot.CFrame * CFrame.new(0, 4, 0) * CFrame.Angles(0, 0, math.pi)
            else
                -- BAIXO: 4 studs pra baixo (Padrão)
                root.CFrame = tRoot.CFrame * CFrame.new(0, -4, 0)
            end

            root.Velocity = Vector3.zero      
            task.wait()      
        until tHum.Sit or tHum.Health <= 0 or not plr.Parent      
      
        -- Só mata se realmente sentou e não deu timeout
        if not timedOut and tHum.Sit and plr.Parent and tRoot.Parent then      
            root.CFrame = CFrame.new(root.Position.X, -200, root.Position.Z)      
            task.wait(0.5)      
            hum:UnequipTools()      
            task.wait(0.2)      
            root.CFrame = savedCFrame      
      
            -- Deleta o Couch      
            task.spawn(function()      
                task.wait(0.1)      
                pcall(function()      
                    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("PlayerWantsToDeleteTool", "Couch")      
                end)      
                for _, obj in {char, player.Backpack, player:FindFirstChild("StarterGear")} do      
                    if obj then      
                        local c = obj:FindFirstChild("Couch")      
                        if c then c:Destroy() end      
                    end      
                end      
            end)      
        else
            -- Falhou ou Timeout
            hum:UnequipTools()
            root.CFrame = savedCFrame 
        end      
      
        -- Delay anti-lag
        task.wait(0.4)      
    end      
      
    -- Limpeza final     
    root.CFrame = savedCFrame
    spin:Disconnect()      
    neverDie:Disconnect()      
    hum.PlatformStand = false      
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do      
        if state ~= Enum.HumanoidStateType.None then      
            hum:SetStateEnabled(state, true)      
        end      
    end      
    p1:Destroy()      
    p2:Destroy()
end)

killPlayerButton.MouseButton1Click:Connect(function()
    if not jogadorSelecionado then return end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    local targetChar = jogadorSelecionado.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

    if not hum or not root or not targetRoot or not targetHum then return end

    local savedCFrame = root.CFrame
    local startTime = tick()
    local alternarVelocidade = 4

    hum.PlatformStand = true
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state ~= Enum.HumanoidStateType.None then
            hum:SetStateEnabled(state, false)
        end
    end

    local plate1 = Instance.new("Part")
    plate1.Size = Vector3.new(400, 1, 400); plate1.Anchored = true; plate1.CanCollide = true; plate1.Transparency = 1; plate1.CFrame = CFrame.new(0, -195, 0); plate1.Parent = workspace
    local plate2 = Instance.new("Part")
    plate2.Size = Vector3.new(600, 1, 600); plate2.Anchored = true; plate2.CanCollide = true; plate2.Transparency = 1; plate2.CFrame = CFrame.new(0, -250, 0); plate2.Parent = workspace

    local neverDie = RunService.Heartbeat:Connect(function()
        if root and root.Parent and root.Position.Y <= -260 then
            root.CFrame = savedCFrame
            root.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    local couchTool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")
    if not couchTool then
        local remote = ReplicatedStorage:FindFirstChild("RE")
        if remote and remote:FindFirstChild("1Too1l") then
            remote["1Too1l"]:InvokeServer("PickingTools", "Couch")
            local toolWaitStart = tick()
            repeat task.wait()
                couchTool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")
            until couchTool or (tick() - toolWaitStart) > 5
        end
    end

    if couchTool and hum then 
        hum:EquipTool(couchTool) 
    end

    while task.wait() do 
        if (tick() - startTime) > 10 then break end 
        if not targetRoot or not targetRoot.Parent or not targetHum or targetHum.Health <= 0 then break end

        local spinY = math.rad((tick() * 1500) % 360)
        local targetPos = targetRoot.Position
        
        local alternar = math.sin(tick() * alternarVelocidade)
        local isAbove = alternar > 0
        local offsetY = isAbove and 4 or -4

        if isAbove then
            root.CFrame = CFrame.new(targetPos.X, targetPos.Y + offsetY, targetPos.Z) * CFrame.Angles(math.pi, spinY, 0)
        else
            root.CFrame = CFrame.new(targetPos.X, targetPos.Y + offsetY, targetPos.Z) * CFrame.Angles(0, spinY, 0)
        end
        
        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero

        if targetHum.Sit then
            root.CFrame = CFrame.new(root.Position.X, -200, root.Position.Z)
            root.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.8)
            hum:UnequipTools()
            break
        end
    end

    if neverDie then neverDie:Disconnect() end

    local safetyChecks = 0
    while char:FindFirstChild("Couch") and safetyChecks < 30 do
        hum:UnequipTools()
        task.wait()
        safetyChecks = safetyChecks + 1
    end

    hum.PlatformStand = false
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state ~= Enum.HumanoidStateType.None then
            hum:SetStateEnabled(state, true)
        end
    end

    task.wait()
    root.CFrame = savedCFrame
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero

    task.spawn(function()
        task.wait()
        local clearRemote = ReplicatedStorage:FindFirstChild("RE")
        if clearRemote and clearRemote:FindFirstChild("1Clea1rTool1s") then
            clearRemote["1Clea1rTool1s"]:FireServer("PlayerWantsToDeleteTool", "Couch")
        end
        for _, obj in pairs({char, player.Backpack, player:FindFirstChild("StarterGear")}) do
            if obj then
                local t = obj:FindFirstChild("Couch")
                if t then t:Destroy() end
            end
        end
    end)

    if plate1 then plate1:Destroy() end
    if plate2 then plate2:Destroy() end
end)

-- BringPlayer lógica
bringPlayerButton.MouseButton1Click:Connect(function()
    if not jogadorSelecionado then
        return
    end

    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetChar = jogadorSelecionado.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

    if not hum or not root or not targetRoot or not targetHum then
        return
    end

    local savedCFrame = root.CFrame

    -- Pose rígida total
    hum.PlatformStand = true
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state ~= Enum.HumanoidStateType.None then
            hum:SetStateEnabled(state, false)
        end
    end

    -- Pega o Couch
    local couchTool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")
    if not couchTool then
        game:GetService("ReplicatedStorage").RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
        repeat task.wait() couchTool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")
        until couchTool
    end
    hum:EquipTool(couchTool)

    -- Giro enquanto espera sentar
    local spin = game:GetService("RunService").Heartbeat:Connect(function(dt)
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(3000)*dt, 0)
    end)

    local startTime = tick() -- Marca o tempo de início para o timeout

    -- Espera o alvo sentar
    while task.wait() do
        if not targetRoot.Parent or not targetHum.Parent then break end
        
        -- Timeout: Se passar de 10 segundos, desiste
        if tick() - startTime > 10 then
            if spin then spin:Disconnect() end
            root.CFrame = savedCFrame -- Volta para posição original
            hum:UnequipTools() -- Solta a ferramenta
            break
        end

        -- Garante que o player está posicionado para forçar o assento (Com randomização de altura)
        -- Teleporta +4 metros acima e -4 abaixo de forma aleatória
        root.CFrame = targetRoot.CFrame * CFrame.new(1, math.random(-4, 4), 0)
        root.Velocity = Vector3.new(0,0,0)

        if targetHum.Sit then
            spin:Disconnect()
            
            -- VOLTA IMEDIATAMENTE para a posição salva
            root.CFrame = savedCFrame

            -- SOLTA O COUCH
            task.wait(0.5) -- Pequena espera para garantir que o alvo sentou e registrou
            hum:UnequipTools()

            -- SÓ AGORA deleta o Couch (você já voltou, alvo cai)
            task.spawn(function()
                task.wait(0.1)
                pcall(function()
                    local args = {"PlayerWantsToDeleteTool", "Couch"}
                    game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer(unpack(args))
                end)
                for _, obj in {char, player.Backpack, player:FindFirstChild("StarterGear")} do
                    if obj then
                        local t = obj:FindFirstChild("Couch")
                        if t then t:Destroy() end
                    end
                end
            end)

            break
        end
    end

    -- Limpeza final
    -- A conexão 'neverDie' e as 'plate' foram removidas daqui.
    hum.PlatformStand = false
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state ~= Enum.HumanoidStateType.None then
            hum:SetStateEnabled(state, true)
        end
    end
end)

bringAllButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    local RunService = game:GetService("RunService")
    local savedCFrame = root.CFrame

    -- Giro (Fling) - Mantido para a física de empurrão
    local spin = RunService.Heartbeat:Connect(function(dt)
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(3000)*dt, 0)
    end)

    -- Função pra pegar Couch
    local function equipCouch()
        local tool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")
        if not tool then
            game:GetService("ReplicatedStorage").RE["1Too1l"]:InvokeServer("PickingTools", "Couch")
            repeat task.wait()
                tool = char:FindFirstChild("Couch") or player.Backpack:FindFirstChild("Couch")
            until tool
        end
        hum:EquipTool(tool)
        task.wait(0.2) -- Delay leve para garantir o equip
        return tool
    end

    -- Coleta alvos
    local targets = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local tHum = plr.Character:FindFirstChild("Humanoid")
            if tHum and tHum.Health > 0 and tHum.Sit == false then
                table.insert(targets, plr)
            end
        end
    end

    -- LOOP PRINCIPAL
    for i, plr in ipairs(targets) do
        local tChar = plr.Character
        if not tChar or not tChar:FindFirstChild("HumanoidRootPart") or not plr.Parent then continue end 
        
        local tRoot = tChar.HumanoidRootPart
        local tHum = tChar.Humanoid
        if tHum.Health <= 0 or tHum.Sit then continue end

        local currentTool = equipCouch()
        local startTime = tick()
        local lastMoveTime = 0

        -- Perseguição Orbitando LENTAMENTE
        repeat
            tChar = plr.Character
            if not tChar or not tChar:FindFirstChild("HumanoidRootPart") or not plr.Parent then break end 
            tRoot = tChar.HumanoidRootPart
            tHum = tChar.Humanoid

            if tHum.Sit or tHum.Health <= 0 then break end 

            -- Trava a pose ereta (Para todas as animações)
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                track:Stop()
            end

            -- Troca de posição a cada 0.5s (Órbita mais lenta para o servidor identificar)
            if tick() - lastMoveTime >= 0.5 then
                local randomOffset = Vector3.new(
                    math.random(-25, 25)/10, 
                    math.random(-25, 25)/10, 
                    math.random(-25, 25)/10
                )
                local targetPos = tRoot.Position + randomOffset
                
                -- Aponta os PÉS para o alvo
                root.CFrame = CFrame.lookAt(targetPos, tRoot.Position) * CFrame.Angles(math.rad(90), 0, 0)
                
                lastMoveTime = tick()
            end
            
            root.Velocity = Vector3.zero
            task.wait()
        until tHum.Sit or tHum.Health <= 0 or not plr.Parent or (tick() - startTime > 12)

        -- SEQUÊNCIA DE FINALIZAÇÃO (LENTA E CLARA)
        if tHum.Sit or (tick() - startTime > 12) then
            -- 1. Teleporta de volta para a coordenada gravada
            root.CFrame = savedCFrame
            
            -- 2. ESPERA 0.5 SEGUNDOS (Obrigatório conforme pedido)
            task.wait(0.5)
            
            -- 3. Tira a ferramenta da mão
            hum:UnequipTools()
            if currentTool then
                currentTool.Parent = player.Backpack
            end
            
            -- 4. ESPERA 1.2 SEGUNDOS (Aumentado para "Demorar" e não ser instantâneo)
            task.wait(1.2)
        end
    end

    -- FINALIZAÇÃO GERAL
    spin:Disconnect()
    hum:UnequipTools()

    task.spawn(function()
        task.wait(0.1)
        pcall(function()
            game:GetService("ReplicatedStorage").RE["1Clea1rTool1s"]:FireServer("PlayerWantsToDeleteTool", "Couch")
        end)
        for _, obj in {char, player.Backpack, player:FindFirstChild("StarterGear")} do
            if obj then
                local c = obj:FindFirstChild("Couch")
                if c then c:Destroy() end
            end
        end
    end)
    
    root.CFrame = savedCFrame
end)


puxarPartsToggle.MouseButton1Click:Connect(function()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local angle = 1
local radius = 10
local blackHoleActive = false
local angleSpeed = 2 
local targetPlayer = LocalPlayer

local originalProps = {}
local charCollisionStates = {}

local function setupPlayer()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local Folder = Instance.new("Folder", Workspace)      
    local Part = Instance.new("Part", Folder)      
    local Attachment1 = Instance.new("Attachment", Part)      
    Part.Anchored = true      
    Part.CanCollide = false      
    Part.Transparency = 1      
    
    return humanoidRootPart, Attachment1
end

local humanoidRootPart, Attachment1 = setupPlayer()

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(part)      
        if typeof(part) == "Instance" and part:IsA("BasePart") and part:IsDescendantOf(Workspace) then      
            table.insert(Network.BaseParts, part)      
            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)      
            part.CanCollide = false      
        end      
    end      
    
    local function EnablePartControl()      
        LocalPlayer.ReplicationFocus = Workspace      
        RunService.Heartbeat:Connect(function()      
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)      
            for _, part in pairs(Network.BaseParts) do      
                if part:IsDescendantOf(Workspace) then      
                    part.Velocity = Network.Velocity      
                end      
            end      
        end)      
    end      
    
    EnablePartControl()
end

local function toggleCharacterCollision(disable)
    local char = LocalPlayer.Character
    if not char then return end

    if disable then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                charCollisionStates[v] = v.CanCollide
                v.CanCollide = false
            end
        end
    else
        for v, state in pairs(charCollisionStates) do
            if v and v.Parent then
                v.CanCollide = state
            end
        end
        charCollisionStates = {}
    end
end

local function ForcePart(v)
    if v:IsA("Part") and not v.Anchored and v.Name ~= "Handle" then
        if LocalPlayer.Character and v:IsDescendantOf(LocalPlayer.Character) then
            return
        end

        local parent = v.Parent
        local parentHasHum = parent and parent:FindFirstChild("Humanoid")
        if parentHasHum and not (targetPlayer and targetPlayer.Character and v:IsDescendantOf(targetPlayer.Character)) then
            return
        end
        
        if not originalProps[v] then
            originalProps[v] = {
                CFrame = v.CFrame,
                Anchored = v.Anchored,
                CanCollide = v.CanCollide,
                Parent = v.Parent
            }
        end

        for _, x in next, v:GetChildren() do
            if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then
            v:FindFirstChild("Attachment"):Destroy()
        end
        if v:FindFirstChild("AlignPosition") then
            v:FindFirstChild("AlignPosition"):Destroy()
        end
        if v:FindFirstChild("Torque") then
            v:FindFirstChild("Torque"):Destroy()
        end
        v.CanCollide = false

        local Torque = Instance.new("Torque", v)      
        Torque.Torque = Vector3.new(1000000, 1000000, 1000000)      
        local AlignPosition = Instance.new("AlignPosition", v)      
        local Attachment2 = Instance.new("Attachment", v)      
        Torque.Attachment0 = Attachment2      
        AlignPosition.MaxForce = math.huge      
        AlignPosition.MaxVelocity = math.huge      
        AlignPosition.Responsiveness = 500      
        AlignPosition.Attachment0 = Attachment2      
        AlignPosition.Attachment1 = Attachment1      
    end
end

local function restoreParts()
    for part, props in pairs(originalProps) do
        if part and part.Parent then
            if part:FindFirstChild("Torque") then part.Torque:Destroy() end
            if part:FindFirstChild("AlignPosition") then part.AlignPosition:Destroy() end
            
            for _, att in pairs(part:GetChildren()) do
                if att:IsA("Attachment") and (att.Parent == part) then 
                    att:Destroy() 
                end
            end

            part.Velocity = Vector3.new(0,0,0)
            part.RotVelocity = Vector3.new(0,0,0)
            part.CanCollide = props.CanCollide
            part.Anchored = props.Anchored 
            part.CFrame = props.CFrame 
        end
    end
    originalProps = {}
end

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    
    if blackHoleActive then
        toggleCharacterCollision(true)

        Workspace.DescendantAdded:Connect(function(v)      
            if blackHoleActive then      
                ForcePart(v)      
            end      
        end)      
    
        spawn(function()      
            while blackHoleActive do
                wait(1)

                for _, v in next, Workspace:GetDescendants() do
                    ForcePart(v)
                end

                angle = angle + math.rad(angleSpeed)

                local torso = nil
                if targetPlayer and targetPlayer.Character then
                    torso = targetPlayer.Character:FindFirstChild("Torso") or targetPlayer.Character:FindFirstChild("UpperTorso") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                end

                if torso then
                    local localOffset = CFrame.Angles(0, angle, 0) * CFrame.new(math.clamp(radius / 10, 0.1, 2), 0, 0)
                    Attachment1.WorldCFrame = torso.CFrame * localOffset
                    humanoidRootPart = torso
                end
            end      
        end)      
    else      
        Attachment1.WorldCFrame = CFrame.new(0, -1000, 0)
        restoreParts() 
        toggleCharacterCollision(false)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if targetPlayer == LocalPlayer then
        humanoidRootPart, Attachment1 = setupPlayer()
    end
    if blackHoleActive then
        blackHoleActive = false 
        toggleBlackHole() 
    end
end)

local library = {}
local windowCount = 0
local sizes = {}
local listOffset = {}
local windows = {}
local pastSliders = {}
local dropdowns = {}
local dropdownSizes = {}
local destroyed

local colorPickers = {}

if game.CoreGui:FindFirstChild('TurtleUiLib') then
    game.CoreGui:FindFirstChild('TurtleUiLib'):Destroy()
    destroyed = true
end

function Lerp(a, b, c)
    return a + ((b - a) * c)
end

local players = game:service('Players');
local player = players.LocalPlayer;
local mouse = player:GetMouse();
local run = game:service('RunService');
local stepped = run.Stepped;
function Dragify(obj)
	spawn(function()
		local minitial;
		local initial;
		local isdragging;
	    obj.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isdragging = true;
				minitial = input.Position;
				initial = obj.Position;
				local con;
                con = stepped:Connect(function()
        			if isdragging then
						local delta = Vector3.new(mouse.X, mouse.Y, 0) - minitial;
						obj.Position = UDim2.new(initial.X.Scale, initial.X.Offset + delta.X, initial.Y.Scale, initial.Y.Offset + delta.Y);
					else
						con:Disconnect();
					end;
                end);
                input.Changed:Connect(function()
    			    if input.UserInputState == Enum.UserInputState.End then
					    isdragging = false;
				    end;
			    end);
		end;
	end);
end)
end

local function protect_gui(obj) 
    if destroyed then
        obj.Parent = game.CoreGui
        return
    end
    if syn and syn.protect_gui then
        syn.protect_gui(obj)
        obj.Parent = game.CoreGui
    elseif PROTOSMASHER_LOADED then
        obj.Parent = get_hidden_gui()
    else
        obj.Parent = game.CoreGui
    end
end
local TurtleUiLib = Instance.new("ScreenGui")

TurtleUiLib.Name = "TurtleUiLib"

protect_gui(TurtleUiLib)

local xOffset = 20

local uis = game:GetService("UserInputService")

local keybindConnection

function library:Destroy()
    TurtleUiLib:Destroy()
    if keybindConnection then
        keybindConnection:Disconnect()
    end
end
function library:Hide()
   TurtleUiLib.Enabled = not TurtleUiLib.Enabled
end	

function library:Keybind(key)
    if keybindConnection then keybindConnection:Disconnect() end

    keybindConnection = uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode[key] then
            TurtleUiLib.Enabled = not TurtleUiLib.Enabled
        end
    end)
end

local function showMessage(text)
    local msg = Instance.new("TextLabel")
    msg.Name = "TLK_Message"
    msg.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
    msg.BorderColor3 = Color3.fromRGB(0,0,0)
    msg.TextColor3 = Color3.fromRGB(255, 110, 110)
    msg.TextSize = 16
    msg.Font = Enum.Font.SourceSansBold
    msg.Text = text or ""
    msg.Size = UDim2.new(0, 220, 0, 26)
    msg.Position = UDim2.new(0, 20, 0, 55)
    msg.ZIndex = 9999
    msg.Parent = TurtleUiLib

    delay(2.5, function()
        if msg and msg.Parent then
            msg:Destroy()
        end
    end)
end

function library:Window(name, closeCallback) 
    windowCount = windowCount + 1
    local winCount = windowCount
    local zindex = winCount * 7
    local UiWindow = Instance.new("Frame")

    UiWindow.Name = "UiWindow"
    UiWindow.Parent = TurtleUiLib
    UiWindow.BackgroundColor3 = Color3.fromRGB(0, 151, 230)
    UiWindow.BorderColor3 = Color3.fromRGB(0, 151, 230)
    UiWindow.Position = UDim2.new(0, xOffset, 0, 20)
    UiWindow.Size = UDim2.new(0, 207, 0, 33)
    UiWindow.ZIndex = 4 + zindex
    UiWindow.Active = true
    Dragify(UiWindow)

    xOffset = xOffset + 230

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = UiWindow
    Header.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
    Header.BorderColor3 = Color3.fromRGB(0, 168, 255)
    Header.Position = UDim2.new(0, 0, -0.0202544238, 0)
    Header.Size = UDim2.new(0, 207, 0, 26)
    Header.ZIndex = 5 + zindex

    local HeaderText = Instance.new("TextLabel")
    HeaderText.Name = "HeaderText"
    HeaderText.Parent = Header
    HeaderText.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    HeaderText.BackgroundTransparency = 1.000
    HeaderText.Position = UDim2.new(0, 0, -0.0020698905, 0)
    HeaderText.Size = UDim2.new(0, 206, 0, 33)
    HeaderText.ZIndex = 6 + zindex
    HeaderText.Font = Enum.Font.SourceSans
    HeaderText.Text = name or "Window"
    HeaderText.TextColor3 = Color3.fromRGB(47, 54, 64)
    HeaderText.TextSize = 17.000

    local Minimise = Instance.new("TextButton")
    local CloseButton = Instance.new("TextButton")
    local Window = Instance.new("Frame")
    
    Minimise.Name = "Minimise"
    Minimise.Parent = Header
    Minimise.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
    Minimise.BorderColor3 = Color3.fromRGB(0, 168, 255)
    Minimise.Position = UDim2.new(0, 163, 0, 2)
    Minimise.Size = UDim2.new(0, 22, 0, 22)
    Minimise.ZIndex = 7 + zindex
    Minimise.Font = Enum.Font.SourceSansLight
    Minimise.Text = "_"
    Minimise.TextColor3 = Color3.fromRGB(0, 0, 0)
    Minimise.TextSize = 20.000
    Minimise.MouseButton1Up:connect(function()
        Window.Visible = not Window.Visible
	    if Window.Visible then
		    Minimise.Text = "_"
	    else
		    Minimise.Text = "+"
	    end
    end)

    CloseButton.Name = "Close"
    CloseButton.Parent = Header
    CloseButton.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
    CloseButton.BorderColor3 = Color3.fromRGB(0, 168, 255)
    CloseButton.Position = UDim2.new(0, 185, 0, 2)
    CloseButton.Size = UDim2.new(0, 22, 0, 22)
    CloseButton.ZIndex = 7 + zindex
    CloseButton.Font = Enum.Font.SourceSansLight
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    CloseButton.TextSize = 20.000
    CloseButton.MouseButton1Up:connect(function()
        if closeCallback then
            closeCallback()
        end
        TurtleUiLib:Destroy()
        destroyed = true
    end)

    Window.Name = "Window"
    Window.Parent = Header
    Window.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
    Window.BorderColor3 = Color3.fromRGB(47, 54, 64)
    Window.Position = UDim2.new(0, 0, 0, 0)
    Window.Size = UDim2.new(0, 207, 0, 33)
    Window.ZIndex = 1 + zindex

    local functions = {}
    sizes[winCount] = 33
    listOffset[winCount] = 10
    function functions:Button(name, callback)
        local name = name or "Button"
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Parent = Window
        Button.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
        Button.BorderColor3 = Color3.fromRGB(113, 128, 147)
        Button.Position = UDim2.new(0, 12, 0, listOffset[winCount])
        Button.Size = UDim2.new(0, 182, 0, 26)
        Button.ZIndex = 2 + zindex
        Button.Selected = true
        Button.Font = Enum.Font.SourceSans
        Button.TextColor3 = Color3.fromRGB(245, 246, 250)
        Button.TextSize = 16.000
        Button.TextStrokeTransparency = 123.000
        Button.TextWrapped = true
        Button.Text = name
        Button.MouseButton1Down:Connect(callback)

        pastSliders[winCount] = false
    end
    function functions:Label(text, color)
        local color = color or Color3.fromRGB(220, 221, 225)

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Parent = Window
        Label.BackgroundColor3 = Color3.fromRGB(220, 221, 225)
        Label.BackgroundTransparency = 1.000
        Label.BorderColor3 = Color3.fromRGB(27, 42, 53)
        Label.Position = UDim2.new(0, 0, 0, listOffset[winCount])
        Label.Size = UDim2.new(0, 206, 0, 29)
        Label.Font = Enum.Font.SourceSans
        Label.Text = text or "Label"
        Label.TextSize = 16.000
        Label.ZIndex = 2 + zindex

        if type(color) == "boolean" and color then
	    spawn(function()
                while wait() do
                    local hue = tick() % 5 / 5
                    Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
                end
	    end)
        else
            Label.TextColor3 = color
        end
        pastSliders[winCount] = false
	
	return Label
    end
    function functions:Toggle(text, on, callback)
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32

        local ToggleDescription = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        local ToggleFiller = Instance.new("Frame")

        ToggleDescription.Name = "ToggleDescription"
        ToggleDescription.Parent = Window
        ToggleDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDescription.BackgroundTransparency = 1.000
        ToggleDescription.Position = UDim2.new(0, 14, 0, listOffset[winCount])
        ToggleDescription.Size = UDim2.new(0, 131, 0, 26)
        ToggleDescription.Font = Enum.Font.SourceSans
        ToggleDescription.Text = text or "Toggle"
        ToggleDescription.TextColor3 = Color3.fromRGB(245, 246, 250)
        ToggleDescription.TextSize = 16.000
        ToggleDescription.TextWrapped = true
        ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDescription.ZIndex = 2 + zindex

        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleDescription
        ToggleButton.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
        ToggleButton.BorderColor3 = Color3.fromRGB(113, 128, 147)
        ToggleButton.Position = UDim2.new(1.2061069, 0, 0.0769230798, 0)
        ToggleButton.Size = UDim2.new(0, 22, 0, 22)
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.TextSize = 14.000
        ToggleButton.ZIndex = 2 + zindex

        ToggleButton.MouseButton1Up:Connect(function()
            ToggleFiller.Visible = not ToggleFiller.Visible
            callback(ToggleFiller.Visible)
        end)

        ToggleFiller.Name = "ToggleFiller"
        ToggleFiller.Parent = ToggleButton
        ToggleFiller.BackgroundColor3 = Color3.fromRGB(68, 189, 50)
        ToggleFiller.BorderColor3 = Color3.fromRGB(47, 54, 64)
        ToggleFiller.Position = UDim2.new(0, 5, 0, 5)
        ToggleFiller.Size = UDim2.new(0, 12, 0, 12)
        ToggleFiller.Visible = on
        ToggleFiller.ZIndex = 2 + zindex
        pastSliders[winCount] = false
        
        local toggleFuncs = {}
        function toggleFuncs:SetState(state)
            ToggleFiller.Visible = state
            callback(state)
        end
        return toggleFuncs
    end
    function functions:Box(text, callback)
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32
        local TextBox = Instance.new("TextBox")
        local BoxDescription = Instance.new("TextLabel")
        TextBox.Parent = Window
        TextBox.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
        TextBox.BorderColor3 = Color3.fromRGB(113, 128, 147)
        TextBox.Position = UDim2.new(0, 99, 0, listOffset[winCount])
        TextBox.Size = UDim2.new(0, 95, 0, 26)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.PlaceholderColor3 = Color3.fromRGB(220, 221, 225)
        TextBox.PlaceholderText = "..."
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(245, 246, 250)
        TextBox.TextSize = 16.000
        TextBox.TextStrokeColor3 = Color3.fromRGB(245, 246, 250)
        TextBox.ZIndex = 2 + zindex
        TextBox:GetPropertyChangedSignal('Text'):connect(function()
            callback(TextBox.Text, false)
        end)
        TextBox.FocusLost:Connect(function()
            callback(TextBox.Text, true)
        end)

        BoxDescription.Name = "BoxDescription"
        BoxDescription.Parent = TextBox
        BoxDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BoxDescription.BackgroundTransparency = 1.000
        BoxDescription.Position = UDim2.new(-0.894736826, 0, 0, 0)
        BoxDescription.Size = UDim2.new(0, 75, 0, 26)
        BoxDescription.Font = Enum.Font.SourceSans
        BoxDescription.Text = text or "Box"
        BoxDescription.TextColor3 = Color3.fromRGB(245, 246, 250)
        BoxDescription.TextSize = 16.000
        BoxDescription.TextXAlignment = Enum.TextXAlignment.Left
        BoxDescription.ZIndex = 2 + zindex
        pastSliders[winCount] = false
    end
    function functions:Slider(text, min, max, default, callback)
        local text = text or "Slider"
        local min = min or 1
        local max = max or 100
        local default = default or max/2
        local callback = callback or function() end
        local offset = 70
        if default > max then
            default = max
        elseif default < min then
            default = min
        end

        if pastSliders[winCount] then
            offset = 60
        end

        sizes[winCount] = sizes[winCount] + offset
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + offset

        local Slider = Instance.new("Frame")
        local SliderButton = Instance.new("Frame")
        local Description = Instance.new("TextLabel")
        local SilderFiller = Instance.new("Frame")
        local Current = Instance.new("TextLabel")
        local Min = Instance.new("TextLabel")
        local Max = Instance.new("TextLabel")

        function SliderMovement(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isdragging = true;
                    minitial = input.Position.X;
                    initial = SliderButton.Position.X.Offset;
                    local delta1 = SliderButton.AbsolutePosition.X - initial
                    local con;
                    con = stepped:Connect(function()
                        if isdragging then
                            local xOffset = mouse.X - delta1 - 3
                            if xOffset > 175 then
                                xOffset = 175
                            elseif xOffset< 0 then
                                xOffset = 0
                            end
                            SliderButton.Position = UDim2.new(0, xOffset , -1.33333337, 0);
                            SilderFiller.Size = UDim2.new(0, xOffset, 0, 6)
                            local value = Lerp(min, max, SliderButton.Position.X.Offset/(Slider.Size.X.Offset-5))
                            Current.Text = tostring(math.round(value))
                        else
                            con:Disconnect();
                        end;
                    end);
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            isdragging = false;
                        end;
                    end);
            end;
        end
        function SliderEnd(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local value = Lerp(min, max, SliderButton.Position.X.Offset/(Slider.Size.X.Offset-5))
            callback(math.round(value))
            end
        end

        Slider.Name = "Slider"
        Slider.Parent = Window
        Slider.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
        Slider.BorderColor3 = Color3.fromRGB(113, 128, 147)
        Slider.Position = UDim2.new(0, 13, 0, listOffset[winCount])
        Slider.Size = UDim2.new(0, 180, 0, 6)
        Slider.ZIndex = 2 + zindex
        Slider.InputBegan:Connect(SliderMovement) 
        Slider.InputEnded:Connect(SliderEnd)      

        SliderButton.Position = UDim2.new(0, (Slider.Size.X.Offset - 5) * ((default - min)/(max-min)), -1.333337, 0)
        SliderButton.Name = "SliderButton"
        SliderButton.Parent = Slider
        SliderButton.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
        SliderButton.BorderColor3 = Color3.fromRGB(113, 128, 147)
        SliderButton.Size = UDim2.new(0, 6, 0, 22)
        SliderButton.ZIndex = 3 + zindex
        SliderButton.InputBegan:Connect(SliderMovement)
        SliderButton.InputEnded:Connect(SliderEnd)    

        Current.Name = "Current"
        Current.Parent = SliderButton
        Current.BackgroundTransparency = 1.000
        Current.Position = UDim2.new(0, 3, 0, 22   )
        Current.Size = UDim2.new(0, 0, 0, 18)
        Current.Font = Enum.Font.SourceSans
        Current.Text = tostring(default)
        Current.TextColor3 = Color3.fromRGB(220, 221, 225)
        Current.TextSize = 14.000  
        Current.ZIndex = 2 + zindex

        Description.Name = "Description"
        Description.Parent = Slider
        Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Description.BackgroundTransparency = 1.000
        Description.Position = UDim2.new(0, -10, 0, -35)
        Description.Size = UDim2.new(0, 200, 0, 21)
        Description.Font = Enum.Font.SourceSans
        Description.Text = text
        Description.TextColor3 = Color3.fromRGB(245, 246, 250)
        Description.TextSize = 16.000
        Description.ZIndex = 2 + zindex

        SilderFiller.Name = "SilderFiller"
        SilderFiller.Parent = Slider
        SilderFiller.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
        SilderFiller.BorderColor3 = Color3.fromRGB(47, 54, 64)
        SilderFiller.Size = UDim2.new(0, (Slider.Size.X.Offset - 5) * ((default - min)/(max-min)), 0, 6)
        SilderFiller.ZIndex = 2 + zindex
        SilderFiller.BorderMode = Enum.BorderMode.Inset

        Min.Name = "Min"
        Min.Parent = Slider
        Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Min.BackgroundTransparency = 1.000
        Min.Position = UDim2.new(-0.00555555569, 0, -7.33333397, 0)
        Min.Size = UDim2.new(0, 77, 0, 50)
        Min.Font = Enum.Font.SourceSans
        Min.Text = tostring(min)
        Min.TextColor3 = Color3.fromRGB(220, 221, 225)
        Min.TextSize = 14.000
        Min.TextXAlignment = Enum.TextXAlignment.Left
        Min.ZIndex = 2 + zindex

        Max.Name = "Max"
        Max.Parent = Slider
        Max.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Max.BackgroundTransparency = 1.000
        Max.Position = UDim2.new(0.577777743, 0, -7.33333397, 0)
        Max.Size = UDim2.new(0, 77, 0, 50)
        Max.Font = Enum.Font.SourceSans
        Max.Text = tostring(max)
        Max.TextColor3 = Color3.fromRGB(220, 221, 225)
        Max.TextSize = 14.000
        Max.TextXAlignment = Enum.TextXAlignment.Right
        Max.ZIndex = 2 + zindex
        pastSliders[winCount] = true

        local slider = {}
        function slider:SetValue(value)
	    value = math.clamp(value, min, max)
            local xOffset = (value-min)/max * (Slider.Size.X.Offset)
            SliderButton.Position = UDim2.new(0, xOffset , -1.33333337, 0);
            SilderFiller.Size = UDim2.new(0, xOffset, 0, 6)
            Current.Text = tostring(math.round(value))
        end
        return slider
    end
    function functions:Dropdown(text, buttons, callback, selective)
        local text = text or "Dropdown"
        local buttons = buttons or {}
        local callback = callback or function() end

        local Dropdown = Instance.new("TextButton")
        local DownSign = Instance.new("TextLabel")
        local DropdownFrame = Instance.new("ScrollingFrame")

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32

        Dropdown.Name = "Dropdown"
        Dropdown.Parent = Window
        Dropdown.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
        Dropdown.BorderColor3 = Color3.fromRGB(113, 128, 147)
        Dropdown.Position = UDim2.new(0, 12, 0, listOffset[winCount])
        Dropdown.Size = UDim2.new(0, 182, 0, 26)
        Dropdown.Selected = true
        Dropdown.Font = Enum.Font.SourceSans
        Dropdown.Text = tostring(text)
        Dropdown.TextColor3 = Color3.fromRGB(245, 246, 250)
        Dropdown.TextSize = 16.000
        Dropdown.TextStrokeTransparency = 123.000
        Dropdown.TextWrapped = true
        Dropdown.ZIndex = 3 + zindex

        DownSign.Name = "DownSign"
        DownSign.Parent = Dropdown
        DownSign.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DownSign.BackgroundTransparency = 1.000
        DownSign.Position = UDim2.new(0, 155, 0, 2)
        DownSign.Size = UDim2.new(0, 27, 0, 22)
        DownSign.Font = Enum.Font.SourceSans
        DownSign.Text = "^"
        DownSign.TextColor3 = Color3.fromRGB(220, 221, 225)
        DownSign.TextSize = 20.000
        DownSign.ZIndex = 4 + zindex
        DownSign.TextYAlignment = Enum.TextYAlignment.Bottom

        DropdownFrame.Name = "DropdownFrame"
        DropdownFrame.Parent = Dropdown
        DropdownFrame.Active = true
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
        DropdownFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
        DropdownFrame.Position = UDim2.new(0, 0, 0, 28)
        DropdownFrame.Size = UDim2.new(0, 182, 0, 0)
        DropdownFrame.Visible = false
        DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        DropdownFrame.ScrollBarThickness = 4
        DropdownFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
        DropdownFrame.ZIndex = 5 + zindex
        DropdownFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(220, 221, 225)
        table.insert(dropdowns, DropdownFrame)
        local dropFunctions = {}
        local canvasSize = 0
        local maxVisible = 6 -- limite de itens visíveis (não ultrapassar limite do header/UI)
        function dropFunctions:Button(name)
            local name = name or ""
            local Button_2 = Instance.new("TextButton")
            Button_2.Name = "Button"
            Button_2.Parent = DropdownFrame
            Button_2.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
            Button_2.BorderColor3 = Color3.fromRGB(113, 128, 147)
            Button_2.Position = UDim2.new(0, 6, 0, canvasSize + 1)
            Button_2.Size = UDim2.new(0, 170, 0, 26)
            Button_2.Selected = true
            Button_2.Font = Enum.Font.SourceSans
            Button_2.TextColor3 = Color3.fromRGB(245, 246, 250)
            Button_2.TextSize = 16.000
            Button_2.TextStrokeTransparency = 123.000
            Button_2.ZIndex = 6 + zindex
            Button_2.Text = name
            Button_2.TextWrapped = true
            canvasSize = canvasSize + 27
            DropdownFrame.CanvasSize = UDim2.new(0, 182, 0, canvasSize + 1)
            -- só aumentar a altura visual até o máximo definido
            if DropdownFrame.Size.Y.Offset < (27 * maxVisible) then
                DropdownFrame.Size = UDim2.new(0, 182, 0, math.min(DropdownFrame.Size.Y.Offset + 27, 27 * maxVisible))
            end
            Button_2.MouseButton1Up:Connect(function()
                callback(name)
		DropdownFrame.Visible = false
		DownSign.Rotation = 0
		if selective then
		   Dropdown.Text = name
		end
            end)
        end
        function dropFunctions:Remove(name)
            local foundIt
            for i, v in pairs(DropdownFrame:GetChildren()) do
                if foundIt then
                    canvasSize = canvasSize - 27
                    v.Position = UDim2.new(0, 6, 0, v.Position.Y.Offset - 27)
                    DropdownFrame.CanvasSize = UDim2.new(0, 182, 0, canvasSize + 1)
                end
                if v.Text == name then
                    foundIt = true
                    v:Destroy()
                    if #DropdownFrame:GetChildren() < 8 then
                        DropdownFrame.Size = UDim2.new(0, 182, 0, DropdownFrame.Size.Y.Offset - 27)
                    end
                end
            end
            if not foundIt then
                warn("The button you tried to remove didn't exist!")
            end
        end

        -- rebuild dinamicamente a lista (excluindo o LocalPlayer)
        function dropFunctions:Rebuild()
            -- remove os botões antigos
            for _, child in ipairs(DropdownFrame:GetChildren()) do
                if child.Name == "Button" then
                    child:Destroy()
                end
            end
            canvasSize = 0
            DropdownFrame.CanvasSize = UDim2.new(0, 182, 0, 0)
            DropdownFrame.Size = UDim2.new(0, 182, 0, 0)
            -- adicionar jogadores atuais (exceto LocalPlayer)
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer then
                    dropFunctions:Button(pl.Name)
                end
            end
        end

        for i,v in pairs(buttons) do
            -- inicialmente adicionar os botões passados (isso pode incluir nomes)
            dropFunctions:Button(v)
        end

        Dropdown.MouseButton1Up:Connect(function()
            -- fechar qualquer outro dropdown aberto
            for i, v in pairs(dropdowns) do
                if v ~= DropdownFrame then
                    v.Visible = false
                end
            end
            -- se já está visível -> ao fechar, RECONSTRUIR a lista (atualizar)
            if DropdownFrame.Visible then
                DropdownFrame.Visible = false
                DownSign.Rotation = 0
                dropFunctions:Rebuild()
            else
                DownSign.Rotation = 180
                DropdownFrame.Visible = true
            end
        end)

        return dropFunctions
    end
    function functions:ColorPicker(name, default, callback)
        local callback = callback or function() end

        local ColorPicker = Instance.new("TextButton")
        local PickerCorner = Instance.new("UICorner")
        local PickerDescription = Instance.new("TextLabel")
        local ColorPickerFrame = Instance.new("Frame")
        local ToggleRGB = Instance.new("TextButton")
        local ToggleFiller_2 = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local ClosePicker = Instance.new("TextButton")
        local Canvas = Instance.new("Frame")
        local CanvasGradient = Instance.new("UIGradient")
        local Cursor = Instance.new("ImageLabel")
        local Color = Instance.new("Frame")
        local ColorGradient = Instance.new("UIGradient")
        local ColorSlider = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local UICorner = Instance.new("UICorner")
        local ColorCorner = Instance.new("UICorner")
        local BlackOverlay = Instance.new("ImageLabel")

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32

        ColorPicker.Name = "ColorPicker"
        ColorPicker.Parent = Window
        ColorPicker.Position = UDim2.new(0, 137, 0, listOffset[winCount])
        ColorPicker.Size = UDim2.new(0, 57, 0, 26)
        ColorPicker.Font = Enum.Font.SourceSans
        ColorPicker.Text = ""
        ColorPicker.TextColor3 = Color3.fromRGB(0, 0, 0)
        ColorPicker.TextSize = 14.000
        ColorPicker.ZIndex = 2 + zindex
        ColorPicker.MouseButton1Up:Connect(function()
            for i, v in pairs(colorPickers) do
                v.Visible = false
            end
            ColorPickerFrame.Visible = not ColorPickerFrame.Visible
        end)

        PickerCorner.Parent = ColorPicker
        PickerCorner.Name = "PickerCorner"
        PickerCorner.CornerRadius = UDim.new(0,2)

        PickerDescription.Name = "PickerDescription"
        PickerDescription.Parent = ColorPicker
        PickerDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PickerDescription.BackgroundTransparency = 1.000
        PickerDescription.Position = UDim2.new(-2.15789509, 0, 0, 0)
        PickerDescription.Size = UDim2.new(0, 116, 0, 26)
        PickerDescription.Font = Enum.Font.SourceSans
        PickerDescription.Text = name or "Color picker"
        PickerDescription.TextColor3 = Color3.fromRGB(245, 246, 250)
        PickerDescription.TextSize = 16.000
        PickerDescription.TextXAlignment = Enum.TextXAlignment.Left
        PickerDescription.ZIndex = 2 + zindex

        ColorPickerFrame.Name = "ColorPickerFrame"
        ColorPickerFrame.Parent = ColorPicker
        ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
        ColorPickerFrame.BorderColor3 = Color3.fromRGB(47, 54, 64)
        ColorPickerFrame.Position = UDim2.new(1.40350854, 0, -2.84615374, 0)
        ColorPickerFrame.Size = UDim2.new(0, 158, 0, 155)
        ColorPickerFrame.ZIndex = 3 + zindex
        ColorPickerFrame.Visible = false

        ToggleRGB.Name = "ToggleRGB"
        ToggleRGB.Parent = ColorPickerFrame
        ToggleRGB.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
        ToggleRGB.BorderColor3 = Color3.fromRGB(113, 128, 147)
        ToggleRGB.Position = UDim2.new(0, 125, 0, 127)
        ToggleRGB.Size = UDim2.new(0, 22, 0, 22)
        ToggleRGB.Font = Enum.Font.SourceSans
        ToggleRGB.Text = ""
        ToggleRGB.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleRGB.TextSize = 14.000
        ToggleRGB.ZIndex = 4 + zindex

        ToggleFiller_2.Name = "ToggleFiller"
        ToggleFiller_2.Parent = ToggleRGB
        ToggleFiller_2.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
        ToggleFiller_2.BorderColor3 = Color3.fromRGB(47, 54, 64)
        ToggleFiller_2.Position = UDim2.new(0, 5, 0, 5)
        ToggleFiller_2.Size = UDim2.new(0, 12, 0, 12)
        ToggleFiller_2.ZIndex = 4 + zindex
        ToggleFiller_2.Visible = false

        TextLabel.Parent = ToggleRGB
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.Position = UDim2.new(-5.13636351, 0, 0, 0)
        TextLabel.Size = UDim2.new(0, 106, 0, 22)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = "Rainbow"
        TextLabel.TextColor3 = Color3.fromRGB(245, 246, 250)
        TextLabel.TextSize = 16.000
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.ZIndex = 4 + zindex

        ClosePicker.Name = "ClosePicker"
        ClosePicker.Parent = ColorPickerFrame
        ClosePicker.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
        ClosePicker.BorderColor3 = Color3.fromRGB(47, 54, 64)
        ClosePicker.Position = UDim2.new(0, 132, 0, 5)
        ClosePicker.Size = UDim2.new(0, 21, 0, 21)
        ClosePicker.Font = Enum.Font.SourceSans
        ClosePicker.Text = "X"
        ClosePicker.TextColor3 = Color3.fromRGB(245, 246, 250)
        ClosePicker.TextSize = 18.000
        ClosePicker.ZIndex = 4 + zindex
        ClosePicker.MouseButton1Down:Connect(function()
            ColorPickerFrame.Visible = not ColorPickerFrame.Visible
        end)

        CanvasGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
        CanvasGradient.Name = "CanvasGradient"
        CanvasGradient.Parent = Canvas

        BlackOverlay.Name = "BlackOverlay"
        BlackOverlay.Parent = Canvas
        BlackOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BlackOverlay.BackgroundTransparency = 1.000
        BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
        BlackOverlay.Image = "rbxassetid://5107152095"
        BlackOverlay.ZIndex = 5 + zindex

        UICorner.Parent = Canvas
        UICorner.Name = "UICorner"
        UICorner.CornerRadius = UDim.new(0,2)

        Cursor.Name = "Cursor"
        Cursor.Parent = Canvas
        Cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cursor.BackgroundTransparency = 1.000
        Cursor.Size = UDim2.new(0, 8, 0, 8)
        Cursor.Image = "rbxassetid://5100115962"
        Cursor.ZIndex = 5 + zindex

        local draggingColor = false
        local hue = 0
        local sat = 1
        local brightness = 1
        
        local con

        ToggleRGB.MouseButton1Down:Connect(function()
            ToggleFiller_2.Visible = not ToggleFiller_2.Visible
            if ToggleFiller_2.Visible then
                con = stepped:Connect(function()
                    if ToggleFiller_2.Visible then
                        local hue2 = tick() % 5 / 5
                        color3 = Color3.fromHSV(hue2, 1, 1)
                        callback(color3, true)
                        ColorPicker.BackgroundColor3 = color3
                    else
                        con:Disconnect()
                    end
                end)
            end
        end)
        
        if default and type(default) == "boolean" then
            ToggleFiller_2.Visible = true
            if ToggleFiller_2.Visible then
                con = stepped:Connect(function()
                    if ToggleFiller_2.Visible then
                        local hue2 = tick() % 5 / 5
                        color3 = Color3.fromHSV(hue2, 1, 1)
                        callback(color3)
                        ColorPicker.BackgroundColor3 = color3
                    else
                        con:Disconnect()
                    end
                end)
            end
        else
            ColorPicker.BackgroundColor3 = default or Color3.fromRGB(0, 168, 255)
        end

        Canvas.Name = "Canvas"
        Canvas.Parent = ColorPickerFrame
        Canvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Canvas.Position = UDim2.new(0, 5, 0, 34)
        Canvas.Size = UDim2.new(0, 148, 0, 64)
        Canvas.ZIndex = 4 + zindex
        local canvasSize, canvasPosition = Canvas.AbsoluteSize, Canvas.AbsolutePosition
        Canvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local initial = Vector2.new(Cursor.Position.X.Offset, Cursor.Position.Y.Offset)
                local delta = Cursor.AbsolutePosition - initial
                local con;
                local isdragging = true

                con = stepped:Connect(function()
                    if isdragging then
                        local delta2 = Vector2.new(mouse.X, mouse.Y) - delta
                        local x = math.clamp(delta2.X, 2, Canvas.Size.X.Offset - 2)
                        local y = math.clamp(delta2.Y, 2, Canvas.Size.Y.Offset - 2)
                        
				        sat = 1 - math.clamp((mouse.X - canvasPosition.X) / canvasSize.X, 0, 1)
				        brightness = 1 - math.clamp((mouse.Y - canvasPosition.Y) / canvasSize.Y, 0, 1)
				
                        color3 = Color3.fromHSV(hue, sat, brightness)
                        
                        Cursor.Position = UDim2.fromOffset(x - 4, y - 4)
                        ColorPicker.BackgroundColor3 = color3
                        callback(color3)
					else
						con:Disconnect();
					end;
                end);
                input.Changed:Connect(function()
    			    if input.UserInputState == Enum.UserInputState.End then
					    isdragging = false;
				    end;
			    end);
		    end;
	    end);

        Color.Name = "Color"
        Color.Parent = ColorPickerFrame
        Color.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Color.Position = UDim2.new(0, 5, 0, 105)
        Color.Size = UDim2.new(0, 148, 0, 14)
        Color.BorderMode = Enum.BorderMode.Inset
        Color.ZIndex = 4 + zindex
        Color.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingColor = true
                local initial2 = ColorSlider.Position.X.Offset;
                local delta1 = ColorSlider.AbsolutePosition.X - initial2
                local con
                con = stepped:Connect(function()
                if draggingColor then
                    local colorPosition, colorSize = Color.AbsolutePosition, Color.AbsoluteSize
                    hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
                    CanvasGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromHSV(hue, 1, 1)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}

                    local xOffset = math.clamp(mouse.X - delta1, 0, Color.Size.X.Offset - 3)
                    ColorSlider.Position = UDim2.new(0, xOffset, 0, 0);

                    color3 = Color3.fromHSV(hue, sat, brightness)
                    ColorPicker.BackgroundColor3  = color3
                    callback(color3)
                else
                    con:Disconnect()
                end
            end)
            end
        end)
        Color.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingColor = false
            end
        end)
        ColorGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), 
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), 
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), 
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), 
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), 
            ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)), 
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
        })
        ColorGradient.Name = "ColorGradient"
        ColorGradient.Parent = Color

        ColorCorner.Parent = Color
        ColorCorner.Name = "ColorCorner"
        ColorCorner.CornerRadius = UDim.new(0,2)

        ColorSlider.Name = "ColorSlider"
        ColorSlider.Parent = Color
        ColorSlider.BackgroundColor3 = Color3.fromRGB(245, 246, 250)
        ColorSlider.BorderColor3 = Color3.fromRGB(245, 246, 250)
        ColorSlider.Size = UDim2.new(0, 2, 0, 14)
        ColorSlider.ZIndex = 5 + zindex

        Title.Name = "Title"
        Title.Parent = ColorPickerFrame
        Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(0, 118, 0, 21)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name or "Color picker"
        Title.TextColor3 = Color3.fromRGB(245, 246, 250)
        Title.TextSize = 16.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 4 + zindex

	    table.insert(colorPickers, ColorPickerFrame)

	    local colorFuncs = {}
        function colorFuncs:UpdateColorPicker(color)
        if type(color) == "userdata" then
            ToggleFiller_2.Visible = false
	        ColorPicker.BackgroundColor3 = color
        elseif color and type(color) == "boolean" and not con then
	        ToggleFiller_2.Visible = true
                con = stepped:Connect(function()
                    if ToggleFiller_2.Visible then
                        local hue2 = tick() % 5 / 5
                        color3 = Color3.fromHSV(hue2, 1, 1)
                        callback(color3)
                        ColorPicker.BackgroundColor3 = color3
                    else
                        con:Disconnect()
                    end
                end)
	        end
	    end
	return colorFuncs
    end

    return functions
end

local window = library:Window("Projeto LKB", function()
    if blackHoleActive then
        toggleBlackHole() 
    end
end)

local playerList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerList, p.Name)
    end
end

local playerDropdown = window:Dropdown("Select Player", playerList, function(name)
    local selected = Players:FindFirstChild(name)
    if selected then
        targetPlayer = selected
    end
end, true)

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        playerDropdown:Button(p.Name)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    playerDropdown:Remove(p.Name)
    if p == targetPlayer then
        if blackHoleActive then
            toggleBlackHole()
        end
        targetPlayer = LocalPlayer
    end
end)

window:Slider("Radius Blackhole",1,100,10, function(Value)
    radius = Value
end)

local blackholeToggle = window:Toggle("Blackhole", false, function(Value)
    if Value then
        if not targetPlayer or targetPlayer == LocalPlayer then
            showMessage("Selecione um jogador")
            if blackholeToggle then
                blackholeToggle:SetState(false)
            end
            return
        end
    end

    if Value ~= blackHoleActive then
        toggleBlackHole()
    end
end)

spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if blackHoleActive then
            angle = angle + math.rad(angleSpeed)
        end
    end
end)


end)

    -- Lógica do Shift Lock Horizontal (Sem Offset)
    shiftLockToggle.MouseButton1Click:Connect(function()
        shiftLockAtivo = not shiftLockAtivo
        local base = "🔒 Shift Lock"
        shiftLockToggle.Text = base .. (shiftLockAtivo and " [ON]" or " [OFF]")
        setToggleColor(shiftLockToggle, shiftLockAtivo)

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if shiftLockAtivo then
            -- Ativar
            if hum then 
                hum.AutoRotate = false 
                hum.CameraOffset = Vector3.new(0,0,0) -- Garante zero offset como você pediu
            end
            
            -- Se já tiver uma conexão rodando, mata ela antes de criar nova
            if shiftLockConnection then safeDisconnect(shiftLockConnection) end

            shiftLockConnection = RunService.RenderStepped:Connect(function()
                if not shiftLockAtivo then return end
                
                local character = player.Character
                local h = character and character:FindFirstChildOfClass("Humanoid")
                local r = character and character:FindFirstChild("HumanoidRootPart")

                if h and r and h.Health > 0 then
                    -- Mantém o autorotate desligado
                    h.AutoRotate = false
                    
                    -- Pega a rotação da câmera
                    local _, yaw, _ = camera.CFrame:ToOrientation()
                    
                    -- Aplica no personagem
                    r.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, yaw, 0)
                end
            end)
            trackConnection(shiftLockConnection) -- Adiciona ao sistema de limpeza do hub

        else
            -- Desativar
            if shiftLockConnection then safeDisconnect(shiftLockConnection); shiftLockConnection = nil end
            
            if hum then
                hum.AutoRotate = true
                hum.CameraOffset = Vector3.new(0, 0, 0)
            end
        end
    end)
    
    -- Garante que reseta se o personagem morrer/renascer
    player.CharacterAdded:Connect(function(newChar)
        if shiftLockAtivo then
            task.wait(0.2) -- Espera carregar
            local h = newChar:WaitForChild("Humanoid", 5)
            if h then h.AutoRotate = false end
        end
    end)
    
-- Toggle Best Light
local bestLightAtivo = false
local defaultSettings = {}
local originalReflectance = {} -- Tabela para guardar os reflexos originais

-- Serviços
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Função para salvar os gráficos e reflexos originais
local function saveDefaultGraphics()
	defaultSettings.Technology = Lighting.Technology
	defaultSettings.GlobalShadows = Lighting.GlobalShadows
	defaultSettings.ShadowSoftness = Lighting.ShadowSoftness
	defaultSettings.Ambient = Lighting.Ambient
	defaultSettings.OutdoorAmbient = Lighting.OutdoorAmbient
	defaultSettings.Brightness = Lighting.Brightness
	defaultSettings.ExposureCompensation = Lighting.ExposureCompensation
	defaultSettings.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
	defaultSettings.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
	defaultSettings.ClockTime = Lighting.ClockTime
	defaultSettings.FogStart = Lighting.FogStart
	defaultSettings.FogEnd = Lighting.FogEnd
	defaultSettings.FogColor = Lighting.FogColor

	local atm = Lighting:FindFirstChildOfClass("Atmosphere")
	if atm then
		defaultSettings.Atmosphere = {
			Density = atm.Density, Offset = atm.Offset, Color = atm.Color,
			Decay = atm.Decay, Glare = atm.Glare, Haze = atm.Haze
		}
	end

	-- Salva o reflexo de cada parte do mapa
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			originalReflectance[obj] = obj.Reflectance
		end
	end
end

-- Função para restaurar TUDO ao padrão
local function restoreDefaultGraphics()
	if not next(defaultSettings) then return end

	Lighting.Technology = defaultSettings.Technology
	Lighting.GlobalShadows = defaultSettings.GlobalShadows
	Lighting.ShadowSoftness = defaultSettings.ShadowSoftness
	Lighting.Ambient = defaultSettings.Ambient
	Lighting.OutdoorAmbient = defaultSettings.OutdoorAmbient
	Lighting.Brightness = defaultSettings.Brightness
	Lighting.ExposureCompensation = defaultSettings.ExposureCompensation
	Lighting.EnvironmentDiffuseScale = defaultSettings.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = defaultSettings.EnvironmentSpecularScale
	Lighting.ClockTime = defaultSettings.ClockTime
	Lighting.FogStart = defaultSettings.FogStart
	Lighting.FogEnd = defaultSettings.FogEnd
	Lighting.FogColor = defaultSettings.FogColor

	-- Limpa efeitos do shader
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere") or v:IsA("SunRaysEffect") then v:Destroy() end
	end

	-- Restaura atmosfera
	if defaultSettings.Atmosphere then
		local atm = Instance.new("Atmosphere", Lighting)
		local d = defaultSettings.Atmosphere
		atm.Density, atm.Offset, atm.Color = d.Density, d.Offset, d.Color
		atm.Decay, atm.Glare, atm.Haze = d.Decay, d.Glare, d.Haze
	end

	-- Restaura os reflexos originais das peças
	for obj, value in pairs(originalReflectance) do
		if obj and obj.Parent then
			obj.Reflectance = value
		end
	end
	originalReflectance = {} -- Limpa a tabela
end

-- Função que aplica o shader
local function applyBestLightShader()
	Lighting.Technology = Enum.Technology.Future
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 1
	Lighting.Ambient = Color3.new(0, 0, 0)
	Lighting.OutdoorAmbient = Color3.fromRGB(12, 12, 18)
	Lighting.Brightness = 1.5
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.8
	Lighting.ExposureCompensation = -0.2

	local Atmosphere = Instance.new("Atmosphere", Lighting)
	Atmosphere.Offset = 0.5
	Atmosphere.Glare = 0.3
	Atmosphere.Haze = 0.6

	local SunFlare = Instance.new("SunRaysEffect", Lighting)
	SunFlare.Intensity = 0.3
	SunFlare.Spread = 0.8

	-- Aplica reflexos (Vidro/Transparente = 1 | Outros = 0.05)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local mat = obj.Material
			if obj.Transparency > 0 or mat == Enum.Material.Glass or mat == Enum.Material.Water or mat == Enum.Material.Ice or mat == Enum.Material.Glacier then
				obj.Reflectance = 1
			else
				obj.Reflectance = 0.05
			end
		end
	end

	if RunService:FindFirstChild("BestLightConnection") then
		RunService.BestLightConnection:Disconnect()
	end

	RunService.BestLightConnection = RunService.RenderStepped:Connect(function()
		local t = Lighting.ClockTime

		if t < 5 or t > 19 then -- NOITE
			Lighting.FogStart, Lighting.FogEnd = 5000, 15000
			Lighting.FogColor = Color3.fromRGB(10, 10, 20)
			Atmosphere.Color = Color3.fromRGB(40, 50, 70)
			Atmosphere.Density = 0.01
		elseif t < 7 or t > 17 then -- TRANSIÇÃO
			Lighting.FogStart, Lighting.FogEnd = 2000, 8000
			Lighting.FogColor = Color3.fromRGB(240, 240, 240)
			Atmosphere.Color = Color3.fromRGB(255, 200, 150)
			Atmosphere.Density = 0.02
		else -- DIA (Sol Âmbar)
			Lighting.FogStart, Lighting.FogEnd = 600, 1800
			Lighting.FogColor = Color3.fromRGB(255, 255, 255)
			Atmosphere.Color = Color3.fromRGB(255, 215, 150) -- Âmbar Intenso
			Atmosphere.Density = 0.035
			SunFlare.Intensity = 0.4
		end
	end)
end

-- Botão
shadersToggle.MouseButton1Click:Connect(function()
	bestLightAtivo = not bestLightAtivo
	shadersToggle.Text = "Best Light" .. (bestLightAtivo and " [ON]" or " [OFF]")
	setToggleColor(shadersToggle, bestLightAtivo)

	if bestLightAtivo then
		saveDefaultGraphics()
		applyBestLightShader()
	else
		restoreDefaultGraphics()
		if RunService:FindFirstChild("BestLightConnection") then
			RunService.BestLightConnection:Disconnect()
		end
	end
end)


	local function killAllHub()
		hubVisivel = false
		espAtivo = false
		clickTpAtivo = false
		noclipAtivo = false
		infiniteJumpAtivo = false
		speedAtivo = false
		debugAtivo = false
		viewPlayerAtivo = false
		sofaRunning = false
		killRunning = false
		
		pcall(stopFlight)
		stopNoclipForce()
		pcall(desligarViewPlayer)
		
		if player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = originalWalkSpeed
			end
		end

		for _, data in ipairs(colisoesSalvas) do
			if data.part and data.part.Parent then data.part.CanCollide = data.collision end
		end
		colisoesSalvas = {}
		
		if Lighting then
			Lighting.GlobalShadows = true
		end
	 
		for _, conn in ipairs(trackedConnections) do    
			safeDisconnect(conn)    
		end    
		trackedConnections = {}    

		if conexaoClickTP then safeDisconnect(conexaoClickTP); conexaoClickTP = nil end    
		if viewConnection then safeDisconnect(viewConnection); viewConnection = nil end    
		if debugConnection then safeDisconnect(debugConnection); debugConnection = nil end    
		if espConnection then safeDisconnect(espConnection); espConnection = nil end    
		if infiniteJumpConnection then safeDisconnect(infiniteJumpConnection); infiniteJumpConnection = nil end
		if AntiSitConnection then safeDisconnect(AntiSitConnection); AntiSitConnection = nil end

		limparESP()    

		for _, b in ipairs(trackedBodies) do    
			safeDestroy(b)    
		end    
		trackedBodies = {}    

		local char = player.Character    
		if char then    
			for _, part in ipairs(char:GetDescendants()) do    
				if part:IsA("BodyAngularVelocity") or part:IsA("BodyVelocity") or part:IsA("BodyGyro") then    
					if string.find(part.Name, "Lobo") then
						pcall(function() part:Destroy() end)    
					end
				end    
			end    
		end    

		for _, g in ipairs(trackedGuis) do    
			if g and g.Parent then    
				pcall(function() g:Destroy() end)    
			end    
		end    
		trackedGuis = {}    
		
		if script then
			script:Destroy()
		end
	end

	killGuiButton.MouseButton1Click:Connect(killAllHub)
end

-- Inicia o Hub
pcall(iniciarHub)
