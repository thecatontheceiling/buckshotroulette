class_name ButtonClass extends Node

@export var cursor : CursorManager
@export var alias : String
@export var isActive : bool
@export var isDynamic : bool
@export var ui : CanvasItem
@export var speaker_press : AudioStreamPlayer2D
@export var speaker_hover : AudioStreamPlayer2D
@export var playing : bool

func _ready():
	get_parent().connect("mouse_entered", OnHover)
	get_parent().connect("mouse_exited", OnExit)
	get_parent().connect("pressed", OnPress)
	pass
	
func OnHover():
	if (isActive):
		if (isDynamic):
			speaker_hover.pitch_scale = randf_range(.95, 1.0)
			speaker_hover.play()
			ui.modulate.a = .78
		cursor.SetCursorImage("hover")

func OnExit():
	if (isActive):
		if (isDynamic):
			ui.modulate.a = 1
		cursor.SetCursorImage("point")

signal is_pressed
func OnPress():
	if (isActive):
		if (isDynamic && playing): speaker_press.play()
		emit_signal("is_pressed")
