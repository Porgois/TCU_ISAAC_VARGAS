class_name MatchOriginNode
extends HBoxContainer

signal link_state_changed(node: MatchOriginNode)

@export var clickable_area : Area2D = null
@export var inner_sprite : TextureRect = null
@export var dot : Control = null
@export var node_text : RichTextLabel = null
@export var node_number : int = 1

var mouse_follow_line_scene : PackedScene = preload("res://scenes/ui/matchUI/generalMouseFollowLine.tscn")
var node_active : bool = false
var current_mouse_line : MouseFollowLine = null
var linked : bool = false

func setNodeNumber(number : int = -1):
	node_number = number

func setDisplayText(text : String) -> void:
	if node_text:
		node_text.text = text

func drawMouseFollowLine():
	inner_sprite.show()
	current_mouse_line = mouse_follow_line_scene.instantiate()
	self.add_child(current_mouse_line)
	current_mouse_line.setOriginNode(self)

func eraseMouseFollowLine() -> void:
	if current_mouse_line != null:
		inner_sprite.hide()
		current_mouse_line.queue_free()
		current_mouse_line = null

func createLink(point : Vector2 = Vector2.ZERO) -> void:
	if current_mouse_line == null:
		return
	
	var target : MatchDestinationNode = current_mouse_line.current_snap_target
	if target == null:  # Fall back to the closest destination to where the link was made
		target = current_mouse_line.findClosestNode(point, INF)
	if target == null:
		return
	
	node_active = false
	current_mouse_line.lockTo(target)
	setLinked(true)

func deleteLink() -> void:
	if current_mouse_line == null:
		return
	current_mouse_line.linked = false
	eraseMouseFollowLine()
	setLinked(false)

func setLinked(value : bool = false):
	linked = value
	link_state_changed.emit(self)

func getAnchor() -> Vector2:
	var anchor : Vector2 = dot.global_position + dot.size / 2.0
	return anchor

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not linked:
			eraseMouseFollowLine()
			node_active = false

func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not linked:
				drawMouseFollowLine()
				node_active = true
