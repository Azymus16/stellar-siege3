class_name UpgradeData
extends Resource
## Décrit une amélioration piochée au level up.
## - stat_key : stat générique du joueur modifiée (voir Player.apply_upgrade)
## - param_key : si non vide, la valeur est transmise à l'arme ou à la compétence
##   active du joueur via apply_upgrade(param_key, value)
## - requires_weapon / requires_skill : si non vide, l'upgrade n'est proposée
##   qu'aux personnages ayant cette arme/compétence (permet des upgrades uniques
##   par personnage, ex: "+1 météore" seulement pour Nova).

var id: String
var display_name: String
var description: String
var icon_letter: String
var icon_color: Color
var stat_key: String = ""
var param_key: String = ""
var value: float = 0.0
var requires_weapon: String = ""
var requires_skill: String = ""
var max_stacks: int = 5

static func make(
	p_id: String, p_name: String, p_desc: String, p_letter: String, p_color: Color,
	p_stat_key: String, p_param_key: String, p_value: float,
	p_req_weapon: String = "", p_req_skill: String = "", p_max_stacks: int = 5
) -> UpgradeData:
	var u := UpgradeData.new()
	u.id = p_id
	u.display_name = p_name
	u.description = p_desc
	u.icon_letter = p_letter
	u.icon_color = p_color
	u.stat_key = p_stat_key
	u.param_key = p_param_key
	u.value = p_value
	u.requires_weapon = p_req_weapon
	u.requires_skill = p_req_skill
	u.max_stacks = p_max_stacks
	return u
