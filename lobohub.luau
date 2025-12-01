
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
local espAtivo = false
local noclipAtivo = false
local clickTpAtivo = false
local flingBodyAtivo = false
local infiniteJumpAtivo = false
local antiSitAtivo = false
local espInstancias = {}
local posicaoSalva = nil
local colisoesSalvas = {}
local jogadorSelecionado = nil
local conexaoClickTP = nil
local noclipConnection = nil 
local infiniteJumpConnection = nil
local antiSitConnection = nil
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
	toggleBotao.Image = "rbxassetid://9163518958" -- ID da imagem do toggle
	toggleBotao.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	toggleBotao.Size = UDim2.new(0, 50, 0, 50)
	toggleBotao.Position = UDim2.new(0, 10, 0.5, -25)
	toggleBotao.Draggable = true
	toggleBotao.Parent = loboHubGui
	trackGui(toggleBotao)

	local cornerToggle = Instance.new("UICorner")
	cornerToggle.CornerRadius = UDim.new(0, 12)
	cornerToggle.Parent = toggleBotao

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 500, 0, 460)
	mainFrame.Position = UDim2.new(0.5, -250, 0.5, -230)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
	header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	header.Parent = mainFrame
	trackGui(header)

	local titulo = Instance.new("TextLabel")
	titulo.Name = "Titulo"
	titulo.Size = UDim2.new(1, 0, 1, 0)
	titulo.Text = "Lobo Hub [DEMO]"
	titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
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
	killGuiButton.Text = "✖️"
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
	tabContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	tabContainer.Parent = mainFrame
	trackGui(tabContainer)

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.Parent = tabContainer

	local function makeTab(nameText)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.Position = UDim2.new(0, 5, 0, 5)
		btn.Text = nameText
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextScaled = true
		btn.Parent = tabContainer
		trackGui(btn)
		return btn
	end

	local tabBemVindo = makeTab("🏠 Bem-vindo")
	local tabParaMim = makeTab("👤 Para mim")
	local tabFuncoes = makeTab("🛠️ Funções")
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
	apelidoLabel.Size = UDim2.new(1, -10, 0, 30)
	apelidoLabel.Text = "Apelido: Carregando..."
	apelidoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	apelidoLabel.BackgroundTransparency = 1
	apelidoLabel.Font = Enum.Font.SourceSansBold
	apelidoLabel.TextScaled = true
	apelidoLabel.LayoutOrder = 2
	apelidoLabel.Parent = pageBemVindo
	trackGui(apelidoLabel)

	local arrobaLabel = Instance.new("TextLabel")
	arrobaLabel.Size = UDim2.new(1, -10, 0, 30)
	arrobaLabel.Text = "@: Carregando..."
	arrobaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	arrobaLabel.BackgroundTransparency = 1
	arrobaLabel.Font = Enum.Font.SourceSansBold
	arrobaLabel.TextScaled = true
	arrobaLabel.LayoutOrder = 3
	arrobaLabel.Parent = pageBemVindo
	trackGui(arrobaLabel)

	local idadeContaLabel = Instance.new("TextLabel")
	idadeContaLabel.Size = UDim2.new(1, -10, 0, 30)
	idadeContaLabel.Text = "Idade da Conta: Carregando..."
	idadeContaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	idadeContaLabel.BackgroundTransparency = 1
	idadeContaLabel.Font = Enum.Font.SourceSansBold
	idadeContaLabel.TextScaled = true
	idadeContaLabel.LayoutOrder = 4
	idadeContaLabel.Parent = pageBemVindo
	trackGui(idadeContaLabel)

	local criadoresLabel = Instance.new("TextLabel")
	criadoresLabel.Size = UDim2.new(1, -10, 0, 30)
	criadoresLabel.Text = "Criadores: Kauã, ChatGPT, criatividade"
	criadoresLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	criadoresLabel.BackgroundTransparency = 1
	criadoresLabel.Font = Enum.Font.SourceSansItalic
	criadoresLabel.TextScaled = true
	criadoresLabel.LayoutOrder = 5
	criadoresLabel.Parent = pageBemVindo
	trackGui(criadoresLabel)

	local discordButton = Instance.new("TextButton")
	discordButton.Size = UDim2.new(1, -10, 0, 40)
	discordButton.Text = "Copiar Discord"
	discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	discordButton.Font = Enum.Font.SourceSansBold
	discordButton.TextScaled = true
	discordButton.LayoutOrder = 6
	discordButton.Parent = pageBemVindo
	trackGui(discordButton)

	local pageParaMim = Instance.new("Frame")
	pageParaMim.Name = "Page_ParaMim"
	pageParaMim.Size = UDim2.new(1, 0, 1, 0)
	pageParaMim.BackgroundTransparency = 1
	pageParaMim.Visible = false
	pageParaMim.Parent = pageContainer
	trackGui(pageParaMim)

	local pageParaMimLayout = Instance.new("UIListLayout")
	pageParaMimLayout.Padding = UDim.new(0, 8)
	pageParaMimLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageParaMimLayout.Parent = pageParaMim

	local pageFuncoes = Instance.new("Frame")
	pageFuncoes.Name = "Page_Funcoes"
	pageFuncoes.Size = UDim2.new(1, 0, 1, 0)
	pageFuncoes.BackgroundTransparency = 1
	pageFuncoes.Visible = false
	pageFuncoes.Parent = pageContainer
	trackGui(pageFuncoes)

	local pageFuncoesLayout = Instance.new("UIListLayout")
	pageFuncoesLayout.Padding = UDim.new(0, 8)
	pageFuncoesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageFuncoesLayout.Parent = pageFuncoes

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
	
	-- INÍCIO DA ABA PROTEÇÕES (CORRETO)
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
	-- FIM DA ABA PROTEÇÕES


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
	
	-- Aba proteções 

	tabProtecoes.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pageParaMim.Visible = false
		pageFuncoes.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = true
	end)


	local playerSelectButton = Instance.new("TextButton")
	playerSelectButton.Name = "PlayerSelectButton"
	playerSelectButton.Size = UDim2.new(1, -10, 0, 40)
	playerSelectButton.Text = "👥 Selecionar Jogador..."
	playerSelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playerSelectButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	playerSelectButton.Font = Enum.Font.SourceSansBold
	playerSelectButton.TextScaled = true
	playerSelectButton.Parent = pageFuncoes
	trackGui(playerSelectButton)

	local playerList = Instance.new("ScrollingFrame")
	playerList.Name = "PlayerList"
	playerList.Size = UDim2.new(1, -10, 0, 180)
	playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
	playerList.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	playerList.BorderSizePixel = 0
	playerList.ScrollBarThickness = 6
	playerList.Visible = false
	playerList.Parent = pageFuncoes
	trackGui(playerList)

	local playerListLayout = Instance.new("UIListLayout")
	playerListLayout.Padding = UDim.new(0, 4)
	playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	playerListLayout.Parent = playerList

	local function makeFuncButton(parent, text, color)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -10, 0, 40)
		b.Text = text
		b.TextColor3 = Color3.fromRGB(255,255,255)
		b.BackgroundColor3 = color or Color3.fromRGB(60,60,60)
		b.Font = Enum.Font.SourceSansBold
		b.TextScaled = true
		b.Parent = parent
		trackGui(b)
		return b
	end

	local espToggle = makeFuncButton(pageParaMim, "🌐 ESP [OFF]", Color3.fromRGB(200,70,70))
	local clickTPToggle = makeFuncButton(pageParaMim, "👆 Click TP [OFF]", Color3.fromRGB(200,70,70))
	local noclipToggle = makeFuncButton(pageParaMim, "🚫 Noclip [OFF]", Color3.fromRGB(200,70,70))
	local infiniteJumpToggle = makeFuncButton(pageParaMim, "🦘 Pulo Infinito [OFF]", Color3.fromRGB(200,70,70))
    local flingBodyToggle = makeFuncButton(pageParaMim,"👺 Fling [OFF]", Color3.fromRGB(200,70,70))
    local antiSitToggle = makeFuncButton(pageProtecoes,"🪑 AntiSit [OFF]", Color3.fromRGB(200,70,70))
	local dynamicShadowsToggle = makeFuncButton(pageClient, "💡 Sombras [ON]", Color3.fromRGB(60,60,60))
	
	
	local flightFrame = Instance.new("Frame")
	flightFrame.Size = UDim2.new(1, -10, 0, 40)
	flightFrame.BackgroundTransparency = 1
	flightFrame.Parent = pageParaMim
	trackGui(flightFrame)

	local flightToggle = Instance.new("TextButton")
	flightToggle.Size = UDim2.new(0, 180, 1, 0)
	flightToggle.Position = UDim2.new(0, 0, 0, 0)
	flightToggle.Text = "🕊 Voo [OFF]"
	flightToggle.Font = Enum.Font.SourceSansBold
	flightToggle.TextColor3 = Color3.fromRGB(255,255,255)
	flightToggle.BackgroundColor3 = Color3.fromRGB(120,60,180)
	flightToggle.Parent = flightFrame
	trackGui(flightToggle)

	local flightCorner = Instance.new("UICorner")
	flightCorner.CornerRadius = UDim.new(0, 6)
	flightCorner.Parent = flightToggle

	local speedBox = Instance.new("TextBox")
	speedBox.Size = UDim2.new(1,-190, 1, 0)
	speedBox.Position = UDim2.new(0, 190, 0, 0)
	speedBox.Text = "50"
	speedBox.PlaceholderText = "vel"
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
	speedFrame.Size = UDim2.new(1, -10, 0, 40)
	speedFrame.BackgroundTransparency = 1
	speedFrame.Parent = pageParaMim
	trackGui(speedFrame)

	-- *** ALTERAÇÃO NO LAYOUT: Ocupando o espaço horizontal ***
	local speedValueBox = Instance.new("TextBox")
	speedValueBox.Size = UDim2.new(1, 0, 1, 0)
	speedValueBox.Position = UDim2.new(0, 0, 0, 0)
	speedValueBox.Text = "16"
	speedValueBox.PlaceholderText = "Velocidade (WalkSpeed)"
	speedValueBox.ClearTextOnFocus = false
	speedValueBox.Font = Enum.Font.SourceSans
	speedValueBox.TextColor3 = Color3.fromRGB(255,255,255)
	speedValueBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
	speedValueBox.Parent = speedFrame
	trackGui(speedValueBox)

	local speedValueCorner = Instance.new("UICorner")
	speedValueCorner.CornerRadius = UDim.new(0,6)
	speedValueCorner.Parent = speedValueBox

	local tpToPlayerButton = makeFuncButton(pageFuncoes, "👆 TP no Jogador")
	local tpBackButton = makeFuncButton(pageFuncoes, "↩️ Voltar Posição")
	local viewPlayerButton = makeFuncButton(pageFuncoes, "👁️ View Player [OFF]")
	local killPlayerButton = makeFuncButton(pageFuncoes, "🔪 Kill Player", Color3.fromRGB(180,40,40))
    local killAllButton = makeFuncButton(pageFuncoes, "🔥 Kill All", Color3.fromRGB(0, 0, 0))
	local debugToggle = Instance.new("TextButton")
	debugToggle.Name = "DebugToggle"
	debugToggle.Size = UDim2.new(1, -10, 0, 40) -- Ajuste de layout
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

	local function showRedMessage(text, duration)
		duration = duration or 3
		local gui = Instance.new("ScreenGui")
		gui.Name = "LoboHub_RedMsg"
		gui.ResetOnSpawn = false
		gui.Parent = playerGui
		trackGui(gui)

		local frame = Instance.new("Frame")    
		frame.Size = UDim2.new(0.6, 0, 0, 48)    
		frame.Position = UDim2.new(0.5, 0, 0.05, 0)    
		frame.AnchorPoint = Vector2.new(0.5,0)    
		frame.BackgroundColor3 = Color3.fromRGB(40,0,0)    
		frame.BorderSizePixel = 0    
		frame.Parent = gui    
		trackGui(frame)    

		local label = Instance.new("TextLabel")    
		label.Size = UDim2.new(1, -8, 1, -8)    
		label.Position = UDim2.new(0,4,0,4)    
		label.BackgroundTransparency = 1    
		label.TextColor3 = Color3.fromRGB(255,100,100)    
		label.Font = Enum.Font.SourceSansBold    
		label.TextSize = 20    
		label.TextScaled = true    
		label.Text = text    
		label.Parent = frame    

		task.delay(duration, function()    
			if gui and gui.Parent then gui:Destroy() end    
		end)
	end

	local function setToggleColor(button, active)
		if not button then return end
		local onColor = Color3.fromRGB(70,200,70)
		local offColor = Color3.fromRGB(200,70,70)
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
	end

	toggleBotao.MouseButton1Click:Connect(function()
		hubVisivel = not hubVisivel
		mainFrame.Visible = hubVisivel
	end)

	tabBemVindo.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = true
		pageParaMim.Visible = false
		pageFuncoes.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)

	tabParaMim.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pageParaMim.Visible = true
		pageFuncoes.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)

	tabFuncoes.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pageParaMim.Visible = false
		pageFuncoes.Visible = true
		pageClient.Visible = false
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)

	tabClient.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pageParaMim.Visible = false
		pageFuncoes.Visible = false
		pageClient.Visible = true
		pageDebug.Visible = false
		pageProtecoes.Visible = false
	end)

	tabDebug.MouseButton1Click:Connect(function()
		pageBemVindo.Visible = false
		pageParaMim.Visible = false
		pageFuncoes.Visible = false
		pageClient.Visible = false
		pageDebug.Visible = true
	    pageProtecoes.Visible = false
	end)
	
	tabProtecoes.MouseButton1Click:Connect(function()
	pageBemVindo.Visible = false
	pageParaMim.Visible = false
	pageFuncoes.Visible = false
	pageClient.Visible = false
	pageDebug.Visible = false
	pageProtecoes.Visible = true
	end)

	do
		local userId = player.UserId
		local thumbType = Enum.ThumbnailType.HeadShot
		local thumbSize = Enum.ThumbnailSize.Size100x100
		local ok, content = pcall(function() return Players:GetUserThumbnailAsync(userId, thumbType, thumbSize) end)
		avatarImg.Image = (ok and content) and content or ""
		apelidoLabel.Text = "Apelido: " .. (player.DisplayName or "N/A")
		arrobaLabel.Text = "@: " .. (player.Name or "N/A")
		idadeContaLabel.Text = "Idade da Conta: " .. tostring(player.AccountAge or 0) .. " dias"
	end

	discordButton.MouseButton1Click:Connect(function()
		local link = "https://discord.gg/Gd2qSuGtb"
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
				btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
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
			playerSelectButton.Text = "👥 Selecionar Jogador..."
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
		-- *** ALTERAÇÃO 4: Cor do ESP para azul claro ***
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
		textLabel.Text = "@" .. targetPlayer.Name    
		textLabel.Size = UDim2.new(1, 0, 1, 0)    
		textLabel.BackgroundTransparency = 1    
		-- *** ALTERAÇÃO 4: Cor do texto ESP para azul claro ***
		textLabel.TextColor3 = Color3.fromRGB(100, 200, 255)    
		textLabel.TextScaled = false
		textLabel.TextSize = 12 
		textLabel.Font = Enum.Font.SourceSansBold    
		textLabel.Parent = billGui    
		table.insert(espInstancias, billGui)
	end

	espToggle.MouseButton1Click:Connect(function()
		espAtivo = not espAtivo
		espToggle.Text = "🌐 ESP" .. (espAtivo and " [ON]" or " [OFF]")
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

	local function onClickToTeleport(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local char = player.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
			local rp = RaycastParams.new()
			rp.FilterDescendantsInstances = {char}
			rp.FilterType = Enum.RaycastFilterType.Exclude
			local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
			if res then
				char.HumanoidRootPart.CFrame = CFrame.new(res.Position)
			end
		end
	end

	clickTPToggle.MouseButton1Click:Connect(function()
		clickTpAtivo = not clickTpAtivo
		local base = "👆 Click TP"
		clickTPToggle.Text = base .. (clickTpAtivo and " [ON]" or " [OFF]")
		setToggleColor(clickTPToggle, clickTpAtivo)
		if clickTpAtivo then
			conexaoClickTP = UserInputService.InputBegan:Connect(onClickToTeleport)
			trackConnection(conexaoClickTP)
		else
			if conexaoClickTP then safeDisconnect(conexaoClickTP); conexaoClickTP = nil end
		end
	end)

	noclipToggle.MouseButton1Click:Connect(function()
		noclipAtivo = not noclipAtivo
		local base = "🚫 Noclip"
		noclipToggle.Text = base .. (noclipAtivo and " [ON]" or " [OFF]")
		setToggleColor(noclipToggle, noclipAtivo)
		local char = player.Character
		
		if not char then 
			if noclipAtivo then
				showRedMessage("Aguarde o personagem carregar...", 2)
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
	
	infiniteJumpToggle.MouseButton1Click:Connect(function()
		infiniteJumpAtivo = not infiniteJumpAtivo
		infiniteJumpToggle.Text = "🦘 Pulo Infinito " .. (infiniteJumpAtivo and "[ON]" or "[OFF]")
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
	
	
antiSitToggle.MouseButton1Click:Connect(function()
	antiSitAtivo = not antiSitAtivo
	antiSitToggle.Text = "AntiSit " .. (antiSitAtivo and "[ON]" or "[OFF]")
	setToggleColor(antiSitToggle, antiSitAtivo)

	if antiSitAtivo then
		
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
		
	else
		-- Desconexão e Reversão do AntiSit
		
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


-- Lógica do botão Fling (Modo Durão + Rotação Insana)
local flingMotorConnection = nil
local flingRotateConnection = nil
local flingAnimationConnection = nil

local function startFlingMode()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	
	if not hum or not root then
		showRedMessage("Aguarde o personagem carregar.", 2)
		flingBodyAtivo = false
		flingBodyToggle.Text = "👺 Fling [OFF]"
        setToggleColor(flingBodyToggle, false)
		return
	end

	----------------------------------------------------------------
	-- MODO DURÃO (sem animação, sem mexer membros)
	----------------------------------------------------------------

	-- Mata animações atuais
	for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
		track:Stop()
	end

	-- Impede animação futura
	if flingAnimationConnection then safeDisconnect(flingAnimationConnection) end
	flingAnimationConnection = hum.AnimationPlayed:Connect(function(track)
		task.wait()
		track:Stop()
	end)
	trackConnection(flingAnimationConnection)

	-- Mantém boneco vivo
	hum.AutoRotate = false  -- ⚠️ DESATIVADO pra não lutar com o tornado
	hum:ChangeState(Enum.HumanoidStateType.Running)

	-- Travar Motor6Ds
	if flingMotorConnection then safeDisconnect(flingMotorConnection) end
	flingMotorConnection = RunService.RenderStepped:Connect(function()
		if not char or not char.Parent then return end

		-- impede Roblox de reposicionar a rotação
		hum.MoveDirection = Vector3.zero

		for _, motor in ipairs(char:GetDescendants()) do
			if motor:IsA("Motor6D") then
				motor.Transform = CFrame.new()
			end
		end
	end)
	trackConnection(flingMotorConnection)

	----------------------------------------------------------------
	-- ROTAÇÃO INFINITA (Anti-walk cancel)
	----------------------------------------------------------------

	if flingRotateConnection then safeDisconnect(flingRotateConnection) end
	flingRotateConnection = RunService.RenderStepped:Connect(function(dt)
		if root and root.Parent then
			
			-- Roblox tenta rotacionar? A gente destrói a tentativa:
			root.CFrame = CFrame.new(root.Position) * 
				root.CFrame.Rotation * 
				CFrame.Angles(0, math.rad(300), 0)

		end
	end)
	trackConnection(flingRotateConnection)

	----------------------------------------------------------------

	showRedMessage("👺 Modo Durão + Tornado Ativado", 2)
end


local function stopFlingMode()
	if flingMotorConnection then safeDisconnect(flingMotorConnection); flingMotorConnection = nil end
	if flingRotateConnection then safeDisconnect(flingRotateConnection); flingRotateConnection = nil end
	if flingAnimationConnection then safeDisconnect(flingAnimationConnection); flingAnimationConnection = nil end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.AutoRotate = true
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end

	showRedMessage("Modo Durão/Tornado Desligado.", 2)
end


-- Botão
flingBodyToggle.MouseButton1Click:Connect(function()
	flingBodyAtivo = not flingBodyAtivo
	local base = "👺 Fling"

	flingBodyToggle.Text = base .. (flingBodyAtivo and " [ON]" or " [OFF]")
	setToggleColor(flingBodyToggle, flingBodyAtivo)

	if flingBodyAtivo then
		startFlingMode()
	else
		stopFlingMode()
	end
end)


	-- *** ALTERAÇÃO 3: Logic update - apply on text change/focus lost instantly ***
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
			applySpeedValue() -- Always try to apply if text is there
		end
	end)

	dynamicShadowsToggle.Text = "💡 Sombras [ON]"
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
			dynamicShadowsToggle.Text = "💡 Sombras [REMOVIDAS]"
			setToggleColor(dynamicShadowsToggle, true)
			showRedMessage("Sombras removidas (RTX Off!)", 2)
		else
			local Lighting = game:GetService("Lighting")
			Lighting.GlobalShadows = true
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.CastShadow = true
				end
			end
			dynamicShadowsToggle.Text = "💡 Sombras [NORMAL]"
			setToggleColor(dynamicShadowsToggle, false)
			showRedMessage("Sombras restauradas!", 2)
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

	local function startFlight()
		if flying then return end
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then
			showRedMessage("Seu personagem não está pronto para voar.", 3)
			return
		end
	   
		-- *** ALTERAÇÃO 2: Limpar forças anteriores e usar força massiva ***
		for _, v in pairs(hrp:GetChildren()) do
			if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") then
				v:Destroy()
			end
		end

		local bv = Instance.new("BodyVelocity")    
		bv.Name = "LoboFlyBV"    
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) -- Força infinita para ignorar gravidade total
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
			local animateScript = char:FindFirstChild("Animate")
			if animateScript then animateScript.Disabled = false end
		end
	end

	flightToggle.MouseButton1Click:Connect(function()
		if flying then
			stopFlight()
			flightToggle.Text = "✈️ Voo [OFF]"
			setToggleColor(flightToggle, false)
		else
			startFlight()
			flightToggle.Text = "✈️ Voo [ON]"
			setToggleColor(flightToggle, true)
		end
	end)

	tpToPlayerButton.MouseButton1Click:Connect(function()
		if not jogadorSelecionado then showRedMessage("Selecione um jogador primeiro.", 3); return end
		local char = player.Character
		local targetChar = jogadorSelecionado.Character
		if char and targetChar and targetChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
			posicaoSalva = char.HumanoidRootPart.CFrame
			char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame
		else
			showRedMessage("Não foi possível teleportar (personagem ausente).", 3)
		end
	end)

	tpBackButton.MouseButton1Click:Connect(function()
		if not posicaoSalva then showRedMessage("Nenhuma posição salva.", 2); return end
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
		viewPlayerButton.Text = "👁️ View Player [OFF]"
		if viewConnection then safeDisconnect(viewConnection); viewConnection = nil end
	end

	local function ligarViewPlayer()
		if not jogadorSelecionado then showRedMessage("Selecione um jogador primeiro.", 2); return end
		if not jogadorSelecionado.Character then showRedMessage("Jogador não tem personagem.", 2); return end
		local targetHumanoid = jogadorSelecionado.Character:FindFirstChildWhichIsA("Humanoid")
		if not targetHumanoid then showRedMessage("Humanoid alvo não encontrado.", 2); return end
		cameraBackupSubject = camera.CameraSubject
		cameraBackupType = camera.CameraType
		pcall(function() camera.CameraSubject = targetHumanoid; camera.CameraType = Enum.CameraType.Custom end)
		viewPlayerAtivo = true
		viewPlayerButton.Text = "👁️ View Player [ON]"
		
		-- *** ALTERAÇÃO 1: Lógica aprimorada para reconectar câmera após morte ***
		viewConnection = RunService.RenderStepped:Connect(function()
			if not viewPlayerAtivo then return end
			
			-- Se o jogador saiu do jogo, desliga
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
		showRedMessage("Script 'Get Couch' executado com sucesso!", 2)
	elseif not success then
		-- Se InvokeServer falhar (ex: erro no servidor ou não existe)
		showRedMessage("ERRO ao executar 'Get Couch': Falha no InvokeServer.", 3)
	else
		-- Se InvokeServer existir mas retornar algo que sugira falha na lógica do servidor
		showRedMessage("Script 'Get Couch' executado, mas resultado indefinido.", 3)
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Nota: Assumimos que 'showRedMessage' e 'jogadorSelecionado' já estão definidos no escopo do seu script maior.

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

    -- Giro insano
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

    -- Primeiro Couch
    equipCouch()

    -- Coleta alvos vivos e de pé
    local targets = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local tHum = plr.Character.Humanoid
            if tHum.Health > 0 and not tHum.Sit then
                table.insert(targets, plr)
            end
        end
    end

    showRedMessage("MASSACRE INICIADO • "..#targets.." ALVOS", 4)

    -- MATA TODOS (exatamente como você gosta)
    for i, plr in ipairs(targets) do
        local tChar = plr.Character
        if not tChar or not tChar:FindFirstChild("HumanoidRootPart") then continue end
        local tRoot = tChar.HumanoidRootPart
        local tHum = tChar.Humanoid

        if tHum.Health <= 0 or tHum.Sit then continue end

        -- Couch novo pra cada vítima
        equipCouch()

        -- Persegue até sentar
        repeat
            if not tRoot.Parent then break end
            root.CFrame = tRoot.CFrame * CFrame.new(1, -4, 0)
            root.Velocity = Vector3.zero
            task.wait()
        until tHum.Sit or tHum.Health <= 0 or not tRoot.Parent

        if tHum.Sit and tRoot.Parent then
            root.CFrame = CFrame.new(root.Position.X, -200, root.Position.Z)
            task.wait(0.5)           -- segurando o sofá
            hum:UnequipTools()       -- solta
            task.wait(0.2)           -- total 0.7s no void
            root.CFrame = savedCFrame -- volta

            -- Deleta o Couch (mata o alvo)
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

            task.wait(0.3) -- delay suave entre kills (evita lag e falhas)
        end
    end

    -- Limpeza final
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

    showRedMessage("SERVIDOR ANIQUILADO • "..#targets.." MORTOS", 6)
end)

killPlayerButton.MouseButton1Click:Connect(function()
    if not jogadorSelecionado then
        showRedMessage("Selecione um player primeiro!", 3)
        return
    end

    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetChar = jogadorSelecionado.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

    if not hum or not root or not targetRoot or not targetHum then
        showRedMessage("Erro: Personagem inválido.", 3)
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

    -- Baseplates de segurança (duas camadas)
    local plate1 = Instance.new("Part")
    plate1.Size = Vector3.new(400, 1, 400)
    plate1.Anchored = true
    plate1.CanCollide = true
    plate1.Transparency = 1
    plate1.CFrame = CFrame.new(0, -195, 0)
    plate1.Parent = workspace

    local plate2 = Instance.new("Part")
    plate2.Size = Vector3.new(600, 1, 600)
    plate2.Anchored = true
    plate2.CanCollide = true
    plate2.Transparency = 1
    plate2.CFrame = CFrame.new(0, -250, 0)
    plate2.Parent = workspace

    -- Garante que você nunca passe de -250
    local neverDie = game:GetService("RunService").Heartbeat:Connect(function()
        if root.Position.Y <= -248 then
            root.CFrame = savedCFrame
            root.Velocity = Vector3.new(0,0,0)
        end
    end)

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

    -- Espera o alvo sentar
    while task.wait() do
        if not targetRoot.Parent or not targetHum.Parent then break end
        root.CFrame = targetRoot.CFrame * CFrame.new(1, -4, 0)
        root.Velocity = Vector3.new(0,0,0)

        if targetHum.Sit then
            spin:Disconnect()

            -- VAI PRO VOID
            root.CFrame = CFrame.new(root.Position.X, -200, root.Position.Z)
            root.Velocity = Vector3.new(0,0,0)

            -- 0,5s segurando o Couch no void
            task.wait(0.5)

            -- SOLTA O COUCH (você vê caindo)
            hum:UnequipTools()

            -- +0,2s → total 0,7s no void → VOLTA IMEDIATAMENTE
            task.wait(0.2)
            root.CFrame = savedCFrame
            showRedMessage("Alvo Eliminado!", 2)

            -- SÓ AGORA deleta o Couch (você já voltou, alvo cai 100%)
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
    neverDie:Disconnect()
    hum.PlatformStand = false
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state ~= Enum.HumanoidStateType.None then
            hum:SetStateEnabled(state, true)
        end
    end
    if plate1 and plate1.Parent then plate1:Destroy() end
    if plate2 and plate2.Parent then plate2:Destroy() end
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
		if antiSitConnection then safeDisconnect(antiSitConnection); antiSitConnection = nil end

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

-- Inicia o Hub de forma robusta
pcall(iniciarHub)
