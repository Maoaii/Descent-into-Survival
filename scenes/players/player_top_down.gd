class_name Player
extends CharacterBody2D

signal bullet_fired(bullet, pos, dir)

enum States {
	IDLE,
	RUNNING,
	ATTACKING,
	INTERACTING
}

@export_group("Debug variables")
@export var state_debug: bool = true
@export var nearest_actionable_debug: bool = true
@export var collision_shape_debug: bool = true

@export_group("Movement variables")
@export var speed: float = 200.0
@export var has_acceleration: bool = false
@export var acceleration: float = 1_000
@export var deacceleration: float = 1_000

@export_group("Shooting variables")
@export var bullet: PackedScene 

@export_group("Actionable variables")
@export_range(1, 10) var action_time: int = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactable_collider: Area2D = $InteractableCollider
@onready var action_timer: Timer = $ActionTimer
@onready var action_bar: ProgressBar = $UI/ActionBar
@onready var end_of_gun: Marker2D = $EndOfGun

var _state: int = States.IDLE
var current_dir: Vector2
var nearest_actionable

func _ready() -> void:
	check_debugs()
	
	action_bar.hide()
	action_bar.max_value = action_time
	action_timer.wait_time = action_time

func check_debugs():
	$UI/StateLabel.visible = state_debug
	$UI/NearestActionableLabel.visible = nearest_actionable_debug
	get_tree().debug_collisions_hint = collision_shape_debug

func _process(_delta: float) -> void:
	if state_debug:
		$UI/StateLabel.text = "State: " + States.find_key(_state)
	if nearest_actionable_debug:
		if nearest_actionable:
			$UI/NearestActionableLabel.text = "Actionable: " + nearest_actionable.get_parent().name
		else:
			$UI/NearestActionableLabel.text = "No actionable"
	
	if Input.is_action_just_pressed("fire"):
		fire()
	
	check_nearest_actionable()
	handle_interaction()


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if direction:
		_state = States.RUNNING
		current_dir = direction
	else:
		_state = States.IDLE
	
	if has_acceleration:
		if direction.length() == 0.0:
			velocity = velocity.move_toward(Vector2.ZERO, deacceleration * delta * speed)
		else:
			velocity = velocity.move_toward(direction * speed, acceleration * delta * speed)
	else:
		velocity = direction * speed
	
	if not action_timer.is_stopped():
		_state = States.INTERACTING
	
	update_sprite()
	update_direction_collider()
	move_and_slide()

func handle_interaction() -> void:
	if Input.is_action_pressed("interact") and nearest_actionable:
		interact()
	elif Input.is_action_just_released("interact") or not nearest_actionable:
		cancel_interaction()

func interact() -> void:
	action_bar.show()
	
	if action_timer.is_stopped():
		action_timer.start()
	
	update_action_bar()


func cancel_interaction() -> void:
	action_bar.hide()
	action_bar.value = 0
	
	action_timer.stop()

func update_action_bar() -> void:
	action_bar.value = abs(action_bar.max_value - action_timer.time_left)

func update_direction_collider() -> void:
	if current_dir.x < 0: # Moving left
		interactable_collider.rotation = -PI
	elif current_dir.x > 0: # Moving right
		interactable_collider.rotation = 0
	elif current_dir.y < 0: # Moving up
		interactable_collider.rotation = -PI/2
	elif current_dir.y > 0: # Moving down
		interactable_collider.rotation = PI/2

func update_sprite() -> void:
	if current_dir.x < 0: # Moving left
		sprite.play("idle_left")
	elif current_dir.x > 0: # Moving right
		sprite.play("idle_right")
	
	if current_dir.y < 0: # Moving up
		sprite.play("idle_back")
	elif current_dir.y > 0: # Moving down
		sprite.play("idle_forward")

func check_nearest_actionable() -> void:
	var areas: Array[Area2D] = interactable_collider.get_overlapping_areas()
	var shortest_distance: float = INF
	var next_nearest_actionable = null
		
	for area in areas:
		var distance: float = area.global_position.distance_to(global_position)
		if distance < shortest_distance and area.collision_layer == 512:
			shortest_distance = distance
			next_nearest_actionable = area
	
	if next_nearest_actionable != nearest_actionable or not is_instance_valid(next_nearest_actionable):
		nearest_actionable = next_nearest_actionable


func fire() -> void:
	var bullet_instance: Area2D = bullet.instantiate()
	var target = get_local_mouse_position()
	var direction_to_mouse = end_of_gun.position.direction_to(target).normalized()
	
	emit_signal("bullet_fired", bullet_instance, end_of_gun.global_position, direction_to_mouse)
