class_name Game
extends RefCounted
## Estado de la partida que viaja de un escenario a otro (vidas, tiempo y
## dónde aparece el jugador). Igual que Story, es estático: no hace falta
## ponerlo en ninguna escena.
##
## Para cambiar el primer escenario del juego, edita FIRST_LEVEL.

const FIRST_LEVEL := "res://scenes/main.tscn"

## Id del LevelSpawn donde aparece el jugador al llegar ("" = donde lo pusiste en la escena).
static var next_spawn: String = ""
## Vidas con las que llega al escenario (-1 = todas).
static var health: int = -1
## Segundos que lleva la partida.
static var elapsed: float = 0.0
## Fragmentos contaminados (grises) recogidos en la partida. Es la puntuación
## educativa: con 1 error o menos y todos los datos, ganas como «Guardián del agua».
static var errors: int = 0


## Empieza una partida desde cero (menú principal, "Jugar de nuevo").
static func new_run() -> void:
	Story.reset()
	next_spawn = ""
	health = -1
	elapsed = 0.0
	errors = 0


## Reinicia el escenario actual (al morir o con "Reiniciar").
## En el primer escenario reinicia toda la partida.
static func restart_level(tree: SceneTree) -> void:
	if tree.current_scene != null and tree.current_scene.scene_file_path == FIRST_LEVEL:
		new_run()
	else:
		health = -1
		next_spawn = ""
	tree.paused = false
	tree.reload_current_scene()


## Vuelve al primer escenario con todo reiniciado.
static func restart_run(tree: SceneTree) -> void:
	new_run()
	tree.paused = false
	tree.change_scene_to_file(FIRST_LEVEL)
