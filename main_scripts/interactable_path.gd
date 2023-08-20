extends Node2D

@export var interactable_area: Vector2
@export var next_area: PackedScene

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D


## Boolean to indicate wether the mouse is inside this interctable path
var mouse_inside: bool = false


func _ready() -> void:
	collision_shape.shape.set_size(interactable_area)
	print(collision_shape.shape.get_size())

func _unhandled_input(_event) -> void:
	if mouse_inside and Input.is_action_just_pressed("left_click"):
		print("Clicked on interactable path!")


func _on_area_2d_mouse_entered():
	mouse_inside = true


func _on_area_2d_mouse_exited():
	mouse_inside = false
