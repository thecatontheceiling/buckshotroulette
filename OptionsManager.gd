class_name OptionsManager extends Node

@export var controller : ControllerManager

@export var defaultOption_language : String = "EN"
@export var defaultOption_windowed : bool
@export var defaultOption_controllerActive : bool
var defaultOption_inputmap_keyboard = {
	"ui_accept": InputMap.action_get_events("ui_accept")[0],
	"ui_cancel": InputMap.action_get_events("ui_cancel")[0],
	"ui_left": InputMap.action_get_events("ui_left")[0],
	"ui_right": InputMap.action_get_events("ui_right")[0],
	"ui_up": InputMap.action_get_events("ui_up")[0],
	"ui_down": InputMap.action_get_events("ui_down")[0],
	"reset": InputMap.action_get_events("reset")[0],
	"exit game": InputMap.action_get_events("exit game")[0]
}
var defaultOption_inputmap_controller = {
	"ui_accept": InputMap.action_get_events("ui_accept")[1],
	"ui_cancel": InputMap.action_get_events("ui_cancel")[1],
	"ui_left": InputMap.action_get_events("ui_left")[1],
	"ui_right": InputMap.action_get_events("ui_right")[1],
	"ui_up": InputMap.action_get_events("ui_up")[1],
	"ui_down": InputMap.action_get_events("ui_down")[1],
	"reset": InputMap.action_get_events("reset")[1],
	"exit game": InputMap.action_get_events("exit game")[1]
}

@export var ui_windowed : CanvasItem
@export var ui_fullscreen : CanvasItem
@export var ui_deviceController : CanvasItem
@export var ui_deviceMouse : CanvasItem
@export var button_windowed : ButtonClass
@export var button_fullscreen : ButtonClass
@export var menu : MenuManager
@export var ui_volume : Label

const savePath := "user://buckshotroulette_options_12.shell"
var data = {}
var data_inputmap = {}
var setting_inputmap_keyboard = {}
var setting_inputmap_controller = {}
var setting_volume = 1
var setting_windowed = false
var setting_language = "EN"
var setting_controllerEnabled = false

func _ready():
	LoadSettings()
	if (!receivedFile):
		setting_windowed = defaultOption_windowed
		setting_controllerEnabled = defaultOption_controllerActive
		setting_language = defaultOption_language
		setting_inputmap_keyboard = defaultOption_inputmap_keyboard
		setting_inputmap_controller = defaultOption_inputmap_controller
		ApplySettings_window()
		ApplySettings_controller()
		ApplySettings_language()
		ApplySettings_inputmap()

func Adjust(alias : String):
	match(alias):
		"increase":
			if setting_volume != 1:
				setting_volume = setting_volume + 0.05
				if setting_volume > 1:
					setting_volume = 1
			UpdateDisplay()
			ApplySettings_volume()
		"decrease":
			if setting_volume != 0:
				setting_volume = setting_volume - 0.05
			if setting_volume < 0:
				setting_volume = 0
			UpdateDisplay()
			ApplySettings_volume()
		"controller enable":
			setting_controllerEnabled = true
			ApplySettings_controller()
		"controller disable":
			setting_controllerEnabled = false
			ApplySettings_controller()
		"windowed":
			setting_windowed = true
			ApplySettings_window()
		"fullscreen":
			setting_windowed = false
			ApplySettings_window()
		
	if (alias != "increase" && alias != "decrease"): menu.ResetButtons()


func AdjustLanguage(alias : String):
	setting_language = alias
	ApplySettings_language()
	menu.ResetButtons()
	return

func ApplySettings_volume():
	AudioServer.set_bus_volume_db(0, linear_to_db(setting_volume))
	UpdateDisplay()
	pass

func UpdateDisplay():
	ui_volume.text = str(snapped(setting_volume * 100, .01)) + "%"

func ApplySettings_window():
	if (!setting_windowed): 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		ui_fullscreen.modulate.a = 1
		ui_windowed.modulate.a = .5
		button_fullscreen.mainActive = true
		button_windowed.mainActive = true
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		ui_fullscreen.modulate.a = .5
		ui_windowed.modulate.a = 1
		button_fullscreen.mainActive = true
		button_windowed.mainActive = true
	pass

