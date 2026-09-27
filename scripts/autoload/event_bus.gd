extends Node
## EventBus : signaux globaux découplant les systèmes entre eux.
## N'importe quel noeud peut faire EventBus.xp_collected.emit(amount) par ex.

signal xp_collected(amount: int)
signal player_leveled_up(new_level: int)
signal player_died()
signal boss_spawned(boss_name: String)
signal boss_died()
signal enemy_died(enemy: Node2D, xp_value: int, global_pos: Vector2)
signal player_health_changed(current: float, max: float)
signal skill_cooldown_changed(ratio: float) # 0.0 = prête, 1.0 = vient d'être utilisée
signal upgrade_chosen(upgrade_id: String)
signal wave_timer_changed(seconds_elapsed: float)
signal run_won()
