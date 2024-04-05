class_name ButtonClass_Main extends Node

@export var alias : String
@export var alias_signature : String
@export var signatureBranch : SignButton
@export var isSignature : bool
@export var usingInteractionPipe : bool
@export var interaction : InteractionManager
@export var isActive : bool
@export var isDynamic : bool
@export var ui : CanvasItem
@export var ui_3D : GeometryInstance3D
@export var is3D : bool
@export var ui_opacity_inactive : float = 1
@export var ui_opacity_active : float = .78
@export var signature : Signature
@export var overridingMouseRaycast : bool
@export var mouseRaycast : MouseRaycast
@export var mouseRaycastVector : Vector2
@export var usingInteractionBranch : bool
var mainActive = true

func _ready():
	get_parent().connect("focus_entered", OnHover)
	get_parent().connect("focus_exited", OnExit)	
	get_parent().connect("pressed", OnPress)
	if (isDynamic): SetUI(false)
	pass

func SetUI(state : bool):
	if (state):
		if (!is3D): ui.modulate.a = ui_opacity_active
		else: ui_3D.transparency = 0
	else:
		if (!is3D): ui.modulate.a = ui_opacity_inactive
		else: ui_3D.transparency = 1

func OnHover():
	if (isActive && mainActive):
		if (isDynamic):
			SetUI(true)
			if (overridingMouseRaycast): mouseRaycast.GetRaycastOverride(mouseRaycastVector)

func OnExit():
	if (isActive && mainActive):
		if (isDynamic):
			SetUI(false)

signal is_pressed
func OnPress():
	if (isActive && mainActive):
		emit_signal("is_pressed")
		if (usingInteractionPipe): interaction.InteractWith(alias)
		if (isSignature): interaction.SignatureButtonRemote(signatureBranch, alias_signature)
		if (overridingMouseRaycast): interaction.MainInteractionEvent()
