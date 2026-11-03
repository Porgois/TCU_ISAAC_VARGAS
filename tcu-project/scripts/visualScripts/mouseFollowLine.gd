class_name MouseFollowLine
extends Line2D

@export var source_node : MatchOriginNode = null
@export var endpoint_area : Area2D = null
@export var snap_distance : float = 40.0

var linked : bool = false
var current_snap_target : MatchDestinationNode = null

func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO
	clear_points()
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)

func setOriginNode(origin_node : MatchOriginNode) -> void:
	source_node = origin_node

func lockTo(target : MatchDestinationNode) -> void:
	current_snap_target = target
	linked = true

func _process(_delta: float) -> void:
	if source_node == null:
		return
	
	set_point_position(0, source_node.getAnchor())  # Center of the origin circle
	
	if linked:
		if current_snap_target != null:
			set_point_position(1, current_snap_target.getAnchor())  # Center of the destination circle
		return
	
	var mouse_pos : Vector2 = get_global_mouse_position()
	current_snap_target = findClosestNode(mouse_pos, snap_distance)
	var end_point : Vector2 = current_snap_target.getAnchor() if current_snap_target != null else mouse_pos
	set_point_position(1, end_point)
	if endpoint_area:
		endpoint_area.global_position = end_point

func findClosestNode(from_pos : Vector2, max_distance : float) -> MatchDestinationNode:
	var closest : MatchDestinationNode = null
	var closest_dist : float = max_distance
	for node in get_tree().get_nodes_in_group("DestinationNode"):
		var dist : float = from_pos.distance_to(node.getAnchor())
		if dist < closest_dist:
			closest_dist = dist
			closest = node
	return closest
