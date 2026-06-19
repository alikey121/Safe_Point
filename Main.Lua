-- SERVICIOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService") -- Para convertir las posiciones a texto

-- VARIABLES PRINCIPALES
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId -- Identificador único del juego actual
local FileName = "TpSettings_" .. tostring(PlaceId) .. ".json" -- Archivo único por juego

-- Tabla para almacenar las posiciones guardadas (Formato: [Nombre] = CFrame)
local savedPositions = {}
local dropdownActive = false
local dropdownButtons = {}

---------------------------------------------------------
-- FUNCIONES DE GUARDADO PERMANENTE (Saves en la carpeta del ejecutor)
---------------------------------------------------------

-- Función para guardar los datos en el archivo local
local function saveToStorage()
	local dataToSave = {}
	for name, cframe in pairs(savedPositions) do
		-- El CFrame no se puede guardar como texto directo, así que guardamos sus componentes numéricos
		dataToSave[name] = {cframe:GetComponents()}
	end
	
	-- Convertimos la tabla a formato JSON (texto)
	local success, jsonString = pcall(function()
		return HttpService:JSONEncode(dataToSave)
	end)
	
	if success and writefile then
		writefile(FileName, jsonString) -- Guarda el archivo permanentemente
	end
end

-- Función para cargar los datos desde el archivo local al entrar
local function loadFromStorage()
	if readfile and isfile and isfile(FileName) then
		local success, jsonString = pcall(function()
			return readfile(FileName)
		end)
		
		if success and jsonString then
			local success2, decodedData = pcall(function()
				return HttpService:JSONDecode(jsonString)
			end)
			
			if success2 and decodedData then
				for name, components in pairs(decodedData) do
					-- Reconstruimos el CFrame original con los componentes guardados
					savedPositions[name] = CFrame.new(unpack(components))
				end
			end
		end
	end
end

-- Cargamos los TPs guardados antes de crear la interfaz
loadFromStorage()


