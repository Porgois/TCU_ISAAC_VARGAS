class_name MessageNotifier
extends Control

@export var notifier_prompt : RichTextLabel = null
@export var notifier_timer : Timer = null

# Scene to go to after timer runs out
var destination_scene_path : String = ""

#region NOTIFIER

func notify(text : String = "", scene_path : String = "", time : float = 2.0):
	setNotifierText(text)
	setDestinationScene(scene_path)
	
	if not is_node_ready():
		await ready
	
	notifier_timer.start(time)

static func showMessage(tree : SceneTree, text : String = "", time : float = 2.0, return_path : String = "") -> void:
	if return_path != "" and not ResourceLoader.exists(return_path):
		printerr("[MESSAGE NOTIFIER] Return scene not found: ", return_path, "\n")
		return

	var notifier_scene : PackedScene = load("res://scenes/ui/messageNotifier.tscn")
	var notifier : MessageNotifier = notifier_scene.instantiate()

	# Show message with its own UI
	addMessageUI(notifier, tree)
	notifier.notify(text, return_path, time)

# Adds a UI environment for the message to be displayed on
static func addMessageUI(notifier : MessageNotifier = null, tree : SceneTree = null):
	# Layer
	var layer := CanvasLayer.new()
	layer.layer = 100 # Very high priority so that it draws first
	
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 1.0)  # solid; lower alpha for a dim overlay
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP  # blocks clicks on the scene underneath
	
	# Assemble
	layer.add_child(bg)
	layer.add_child(notifier)  # Add it after so that it draws on top of the background
	tree.root.add_child(layer)

#endregion

#region NOTIFIER PROMPT

func setNotifierText(new_text : String = ""):
	if notifier_prompt:
		notifier_prompt.text = new_text

func getNotifierText() -> String:
	var result : String = ""
	
	if notifier_prompt:
		result = notifier_prompt.text
	
	return result

#endregion

#region DESTINATION SCENE

func setDestinationScene(new_scene_name : String = ""):
	destination_scene_path = new_scene_name

#endregion

#region TIMER

func _on_scene_switch_timer_timeout() -> void:
	if destination_scene_path != "":
		get_tree().change_scene_to_file(destination_scene_path)  # only when explicitly set a valid next route (want to leave)
	get_parent().queue_free()  # frees the CanvasLayer and the notifier

#endregion
