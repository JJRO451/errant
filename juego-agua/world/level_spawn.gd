@tool
class_name LevelSpawn
extends Marker2D
## Punto donde aparece el jugador al llegar desde otro escenario.
## En la salida del otro escenario (LevelExit) escribe este mismo "id" en "spawn_id".
## Solo se ve en el editor (una cruz verde con su id).

@export var id: String = "":
	set(value):
		id = value
		queue_redraw()


func _ready() -> void:
	add_to_group("level_spawns")


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var color := Color(0.3, 1.0, 0.5)
	draw_circle(Vector2.ZERO, 14.0, Color(color, 0.25))
	draw_line(Vector2(-18, 0), Vector2(18, 0), color, 3.0)
	draw_line(Vector2(0, -18), Vector2(0, 18), color, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(-60, -26), "Entrada: " + id,
		HORIZONTAL_ALIGNMENT_CENTER, 120, 16, color)
