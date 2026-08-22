class_name MouseFollowLine
extends Line2D

@export var source_node : MatchOriginNode = null
@export var endpoint_area : Area2D = null

# Movement
var source_point : Vector2 = Vector2.ZERO # index = 0
var destination_point : Vector2 = Vector2.ZERO # index = 1

# Linking
var linking_point : Vector2 = Vector2.ZERO # replaces destination point
var can_link : bool = false

func _ready() -> void:
	setupLine()

func _process(_delta: float) -> void:
	followMouse()

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

func setCanLink(link : bool = false):
	can_link = link

func _on_endpoint_area_area_entered(area: Area2D) -> void:
	print("[MOUSE FOLLOW LINE] Contact with: ", area.name, " area!\n")
