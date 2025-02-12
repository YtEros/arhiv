repeat wait()
	a = pcall(function()
		game:WaitForChild("Players").LocalPlayer:WaitForChild("PlayerScripts").ChildAdded:Connect(function(c)
			if c.Name == "PlayerScriptsLoader"then
				c.Disabled = true
			end
		end)
	end)
	if a == true then break end
until true == false

game:WaitForChild("Players").LocalPlayer:WaitForChild("PlayerScripts").ChildAdded:Connect(function(c)
	if c.Name == "PlayerScriptsLoader"then
		c.Disabled = true
	end
end)

function _CameraUI()
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")

	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		LocalPlayer = Players.LocalPlayer
	end

	local function waitForChildOfClass(parent, class)
		local child = parent:FindFirstChildOfClass(class)
		while not child or child.ClassName ~= class do
			child = parent.ChildAdded:Wait()
		end
		return child
	end

	local PlayerGui = waitForChildOfClass(LocalPlayer, "PlayerGui")

	local TOAST_OPEN_SIZE = UDim2.new(0, 326, 0, 58)
	local TOAST_CLOSED_SIZE = UDim2.new(0, 80, 0, 58)
	local TOAST_BACKGROUND_COLOR = Color3.fromRGB(32, 32, 32)
	local TOAST_BACKGROUND_TRANS = 0.4
	local TOAST_FOREGROUND_COLOR = Color3.fromRGB(200, 200, 200)
	local TOAST_FOREGROUND_TRANS = 0

	-- Convenient syntax for creating a tree of instanes
	local function create(className)
		return function(props)
			local inst = Instance.new(className)
			local parent = props.Parent
			props.Parent = nil
			for name, val in pairs(props) do
				if type(name) == "string" then
					inst[name] = val
				else
					val.Parent = inst
				end
			end
			-- Only set parent after all other properties are initialized
			inst.Parent = parent
			return inst
		end
	end

	local initialized = false

	local uiRoot
	local toast
	local toastIcon
	local toastUpperText
	local toastLowerText

	local function initializeUI()
		assert(not initialized)

		uiRoot = create("ScreenGui"){
			Name = "RbxCameraUI",
			AutoLocalize = false,
			Enabled = true,
			DisplayOrder = -1, -- Appears behind default developer UI
			IgnoreGuiInset = false,
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

			create("ImageLabel"){
				Name = "Toast",
				Visible = false,
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 8),
				Size = TOAST_CLOSED_SIZE,
				Image = "rbxasset://textures/ui/Camera/CameraToast9Slice.png",
				ImageColor3 = TOAST_BACKGROUND_COLOR,
				ImageRectSize = Vector2.new(6, 6),
				ImageTransparency = 1,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(3, 3, 3, 3),
				ClipsDescendants = true,

				create("Frame"){
					Name = "IconBuffer",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(0, 80, 1, 0),

					create("ImageLabel"){
						Name = "Icon",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0, 48, 0, 48),
						ZIndex = 2,
						Image = "rbxasset://textures/ui/Camera/CameraToastIcon.png",
						ImageColor3 = TOAST_FOREGROUND_COLOR,
						ImageTransparency = 1,
					}
				},

				create("Frame"){
					Name = "TextBuffer",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 80, 0, 0),
					Size = UDim2.new(1, -80, 1, 0),
					ClipsDescendants = true,

					create("TextLabel"){
						Name = "Upper",
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 0, 19),
						Font = Enum.Font.GothamSemibold,
						Text = "Camera control enabled",
						TextColor3 = TOAST_FOREGROUND_COLOR,
						TextTransparency = 1,
						TextSize = 19,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
					},

					create("TextLabel"){
						Name = "Lower",
						AnchorPoint = Vector2.new(0, 0),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0.5, 3),
						Size = UDim2.new(1, 0, 0, 15),
						Font = Enum.Font.Gotham,
						Text = "Right mouse button to toggle",
						TextColor3 = TOAST_FOREGROUND_COLOR,
						TextTransparency = 1,
						TextSize = 15,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
					},
				},
			},

			Parent = PlayerGui,
		}

		toast = uiRoot.Toast
		toastIcon = toast.IconBuffer.Icon
		toastUpperText = toast.TextBuffer.Upper
		toastLowerText = toast.TextBuffer.Lower

		initialized = true
	end

	local CameraUI = {}

	do
		-- Instantaneously disable the toast or enable for opening later on. Used when switching camera modes.
		function CameraUI.setCameraModeToastEnabled(enabled)
			if not enabled and not initialized then
				return
			end

			if not initialized then
				initializeUI()
			end

			toast.Visible = enabled
			if not enabled then
				CameraUI.setCameraModeToastOpen(false)
			end
		end

		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		-- Tween the toast in or out. Toast must be enabled with setCameraModeToastEnabled.
		function CameraUI.setCameraModeToastOpen(open)
			assert(initialized)

			TweenService:Create(toast, tweenInfo, {
				Size = open and TOAST_OPEN_SIZE or TOAST_CLOSED_SIZE,
				ImageTransparency = open and TOAST_BACKGROUND_TRANS or 1,
			}):Play()

			TweenService:Create(toastIcon, tweenInfo, {
				ImageTransparency = open and TOAST_FOREGROUND_TRANS or 1,
			}):Play()

			TweenService:Create(toastUpperText, tweenInfo, {
				TextTransparency = open and TOAST_FOREGROUND_TRANS or 1,
			}):Play()

			TweenService:Create(toastLowerText, tweenInfo, {
				TextTransparency = open and TOAST_FOREGROUND_TRANS or 1,
			}):Play()
		end
	end

	return CameraUI
