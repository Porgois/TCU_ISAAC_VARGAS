@tool
class_name ExpressionInterpreter
extends Node3D

@export var character_mesh : MeshInstance3D = null
@export var base_y_offset_amount : float = 0.25

var eye_material : StandardMaterial3D = null
var mouth_material : StandardMaterial3D = null

func _ready() -> void:
	# Set materials
	if character_mesh:
		eye_material = character_mesh.get_active_material(1)
		mouth_material = character_mesh.get_active_material(2)

func offsetEyeYUV(offset_amount : float = base_y_offset_amount):
	if eye_material:
		eye_material.uv1_offset.y = offset_amount

func offsetMouthYUV(offset_amount : float = base_y_offset_amount):
	if mouth_material:
		mouth_material.uv1_offset.y = offset_amount
