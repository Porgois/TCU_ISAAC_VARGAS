class_name MatchEnvironment
extends Control

@export var node_pair_count : int = 1
@export var matchContainer : GridContainer = null

var origin_node_scene : PackedScene = preload("res://scenes/ui/matchUI/generalMatchOriginNode.tscn")
var destination_node_scene : PackedScene = preload("res://scenes/ui/matchUI/generalMatchDestinationNode.tscn")

func _ready() -> void:
	instantiateMatchEntities()

func instantiateMatchEntities():
	for node in node_pair_count:
		# Origin node
		var origin_node : MatchOriginNode = origin_node_scene.instantiate()
		matchContainer.add_child(origin_node)
		
		# Destination node
		var destination_node : MatchDestinationNode = destination_node_scene.instantiate()
		matchContainer.add_child(destination_node)
