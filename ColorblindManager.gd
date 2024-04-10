class_name Colorblind extends Node

@export var mat_live : StandardMaterial3D
@export var mat_blank : StandardMaterial3D
@export var mat_emission : StandardMaterial3D

func _ready():
	if (GlobalVariables.colorblind): mat_live.albedo_color = GlobalVariables.colorblind_color_live; mat_blank.albedo_color = GlobalVariables.colorblind_color_blank
	else: mat_live.albedo_color = GlobalVariables.default_color_live; mat_blank.albedo_color = GlobalVariables.default_color_blank
