class_name CrtIcon extends Node

@export var texture_active : CompressedTexture2D
@export var texture_inactive : CompressedTexture2D
@export var activeIndex : int

var instance : GeometryInstance3D

func _ready():
	instance = get_parent()
	SetState(false)
	

func CheckState(currentIndex : int):
	if (currentIndex == activeIndex): SetState(true)
	else: SetState(false)

func SetState(act : bool):
	if act:
		instance.material_override.albedo_texture = texture_active
	else:
		instance.material_override.albedo_texture = texture_inactive
