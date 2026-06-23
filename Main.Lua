-- SERVICIOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- VARIABLES PRINCIPALES
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId 
local FileName = "TpSettings_" .. tostring(PlaceId) .. ".json" 

local savedPositions = {}
local dropdownActive = false
local dropdownButtons = {}

---------------------------------------------------------
-- FUNCIONES DE GUARDADO PERMANENTE
---------------------------------------------------------

local function saveToStorage()
    local dataToSave = {}
    for name, cframe in pairs(savedPositions) do
        dataToSave[name] = {cframe:GetComponents()}
    end

    local success, jsonString = pcall(function()
        return HttpService:JSONEncode(dataToSave)
    end)

    if success and writefile then
        writefile(FileName, jsonString)
    end
end

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
                    savedPositions[name] = CFrame.new(unpack(components))
                end
            end
        end
    end
end

loadFromStorage()

-- 1. INTERFAZ GRÁFICA
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TpMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local menuFrame = Instance.new("Frame")
menuFrame.Name = "TpMenuFrame"
menuFrame.Size = UDim2.new(0, 190, 0, 155) 
menuFrame.Position = UDim2.new(0.5, -95, 0.4, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
menuFrame.Active = true
menuFrame.ClipsDescendants = false 
menuFrame.Parent = screenGui

-- SCRIPT DE ARRASTRE MODERNO
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
menuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
menuFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(255, 0, 0) 
menuStroke.Thickness = 2.5
menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
menuStroke.Parent = menuFrame

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menuFrame

local watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Name = "WatermarkLabel"
watermarkLabel.Size = UDim2.new(0, 100, 0, 15)
watermarkLabel.Position = UDim2.new(0, 8, 0, 4)
watermarkLabel.BackgroundTransparency = 1
watermarkLabel.Text = "Js Like Beta"
watermarkLabel.TextColor3 = Color3.fromRGB(255, 0, 0) 
watermarkLabel.Font = Enum.Font.SourceSansBold
watermarkLabel.TextSize = 11 
watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left 
watermarkLabel.Parent = menuFrame

---------------------------------------------------------
-- COMPONENTES DEL TELEPORT (REUBICADOS)
---------------------------------------------------------

-- COLUMNA IZQUIERDA
local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(0, 75, 0, 40) 
saveButton.Position = UDim2.new(0, 12, 0, 24) 
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

local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0, 75, 0, 40) 
tpButton.Position = UDim2.new(0, 12, 0, 68) 
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


-- COLUMNA DERECHA (NUEVA DISTRIBUCIÓN)

-- Botón BORRAR (Ahora arriba a la derecha, ancho 85)
local deleteButton = Instance.new("TextButton")
deleteButton.Size = UDim2.new(0, 85, 0, 40) 
deleteButton.Position = UDim2.new(0, 93, 0, 24) 
deleteButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
deleteButton.Text = "Borrar"
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.SourceSansBold
deleteButton.TextSize = 14
deleteButton.Parent = menuFrame

local deleteStroke = Instance.new("UIStroke")
deleteStroke.Color = Color3.fromRGB(255, 0, 0)
deleteStroke.Thickness = 1.5
deleteStroke.Parent = deleteButton

local cornerDelete = Instance.new("UICorner")
cornerDelete.CornerRadius = UDim.new(0, 6)
cornerDelete.Parent = deleteButton

-- CUADRO DE TEXTO "ESCRIBE" (Ahora en el centro a la derecha)
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 85, 0, 40)
textBox.Position = UDim2.new(0, 93, 0, 68) 
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
textBox.TextColor3 = Color3.fromRGB(0, 0, 0) 
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
dropdownMain.Size = UDim2.new(0, 85, 0, 40)
dropdownMain.Position = UDim2.new(0, 93, 0, 112)
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

-- Contenedor de la lista desplegable
local dropdownListFrame = Instance.new("ScrollingFrame")
dropdownListFrame.Size = UDim2.new(0, 85, 0, 0) 
dropdownListFrame.Position = UDim2.new(0, 93, 0, 152) -- Abre justo abajo del menú principal
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

-- ACCIÓN DE GUARDAR
saveButton.MouseButton1Click:Connect(function()
    local name = textBox.Text
    if name ~= "" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPositions[name] = LocalPlayer.Character.HumanoidRootPart.CFrame
        textBox.Text = "" 

        saveToStorage()

        saveButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        task.wait(0.2)
        saveButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    else
        saveButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        task.wait(0.2)
        saveButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
end)

-- ACCIÓN DE TEPEAR
tpButton.MouseButton1Click:Connect(function()
    local name = textBox.Text
    if name ~= "" and savedPositions[name] and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(savedPositions[name])

        tpButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        task.wait(0.2)
        tpButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    else
        tpButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        task.wait(0.2)
        tpButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
end)

-- ACCIÓN DE BORRAR
deleteButton.MouseButton1Click:Connect(function()
    local name = textBox.Text
    if name ~= "" and savedPositions[name] then
        savedPositions[name] = nil 
        textBox.Text = "" 

        saveToStorage() 
        
        if dropdownActive then
            refreshDropdown()
        end

        deleteButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        task.wait(0.2)
        deleteButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    else
        deleteButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        task.wait(0.2)
        deleteButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
end)
