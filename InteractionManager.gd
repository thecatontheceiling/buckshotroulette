class_name InteractionManager extends Node

@export var sign : Signature
@export var brief : BriefcaseMachine
@export var heaven : Heaven
@export var intro : IntroManager
@export var cursor : CursorManager
@export var mouseRay : MouseRaycast
@export var shotgun : ShotgunShooting
@export var decision : DecisionTextManager
@export var itemManager : ItemManager
@export var itemInteraction : ItemInteraction
@export var crt : CRT
var activeParent
var activeInteractionBranch
var checking = true

func _process(delta):
	CheckPickupLerp()
	CheckInteractionBranch()
	if (checking): CheckIfHovering()
	pass

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		MainInteractionEvent()

func MainInteractionEvent():
	if (activeInteractionBranch != null && activeInteractionBranch.interactionAllowed && !activeInteractionBranch.interactionInvalid):
		var childArray = activeInteractionBranch.get_parent().get_children()
		for i in range(childArray.size()): if (childArray[i] is PickupIndicator): childArray[i].SnapToMax()
		if (!activeInteractionBranch.isGrid): InteractWith(activeInteractionBranch.interactionAlias)
		else: InteractWithGrid(activeInteractionBranch.gridIndex)

func CheckIfHovering():
	if (activeInteractionBranch != null && activeInteractionBranch.interactionAllowed):
		if (activeInteractionBranch.interactionAllowed && !activeInteractionBranch.interactionInvalid):
			cursor.SetCursorImage("hover")
		else: if (activeInteractionBranch.interactionAllowed && activeInteractionBranch.interactionInvalid):
			cursor.SetCursorImage("invalid")
	else:
		cursor.SetCursorImage("point")

var fs_dec = false
func InteractWith(alias : String):
	match(alias):
		"shotgun":
			shotgun.GrabShotgun()
		"text dealer":
			if (!fs_dec):
				shotgun.Shoot("dealer")
				decision.SetUI(false)
				fs_dec = true
		"text you":
			if (!fs_dec):
				shotgun.Shoot("self")
				decision.SetUI(false)
				fs_dec = true
		"briefcase intake":
			itemManager.GrabItem()
		"item":
			if (activeInteractionBranch.itemName != ""):
				itemInteraction.PickupItemFromTable(activeInteractionBranch.get_parent(), activeInteractionBranch.itemName)
		"bathroom door":
			intro.Interaction_BathroomDoor()
		"backroom door":
			intro.Interaction_BackroomDoor()
		"heaven door":
			heaven.Fly()
		"latch left":
			brief.OpenLatch("L")
		"latch right":
			brief.OpenLatch("R")
		"briefcase lid":
			brief.OpenLid()
		"release form on table":
			sign.PickUpWaiver()
		"signature machine button":
			sign.GetInput(activeInteractionBranch.signatureButton_letterAlias, activeInteractionBranch.signatureButton_specialAlias)
			activeInteractionBranch.assignedSignatureButton.Press()
		"pill bottle":
			intro.Interaction_PillBottle()
		"pill choice no":
			intro.SelectedPill(false)
		"pill choice yes":
			intro.SelectedPill(true)
		"double yes":
			shotgun.roundManager.Response(true)
		"double no":
			shotgun.roundManager.Response(false)
		"crt":
			intro.Interaction_CRT()
		"crt button":
			if (activeInteractionBranch.crtButton_alias != ""): 
				#activeInteractionBranch.get_parent().get_child(1).Press()
				crt.Interaction(activeInteractionBranch.crtButton_alias)

func SignatureButtonRemote(assignedBranch : SignButton, alias : String):
	sign.GetInput(alias, alias)
	assignedBranch.Press()
	pass

func InteractWithGrid(tempGridIndex : int):
	itemManager.PlaceDownItem(tempGridIndex)
	pass

func CheckPickupLerp():
	if (mouseRay.result != null && mouseRay.result.has("collider") && cursor.cursor_visible):
		var parent = mouseRay.result.collider.get_parent()
		activeParent = parent
		var childArray = parent.get_children()
		for i in range(childArray.size()):
			if (childArray[i] is PickupIndicator):
				var indicator = childArray[i]
		pass
	else:	
		activeParent = null
	pass

func CheckInteractionBranch():
	var isFound = null
	if (activeParent != null):
		var childArray = activeParent.get_children()
		for i in range(childArray.size()):
			if (childArray[i] is InteractionBranch):
				var branch = childArray[i]
				# activeInteractionBranch = childArray[i]
				isFound = childArray[i]
				break
	if (isFound):
		activeInteractionBranch = isFound
	else:
		activeInteractionBranch = null
