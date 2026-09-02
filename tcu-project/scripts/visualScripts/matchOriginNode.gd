class_name MatchOriginNode
extends Control

signal link_state_changed(node: MatchOriginNode)

@export var clickable_area : Area2D = null
@export var inner_sprite : Sprite2D = null
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

func eraseMouseFollowLine():
	if current_mouse_line != null:
		inner_sprite.hide()
		current_mouse_line.queue_free()

func createLink(point : Vector2):
	node_active = false
	current_mouse_line.linked = true
	setLinked(true)
	
	var local_point : Vector2 = current_mouse_line.to_local(point)
	current_mouse_line.destination_point = local_point
	current_mouse_line.updateLastPoint(local_point)

func deleteLink():
	print("[ORIGIN NODE] Attempted to delete link!\n")
	current_mouse_line.linked = false
	eraseMouseFollowLine()
	setLinked(false)

func setLinked(value : bool = false):
	print("[ORIGIN NODE] linked set to: ", value)
	linked = value
	link_state_changed.emit(self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not linked:
			eraseMouseFollowLine()
			node_active = false

func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not linked:
				print("[CLICKABLE AREA] The player clicked directly on this object!")
				drawMouseFollowLine()
				node_active = true
