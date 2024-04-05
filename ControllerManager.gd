class_name ControllerManager extends Node

@export var dynamicallySwappingDevice : bool
@export var buttons : Array[ButtonClass]
@export var brackets : Array[Control]
@export var cursor : CursorManager
@export var exitingButtons : bool
@export var settingVisibility : bool
@export var mouseRaycast : MouseRaycast
var previousFocus : Control

func _ready():
	get_viewport().connect("gui_focus_changed", _on_focus_changed)
	var controllers = Input.get_connected_joypads()

func _process(delta):
	if (settingVisibility): SetVisibility()

func _on_focus_changed(control:Control):
	if (control != null):
		previousFocus = control

var controller_currently_enabled = false
func SetMainControllerState(controllerActive : bool):
	match controllerActive:
		true:
			controller_currently_enabled = true
			cursor.controller_active = true
			SetPrevFocus(true)
			cursor.SetCursor(cursor.cursor_visible, false)
		false:
			controller_currently_enabled = false
			cursor.controller_active = false
			SetPrevFocus(false)
			cursor.SetCursor(cursor.cursor_visible, false)

var printing = false
var checkingForInput = true
func _input(event):
	if (dynamicallySwappingDevice && checkingForInput):
		#ENABLE CONTROLLER
		if(event is InputEventJoypadButton):
			cursor.controller_active = true
			SetPrevFocus(true)
			if (printing): print("JOYPAD BUTTON")
			cursor.SetCursor(cursor.cursor_visible, false)
		elif(event is InputEventKey):
			if (!IsEventAssignedToNavigation(event)): return
			cursor.controller_active = true
			SetPrevFocus(true)
			if (printing):print("EVENT KEY")
			cursor.SetCursor(cursor.cursor_visible, false)
		#DISABLE CONTROLLER
		elif(event is InputEventMouse):
			cursor.controller_active = false
			SetPrevFocus(false)
			if (printing):print("EVENT MOUSE")
			cursor.SetCursor(cursor.cursor_visible, false)
		elif(event is InputEventMouseButton):
			cursor.controller_active = false
			SetPrevFocus(false)
			if (printing):print("EVENT MOUSE BUTTON")
			cursor.SetCursor(cursor.cursor_visible, false)

var navigationBinds = ["ui_up", "ui_down", "ui_left", "ui_right"]
func IsEventAssignedToNavigation(key : InputEventKey):
	for b in navigationBinds:
		if (key.is_action(b)): return true
	return false

func SetRebindFocus(settingToPrevious : bool):
	if (!settingToPrevious): 
		previousFocus.release_focus()
		return
	if (cursor.controller_active):
		if (settingToPrevious):
			previousFocus.grab_focus()

var fs1 = false
var fs2 = true
@export var stoppingOverride = true
@export var settingFilter : bool
func SetPrevFocus(grabbing : bool):
	if (grabbing && !fs1):
		ExitButtons()
		if (settingFilter): for b in buttons:  b.SetFilter("ignore")
		if (previousFocus != null): previousFocus.grab_focus()
		fs2 = false
		fs1 = true
	elif (!grabbing && !fs2):
		ExitButtons()
		if (previousFocus != null): previousFocus.release_focus()
		if (stoppingOverride): mouseRaycast.StopRaycastOverride()
		if (settingFilter): for b in buttons:  b.SetFilter("stop")
		fs1 = false
		fs2 = true

func SetVisibility():
	for b in brackets: b.visible = cursor.controller_active

func ExitButtons():
	if (exitingButtons):
		for b in buttons:
			if(!b.resetting): b.OnExit()
