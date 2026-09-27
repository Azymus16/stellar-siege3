extends Node2D
class_name WeaponBase
## Base commune à toutes les armes automatiques.
## Chaque arme concrète (plasma, gravity, stellar, ice) surcharge fire()
## et éventuellement apply_upgrade().

var player: Node # référence au Player (typé Node pour éviter les cycles de dépendance)
var base_interval: float = 1.0 # secondes entre 2 tirs, avant multiplicateur de vitesse
var _timer: float = 0.0
var extra_projectiles: int = 0
var pierce: int = 0

func setup(p_player: Node) -> void:
	player = p_player
	_timer = base_interval

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player) or player.is_dead:
		return
	var atk_speed: float = player.attack_speed_multiplier
	_timer -= delta * atk_speed
	if _timer <= 0.0:
		fire()
		_timer = base_interval

func fire() -> void:
	pass # surchargé par les armes concrètes

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"extra_projectile":
			extra_projectiles += int(value)
		"pierce":
			pierce += int(value)
		_:
			pass

func find_nearest_enemy(max_range: float = 900.0) -> Node2D:
	var enemies := player.get_tree().get_nodes_in_group("enemy")
	var best: Node2D = null
	var best_dist := max_range
	for e: Node2D in enemies:
		if not is_instance_valid(e):
			continue
		var d: float = player.global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best

func spawn_projectile(scene_path: String, direction: Vector2, extra := {}) -> Node2D:
	var scene: PackedScene = load(scene_path)
	var proj := scene.instantiate()
	player.get_tree().current_scene.add_child(proj)
	proj.global_position = player.global_position
	if proj.has_method("launch"):
		proj.launch(direction, player.get_effective_damage(), pierce, extra)
	return proj
