class_name MatchEnvironment
extends Control

## Emitted once the player presses Confirm (only enabled once every
## origin node has some link, correct or not).
signal match_confirmed

@export var matchContainer : GridContainer = null
@export var confirm_button : Button = null
@export var confirmation_text : String = "Confirm"
@export var grid_spacing_vector : Vector2 = Vector2(250, 85) # x -> h, y -> v

var origin_node_scene : PackedScene = preload("res://scenes/ui/matchUI/generalMatchOriginNode.tscn")
var destination_node_scene : PackedScene = preload("res://scenes/ui/matchUI/generalMatchDestinationNode.tscn")

var origin_nodes : Array[MatchOriginNode] = []
var destination_nodes : Array[MatchDestinationNode] = []
var pair_count : int = 0

func _ready() -> void:
	setGridSpacing()
	
	if confirm_button:
		confirm_button.hide()
		confirm_button.pressed.connect(_on_confirm_pressed)
		confirm_button.button_label.text = confirmation_text

# Sets custom grid spacing at start
func setGridSpacing():
	matchContainer.add_theme_constant_override("h_separation", grid_spacing_vector.x)
	matchContainer.add_theme_constant_override("v_separation", grid_spacing_vector.y)

# Spawns one origin/destination node per question pair, shuffling which definition ends up next to which term 
func configureFromPairs(pairs: Array) -> void:
	_clearEntities()
	pair_count = pairs.size()
	if pair_count == 0:
		return

	var destination_order: Array = range(pair_count)
	destination_order.shuffle()

	for i in range(pair_count):
		var pair = pairs[i]
		var shuffled_index: int = destination_order[i]
		var shuffled_pair = pairs[shuffled_index]

		# Origin node: this pair's term, keyed by its own index
		var origin_node: MatchOriginNode = origin_node_scene.instantiate()
		matchContainer.add_child(origin_node)
		origin_node.setNodeNumber(i)
		origin_node.setDisplayText(pair.term)
		origin_node.link_state_changed.connect(_on_origin_link_state_changed)
		origin_nodes.append(origin_node)

		# Destination node: a (possibly different) pair's definition,
		# keyed by THAT pair's index so compatibility checks still work.
		var destination_node: MatchDestinationNode = destination_node_scene.instantiate()
		matchContainer.add_child(destination_node)
		destination_node.setNodeNumber(shuffled_index)
		var definition_text: String = shuffled_pair.definitions[0] if shuffled_pair.definitions.size() > 0 else ""
		destination_node.setDisplayText(definition_text)
		destination_nodes.append(destination_node)

	_updateConfirmVisibility()

func _clearEntities() -> void:
	for node in origin_nodes:
		node.queue_free()
	for node in destination_nodes:
		node.queue_free()
	origin_nodes.clear()
	destination_nodes.clear()
	if confirm_button:
		confirm_button.hide()

func _on_origin_link_state_changed(_node: MatchOriginNode) -> void:
	_updateConfirmVisibility()

func _updateConfirmVisibility() -> void:
	if confirm_button == null:
		return
	var all_linked: bool = origin_nodes.size() > 0
	for node in origin_nodes:
		if not node.linked:
			all_linked = false
			break
	confirm_button.visible = all_linked

func _on_confirm_pressed() -> void:
	confirm_button.hide()
	match_confirmed.emit()

## Call after match_confirmed fires. Returns {"correct": int, "total": int}
## and tears down the spawned nodes.
func collectResults() -> Dictionary:
	var correct_count := 0
	for destination_node in destination_nodes:
		if destination_node.current_node != null and destination_node.checkNodeCompatibility():
			correct_count += 1

	var total := pair_count
	_clearEntities()
	return {"correct": correct_count, "total": total}