end

function _CameraToggleStateController()
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local GameSettings = UserSettings():GetService("UserGameSettings")

	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		LocalPlayer = Players.LocalPlayer
	end

	local Mouse = LocalPlayer:GetMouse()

	local Input = _CameraInput()
	local CameraUI = _CameraUI()

	local lastTogglePan = false
	local lastTogglePanChange = tick()

	local CROSS_MOUSE_ICON = "rbxasset://textures/Cursors/CrossMouseIcon.png"

	local lockStateDirty = false
	local wasTogglePanOnTheLastTimeYouWentIntoFirstPerson = false
	local lastFirstPerson = false

	CameraUI.setCameraModeToastEnabled(false)

	return function(isFirstPerson)
		local togglePan = Input.getTogglePan()
		local toastTimeout = 3

		if isFirstPerson and togglePan ~= lastTogglePan then
			lockStateDirty = true
		end

		if lastTogglePan ~= togglePan or tick() - lastTogglePanChange > toastTimeout then
			local doShow = togglePan and tick() - lastTogglePanChange < toastTimeout

			CameraUI.setCameraModeToastOpen(doShow)

			if togglePan then
				lockStateDirty = false
			end
			lastTogglePanChange = tick()
			lastTogglePan = togglePan
		end

		if isFirstPerson ~= lastFirstPerson then
			if isFirstPerson then
				wasTogglePanOnTheLastTimeYouWentIntoFirstPerson = Input.getTogglePan()
				Input.setTogglePan(true)
			elseif not lockStateDirty then
				Input.setTogglePan(wasTogglePanOnTheLastTimeYouWentIntoFirstPerson)
			end
		end

		if isFirstPerson then
			if Input.getTogglePan() then
				Mouse.Icon = CROSS_MOUSE_ICON
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				--GameSettings.RotationType = Enum.RotationType.CameraRelative
			else
				Mouse.Icon = ""
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				--GameSettings.RotationType = Enum.RotationType.CameraRelative
			end

		elseif Input.getTogglePan() then
			Mouse.Icon = CROSS_MOUSE_ICON
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			GameSettings.RotationType = Enum.RotationType.MovementRelative

		elseif Input.getHoldPan() then
			Mouse.Icon = ""
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			GameSettings.RotationType = Enum.RotationType.MovementRelative

		else
			Mouse.Icon = ""
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			GameSettings.RotationType = Enum.RotationType.MovementRelative
		end

		lastFirstPerson = isFirstPerson
	end
end

