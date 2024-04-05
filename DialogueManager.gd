class_name Dialogue extends Node

@export var speaker_click : AudioStreamPlayer2D
@export var soundArray_clicks : Array[AudioStream]
@export var dialogueUI : Label
@export var dialogueUI_backdrop : ColorRect
@export var dialogueSpeed : float
@export var incrementDelay : float

var dealerLowPitched = false
var elapsed = 0
var moving = false
var looping = false
var origscale_backdrop

func _ready():
	origscale_backdrop = dialogueUI_backdrop.scale
	speaker_click.stream = soundArray_clicks[3]

func ShowText_ForDuration(activeText : String, showDuration : float):
	if(dialogueUI_backdrop.scale != origscale_backdrop): dialogueUI_backdrop.scale = origscale_backdrop
	looping = false
	dialogueUI.visible_characters = 0
	dialogueUI.text = activeText
	dialogueUI.visible = true
	dialogueUI_backdrop.visible = true
	looping = true
	TickText()
	await get_tree().create_timer(showDuration, false).timeout
	looping = false
	dialogueUI.visible = false
	dialogueUI_backdrop.visible = false

var scaling = false
func ShowText_Forever(activeText : String):
	if (scaling): 
		dialogueUI_backdrop.scale = Vector2(17.209, dialogueUI_backdrop.scale.y)
	else: dialogueUI_backdrop.scale = origscale_backdrop
	
	looping = false
	dialogueUI.visible_characters = 0
	dialogueUI.text = activeText
	dialogueUI.visible = true
	dialogueUI_backdrop.visible = true
	looping = true
	TickText()
	scaling = false

func ShowDealerInspectionText():
	if(dialogueUI_backdrop.scale != origscale_backdrop): dialogueUI_backdrop.scale = origscale_backdrop
	ShowText_Forever(tr("INTERESTING"))

func HideText():
	looping = false
	dialogueUI.visible = false
	dialogueUI_backdrop.visible = false
	pass

func TickText():
	while(looping):
		dialogueUI.visible_characters += 1
		if (!dealerLowPitched): speaker_click.pitch_scale = randf_range(0.5, .6)
		else: speaker_click.pitch_scale = randf_range(.2, .3)
		speaker_click.play()
		if (dialogueUI.visible_ratio >= 1):
			looping = false
		await get_tree().create_timer(incrementDelay, false).timeout
		pass
	pass
