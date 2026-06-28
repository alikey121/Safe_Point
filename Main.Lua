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

-- COLORES ESTILO JS-LIKE (DARK)
local COLOR_BG = Color3.fromRGB(12, 12, 12)
local COLOR_ACCENT = Color3.fromRGB(230, 0, 0)
local COLOR_BUTTON_DROP = Color3.fromRGB(18, 18, 18)
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)

---------------------------------------------------------
-- FUNCIONES DE GUARDADO
---------------------------------------------------------
local function saveToStorage()
    local dataToSave = {}
    for name, cframe in pairs(savedPositions) do
        dataToSave[name] = {cframe:GetComponents()}
    end
    if writefile then writefile(FileName, HttpService:JSONEncode(dataToSave)) end
end

local function loadFromStorage()
    if readfile and isfile and isfile(FileName) then
        local success, decodedData = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if success and decodedData then
            for name, components in pairs(decodedData) do savedPositions[name] = CFrame.new(unpack(components)) end
        end
    end
end
loadFromStorage()

-- INTERFAZ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TpMenuGui"
screenGui.ResetOnSpawn = false -- CORRECCIÓN: Evita que el menú se borre al morir
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Name = "TpMenuFrame"
menuFrame.Size = UDim2.new(0, 190, 0, 160)
menuFrame.Position = UDim2.new(0.5, -95, 0.4, 0)
menuFrame.BackgroundColor3 = COLOR_BG
menuFrame.BackgroundTransparency = 0.05
menuFrame.Active = true
menuFrame.BorderSizePixel = 0
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 12)
local menuStroke = Instance.new("UIStroke", menuFrame)
menuStroke.Color = COLOR_ACCENT
menuStroke.Thickness = 2

-- LÓGICA DE ARRASTRE
local dragging, dragStart, startPos
menuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
    end
end)
menuFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- TÍTULO
local title = Instance.new("TextLabel", menuFrame)
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Js Like Beta // TPs"
title.TextColor3 = COLOR_ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left

-- COMPONENTES BASE
local function createStyledButton(pos, size, text)
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = text
    btn.TextColor3 = COLOR_TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = COLOR_ACCENT
    stroke.Thickness = 1
    return btn
end

-- TEXTBOX
local textBox = Instance.new("TextBox", menuFrame)
textBox.Size = UDim2.new(0, 75, 0, 40)
textBox.Position = UDim2.new(0, 12, 0, 28)
textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
textBox.TextColor3 = COLOR_TEXT
textBox.PlaceholderText = "New Tp.."
textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 12
Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", textBox, {Color = COLOR_ACCENT, Thickness = 1})

-- BOTONES
local deleteButton = createStyledButton(UDim2.new(0, 93, 0, 28), UDim2.new(0, 85, 0, 40), "Borrar")
local dropdownMain = createStyledButton(UDim2.new(0, 12, 0, 72), UDim2.new(0, 75, 0, 40), "Ver Tps ►")
local tpButton = createStyledButton(UDim2.new(0, 12, 0, 116), UDim2.new(0, 75, 0, 40), "Tepear")
local saveButton = createStyledButton(UDim2.new(0, 93, 0, 72), UDim2.new(0, 85, 0, 40), "Guardar")

-- DROPDOWN DERECHA
local dropdownListFrame = Instance.new("ScrollingFrame", menuFrame)
dropdownListFrame.Name = "DropdownFrame"
dropdownListFrame.Size = UDim2.new(0, 0, 0, 160)
dropdownListFrame.Position = UDim2.new(1, 5, 0, 0)
dropdownListFrame.BackgroundColor3 = COLOR_BG
dropdownListFrame.Visible = false
dropdownListFrame.ScrollBarThickness = 2
dropdownListFrame.BorderSizePixel = 0
dropdownListFrame.ClipsDescendants = true
Instance.new("UICorner", dropdownListFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", dropdownListFrame, {Color = COLOR_ACCENT, Thickness = 2})
local listLayout = Instance.new("UIListLayout", dropdownListFrame)
listLayout.Padding = UDim.new(0, 0)

local function refreshDropdown()
    for _, btn in ipairs(dropdownButtons) do btn:Destroy() end
    dropdownButtons = {}
    for posName, _ in pairs(savedPositions) do
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 28)
        item.BackgroundColor3 = COLOR_BUTTON_DROP
        item.AutoButtonColor = false
        item.Text = posName
        item.TextColor3 = COLOR_TEXT
        item.Font = Enum.Font.Gotham
        item.TextSize = 12
        item.BorderSizePixel = 0
        item.Parent = dropdownListFrame

        item.MouseEnter:Connect(function() item.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end)
        item.MouseLeave:Connect(function() item.BackgroundColor3 = COLOR_BUTTON_DROP end)

        item.MouseButton1Click:Connect(function() 
            textBox.Text = posName
        end)
        table.insert(dropdownButtons, item)
    end
    dropdownListFrame.CanvasSize = UDim2.new(0, 0, 0, #dropdownButtons * 28)
end

dropdownMain.MouseButton1Click:Connect(function()
    dropdownActive = not dropdownActive
    if dropdownActive then 
        refreshDropdown()
        dropdownListFrame.Visible = true
        TweenService:Create(dropdownListFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 120, 0, 160)}):Play()
    else 
        TweenService:Create(dropdownListFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 160)}):Play()
        task.wait(0.2)
        dropdownListFrame.Visible = false 
    end
end)

-- EVENTOS DE BOTONES
saveButton.MouseButton1Click:Connect(function() 
    if textBox.Text ~= "" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        savedPositions[textBox.Text] = LocalPlayer.Character.HumanoidRootPart.CFrame
        saveToStorage()
        textBox.Text = "" 
        refreshDropdown()
    end 
end)

tpButton.MouseButton1Click:Connect(function() 
    if savedPositions[textBox.Text] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = savedPositions[textBox.Text]
    end 
end)

deleteButton.MouseButton1Click:Connect(function() 
    if savedPositions[textBox.Text] then 
        savedPositions[textBox.Text] = nil
        saveToStorage()
        refreshDropdown() 
        textBox.Text = ""
    end 
end)
