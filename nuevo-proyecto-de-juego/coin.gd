extends Area2D

signal collected

func _ready() -> void:
	add_to_group("coins")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Se usa un grupo en lugar del nombre del nodo, para que siga
	# funcionando aunque renombres al jugador.
	if body.is_in_group("player"):
		collected.emit()
		queue_free()
