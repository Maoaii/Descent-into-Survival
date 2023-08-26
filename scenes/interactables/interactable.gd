class_name Interactable
extends Area2D


signal interacted(actions: Array[InteractableAction])

@export var actions: Array[InteractableAction]


func interact() -> void:
	interacted.emit(actions)
