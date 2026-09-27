extends Node2D
## Game : orchestre une run complète — spawn du joueur, connexion du HUD,
## gestion de la file de montées de niveau, fin de partie (victoire/défaite).

@onready var hud = $HUD
@onready var upgrade_popup = $UpgradePopup
@onready var end_screen = $EndScreen
@onready var spawner = $EnemySpawner

var player: Node = null
var pending_level_ups: int = 0
var run_time: float = 0.0
var run_ended: bool = false

func _ready() -> void:
	randomize()
	get_tree().paused = false
	_spawn_player()
	hud.set_player(player)

	upgrade_popup.card_chosen.connect(_on_upgrade_chosen)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.player_died.connect(_on_player_died)
	EventBus.boss_died.connect(_on_boss_died)
	EventBus.enemy_died.connect(_on_enemy_died)

func _spawn_player() -> void:
	var scene: PackedScene = load("res://scenes/player/Player.tscn")
	player = scene.instantiate()
	add_child(player)
	player.add_to_group("player")
	var data: CharacterData = CharacterDatabase.get_character(GameManager.selected_character_id)
	player.setup(data)
	player.global_position = Vector2.ZERO

func _process(delta: float) -> void:
	if run_ended:
		return
	run_time += delta
	if player and is_instance_valid(player):
		# Empêche de s'éloigner indéfiniment du cœur de l'arène.
		player.global_position = player.global_position.limit_length(GameManager.ARENA_RADIUS)

func _on_player_leveled_up(_new_level: int) -> void:
	pending_level_ups += 1
	if not upgrade_popup.visible:
		_show_next_upgrade()

func _show_next_upgrade() -> void:
	if pending_level_ups > 0:
		pending_level_ups -= 1
		get_tree().paused = true
		var data: CharacterData = CharacterDatabase.get_character(GameManager.selected_character_id)
		var choices: Array = UpgradeDatabase.get_random_choices(3, data, player.taken_upgrade_counts)
		upgrade_popup.show_choices(choices)
	else:
		get_tree().paused = false

func _on_upgrade_chosen(u: UpgradeData) -> void:
	player.apply_upgrade(u)
	_show_next_upgrade()

func _on_enemy_died(_enemy: Node2D, xp_value: int, pos: Vector2) -> void:
	if player and is_instance_valid(player):
		player.register_kill()
	if xp_value > 0:
		var scene: PackedScene = load("res://scenes/pickups/XpGem.tscn")
		var g := scene.instantiate()
		add_child(g)
		g.global_position = pos
		g.set_value(xp_value)

func _on_player_died() -> void:
	_end_run(false)

func _on_boss_died() -> void:
	_end_run(true)

func _end_run(victory: bool) -> void:
	if run_ended:
		return
	run_ended = true
	var lvl: int = player.level if player else 1
	var kills: int = player.kill_count if player else 0
	GameManager.report_run_end(run_time, lvl, kills, victory)
	end_screen.show_result(victory, run_time, lvl, kills)
