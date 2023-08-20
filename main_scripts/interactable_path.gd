extends Node2D

@export var interactable_area: Vector2
@export_file var next_area: String

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D


## Boolean to indicate wether the mouse is inside this interctable path
var mouse_inside: bool = false
var changing_area: bool = false
var loaded_next_area: Resource

func _ready() -> void:
	collision_shape.shape.set_size(interactable_area)
	loaded_next_area = load(next_area)

func _unhandled_input(_event) -> void:
	if not changing_area and mouse_inside and Input.is_action_just_pressed("left_click"):
		changing_area = true
		get_tree().get_first_node_in_group("GameManager").change_area(loaded_next_area)
		get_parent().queue_free()


func _on_area_2d_mouse_entered():
	mouse_inside = true


func _on_area_2d_mouse_exited():
	mouse_inside = false
