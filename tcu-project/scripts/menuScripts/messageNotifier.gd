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
	# If no custom path is given, return to the path it was called from
	if return_path == "":
		return_path = tree.current_scene.scene_file_path
	elif not ResourceLoader.exists(return_path):
		printerr("[MESSAGE NOTIFIER] Return scene not found: ", return_path, "\n")
		return
	
	var notifier_scene : PackedScene = load("res://scenes/ui/messageNotifier.tscn")
	var notifier : MessageNotifier = notifier_scene.instantiate()
	
	tree.change_scene_to_node(notifier)
	notifier.notify(text, return_path, time)

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
		get_tree().change_scene_to_file(destination_scene_path)

#endregion
