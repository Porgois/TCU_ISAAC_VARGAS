class_name MouseFollowLine
extends Line2D

@export var source_node : MatchOriginNode = null
@export var endpoint_area : Area2D = null
@export var snap_angle_degrees : float = 45.0

# Movement
var source_point : Vector2 = Vector2.ZERO # index = 0
var destination_point : Vector2 = Vector2.ZERO # index = 1

# Linking
var linked : bool = false

func _ready() -> void:
	setupLine()

func _process(_delta: float) -> void:
	if not linked:
		followMouse()

func updateLastPoint(target_pos : Vector2 = Vector2.ZERO):
	if points.size() == 0:
		return
	
	# Start position
	var start_pos : Vector2 = Vector2.ZERO
	if points.size() > 1:
		start_pos = points[points.size() - 2]
	else:
		start_pos = points[0]
	
	# Direction, distance and angle
	var dir : Vector2 = target_pos - start_pos
	var dist : float = dir.length()
	var angle : float = dir.angle()
	
	# Convert angle to radians & angle snap
	var snap_radians : float = deg_to_rad(snap_angle_degrees)
	var snapped_angle : float = snapped(angle, snap_radians)
	
	# Recalculate pos based on distance and snapping angle
	var final_pos : Vector2 = start_pos + Vector2(cos(snapped_angle), sin(snapped_angle)) * dist
	
	# Update pos
	set_point_position(points.size() - 1, final_pos)
	
func setupLine():
	# Only set valid source node pos
	if source_node != null:
		source_point = source_node.global_position
	else:
		source_point = Vector2.ZERO
		
	# The line only has two points
	clear_points()
	add_point(source_point)
	add_point(destination_point)

func followMouse():
	set_point_position(0, source_point)
	set_point_position(1, get_local_mouse_position())
	endpoint_area.position = get_local_mouse_position()

func setOriginNode(origin_node : MatchOriginNode):
	source_node = origin_node

func _on_endpoint_area_area_entered(area: Area2D) -> void:
	print("[MOUSE FOLLOW LINE] Contact with: ", area.name, " area!\n")
