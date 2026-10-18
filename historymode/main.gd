extends Node2D
## Nivel principal: el pueblo de Villaluz.
## Aquí se junta todo: marcador, vidas, cronómetro, pausa, diálogos e historia.

## Archivo aparte de las opciones (settings.cfg), para no pisarse con el menú.
const RECORDS_PATH := "user://records.cfg"

var score: int = 0
var total_coins: int = 0
var finished: bool = false

## Segundos transcurridos en la partida actual.
var elapsed: float = 0.0
## Mejor tiempo guardado. -1 significa que aún no hay récord.
var best_time: float = -1.0

var pause_menu: PauseMenu
var dialogue: DialogueBox
var _last_health: int = 0

@onready var score_label: Label = $HUD/ScoreLabel
@onready var health_label: Label = $HUD/HealthLabel
@onready var time_label: Label = $HUD/TimeLabel
@onready var objective_label: Label = $HUD/ObjectiveLabel
@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D


func _init() -> void:
	# _init corre antes que el _ready de cualquier nodo de la escena, así que
	# cada vez que se carga el nivel la historia empieza de cero.
	# (Cuando haya varios niveles, mover este reset al botón "Jugar" del menú.)
	Story.reset()
	_ensure_interact_action()


func _ready() -> void:
	# Recibe los avisos de "la historia avanzó" (ver on_story_changed).
	add_to_group("story_listeners")

	# Menú de pausa / victoria y cuadro de diálogo (se construyen por código).
	pause_menu = PauseMenu.new()
	add_child(pause_menu)

	dialogue = DialogueBox.new()
	add_child(dialogue)
	dialogue.finished.connect(_on_dialogue_finished)

	# La cámara sigue al jugador, pero no se sale del escenario.
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(Scenery.WORLD_SIZE.x)
	camera.limit_bottom = int(Scenery.WORLD_SIZE.y)

	var coins = get_tree().get_nodes_in_group("coins")
	total_coins = coins.size()

	for coin in coins:
		coin.connect("collected", _on_coin_collected)

	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)

	_load_best_time()
	_last_health = player.health

	_update_score_label()
	_update_health_label(player.health, player.max_health)
	_update_time_label()
	_update_objective_label()

	# La historia empieza con la introducción (ver story.gd).
	dialogue.play.call_deferred("intro")


func _process(delta: float) -> void:
	# Al pausar el árbol, _process se detiene solo y el tiempo no corre.
	if finished:
		return

	elapsed += delta
	_update_time_label()


func _unhandled_input(event: InputEvent) -> void:
	# Esc (o B del mando) abre la pausa.
	if (
		event.is_action_pressed("ui_cancel")
		and not finished
		and not pause_menu.is_open()
		and not dialogue.is_open()
	):
		pause_menu.open("Pausa", true)
		get_viewport().set_input_as_handled()


## La tecla E para hablar. Si prefieres, defínela tú en Proyecto > Configuración
## del proyecto > Mapa de entrada con el nombre "interact" y esto no hará nada.
func _ensure_interact_action() -> void:
	if InputMap.has_action("interact"):
		return

	InputMap.add_action("interact")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_E
	InputMap.action_add_event("interact", key)


# --- Historia ---------------------------------------------------------------

## Lo llama el cuadro de diálogo cada vez que termina uno (grupo "story_listeners").
func on_story_changed() -> void:
	_update_objective_label()


func _on_dialogue_finished(dialogue_id: String) -> void:
	# Al terminar el diálogo final, se muestra la pantalla de victoria.
	if dialogue_id == "ending":
		_win()


# --- Monedas (fragmentos de luz) -------------------------------------------

func _on_coin_collected() -> void:
	if finished:
		return

	score += 1
	_update_score_label()

	if score >= total_coins:
		_finish_level()


func _finish_level() -> void:
	# El cronómetro se detiene aquí; la victoria se muestra al acabar el diálogo final.
	finished = true

	if Story.get_dialogue("ending").is_empty():
		_win()
	else:
		dialogue.play("ending")


func _win() -> void:
	score_label.text = "¡GANASTE!"

	var subtitle := "Tiempo: %s" % _format_time(elapsed)
	if best_time < 0.0 or elapsed < best_time:
		best_time = elapsed
		_save_best_time()
		subtitle += "\n¡Nuevo récord!"
	else:
		subtitle += "\nMejor: %s" % _format_time(best_time)

	_update_time_label()
	# Pausa el juego (el jugador deja de moverse) y muestra las opciones.
	pause_menu.open("¡Ganaste!", false, "Jugar de nuevo", subtitle)


# --- Vidas ------------------------------------------------------------------

func _on_player_health_changed(current: int, maximum: int) -> void:
	_update_health_label(current, maximum)

	# Temblor de pantalla solo al perder vida (no al curarse).
	if current < _last_health:
		_shake_camera(16.0 if current <= 0 else 9.0)
	_last_health = current


func _on_player_died() -> void:
	if finished:
		return

	finished = true
	score_label.text = "¡PERDISTE!"
	pause_menu.open("Game Over", false, "Intentar de nuevo", "Tiempo: %s" % _format_time(elapsed))


# --- Interfaz ---------------------------------------------------------------

func _update_score_label() -> void:
	score_label.text = "Fragmentos: %d / %d" % [score, total_coins]


func _update_health_label(current: int, maximum: int) -> void:
	health_label.text = "Vidas: %d / %d" % [current, maximum]


func _update_time_label() -> void:
	var text := "Tiempo: %s" % _format_time(elapsed)
	if best_time >= 0.0:
		text += "   Mejor: %s" % _format_time(best_time)
	time_label.text = text


func _update_objective_label() -> void:
	objective_label.visible = Story.objective != ""
	objective_label.text = "Objetivo: %s" % Story.objective


func _format_time(seconds: float) -> String:
	return "%.1f s" % seconds


# --- Efectos ----------------------------------------------------------------

func _shake_camera(strength: float = 9.0, duration: float = 0.3) -> void:
	var tween := create_tween()
	# Que el temblor termine aunque el juego se pause justo después (al morir).
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	var steps := 8
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var shake := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * falloff
		tween.tween_property(camera, "offset", shake, duration / steps)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)


# --- Récord -----------------------------------------------------------------

func _load_best_time() -> void:
	var config := ConfigFile.new()
	if config.load(RECORDS_PATH) == OK:
		best_time = config.get_value("records", "best_time", -1.0)


func _save_best_time() -> void:
	var config := ConfigFile.new()
	# Se carga primero por si más adelante se guardan más datos en el mismo archivo.
	config.load(RECORDS_PATH)
	config.set_value("records", "best_time", best_time)
	config.save(RECORDS_PATH)
