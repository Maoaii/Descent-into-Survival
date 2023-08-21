extends CharacterBody2D


enum States {
	IDLE,
	RUNNING,
	ATTACKING
}

@export var state_debug: bool = true
@export var speed := 200.0
@export var has_acceleration := false
@export var acceleration := 1_000
@export var deacceleration := 1_000

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _state: int = States.IDLE
var last_dir: Vector2

func _process(_delta: float) -> void:
	if state_debug:
		$StateLabel.text = "State: " + States.find_key(_state)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if direction:
		_state = States.RUNNING
		last_dir = direction
		update_sprite(direction)
	else:
		_state = States.IDLE
	
	if has_acceleration:
		if direction.length() == 0.0:
			velocity = velocity.move_toward(Vector2.ZERO, deacceleration * delta)
		else:
			velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = direction * speed
	
	move_and_slide()

func update_sprite(direction: Vector2) -> void:
	if direction.x < 0: # Moving left
		sprite.play("idle_left")
		pass
	elif direction.x > 0: # Moving right
		sprite.play("idle_right")
		pass
	
	if direction.y < 0: # Moving up
		sprite.play("idle_back")
	elif direction.y > 0: # Moving down
		sprite.play("idle_forward")
