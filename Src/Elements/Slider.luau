local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
    local Library = self.Library
    assert(Config.Max, "Slider - Missing maximum value.")

    local Slider = {
        Value = nil,
        Min = typeof(Config.Min) == "number" and Config.Min or 0,
        Max = Config.Max,
        Rounding = typeof(Config.Rounding) == "number" and Config.Rounding or 0,
        Callback = typeof(Config.Callback) == "function" and Config.Callback or function(Value, OldValue) end,
        Changed = Config.Changed or function() end,
        Type = "Slider"
    }

    local Dragging = false
    local LastInput = nil

    local SliderFrame = require(Components.Element)(Config.Title or "Slider", Config.Description, self.Container, false)
    SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

    Slider.SetTitle = SliderFrame.SetTitle
    Slider.SetDesc = SliderFrame.SetDesc

    local TouchArea = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 20),
        Position = UDim2.new(0, 0, 0, -10),
        ZIndex = 10
    })

    local SliderDot = New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -7, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ThemeTag = {
            ImageColor3 = "Accent",
        }
    })

    local function UpdateSlider(InputPosition)
        local SliderPosition = InputPosition.X
        local SliderStart = SliderRail.AbsolutePosition.X
        local SliderWidth = SliderRail.AbsoluteSize.X
        local SizeScale = math.clamp((SliderPosition - SliderStart) / SliderWidth, 0, 1)
        local TargetValue = Slider.Min + ((Slider.Max - Slider.Min) * SizeScale)
        Slider:SetValue(TargetValue)
    end

    local function HandleInput(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            LastInput = Input.Position
            UpdateSlider(Input.Position)
        end
    end

    local function HandleInputEnd(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            LastInput = nil
        end
    end

    Creator.AddSignal(TouchArea.InputBegan, HandleInput)
    Creator.AddSignal(TouchArea.InputEnded, HandleInputEnd)
    Creator.AddSignal(SliderDot.InputBegan, HandleInput)
    Creator.AddSignal(SliderDot.InputEnded, HandleInputEnd)

    Creator.AddSignal(UserInputService.InputChanged, function(Input)
        if Dragging and (
            Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch
        ) then
            LastInput = Input.Position
            UpdateSlider(Input.Position)
        end
    end)

    if UserInputService.TouchEnabled then
        Creator.AddSignal(TouchArea.TouchMoved, function(Touch)
            if Dragging then
                LastInput = Touch.Position
                UpdateSlider(Touch.Position)
            end
        end)
    end

    function Slider:SetValue(Value: number)
        local OldValue = self.Value or Value
        local NewValue = Library.Utilities:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
        rawset(self, "Value", NewValue)
        local Progress = (NewValue - Slider.Min) / (Slider.Max - Slider.Min)
        SliderDot.Position = UDim2.new(Progress, -7, 0.5, 0)
        SliderFill.Size = UDim2.fromScale(Progress, 1)
        SliderDisplay.Text = tostring(NewValue)
        if NewValue ~= OldValue then
            if typeof(Slider.Callback) == "function" then
                Library:SafeCallback(Slider.Callback, NewValue, OldValue)
            end
            if typeof(Slider.Changed) == "function" then
                Library:SafeCallback(Slider.Changed, NewValue, OldValue)
            end
        end
    end

    return setmetatable(Slider, {
        __newindex = function(self, index, newvalue)
            if index == "Value" then
                task.spawn(Slider.SetValue, Slider, newvalue)
            end
            rawset(self, index, newvalue)
        end
    })
end

return Element		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = "Value",
		ClearTextOnFocus = true,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 14),
		Position = UDim2.new(0, -4, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = {
			TextColor3 = "SubText",
		}
	})

	local SliderInner = New("Frame", {
		Size = UDim2.new(1, 0, 0, 4),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 0.4,
		Parent = SliderFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "SliderRail",
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		New("UISizeConstraint", {
			MaxSize = Vector2.new(150, math.huge),
		}),
		SliderDisplay,
		SliderFill,
		SliderRail
	})

	Creator.AddSignal(SliderDot.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = true
		end
	end)

	Creator.AddSignal(SliderDot.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = false
		end
	end)

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Library:SafeCallback(Func, Slider.Value, Slider.Value)
	end

	function Slider:SetValue(Value: number)
		local OldValue = self.Value or Value

		rawset(self, "Value", Library.Utilities:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding))

		SliderDot.Position = UDim2.new((self.Value - Slider.Min) / (Slider.Max - Slider.Min), -7, 0.5, 0)
		SliderFill.Size = UDim2.fromScale((self.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)
		SliderDisplay.Text = tostring(self.Value)

		if typeof(Slider.Callback) == "function" then
			Library:SafeCallback(Slider.Callback, self.Value, OldValue)
		end
		if typeof(Slider.Changed) == "function" then
			Library:SafeCallback(Slider.Changed, self.Value, OldValue)
		end
	end

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if
			Dragging
			and (
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local SizeScale =
				math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
			Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
		end
	end)

	Creator.AddSignal(SliderDisplay.FocusLost, function()
		Slider:SetValue(tonumber(SliderDisplay.Text) or Slider.Value)
	end)

	function Slider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(typeof(Config.Default) == "number" and Config.Default or Slider.Min)

	Library.Options[Idx] = Slider

	Slider.Instance = SliderFrame

	return setmetatable(Slider, {
		__newindex =  function(self, index, newvalue)
			if index == "Value" then
				task.spawn(Slider.SetValue, Slider, newvalue)
			end
			rawset(self, index, newvalue)
		end
	})
end

return Element
