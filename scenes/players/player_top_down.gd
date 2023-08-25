class_name Player
extends CharacterBody2D

signal bullet_fired(bullet, pos, dir)

enum States {
	IDLE,
	RUNNING,
	ATTACKING,
	INTERACTING,
	STUNNED
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
@export_range(0.01, 100) var shoot_cooldown: float = 1.0
@export var magazine_size: int = 10
@export var reload_time: int = 2
@export var max_recoil: float = 10.0

@export_group("Actionable variables")
@export_range(1, 10) var action_time: int = 3

@export_group("Sound effects")
@export_file(".wav") var footsteps: String
@export_file(".wav") var footsteps2: String
@export_file(".wav") var shooting: String

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactable_collider: Area2D = $InteractableCollider
@onready var action_timer: Timer = $ActionTimer
@onready var action_bar: ProgressBar = $UI/ActionBar
@onready var end_of_gun: Marker2D = $EndOfGun
@onready var shoot_cooldown_timer: Timer = $ShootCooldown
@onready var reload_timer: Timer = $ReloadTimer
@onready var stun_timer: Timer = $StunTimer
@onready var health_component: HealthComponent = $HealthComponent

var health_bar: TextureProgressBar
var ammo_bar: TextureProgressBar
var _state: int = States.IDLE
var current_bullets: int
var current_dir: Vector2 = Vector2.DOWN
var last_dir: Vector2 = Vector2.DOWN
var invincible: bool = false
var current_recoil: float = 0.0
var nearest_actionable
var dead: bool = false
var has_axe: bool = false
var has_powercell: bool = false
var has_key: bool = false
var has_torch: bool = false

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	check_debugs()
	
	current_bullets = magazine_size
	
	action_bar.hide()
	action_bar.max_value = action_time
	action_timer.wait_time = action_time
	
	shoot_cooldown_timer.wait_time = shoot_cooldown
	reload_timer.wait_time = reload_time
	
	health_bar = get_tree().get_first_node_in_group("HealthBar")
	health_component.current_health = health_component.max_health
	health_component.health_depleted.connect(player_dead)
	
	ammo_bar = get_tree().get_first_node_in_group("AmmoBar")


func check_debugs():
	$UI/StateLabel.visible = state_debug
	$UI/NearestActionableLabel.visible = nearest_actionable_debug
	get_tree().debug_collisions_hint = collision_shape_debug

func _process(_delta: float) -> void:
	if dead:
		return
	if state_debug:
		$UI/StateLabel.text = "State: " + States.find_key(_state)
	if nearest_actionable_debug:
		if nearest_actionable:
			$UI/NearestActionableLabel.text = "Actionable: " + nearest_actionable.get_parent().name
		else:
			$UI/NearestActionableLabel.text = "No actionable"
	
	if Input.is_action_pressed("fire") and reload_timer.is_stopped():
		fire()
	if Input.is_action_just_pressed("reload") and reload_timer.is_stopped() and current_bullets != magazine_size:
		reload_timer.start()
		$SFXShooting.stream = load("res://sound/sfx/Game Jam_Reload.wav")
		$SFXShooting.play()
	
	check_nearest_actionable()
	handle_interaction()
	
