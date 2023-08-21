class_name BulletManager
extends Node2D



func handle_bullet_spawned(bullet: Bullet, pos: Vector2, dir: Vector2) -> void:
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(dir)
