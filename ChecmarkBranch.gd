class_name Checkmark extends Node

@export var ui : TextureRect
@export var checkmark_active : CompressedTexture2D
@export var checkmark_ianctive : CompressedTexture2D

func UpdateCheckmark(state : bool):
	if (state): ui.texture = checkmark_active
	else: ui.texture = checkmark_ianctive
