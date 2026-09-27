extends Node2D
## EnemySpawner : fait apparaître des vagues d'ennemis autour du joueur hors du
## champ visuel, avec une difficulté croissante, puis déclenche le boss.

var elapsed: float = 0.0
var spawn_timer: float = 0.0
var boss_triggered: bool = false
var player_ref: Node2D

const SPAWN_MIN_DIST: float = 620.0
const SPAWN_MAX_DIST: float = 760.0

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if boss_triggered:
		return

	elapsed += delta
	EventBus.wave_timer_changed.emit(elapsed)

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = _current_spawn_interval()
		_spawn_wave()

	if elapsed >= GameManager.BOSS_SPAWN_TIME:
		boss_triggered = true
		_spawn_boss()

func _current_spawn_interval() -> float:
	return max(0.35, 1.6 - elapsed / 180.0)

func _spawn_wave() -> void:
	var count: int = 1 + int(elapsed / 18.0)
	count = min(count, 8)
	for i in range(count):
		_spawn_one_enemy()

func _spawn_one_enemy() -> void:
	var scene_path: String
	if elapsed < 25.0:
		scene_path = "res://scenes/enemies/SwarmlingEnemy.tscn"
	else:
		var roll: float = randf()
		if roll < 0.55:
			scene_path = "res://scenes/enemies/SwarmlingEnemy.tscn"
		elif roll < 0.82:
			scene_path = "res://scenes/enemies/DroneEnemy.tscn"
		else:
			scene_path = "res://scenes/enemies/BruteEnemy.tscn"

	var scene: PackedScene = load(scene_path)
	var e := scene.instantiate()
	get_tree().current_scene.add_child(e)
	e.global_position = _random_spawn_position()

	var hp_scale: float = 1.0 + elapsed / 240.0
	e.max_hp *= hp_scale
	e.current_hp = e.max_hp

func _random_spawn_position() -> Vector2:
	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
	if player_ref == null or not is_instance_valid(player_ref):
		return Vector2.ZERO
	var angle: float = randf() * TAU
	var dist: float = randf_range(SPAWN_MIN_DIST, SPAWN_MAX_DIST)
	return player_ref.global_position + Vector2.RIGHT.rotated(angle) * dist

func _spawn_boss() -> void:
	var scene: PackedScene = load("res://scenes/enemies/BossVoidTitan.tscn")
	var b := scene.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = _random_spawn_position()
