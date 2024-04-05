class_name Unlocker extends Node

const savepath := "user://buckshotroulette_pills.shell"
@export var ach : Achievement
@export var dia : DialogueEnding
@export var ui : Label
@export var anim : AnimationPlayer
var t = "DOUBLE UNLOCK"

func UnlockRoutine():
	UnlockMode()
	await get_tree().create_timer(1, false).timeout
	dia.overriding = true
	dia.dialogueUI = ui
	dia.HideText()
	dia.ShowText_Forever(tr(t))
	await get_tree().create_timer(4, false).timeout
	anim.play("fade")
	await get_tree().create_timer(1, false).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func UnlockMode():
	var data = {
		"total_amount_selected" : 0
	}
	var file = FileAccess.open(savepath, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func IncrementAmount():
	if (FileAccess.file_exists(savepath)):
		var file = FileAccess.open(savepath, FileAccess.READ)
		var data = file.get_var()
		file.close()
		print("data: ", data)
		var amount = data.total_amount_selected
		amount += 1
		var new_data = {
			"total_amount_selected" : amount
		}
		var new_file = FileAccess.open(savepath, FileAccess.WRITE)
		new_file.store_var(new_data)
		new_file.close()
		if (amount >= 10): ach.UnlockAchievement("ach4")
