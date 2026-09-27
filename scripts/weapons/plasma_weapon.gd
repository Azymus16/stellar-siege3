extends "res://scripts/weapons/weapon_base.gd"
## Arme de Nova : tirs de plasma homing vers l'ennemi le plus proche.

func _ready() -> void:
	base_interval = 0.55

func setup(p_player: Node) -> void:
	super.setup(p_player)

func fire() -> void:
	var target := find_nearest_enemy()
	var base_dir: Vector2 = Vector2.RIGHT.rotated(player.sprite.rotation - PI / 2.0)
	if target:
		base_dir = (target.global_position - player.global_position).normalized()

	var shots: int = 1 + extra_projectiles
	var spread_step: float = 12.0 # degrés entre les tirs multiples
	var start_angle: float = -spread_step * float(shots - 1) / 2.0

	for i in range(shots):
		var angle_deg: float = start_angle + spread_step * float(i)
		var dir: Vector2 = base_dir.rotated(deg_to_rad(angle_deg))
		var extra := {}
		if target:
			extra["homing_target"] = target
			extra["homing_strength"] = 2.5
		spawn_projectile("res://scenes/projectiles/PlasmaBolt.tscn", dir, extra)
