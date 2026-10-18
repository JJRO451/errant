class_name Enemy
extends CharacterBody2D
## Enemigo reutilizable. Cada instancia se configura desde el Inspector:
##  - Patrulla: pon un "patrol_offset" distinto de cero y el enemigo irá y vendrá
##    entre su posición inicial y esa distancia. Sube "patrol_speed" para uno rápido.
##  - Persecución: activa "chase_player" y perseguirá al jugador mientras esté
##    dentro de "detect_radius". Si lo pierde, vuelve a su ruta de patrulla.
##  - Disparo: activa "shoots" y lanzará proyectiles al jugador cada "shoot_interval"
##    segundos mientras esté a menos de "shoot_range". Puede estar quieto (torreta).
##  - Sin patrulla, persecución ni disparo se queda quieto (sirve como trampa).
## Al tocar al jugador le quita vida (el jugador tiene un tiempo de invulnerabilidad).

const PROJECTILE := preload("res://projectile.tscn")

@export_group("Daño")
@export var damage: int = 1

@export_group("Patrulla")
@export var patrol_offset: Vector2 = Vector2.ZERO
@export var patrol_speed: float = 100.0

@export_group("Persecución")
@export var chase_player: bool = false
@export var detect_radius: float = 250.0
@export var chase_speed: float = 120.0

@export_group("Disparo")
@export var shoots: bool = false
@export var shoot_interval: float = 2.0
@export var shoot_range: float = 500.0
@export var projectile_speed: float = 220.0

@onready var hitbox: Area2D = $Hitbox

var _point_a: Vector2
var _point_b: Vector2
var _target: Vector2
var _shoot_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	_point_a = global_position
	_point_b = global_position + patrol_offset
	_target = _point_b
	_shoot_timer = shoot_interval


func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var patrols := patrol_offset != Vector2.ZERO
	var chasing := (
		chase_player
		and player != null
		and global_position.distance_to(player.global_position) <= detect_radius
	)

	if chasing:
		velocity = global_position.direction_to(player.global_position) * chase_speed
	elif patrols:
		if global_position.distance_to(_target) < 6.0:
			_swap_target()
		velocity = global_position.direction_to(_target) * patrol_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Si patrullando choca con un obstáculo, da media vuelta.
	if patrols and not chasing and _hit_obstacle():
		_swap_target()

	if shoots and player != null:
		_update_shooting(player, delta)

	_damage_player_on_contact()


func _update_shooting(player: Node2D, delta: float) -> void:
	_shoot_timer -= delta
	if _shoot_timer > 0.0:
		return

	_shoot_timer = shoot_interval
	if global_position.distance_to(player.global_position) <= shoot_range:
		_shoot(player)


func _shoot(target: Node2D) -> void:
	var projectile := PROJECTILE.instantiate() as Projectile
	projectile.direction = global_position.direction_to(target.global_position)
	projectile.speed = projectile_speed
	projectile.damage = damage
	get_parent().add_child(projectile)
	projectile.global_position = global_position


func _swap_target() -> void:
	_target = _point_a if _target == _point_b else _point_b


func _hit_obstacle() -> bool:
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider() as Node
		if collider != null and not collider.is_in_group("player"):
			return true
	return false


func _damage_player_on_contact() -> void:
	for body in hitbox.get_overlapping_bodies():
		var player := body as Player
		if player != null:
			player.take_damage(damage, global_position)
