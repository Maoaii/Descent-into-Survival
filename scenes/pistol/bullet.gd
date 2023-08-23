class_name Bullet
extends Area2D

@export var speed: float = 10
@export_range(0.1, 100) var despawn_time: float = 1.0
@export var damage: int = 5

@onready var despawn_timer: Timer = $DespawnTimer

var direction: Vector2 = Vector2.ZERO
var current_enemy_group: String

func _ready() -> void:
	despawn_timer.wait_time = despawn_time
	despawn_timer.start()

func _physics_process(_delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		
		global_position += velocity

func set_direction(dir: Vector2) -> void:
	direction = dir
	rotation += dir.angle()

func _on_despawn_timer_timeout() -> void:
	queue_free()

func set_enemy(enemy_group: String) -> void:
	current_enemy_group = enemy_group

func set_damage(new_damage: int) -> void:
	damage = new_damage

func _on_body_entered(body) -> void:
	if body.name == "CollidablesTileMap" or body.is_in_group("Obstacle"):
		queue_free()
	if body.is_in_group(current_enemy_group):
		if body.is_in_group("Enemies"):
			body.take_damage(damage)
		elif body.is_in_group("Player"):
			body.hurt_player(damage)
		queue_free()
