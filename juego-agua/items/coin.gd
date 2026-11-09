extends Area2D
## Fragmento de luz dorado (agua limpia). Al recogerlo muestra un dato educativo.
##   fact_id - id del dato en story.gd (los que empiezan con "fact_"). Vacío = ninguno.

signal collected

@export var fact_id: String = ""


func _ready() -> void:
	add_to_group("coins")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Se usa un grupo en lugar del nombre del nodo, para que siga
	# funcionando aunque renombres al jugador.
	if body.is_in_group("player"):
		Effects.burst(get_parent(), global_position, Color(1, 0.9, 0.2))
		collected.emit()
		queue_free()
