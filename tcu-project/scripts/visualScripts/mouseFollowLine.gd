class_name MouseFollowLine
extends Line2D

@export var source_node : MatchOriginNode = null
@export var endpoint_area : Area2D = null
@export var snap_distance : float = 40.0  # how close before it snaps

# Movement
var source_point : Vector2 = Vector2.ZERO
var destination_point : Vector2 = Vector2.ZERO

# Linking
var linked : bool = false
var current_snap_target : Control = null  # the node we're currently snapped to

func _ready() -> void:
	setupLine()

func _process(_delta: float) -> void:
	if not linked:
		followMouse()

func setupLine():
	if source_node != null:
		source_point = source_node.global_position
	else:
		source_point = Vector2.ZERO
	clear_points()
	add_point(source_point)
	add_point(destination_point)

func followMouse():
	var mouse_pos : Vector2 = get_local_mouse_position()
	var target_pos : Vector2 = mouse_pos
	current_snap_target = find_closest_node(mouse_pos)

	if current_snap_target != null:
		target_pos = to_local(current_snap_target.global_position)

	set_point_position(0, source_point)
	set_point_position(1, target_pos)
	endpoint_area.position = target_pos

func find_closest_node(from_pos : Vector2) -> Control:
	var closest : Control = null
	var closest_dist : float = snap_distance
	
	for node in get_tree().get_nodes_in_group("DestinationNode"):
		var node_local_pos : Vector2 = to_local(node.global_position)
		var dist : float = from_pos.distance_to(node_local_pos)
		if dist < closest_dist:
			closest_dist = dist
			closest = node
	
	return closest

func updateLastPoint(target_pos : Vector2 = Vector2.ZERO):
	if points.size() == 0:
		return
	set_point_position(points.size() - 1, target_pos)

func setOriginNode(origin_node : MatchOriginNode):
	source_node = origin_node

func _on_endpoint_area_area_entered(area: Area2D) -> void:
	print("[MOUSE FOLLOW LINE] Contact with: ", area.name, " area!\n")
