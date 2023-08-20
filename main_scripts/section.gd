extends Node2D

@export var focused_entity: Control

func _ready():
	call_deferred("focus_first_entity")

func focus_first_entity() -> void:
	focused_entity.grab_focus()