function _CameraInput()
	local UserInputService = game:GetService("UserInputService")

	local MB_TAP_LENGTH = 0.3 -- length of time for a short mouse button tap to be registered

	local rmbDown, rmbUp
	do
		local rmbDownBindable = Instance.new("BindableEvent")
		local rmbUpBindable = Instance.new("BindableEvent")

		rmbDown = rmbDownBindable.Event
		rmbUp = rmbUpBindable.Event

		UserInputService.InputBegan:Connect(function(input, gpe)
			if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
				rmbDownBindable:Fire()
			end
		end)

		UserInputService.InputEnded:Connect(function(input, gpe)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				rmbUpBindable:Fire()
			end
		end)
	end

	local holdPan = false
	local togglePan = false
	local lastRmbDown = 0 -- tick() timestamp of the last right mouse button down event

	local CameraInput = {}

	function CameraInput.getHoldPan()
		return holdPan
	end

	function CameraInput.getTogglePan()
		return togglePan
	end

	function CameraInput.getPanning()
		return togglePan or holdPan
	end

	function CameraInput.setTogglePan(value)
		togglePan = value
	end

	local cameraToggleInputEnabled = false
	local rmbDownConnection
	local rmbUpConnection

	function CameraInput.enableCameraToggleInput()
		if cameraToggleInputEnabled then
			return
		end
		cameraToggleInputEnabled = true

		holdPan = false
		togglePan = false

		if rmbDownConnection then
			rmbDownConnection:Disconnect()
		end

		if rmbUpConnection then
			rmbUpConnection:Disconnect()
		end

		rmbDownConnection = rmbDown:Connect(function()
			holdPan = true
			lastRmbDown = tick()
		end)

		rmbUpConnection = rmbUp:Connect(function()
			holdPan = false
			if tick() - lastRmbDown < MB_TAP_LENGTH and (togglePan or UserInputService:GetMouseDelta().Magnitude < 2) then
				togglePan = not togglePan
			end
		end)
	end

	function CameraInput.disableCameraToggleInput()
		if not cameraToggleInputEnabled then
			return
		end
		cameraToggleInputEnabled = false

		if rmbDownConnection then
			rmbDownConnection:Disconnect()
			rmbDownConnection = nil
		end
		if rmbUpConnection then
			rmbUpConnection:Disconnect()
			rmbUpConnection = nil
		end
	end

	return CameraInput
end

