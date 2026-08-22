class_name MatchOriginNode
extends Control

@export var clickable_area : Area2D = null
@export var node_number : int = 1

var mouse_follow_line_scene : PackedScene = preload("res://scenes/ui/matchUI/generalMouseFollowLine.tscn")
var node_active : bool = false
var current_mouse_line : MouseFollowLine = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			eraseMouseFollowLine()
			node_active = false

func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("[CLICKABLE AREA] The player clicked directly on this object!")
				drawMouseFollowLine()
				node_active = true

func drawMouseFollowLine():
	current_mouse_line = mouse_follow_line_scene.instantiate()
	self.add_child(current_mouse_line)
	current_mouse_line.setOriginNode(self)

func eraseMouseFollowLine():
	if current_mouse_line != null:
		current_mouse_line.queue_free()