-- 1. INTERFAZ GRÁFICA PEQUEÑA (Exclusiva para Teleport - Compacta)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TpMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- El cuadro principal movible
local menuFrame = Instance.new("Frame")
menuFrame.Name = "TpMenuFrame"
menuFrame.Size = UDim2.new(0, 190, 0, 125) 
menuFrame.Position = UDim2.new(0.5, -95, 0.4, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Fondo Negro oscuro
menuFrame.Active = true
menuFrame.Draggable = true 
menuFrame.ClipsDescendants = false 
menuFrame.Parent = screenGui

-- Borde Rojo para el cuadro
local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(255, 0, 0) -- Borde Rojo
menuStroke.Thickness = 2.5
menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
menuStroke.Parent = menuFrame

-- Esquinas redondeadas
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menuFrame

-- MARCA DE AGUA: "Js Like Beta" (Muy pequeño arriba a la izquierda en rojo)
local watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Name = "WatermarkLabel"
watermarkLabel.Size = UDim2.new(0, 100, 0, 15)
watermarkLabel.Position = UDim2.new(0, 8, 0, 4)
watermarkLabel.BackgroundTransparency = 1
watermarkLabel.Text = "Js Like Beta"
watermarkLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Color Rojo
watermarkLabel.Font = Enum.Font.SourceSansBold
watermarkLabel.TextSize = 11 -- Muy pequeño
watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left 
watermarkLabel.Parent = menuFrame

---------------------------------------------------------
-- COMPONENTES DEL TELEPORT
---------------------------------------------------------

-- Botón GUARDAR (Arriba a la izquierda)
local saveButton = Instance.new("TextButton")
saveButton.Name = "SaveButton"
saveButton.Size = UDim2.new(0, 75, 0, 40)
saveButton.Position = UDim2.new(0, 12, 0, 26) 
saveButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
saveButton.Text = "Guardar"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.Font = Enum.Font.SourceSansBold
saveButton.TextSize = 14
saveButton.Parent = menuFrame

local saveStroke = Instance.new("UIStroke")
saveStroke.Color = Color3.fromRGB(255, 0, 0)
saveStroke.Thickness = 1.5
saveStroke.Parent = saveButton

local cornerSave = Instance.new("UICorner")
cornerSave.CornerRadius = UDim.new(0, 6)
cornerSave.Parent = saveButton

-- Botón TEPEAR (Abajo a la izquierda)
local tpButton = Instance.new("TextButton")
tpButton.Name = "TpButton"
tpButton.Size = UDim2.new(0, 75, 0, 40)
tpButton.Position = UDim2.new(0, 12, 0, 74)
tpButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tpButton.Text = "Tepear"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.Font = Enum.Font.SourceSansBold
tpButton.TextSize = 14
tpButton.Parent = menuFrame

local tpStroke = Instance.new("UIStroke")
tpStroke.Color = Color3.fromRGB(255, 0, 0)
tpStroke.Thickness = 1.5
tpStroke.Parent = tpButton

local cornerTp = Instance.new("UICorner")
cornerTp.CornerRadius = UDim.new(0, 6)
cornerTp.Parent = tpButton

-- CUADRO DE TEXTO "ESCRIBE" (Arriba a la derecha - Blanco)
local textBox = Instance.new("TextBox")
textBox.Name = "PositionTextBox"
textBox.Size = UDim2.new(0, 85, 0, 40)
textBox.Position = UDim2.new(0, 93, 0, 26)
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Fondo blanco
textBox.TextColor3 = Color3.fromRGB(0, 0, 0) -- Texto negro
textBox.PlaceholderText = "Escribe..."
textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
textBox.Text = ""
textBox.Font = Enum.Font.SourceSansBold
textBox.TextSize = 14
textBox.ClipsDescendants = true
textBox.Parent = menuFrame

local cornerText = Instance.new("UICorner")
cornerText.CornerRadius = UDim.new(0, 6)
cornerText.Parent = textBox

-- CUADRO DESPLEGABLE / DROPDOWN PRINCIPAL (Abajo a la derecha)
local dropdownMain = Instance.new("TextButton")
dropdownMain.Name = "DropdownMain"
dropdownMain.Size = UDim2.new(0, 85, 0, 40)
dropdownMain.Position = UDim2.new(0, 93, 0, 74)
dropdownMain.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
dropdownMain.Text = "Ver Tps ▼"
dropdownMain.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownMain.Font = Enum.Font.SourceSansBold
dropdownMain.TextSize = 13
dropdownMain.Parent = menuFrame

local dropdownStroke = Instance.new("UIStroke")
dropdownStroke.Color = Color3.fromRGB(255, 0, 0)
dropdownStroke.Thickness = 1.5
dropdownStroke.Parent = dropdownMain

local cornerDrop = Instance.new("UICorner")
cornerDrop.CornerRadius = UDim.new(0, 6)
cornerDrop.Parent = dropdownMain

-- Contenedor de la lista desplegable (Se abre hacia abajo)
local dropdownListFrame = Instance.new("ScrollingFrame")
dropdownListFrame.Name = "DropdownListFrame"
dropdownListFrame.Size = UDim2.new(0, 85, 0, 0) -- Inicia colapsado
dropdownListFrame.Position = UDim2.new(0, 93, 0, 114)
dropdownListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
dropdownListFrame.BorderSizePixel = 0
dropdownListFrame.ScrollBarThickness = 4
dropdownListFrame.Visible = false
dropdownListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownListFrame.Parent = menuFrame

local listStroke = Instance.new("UIStroke")
listStroke.Color = Color3.fromRGB(255, 0, 0)
listStroke.Thickness = 1
listStroke.Parent = dropdownListFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = dropdownListFrame


---------------------------------------------------------
-- LÓGICA DE FUNCIONAMIENTO
---------------------------------------------------------

-- Redibujar las opciones dentro del menú desplegable
local function refreshDropdown()
	for _, btn in ipairs(dropdownButtons) do
		btn:Destroy()
	end
	dropdownButtons = {}
	
	local index = 0
	for posName, _ in pairs(savedPositions) do
		index = index + 1
		local itemButton = Instance.new("TextButton")
		itemButton.Size = UDim2.new(1, 0, 0, 25)
		itemButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		itemButton.BorderSizePixel = 0
		itemButton.Text = posName
		itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemButton.Font = Enum.Font.SourceSans
		itemButton.TextSize = 12
		itemButton.Parent = dropdownListFrame
		
		itemButton.MouseButton1Click:Connect(function()
			textBox.Text = posName 
			dropdownActive = false
			dropdownListFrame.Visible = false
			dropdownListFrame.Size = UDim2.new(0, 85, 0, 0)
		end)
		
		table.insert(dropdownButtons, itemButton)
	end
	
	dropdownListFrame.CanvasSize = UDim2.new(0, 0, 0, index * 25)
end

-- Mecanismo para abrir/cerrar el dropdown
dropdownMain.MouseButton1Click:Connect(function()
	dropdownActive = not dropdownActive
	if dropdownActive then
		refreshDropdown()
		dropdownListFrame.Visible = true
		TweenService:Create(dropdownListFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 85, 0, math.min(#dropdownButtons * 25, 100))}):Play()
	else
		local tween = TweenService:Create(dropdownListFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 85, 0, 0)})
		tween:Play()
		tween.Completed:Connect(function()
			if not dropdownActive then dropdownListFrame.Visible = false end
		end)
	end
end)

-- Acción de GUARDAR posición actual (Y escribirla en el archivo permanente)
saveButton.MouseButton1Click:Connect(function()
	local name = textBox.Text
	if name ~= "" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		savedPositions[name] = LocalPlayer.Character.HumanoidRootPart.CFrame
		textBox.Text = "" 
		
		saveToStorage() -- GUARDA EN EL ARCHIVO DEL INYECTOR
		
		-- Destello verde rápido de confirmación
		saveButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
		task.wait(0.2)
		saveButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	end
end)

-- Acción de TEPEAR
tpButton.MouseButton1Click:Connect(function()
	local name = textBox.Text
	if name ~= "" and savedPositions[name] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.CFrame = savedPositions[name]
		
		tpButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
		task.wait(0.2)
		tpButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	end
end)
