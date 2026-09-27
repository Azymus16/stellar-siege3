extends Node
## UpgradeDatabase (autoload) : pool complet des améliorations possibles.
## get_random_choices() filtre selon le personnage et pioche 3 upgrades différentes,
## en respectant les limites de stacks déjà prises.

var pool: Array[UpgradeData] = []

func _ready() -> void:
	_build_pool()

func _build_pool() -> void:
	pool.clear()
	var col_dmg := Color(1.0, 0.35, 0.3)
	var col_spd := Color(0.4, 1.0, 0.6)
	var col_def := Color(0.4, 0.7, 1.0)
	var col_util := Color(1.0, 0.85, 0.3)
	var col_special := Color(1.0, 0.5, 1.0)

	# --- Améliorations génériques (tous personnages) ---
	pool.append(UpgradeData.make("dmg_up", "Puissance de Tir", "+18% de dégâts sur l'attaque principale.", "D", col_dmg, "damage_mult", "", 0.18))
	pool.append(UpgradeData.make("atkspd_up", "Cadence Accrue", "+15% de vitesse d'attaque.", "C", col_dmg, "attack_speed_mult", "", 0.15))
	pool.append(UpgradeData.make("speed_up", "Propulseurs", "+10% de vitesse de déplacement.", "V", col_spd, "move_speed_mult", "", 0.10))
	pool.append(UpgradeData.make("hp_up", "Coque Renforcée", "+20 PV max, soigne immédiatement.", "P", col_def, "max_hp_flat", "", 20.0))
	pool.append(UpgradeData.make("armor_up", "Blindage", "-1 dégât subi sur chaque coup.", "B", col_def, "armor_flat", "", 1.0, "", "", 6))
	pool.append(UpgradeData.make("pickup_up", "Champ Magnétique", "+40% de rayon de collecte d'XP.", "M", col_util, "pickup_radius_mult", "", 0.40))
	pool.append(UpgradeData.make("cdr_up", "Surcharge", "-12% de délai de recharge de compétence.", "R", col_util, "skill_cooldown_mult", "", 0.12, "", "", 4))
	pool.append(UpgradeData.make("xpgain_up", "Résonance Stellaire", "+15% d'expérience gagnée.", "X", col_util, "xp_gain_mult", "", 0.15))
	pool.append(UpgradeData.make("regen_up", "Auto-Réparation", "Régénère 1 PV/s.", "+", col_def, "regen_flat", "", 1.0, "", "", 4))

	# --- Spécifiques ARME : Plasma (Nova) ---
	pool.append(UpgradeData.make("plasma_multi", "Tir Fractionné", "+1 projectile de plasma.", "M", col_special, "", "extra_projectile", 1.0, "plasma", "", 4))
	pool.append(UpgradeData.make("plasma_pierce", "Plasma Perforant", "Les tirs traversent 1 ennemi de plus.", "P", col_special, "", "pierce", 1.0, "plasma", "", 3))

	# --- Spécifiques COMPÉTENCE : Météores (Nova) ---
	pool.append(UpgradeData.make("meteor_count", "Pluie Renforcée", "+1 météore par activation.", "M", col_special, "", "extra_meteor", 1.0, "", "meteor", 4))
	pool.append(UpgradeData.make("meteor_radius", "Impact Elargi", "+30% de rayon d'explosion des météores.", "R", col_special, "", "radius_mult", 0.30, "", "meteor", 4))

	# --- Spécifiques ARME : Gravité (Orion) ---
	pool.append(UpgradeData.make("gravity_radius", "Onde Amplifiée", "+25% de portée de l'onde gravitationnelle.", "R", col_special, "", "radius_mult", 0.25, "gravity", "", 4))
	pool.append(UpgradeData.make("gravity_knockback", "Choc Repoussant", "+40% de force de repousse.", "K", col_special, "", "knockback_mult", 0.40, "gravity", "", 3))

	# --- Spécifiques COMPÉTENCE : Trou Noir (Orion) ---
	pool.append(UpgradeData.make("blackhole_duration", "Singularité Stable", "+35% de durée du trou noir.", "D", col_special, "", "duration_mult", 0.35, "", "blackhole", 4))
	pool.append(UpgradeData.make("blackhole_pull", "Attraction Intense", "+30% de force d'attraction.", "A", col_special, "", "pull_mult", 0.30, "", "blackhole", 4))

	# --- Spécifiques ARME : Stellaire (Lyra) ---
	pool.append(UpgradeData.make("stellar_bounce", "Rebond Supplémentaire", "+1 rebond sur les tirs stellaires.", "B", col_special, "", "extra_bounce", 1.0, "stellar", "", 5))
	pool.append(UpgradeData.make("stellar_multi", "Double Étoile", "+1 projectile stellaire.", "M", col_special, "", "extra_projectile", 1.0, "stellar", "", 3))

	# --- Spécifiques COMPÉTENCE : Constellation (Lyra) ---
	pool.append(UpgradeData.make("const_nodes", "Constellation Élargie", "+1 nœud de constellation.", "N", col_special, "", "extra_node", 1.0, "", "constellation", 3))
	pool.append(UpgradeData.make("const_damage", "Résonance Cosmique", "+30% dégâts d'explosion de constellation.", "D", col_special, "", "damage_mult", 0.30, "", "constellation", 4))

	# --- Spécifiques ARME : Glace (Comète) ---
	pool.append(UpgradeData.make("ice_slow", "Gel Renforcé", "+20% d'efficacité du ralentissement.", "G", col_special, "", "slow_mult", 0.20, "ice", "", 4))
	pool.append(UpgradeData.make("ice_multi", "Éclats Multiples", "+1 projectile de glace.", "M", col_special, "", "extra_projectile", 1.0, "ice", "", 4))

	# --- Spécifiques COMPÉTENCE : Dash (Comète) ---
	pool.append(UpgradeData.make("dash_trail", "Traînée Prolongée", "+40% de durée de la traînée de givre.", "T", col_special, "", "duration_mult", 0.40, "", "dash", 4))
	pool.append(UpgradeData.make("dash_damage", "Impact Glacial", "+25% dégâts de la traînée.", "D", col_special, "", "damage_mult", 0.25, "", "dash", 4))

func get_random_choices(count: int, character: CharacterData, taken_counts: Dictionary) -> Array[UpgradeData]:
	var eligible: Array[UpgradeData] = []
	for u in pool:
		if u.requires_weapon != "" and u.requires_weapon != character.weapon_id:
			continue
		if u.requires_skill != "" and u.requires_skill != character.skill_id:
			continue
		var current: int = taken_counts.get(u.id, 0)
		if current >= u.max_stacks:
			continue
		eligible.append(u)
	eligible.shuffle()
	var n: int = min(count, eligible.size())
	return eligible.slice(0, n)
