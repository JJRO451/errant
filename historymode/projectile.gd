class_name Projectile
extends Area2D
## Proyectil disparado por los enemigos tipo torreta.
## Daña al jugador y desaparece al chocar con él o con un obstáculo.

var direction: Vector2 = Vector2.RIGHT
var speed: float = 220.0
var damage: int = 1
## Segundos que sobrevive si no choca con nada.
var lifetime: float = 5.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player != null:
		player.take_damage(damage, global_position)

	Effects.burst(get_parent(), global_position, Color(1, 0.6, 1), 6, 90.0, 0.3)
	queue_free()
