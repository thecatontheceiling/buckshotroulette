class_name DotFix extends Node

var key
var p

func _ready():
	p = get_parent()
	key = p.text
	await get_tree().create_timer(1, false).timeout
	Fix()

func Fix():
	if key == "TOTAL CASH" && TranslationServer.get_locale() == "EN": p.text = "TOTAL CASH "; return
	if key == "SHOTS FIRED" && TranslationServer.get_locale() == "EN": p.text = "SHOTS FIRED "; return
	var orig = tr(key)
	var modif = orig.replace(".", "").replace(":", "").replace("：", "").replace(":", "")
	p.text = modif
