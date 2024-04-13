extends Node

@export var isHeaven : bool = false
@export var text_dealer : Label3D

func _ready():
	await get_tree().create_timer(1, false).timeout
	Prevent()

func Prevent():
	var loc = TranslationServer.get_locale()
	if (!isHeaven):
		await get_tree().create_timer(1, false).timeout
		if (loc == "ES" or loc == "JA"): self.get_parent().visible = false
		if (loc == "JA"): text_dealer.scale = Vector3(1.409, 2.466, 1.752)
	else:
		#if (loc == "DE" or loc == "ES" or loc == "ES LATAM" or loc == "BR" or loc == "PT" or loc == "PL" or loc == "TR"): self.get_parent().text = "<                    >"
		#else: self.get_parent().text = "<          >"
		self.get_parent().text = ""
