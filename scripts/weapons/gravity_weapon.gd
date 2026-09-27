extends "res://scripts/weapons/weapon_base.gd"
## Arme d'Orion : onde gravitationnelle périodique autour du joueur (zone, pas de visée).

var wave_radius: float = 190.0
var knockback: float = 230.0

func _ready() -> void:
	base_interval = 1.1

func fire() -> void:
	var scene: PackedScene = load("res://scenes/projectiles/GravityWave.tscn")
	var wave := scene.instantiate()
	player.get_tree().current_scene.add_child(wave)
	wave.global_position = player.global_position
	wave.setup(player.get_effective_damage(), wave_radius, 0.4, knockback)

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"radius_mult":
			wave_radius *= (1.0 + value)
		"knockback_mult":
			knockback *= (1.0 + value)
		_:
			super.apply_upgrade(param_key, value)