	if not reload_timer.is_stopped():
		ammo_bar.value = remap_range((reload_timer.wait_time - reload_timer.time_left), 0, reload_timer.wait_time, 0, 8)

func remap_range(value, InputA, InputB, OutputA, OutputB):
	return (value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA

func handle_sound_effects() -> void:
	if _state == States.IDLE:
		$SFXPlayer.stop()
	if _state == States.RUNNING and $SFXPlayer.get_playback_position() <= 0:
		var random = randi_range(0, 1)
		if random == 0:
			play_sound_effect(footsteps)
		else:
			play_sound_effect(footsteps2)

func _physics_process(delta: float) -> void:
	if dead:
		return
	if not stun_timer.is_stopped():
		return
	
	if not Input.is_action_pressed("fire"):
		var recoil_increment = max_recoil * 0.05
		current_recoil = clamp(current_recoil - recoil_increment, 0.0, max_recoil)
	
	current_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if current_dir:
		_state = States.RUNNING
		last_dir = current_dir
	else:
		_state = States.IDLE
	
	if has_acceleration:
		if current_dir.length() == 0.0:
			velocity = velocity.move_toward(Vector2.ZERO, deacceleration * delta * speed)
		else:
			velocity = velocity.move_toward(current_dir * speed, acceleration * delta * speed)
	else:
		velocity = current_dir * speed
	
	if not action_timer.is_stopped():
		_state = States.INTERACTING
	
	update_sprite()
	update_direction_collider()
	handle_sound_effects()
	move_and_slide()

func play_sound_effect(sfx: String) -> void:
	$SFXPlayer.stream = load(sfx)
	$SFXPlayer.play()

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
		sprite.play("RunLeft")
	elif current_dir.x > 0: # Moving right
		sprite.play("RunRight")
	
	
	if current_dir.y < 0: # Moving up
		sprite.play("IdleBack")
	elif current_dir.y > 0: # Moving down
		sprite.play("IdleFront")
	
	if current_dir == Vector2.ZERO:
		if last_dir.x < 0:
			sprite.play("IdleLeft")
		elif last_dir.x > 0:
			sprite.play("IdleRight")
		elif last_dir.y < 0:
			sprite.play("IdleBack")
		elif last_dir.y > 0:
			sprite.play("IdleFront")

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
		if nearest_actionable != null:
			nearest_actionable.get_parent().remove_highlight()
		nearest_actionable = next_nearest_actionable
		if nearest_actionable != null:
			nearest_actionable.get_parent().highlight()


func fire() -> void:
	if current_bullets <= 0:
		return
	
	if not shoot_cooldown_timer.is_stopped():
		return
	shoot_cooldown_timer.start()
	current_bullets -= 1
	ammo_bar.value = current_bullets
	
	var random_pitch = randf_range(0.5, 2.0)
	$SFXShooting.pitch_scale = random_pitch
	$SFXShooting.stream = load("res://sound/sfx/Game Jam_Gun.wav")
	$SFXShooting.play()
	
	var bullet_instance: Area2D = bullet.instantiate()
	var target = get_local_mouse_position()
	var direction_to_mouse = end_of_gun.position.direction_to(target).normalized()
	
	var recoil_degree_max: float = current_recoil * 0.5
	var recoil_radians_actual: float = deg_to_rad(randf_range(-recoil_degree_max, recoil_degree_max))
	var actual_bullet_direction: Vector2 = direction_to_mouse.rotated(recoil_radians_actual)
	var recoil_increment: float = max_recoil * 0.1
	
	emit_signal("bullet_fired", bullet_instance, end_of_gun.global_position, actual_bullet_direction)
	
	current_recoil = clamp(current_recoil + recoil_increment, 0.0, max_recoil)

func reload_gun() -> void:
	current_bullets = magazine_size
	ammo_bar.value = current_bullets


func _on_reload_timer_timeout():
	reload_gun()

func stun(duration: float) -> void:
	stun_timer.wait_time = duration
	stun_timer.start()
	_state = States.STUNNED

func hurt_player(damage: int) -> void:
	if invincible:
		return
	health_component.take_damage(damage)
	health_bar.value = health_component.current_health
	
	$AnimationPlayer.play("flash")
	invincible = true
	await  $AnimationPlayer.animation_finished
	invincible = false

func player_dead() -> void:
	dead = true
	Global.reset_dialogue_triggers()
	get_parent()._death()

func pickup(object: Pickup) -> void:
	if object.name == "Axe":
		has_axe = true
		get_tree().get_first_node_in_group("Axe").play("Active")
	elif object.name == "Powercell":
		has_powercell = true
		get_tree().get_first_node_in_group("Powercell").play("Active")
	elif object.name == "Key":
		has_key = true
		get_tree().get_first_node_in_group("Key").play("Active")
	elif object.name == "Torch":
		has_torch = true
		get_tree().get_first_node_in_group("Torch").play("Active")