function _BaseCamera()
        --[[
            BaseCamera - Abstract base class for camera control modules
            2018 Camera Update - AllYourBlox
        --]]

	--[[ Local Constants ]]--
	local UNIT_Z = Vector3.new(0,0,1)
	local X1_Y0_Z1 = Vector3.new(1,0,1)	--Note: not a unit vector, used for projecting onto XZ plane

	local THUMBSTICK_DEADZONE = 0.2
	local DEFAULT_DISTANCE = 12.5	-- Studs
	local PORTRAIT_DEFAULT_DISTANCE = 25		-- Studs
	local FIRST_PERSON_DISTANCE_THRESHOLD = 1.0 -- Below this value, snap into first person

	local CAMERA_ACTION_PRIORITY = Enum.ContextActionPriority.Default.Value

	-- Note: DotProduct check in CoordinateFrame::lookAt() prevents using values within about
	-- 8.11 degrees of the +/- Y axis, that's why these limits are currently 80 degrees
	local MIN_Y = math.rad(-80)
	local MAX_Y = math.rad(80)

	local TOUCH_ADJUST_AREA_UP = math.rad(30)
	local TOUCH_ADJUST_AREA_DOWN = math.rad(-15)

	local TOUCH_SENSITIVTY_ADJUST_MAX_Y = 2.1
	local TOUCH_SENSITIVTY_ADJUST_MIN_Y = 0.5

	local VR_ANGLE = math.rad(15)
	local VR_LOW_INTENSITY_ROTATION = Vector2.new(math.rad(15), 0)
	local VR_HIGH_INTENSITY_ROTATION = Vector2.new(math.rad(45), 0)
	local VR_LOW_INTENSITY_REPEAT = 0.1
	local VR_HIGH_INTENSITY_REPEAT = 0.4

	local ZERO_VECTOR2 = Vector2.new(0,0)
	local ZERO_VECTOR3 = Vector3.new(0,0,0)

	local TOUCH_SENSITIVTY = Vector2.new(0.00945 * math.pi, 0.003375 * math.pi)
	local MOUSE_SENSITIVITY = Vector2.new( 0.002 * math.pi, 0.0015 * math.pi )

	local SEAT_OFFSET = Vector3.new(0,5,0)
	local VR_SEAT_OFFSET = Vector3.new(0,4,0)
	local HEAD_OFFSET = Vector3.new(0,1.5,0)
	local R15_HEAD_OFFSET = Vector3.new(0, 1.5, 0)
	local R15_HEAD_OFFSET_NO_SCALING = Vector3.new(0, 2, 0)
	local HUMANOID_ROOT_PART_SIZE = Vector3.new(2, 2, 1)

	local GAMEPAD_ZOOM_STEP_1 = 0
	local GAMEPAD_ZOOM_STEP_2 = 10
	local GAMEPAD_ZOOM_STEP_3 = 20

	local PAN_SENSITIVITY = 20
	local ZOOM_SENSITIVITY_CURVATURE = 0.5

	local abs = math.abs
	local sign = math.sign

	local FFlagUserCameraToggle do
		local success, result = pcall(function()
			return UserSettings():IsUserFeatureEnabled("UserCameraToggle")
		end)
		FFlagUserCameraToggle = success and result
	end

	local FFlagUserDontAdjustSensitvityForPortrait do
		local success, result = pcall(function()
			return UserSettings():IsUserFeatureEnabled("UserDontAdjustSensitvityForPortrait")
		end)
		FFlagUserDontAdjustSensitvityForPortrait = success and result
	end

	local FFlagUserFixZoomInZoomOutDiscrepancy do
		local success, result = pcall(function()
			return UserSettings():IsUserFeatureEnabled("UserFixZoomInZoomOutDiscrepancy")
		end)
		FFlagUserFixZoomInZoomOutDiscrepancy = success and result
	end

	local Util = _CameraUtils()
	local ZoomController = _ZoomController()
	local CameraToggleStateController = _CameraToggleStateController()
	local CameraInput = _CameraInput()
	local CameraUI = _CameraUI()

	--[[ Roblox Services ]]--
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local StarterGui = game:GetService("StarterGui")
	local GuiService = game:GetService("GuiService")
	local ContextActionService = game:GetService("ContextActionService")
	local VRService = game:GetService("VRService")
	local UserGameSettings = UserSettings():GetService("UserGameSettings")

	local player = Players.LocalPlayer 

	--[[ The Module ]]--
	local BaseCamera = {}
	BaseCamera.__index = BaseCamera

	function BaseCamera.new()
		local self = setmetatable({}, BaseCamera)

		-- So that derived classes have access to this
		self.FIRST_PERSON_DISTANCE_THRESHOLD = FIRST_PERSON_DISTANCE_THRESHOLD

		self.cameraType = nil
		self.cameraMovementMode = nil

		self.lastCameraTransform = nil
		self.rotateInput = ZERO_VECTOR2
		self.userPanningCamera = false
		self.lastUserPanCamera = tick()

		self.humanoidRootPart = nil
		self.humanoidCache = {}

		-- Subject and position on last update call
		self.lastSubject = nil
		self.lastSubjectPosition = Vector3.new(0,5,0)

		-- These subject distance members refer to the nominal camera-to-subject follow distance that the camera
		-- is trying to maintain, not the actual measured value.
		-- The default is updated when screen orientation or the min/max distances change,
		-- to be sure the default is always in range and appropriate for the orientation.
		self.defaultSubjectDistance = math.clamp(DEFAULT_DISTANCE, player.CameraMinZoomDistance, player.CameraMaxZoomDistance)
		self.currentSubjectDistance = math.clamp(DEFAULT_DISTANCE, player.CameraMinZoomDistance, player.CameraMaxZoomDistance)

		self.inFirstPerson = false
		self.inMouseLockedMode = false
		self.portraitMode = false
		self.isSmallTouchScreen = false

		-- Used by modules which want to reset the camera angle on respawn.
		self.resetCameraAngle = true

		self.enabled = false

		-- Input Event Connections
		self.inputBeganConn = nil
		self.inputChangedConn = nil
		self.inputEndedConn = nil

		self.startPos = nil
		self.lastPos = nil
		self.panBeginLook = nil

		self.panEnabled = true
		self.keyPanEnabled = true
		self.distanceChangeEnabled = true

		self.PlayerGui = nil

		self.cameraChangedConn = nil
		self.viewportSizeChangedConn = nil

		self.boundContextActions = {}

		-- VR Support
		self.shouldUseVRRotation = false
		self.VRRotationIntensityAvailable = false
		self.lastVRRotationIntensityCheckTime = 0
		self.lastVRRotationTime = 0
		self.vrRotateKeyCooldown = {}
		self.cameraTranslationConstraints = Vector3.new(1, 1, 1)
		self.humanoidJumpOrigin = nil
		self.trackingHumanoid = nil
		self.cameraFrozen = false
		self.subjectStateChangedConn = nil

		-- Gamepad support
		self.activeGamepad = nil
		self.gamepadPanningCamera = false
		self.lastThumbstickRotate = nil
		self.numOfSeconds = 0.7
		self.currentSpeed = 0
		self.maxSpeed = 6
		self.vrMaxSpeed = 4
		self.lastThumbstickPos = Vector2.new(0,0)
		self.ySensitivity = 0.65
		self.lastVelocity = nil
		self.gamepadConnectedConn = nil
		self.gamepadDisconnectedConn = nil
		self.currentZoomSpeed = 1.0
		self.L3ButtonDown = false
		self.dpadLeftDown = false
		self.dpadRightDown = false

		-- Touch input support
		self.isDynamicThumbstickEnabled = false
		self.fingerTouches = {}
		self.dynamicTouchInput = nil
		self.numUnsunkTouches = 0
		self.inputStartPositions = {}
		self.inputStartTimes = {}
		self.startingDiff = nil
		self.pinchBeginZoom = nil
		self.userPanningTheCamera = false
		self.touchActivateConn = nil

		-- Mouse locked formerly known as shift lock mode
		self.mouseLockOffset = ZERO_VECTOR3

		-- [[ NOTICE ]] --
		-- Initialization things used to always execute at game load time, but now these camera modules are instantiated
		-- when needed, so the code here may run well after the start of the game

		if player.Character then
			self:OnCharacterAdded(player.Character)
		end

		player.CharacterAdded:Connect(function(char)
			self:OnCharacterAdded(char)
		end)

		if self.cameraChangedConn then self.cameraChangedConn:Disconnect() end
		self.cameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			self:OnCurrentCameraChanged()
		end)
		self:OnCurrentCameraChanged()

		if self.playerCameraModeChangeConn then self.playerCameraModeChangeConn:Disconnect() end
		self.playerCameraModeChangeConn = player:GetPropertyChangedSignal("CameraMode"):Connect(function()
			self:OnPlayerCameraPropertyChange()
		end)

		if self.minDistanceChangeConn then self.minDistanceChangeConn:Disconnect() end
		self.minDistanceChangeConn = player:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
			self:OnPlayerCameraPropertyChange()
		end)

		if self.maxDistanceChangeConn then self.maxDistanceChangeConn:Disconnect() end
		self.maxDistanceChangeConn = player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
			self:OnPlayerCameraPropertyChange()
		end)

		if self.playerDevTouchMoveModeChangeConn then self.playerDevTouchMoveModeChangeConn:Disconnect() end
		self.playerDevTouchMoveModeChangeConn = player:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
			self:OnDevTouchMovementModeChanged()
		end)
		self:OnDevTouchMovementModeChanged() -- Init

		if self.gameSettingsTouchMoveMoveChangeConn then self.gameSettingsTouchMoveMoveChangeConn:Disconnect() end
		self.gameSettingsTouchMoveMoveChangeConn = UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
			self:OnGameSettingsTouchMovementModeChanged()
		end)
		self:OnGameSettingsTouchMovementModeChanged() -- Init

		UserGameSettings:SetCameraYInvertVisible()
		UserGameSettings:SetGamepadCameraSensitivityVisible()

		self.hasGameLoaded = game:IsLoaded()
		if not self.hasGameLoaded then
			self.gameLoadedConn = game.Loaded:Connect(function()
				self.hasGameLoaded = true
				self.gameLoadedConn:Disconnect()
				self.gameLoadedConn = nil
			end)
		end

		self:OnPlayerCameraPropertyChange()

		return self
	end

	function BaseCamera:GetModuleName()
		return "BaseCamera"
	end

	function BaseCamera:OnCharacterAdded(char)
		self.resetCameraAngle = self.resetCameraAngle or self:GetEnabled()
		self.humanoidRootPart = nil
		if UserInputService.TouchEnabled then
			self.PlayerGui = player:WaitForChild("PlayerGui")
			for _, child in ipairs(char:GetChild
