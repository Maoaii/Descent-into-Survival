extends Node


func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("pause"):
		
		get_parent().get_node("Paused").pause()

func change_area(new_area: PackedScene) -> void:
	add_sibling(new_area.instantiate())
