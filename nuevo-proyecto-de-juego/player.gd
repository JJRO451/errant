class_name Player
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 3
## Segundos de invulnerabilidad tras recibir un golpe.
@export var invulnerability_time: float = 1.0
## Fuerza del empujón al recibir un golpe y rapidez con la que se detiene.
@export var knockback_strength: float = 450.0
@export var knockback_decay: float = 1800.0

var speed := 300.0
var health: int
var _invulnerable: bool = false
var _knockback: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("player")
	health = max_health

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# El empujón se suma al movimiento normal y se va apagando solo.
	velocity = direction * speed + _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
	move_and_slide()

	var screen_size = get_viewport_rect().size

	global_position.x = clamp(
		global_position.x,
		64.0,
		screen_size.x - 64.0
	)

	global_position.y = clamp(
		global_position.y,
		64.0,
		screen_size.y - 64.0
	)


## Lo llaman los enemigos y proyectiles al tocar al jugador.
## source_position (opcional) es de dónde viene el golpe, para empujar al jugador en sentido contrario.
func take_damage(amount: int = 1, source_position: Vector2 = Vector2.INF) -> void:
	if _invulnerable or health <= 0:
		return

	health = maxi(health - amount, 0)

	Effects.burst(get_parent(), global_position, Color(1, 0.3, 0.3), 18, 200.0)
	if source_position.is_finite():
		_knockback = source_position.direction_to(global_position) * knockback_strength

	health_changed.emit(health, max_health)

	if health <= 0:
		_invulnerable = true
		died.emit()
	else:
		_start_invulnerability()


## Recupera vida. Devuelve false si no hacía falta (vida completa o ya muerto).
func heal(amount: int = 1) -> bool:
	if health <= 0 or health >= max_health:
		return false

	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)
	return true


func _start_invulnerability() -> void:
	_invulnerable = true

	# Parpadeo mientras dura la invulnerabilidad.
	var step := invulnerability_time / 10.0
	var tween := create_tween()
	for _i in 5:
		tween.tween_property(sprite, "modulate:a", 0.3, step)
		tween.tween_property(sprite, "modulate:a", 1.0, step)
	tween.tween_callback(func() -> void: _invulnerable = false)
