class_name Level
extends Node2D
## Script de CADA escenario del juego (Villaluz, el bosque, las ruinas...).
## Aquí se junta todo: marcador, vidas, cronómetro, pausa, diálogos e historia.
## Cada escenario necesita en su escena: un Player (player/player.tscn), un HUD
## (ui/hud.tscn) y, si quieres conectarlo con otros, LevelExit y LevelSpawn.
## El tamaño del mundo se toma del nodo LevelGround (o de Scenery en Villaluz).

## Archivo aparte de las opciones (settings.cfg), para no pisarse con el menú.
const RECORDS_PATH := "user://records.cfg"

var score: int = 0
var total_coins: int = 0
var finished: bool = false

## Segundos transcurridos en la partida actual.
var elapsed: float = 0.0
## Mejor tiempo guardado. -1 significa que aún no hay récord.
var best_time: float = -1.0

@export_group("Escenario")
## Nombre que aparece en grande al entrar (vacío = no se muestra).
@export var level_title: String = ""
@export var level_subtitle: String = ""
## Diálogo de entrada (ver story.gd). Solo se muestra la primera vez. Vacío = ninguno.
@export var intro_dialogue: String = "intro"
## true = al recoger todos los fragmentos de este escenario se acaba el juego.
@export var finish_on_all_coins: bool = true
## Objetivo que se muestra al juntar todos los fragmentos (si el juego no termina aquí).
@export_multiline var completed_objective: String = ""

@export_group("Ambiente")
## Luz alrededor del jugador. Úsala en escenarios oscuros (con un nodo CanvasModulate).
@export var player_light: bool = false
@export var player_light_color: Color = Color(1.0, 0.93, 0.75)
@export_range(0.0, 3.0, 0.05) var player_light_energy: float = 1.0
@export_range(0.5, 8.0, 0.1) var player_light_scale: float = 3.0

var pause_menu: PauseMenu
var dialogue: DialogueBox
var _last_health: int = 0
var _fade: ColorRect
var _traveling: bool = false
## true = el nivel ya se completó, pero falta cerrar el dato del último fragmento
## antes de empezar el diálogo final.
var _ending_pending: bool = false
## Tamaño del mundo de este escenario (cámara y límites del jugador).
var world_size: Vector2 = Vector2(3000, 1700)

@onready var score_label: Label = $HUD/ScoreLabel
@onready var health_label: Label = $HUD/HealthLabel
@onready var time_label: Label = $HUD/TimeLabel
@onready var objective_label: Label = $HUD/ObjectiveLabel
@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D


func _init() -> void:
	# La historia se reinicia al empezar una partida (Game.new_run, desde el botón
	# "Jugar"), no al cargar cada escenario: así avanza de uno a otro.
	_ensure_interact_action()


func _ready() -> void:
	# Recibe los avisos de "la historia avanzó" (ver on_story_changed).
	add_to_group("story_listeners")
	add_to_group("level")

	world_size = _find_world_size()
	_build_fade()

	# Menú de pausa / victoria y cuadro de diálogo (se construyen por código).
	pause_menu = PauseMenu.new()
	add_child(pause_menu)

	dialogue = DialogueBox.new()
	add_child(dialogue)
	dialogue.finished.connect(_on_dialogue_finished)

	# La cámara sigue al jugador, pero no se sale del escenario.
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(world_size.x)
	camera.limit_bottom = int(world_size.y)
	player.world_size = world_size

	# Llegada desde otro escenario: vidas, tiempo y lugar de aparición.
	if Game.health > 0:
		player.health = mini(Game.health, player.max_health)
	elapsed = Game.elapsed
	_place_player_at_spawn()
	_setup_player_light()

	var coins = get_tree().get_nodes_in_group("coins")
	total_coins = coins.size()

	# Cada fragmento avisa con su dato educativo (fact_id, ver story.gd).
	for coin in coins:
		coin.connect("collected", _on_coin_collected.bind(coin.fact_id))

	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)

	_load_best_time()
	_last_health = player.health

	_update_score_label()
	_update_health_label(player.health, player.max_health)
	_update_time_label()
	_update_objective_label()

	# Título del escenario y diálogo de entrada (ver story.gd).
	_show_title()
	if intro_dialogue != "" and not Story.has_flag("done_" + intro_dialogue):
		dialogue.play.call_deferred(intro_dialogue)


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


# --- Escenarios -------------------------------------------------------------