func ApplySettings_controller():
	if (setting_controllerEnabled):
		controller.SetMainControllerState(true)
		ui_deviceController.modulate.a = 1
		ui_deviceMouse.modulate.a = .5
		GlobalVariables.controllerEnabled = true
	else:
		controller.SetMainControllerState(false)
		ui_deviceController.modulate.a = .5
		ui_deviceMouse.modulate.a = 1
		GlobalVariables.controllerEnabled = false

func ParseInputMapDictionary():
	setting_inputmap_keyboard = {
		"ui_accept": var_to_str(InputMap.action_get_events("ui_accept")[0]),
		"ui_cancel": var_to_str(InputMap.action_get_events("ui_cancel")[0]),
		"ui_left": var_to_str(InputMap.action_get_events("ui_left")[0]),
		"ui_right": var_to_str(InputMap.action_get_events("ui_right")[0]),
		"ui_up": var_to_str(InputMap.action_get_events("ui_up")[0]),
		"ui_down": var_to_str(InputMap.action_get_events("ui_down")[0]),
		"reset": var_to_str(InputMap.action_get_events("reset")[0]),
		"exit game": var_to_str(InputMap.action_get_events("exit game")[0])
	}
	setting_inputmap_controller = {
		"ui_accept": var_to_str(InputMap.action_get_events("ui_accept")[1]),
		"ui_cancel": var_to_str(InputMap.action_get_events("ui_cancel")[1]),
		"ui_left": var_to_str(InputMap.action_get_events("ui_left")[1]),
		"ui_right": var_to_str(InputMap.action_get_events("ui_right")[1]),
		"ui_up": var_to_str(InputMap.action_get_events("ui_up")[1]),
		"ui_down": var_to_str(InputMap.action_get_events("ui_down")[1]),
		"reset": var_to_str(InputMap.action_get_events("reset")[1]),
		"exit game": var_to_str(InputMap.action_get_events("exit game")[1])
	}

func ResetControls():
	setting_inputmap_keyboard = defaultOption_inputmap_keyboard
	setting_inputmap_controller = defaultOption_inputmap_controller
	ApplySettings_inputmap()
	keyrebinding.UpdateBindList()

@export var keyrebinding : Rebinding
var setting = false
func ApplySettings_inputmap():
	for key in setting_inputmap_keyboard:
		var value = setting_inputmap_keyboard[key]
		if (setting): value = str_to_var(value)
		InputMap.action_erase_events(key)
		InputMap.action_add_event(key, value)
	for key in setting_inputmap_controller:
		var value = setting_inputmap_controller[key]
		if (setting): value = str_to_var(value)
		InputMap.action_add_event(key, value)
	keyrebinding.UpdateBindList()
	setting = false

func ApplySettings_language():
	TranslationServer.set_locale(setting_language)

func SaveSettings():
	data = {
		#"has_read_introduction": roundManager.playerData.hasReadIntroduction,
		"setting_volume": setting_volume,
		"setting_windowed": setting_windowed,
		"setting_language" : setting_language,
		"setting_controllerEnabled" : setting_controllerEnabled,
		"setting_inputmap_keyboard": setting_inputmap_keyboard,
		"setting_inputmap_controller": setting_inputmap_controller
	}
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	file.store_var(data)
	file.close()

var receivedFile = false
func LoadSettings():
	if (FileAccess.file_exists(savePath)):
		var file = FileAccess.open(savePath, FileAccess.READ)
		data = file.get_var()
		setting_volume = data.setting_volume
		setting_windowed = data.setting_windowed
		setting_language = data.setting_language
		setting_controllerEnabled = data.setting_controllerEnabled
		setting_inputmap_keyboard = data.setting_inputmap_keyboard
		setting_inputmap_controller = data.setting_inputmap_controller
		file.close()
		setting = true
		ApplySettings_volume()
		ApplySettings_window()
		ApplySettings_language()
		ApplySettings_controller()
		ApplySettings_inputmap()
		receivedFile = true
