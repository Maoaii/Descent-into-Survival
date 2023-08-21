class_name Bullet
extends Area2D

@export var speed: float = 10
@export_range(0.1, 100) var despawn_time: float = 1.0

@onready var despawn_timer: Timer = $DespawnTimer

var direction: Vector2 = Vector2.ZERO

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

func _on_despawn_timer_timeout():
	queue_free()
