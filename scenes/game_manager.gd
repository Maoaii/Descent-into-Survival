extends Node

var bullet_manager: BulletManager
var player: Player

func _ready() -> void:
	bullet_manager = get_tree().get_first_node_in_group("BulletManager")
	player = get_tree().get_first_node_in_group("Player")
	
	player.bullet_fired.connect(bullet_manager.handle_bullet_spawned)
