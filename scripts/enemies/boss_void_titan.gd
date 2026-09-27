extends "res://scripts/enemies/enemy_base.gd"
## Titan du Vide : boss de fin de run.
## - Se déplace lentement vers le joueur.
## - Tire régulièrement une salve circulaire de projectiles.
## - Invoque des Éclaireurs en renfort quand ses PV passent sous 50%.

const BURST_PROJECTILE_COUNT: int = 10
var burst_interval: float = 3.2
var summon_interval: float = 9.0
var _burst_timer: float = 0.0
var _summon_timer: float = 0.0
var _summoned_once_below_half: bool = false

func _ready() -> void:
	max_hp = 900.0
	move_speed = 55.0
	contact_damage = 22.0
	xp_value = 0 # l'XP du boss est donnée manuellement à la mort (grosse récompense)
	super._ready()
	add_to_group("boss")
	_burst_timer = 2.0
	_summon_timer = summon_interval
	EventBus.boss_spawned.emit("Titan du Vide")

func _steer(delta: float) -> Vector2:
	_burst_timer -= delta
	if _burst_timer <= 0.0:
		_burst_timer = burst_interval
		_fire_burst()

	_summon_timer -= delta
	if _summon_timer <= 0.0:
		_summon_timer = summon_interval
		_summon_adds()

	return super._steer(delta)

func _fire_burst() -> void:
	for i in range(BURST_PROJECTILE_COUNT):
		var angle: float = TAU * float(i) / float(BURST_PROJECTILE_COUNT)
		var dir: Vector2 = Vector2.RIGHT.rotated(angle)
		var scene: PackedScene = load("res://scenes/projectiles/EnemyBolt.tscn")
		var b := scene.instantiate()
		get_tree().current_scene.add_child(b)
		b.global_position = global_position
		b.launch(dir, 10.0)

func _summon_adds() -> void:
	var spawn_scene: PackedScene = load("res://scenes/enemies/SwarmlingEnemy.tscn")
	for i in range(3):
		var angle: float = randf() * TAU
		var pos: Vector2 = global_position + Vector2.RIGHT.rotated(angle) * 140.0
		var e := spawn_scene.instantiate()
		get_tree().current_scene.add_child(e)
		e.global_position = pos

func take_damage(amount: float) -> void:
	super.take_damage(amount)
	if current_hp > 0.0 and current_hp <= max_hp * 0.5 and not _summoned_once_below_half:
		_summoned_once_below_half = true
		_summon_adds()

func die() -> void:
	EventBus.enemy_died.emit(self, 40, global_position)
	EventBus.boss_died.emit()
	queue_free()
