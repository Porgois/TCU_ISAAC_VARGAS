class_name MatchDestinationNode
extends Control

@export var linking_point : Marker2D = null
@export var clickable_area : Area2D = null
@export var inner_sprite : Sprite2D = null
@export var node_text : RichTextLabel = null
@export var node_number : int = 0

var current_line : MouseFollowLine = null
var current_node : MatchOriginNode = null
var previous_node : MatchOriginNode = null

func saveNode(area : Area2D = null):
	current_line = area.get_parent()
	if current_node == null:
		current_node = current_line.source_node
	else:
		previous_node = current_node
		current_node = current_line.source_node
		previous_node.deleteLink()
	
	inner_sprite.show()
	current_node.createLink(linking_point.global_position)
	print("[DESTINATION NODE] This is a valid origin area!\n")
	miscPrint()

func setNodeNumber(number : int = -1):
	node_number = number

func setDisplayText(text : String) -> void:
	if node_text:
		node_text.text = text

func checkNodeCompatibility() -> bool:
	if node_number == current_node.node_number:
		return true
	else:
		return false

func miscPrint():
	if checkNodeCompatibility():
		print("[DESTINATION NODE] Nodes are compatible!\n")
	else:
		print("[DESTINATION NODE] Nodes are not compatible!\n")

func _on_detection_area_area_entered(area: Area2D) -> void:
	print("Area: ", area.name)
	
	if area.is_in_group("ConnectionArea"):
		saveNode(area)

func _on_detection_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if current_node and current_node.linked == true:
						inner_sprite.hide()
						current_node.deleteLink()
						current_node = null
