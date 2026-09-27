class_name CharacterData
extends Resource
## Décrit un personnage jouable : identité, stats de base, arme et compétence.
## Un objet CharacterData est créé en code par CharacterDatabase (pas de .tres à la main,
## plus simple à maintenir et à équilibrer).

var id: String
var display_name: String
var tagline: String
var color: Color
var sprite_path: String

var max_hp: float
var move_speed: float
var base_damage: float

var weapon_id: String     # ex: "plasma", "gravity", "stellar", "ice"
var skill_id: String      # ex: "meteor", "blackhole", "constellation", "dash"
var skill_name: String
var skill_cooldown: float

static func make(
	p_id: String, p_name: String, p_tagline: String, p_color: Color, p_sprite: String,
	p_hp: float, p_speed: float, p_damage: float,
	p_weapon_id: String, p_skill_id: String, p_skill_name: String, p_skill_cd: float
) -> CharacterData:
	var d := CharacterData.new()
	d.id = p_id
	d.display_name = p_name
	d.tagline = p_tagline
	d.color = p_color
	d.sprite_path = p_sprite
	d.max_hp = p_hp
	d.move_speed = p_speed
	d.base_damage = p_damage
	d.weapon_id = p_weapon_id
	d.skill_id = p_skill_id
	d.skill_name = p_skill_name
	d.skill_cooldown = p_skill_cd
	return d
