extends Node

@export var isHeaven : bool = false

func _ready():
	await get_tree().create_timer(1, false).timeout
	Prevent()

func Prevent():
	var loc = TranslationServer.get_locale()
	if (!isHeaven):
		await get_tree().create_timer(1, false).timeout
		if (loc == "ES" or loc == "JA"): self.get_parent().visible = false
	else:
		if (loc == "DE" or loc == "ES" or loc == "ES LATAM" or loc == "BR" or loc == "PT" or loc == "PL" or loc == "TR"): self.get_parent().text = "<                    >"
		else: self.get_parent().text = "<          >"
