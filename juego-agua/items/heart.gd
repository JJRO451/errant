extends Area2D
## Corazón: al tocarlo, el jugador recupera vida.
## Si ya tiene todas las vidas, el corazón se queda esperando.

@export var heal_amount: int = 1


func _ready() -> void:
	# Latido suave para que destaque en pantalla.
	var tween := create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.5)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		var player := body as Player
		if player != null and player.heal(heal_amount):
			Effects.burst(get_parent(), global_position, Color(1, 0.4, 0.7))
			queue_free()
			return
