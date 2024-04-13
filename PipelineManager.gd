class_name PipelineManager extends Node

@export var env : WorldEnvironment
@export var cam : CameraManager

@export var scene : String
@export var overlay : Control

@export var main_array_lights : Array[Light3D]
@export var main_array_hide : Array[Node3D]
@export var main_array_toggle : Array[Node3D]
@export var main_restroom : Node3D
@export var main_light_tabletop2 : Light3D
@export var main_light_tabletop : Light3D

func _ready():
	CheckStatus()
	if (scene == "menu"): CheckStatus()
	AdjustSettings(scene)

func CheckStatus():
	GlobalVariables.using_gl = !is_instance_valid(RenderingServer.get_rendering_device())
	print("running openGL: ", GlobalVariables.using_gl)

func Toggle():
	if (GlobalVariables.using_gl):
		main_restroom.visible = false
		main_restroom.visible = true

func AdjustSettings(scene : String):
	if (GlobalVariables.using_gl): 
		print("adjusting settings in scene: ", scene)
		overlay.visible = true
		match scene:
			"menu":
				print("adjust menu")
			"main":
				for i in main_array_hide: i.visible = false
				main_light_tabletop.visible = false
				for i in main_array_toggle: i.visible = false
				await get_tree().create_timer(.1, false).timeout
				for i in main_array_toggle: i.visible = true
				main_light_tabletop2.light_energy = -3.54
				for i in main_array_lights: i.light_energy /= 2
			"heaven":
				env.environment.background_color = Color(1, 1, 1)
