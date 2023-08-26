extends Node

var bullet_manager: BulletManager
var player: Player

var first_gate_active: bool = true
var second_gate_active: bool = true
var third_gate_active: bool = true

var used_axe: bool = false
var used_key: bool = false
var used_powercell: bool = false

var exit_gate_opened: bool = false

func _ready() -> void:
	bullet_manager = get_tree().get_first_node_in_group("BulletManager")
	player = get_tree().get_first_node_in_group("Player")
	
	player.bullet_fired.connect(bullet_manager.handle_bullet_spawned)



func _process(_delta) -> void:
	if not exit_gate_opened and used_axe and used_key and used_powercell:
		get_tree().get_first_node_in_group("ExitGate").queue_free()
		exit_gate_opened = true
	
	if first_gate_active and player.has_key:
		get_tree().get_first_node_in_group("FirstGate").queue_free()
		first_gate_active = false
	if second_gate_active and player.has_axe:
		get_tree().get_first_node_in_group("SecondGate").queue_free()
		second_gate_active = false
	if third_gate_active and player.has_powercell:
		get_tree().get_first_node_in_group("ThirdGate").queue_free()
		third_gate_active = false

func set_used_axe() -> void:
	used_axe = true

func set_used_key() -> void:
	used_key = true

func set_used_powercell() -> void:
	used_powercell = true

func _on_end_zone_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().get_first_node_in_group("LeftMarker").start_spawning()
		get_tree().get_first_node_in_group("MiddleMarker").start_spawning()
		get_tree().get_first_node_in_group("RightMarker").start_spawning()
		DialogueManager.show_dialogue_balloon(load("res://dialogues/coming.dialogue"), "start", 4)