## Viaja a otro escenario (lo llama LevelExit). spawn_id es el LevelSpawn de destino.
func travel_to(scene_path: String, spawn_id: String = "") -> void:
	if _traveling:
		return
	if not ResourceLoader.exists(scene_path):
		push_warning("No existe el escenario: %s" % scene_path)
		return

	_traveling = true
	Game.health = player.health
	Game.elapsed = elapsed
	Game.next_spawn = spawn_id

	# El jugador se detiene mientras la pantalla se oscurece.
	player.set_physics_process(false)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade, "color:a", 1.0, 0.4)
	tween.tween_callback(func() -> void: get_tree().change_scene_to_file(scene_path))


func _find_world_size() -> Vector2:
	for child in get_children():
		if child is LevelGround:
			return (child as LevelGround).world_size
	return Scenery.WORLD_SIZE


func _place_player_at_spawn() -> void:
	var wanted := Game.next_spawn
	Game.next_spawn = ""
	if wanted == "":
		return

	for node in get_tree().get_nodes_in_group("level_spawns"):
		if node is LevelSpawn and (node as LevelSpawn).id == wanted:
			player.global_position = (node as LevelSpawn).global_position
			return
	push_warning("No hay ningún LevelSpawn con el id '%s' en este escenario." % wanted)


func _setup_player_light() -> void:
	var light := player.get_node_or_null("Light") as PointLight2D
	if light == null:
		return
	light.enabled = player_light
	light.color = player_light_color
	light.energy = player_light_energy
	light.texture_scale = player_light_scale


## Pantalla negra que se desvanece al entrar (y se oscurece al salir).
func _build_fade() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)

	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 1)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade, "color:a", 0.0, 0.5)


func _show_title() -> void:
	if level_title == "":
		return

	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)

	var label := Label.new()
	label.text = level_title if level_subtitle == "" else "%s\n%s" % [level_title, level_subtitle]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 10)
	label.modulate.a = 0.0
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	label.offset_top = 120.0
	label.offset_left = -500.0
	label.offset_right = 500.0

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.6)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)
	tween.tween_interval(2.2)
	tween.tween_property(label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(layer.queue_free)


# --- Historia ---------------------------------------------------------------

## Lo llama el cuadro de diálogo cada vez que termina uno (grupo "story_listeners").
func on_story_changed() -> void:
	_update_objective_label()


func _on_dialogue_finished(dialogue_id: String) -> void:
	# Al terminar el diálogo final, se muestra la pantalla de victoria.
	if dialogue_id == "ending":
		_win()
	elif _ending_pending:
		# Se cerró el dato del último fragmento: ahora sí, el final.
		_ending_pending = false
		_play_ending()


# --- Monedas (fragmentos de luz) -------------------------------------------

func _on_coin_collected(fact_id: String = "") -> void:
	if finished:
		return

	score += 1
	_update_score_label()
	var fact_shown := _show_fact(fact_id)

	if score >= total_coins:
		if finish_on_all_coins:
			_finish_level(fact_shown)
		elif completed_objective != "":
			Story.objective = completed_objective
			_update_objective_label()


## Muestra el dato educativo de un fragmento (solo la primera vez que se aprende).
## Devuelve true si se abrió el cuadro de diálogo.
func _show_fact(fact_id: String) -> bool:
	if fact_id == "" or Story.has_flag("done_" + fact_id):
		return false

	dialogue.play(fact_id)
	return dialogue.is_open()


func _finish_level(wait_for_fact: bool = false) -> void:
	# El cronómetro se detiene aquí; la victoria se muestra al acabar el diálogo final.
	finished = true

	if wait_for_fact:
		_ending_pending = true
	else:
		_play_ending()


func _play_ending() -> void:
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

	# Resumen educativo: datos descubiertos y errores (fragmentos contaminados).
	var total_facts := Story.fact_ids().size()
	var learned := Story.facts_learned()
	subtitle += "\nDatos del agua descubiertos: %d / %d" % [learned, total_facts]
	subtitle += "\nErrores: %d" % Game.errors

	var title := "¡Ganaste!"
	if learned >= total_facts and Game.errors <= 1:
		title = "¡Guardián del agua!"
		subtitle += "\nDominas el ciclo del agua."

	_update_time_label()
	# Pausa el juego (el jugador deja de moverse) y muestra las opciones.
	pause_menu.open(title, false, "Jugar de nuevo", subtitle, true)


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

## Lo llaman los fragmentos contaminados al tocarlos (ver dirty_fragment.gd).
func register_error() -> void:
	Game.errors += 1
	_update_score_label()


func _update_score_label() -> void:
	score_label.text = "Fragmentos: %d / %d" % [score, total_coins]
	if Game.errors > 0:
		score_label.text += "   Errores: %d" % Game.errors


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
