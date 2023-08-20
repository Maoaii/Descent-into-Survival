extends Button


@export_file var next_area: String

var changing_area: bool = false
var loaded_next_area: Resource

func _ready() -> void:
	loaded_next_area = load(next_area)

func _on_pressed():
	if not changing_area:
		changing_area = true
		get_tree().get_first_node_in_group("GameManager").change_area(loaded_next_area)
		get_parent().queue_free()
