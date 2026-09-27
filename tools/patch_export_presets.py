"""
Configure le preset d'export iOS dans export_presets.cfg après que Godot
l'a généré automatiquement (godot --headless --generate-export-presets).

Ce script se contente de renseigner les quelques champs indispensables
(nom du preset, chemin de sortie, identifiant de l'app). Tous les autres
réglages restent aux valeurs par défaut de Godot, ce qui suffit pour une
compilation de test non signée.
"""
import configparser
import sys

PATH = "export_presets.cfg"
BUNDLE_ID = "com.stellarsiege.game"
APP_NAME = "Stellar Siege"
EXPORT_PATH = "build/ios/StellarSiege.xcodeproj"

config = configparser.ConfigParser(interpolation=None, strict=False)
config.optionxform = str  # préserve la casse des clés
read_ok = config.read(PATH)

if not read_ok:
    print(f"Impossible de lire {PATH} — le generate-export-presets a-t-il bien tourné ?")
    sys.exit(1)

ios_section = None
for section in config.sections():
    if section.startswith("preset.") and not section.endswith(".options"):
        platform = config.get(section, "platform", fallback="").strip('"')
        if platform == "iOS":
            ios_section = section
            break

if ios_section is None:
    print("Aucun preset avec platform=\"iOS\" trouvé dans export_presets.cfg.")
    print("Sections présentes :", config.sections())
    sys.exit(1)

idx = ios_section.split(".")[1]
options_section = f"preset.{idx}.options"
if not config.has_section(options_section):
    config.add_section(options_section)

config.set(ios_section, "name", '"iOS"')
config.set(ios_section, "export_path", f'"{EXPORT_PATH}"')
config.set(ios_section, "runnable", "true")

config.set(options_section, "application/identifier", f'"{BUNDLE_ID}"')
config.set(options_section, "application/name", f'"{APP_NAME}"')
config.set(options_section, "application/short_version", '"1.0"')
config.set(options_section, "application/version", '"1"')

with open(PATH, "w") as f:
    config.write(f, space_around_delimiters=False)

print(f"Preset iOS configuré avec succès : [{ios_section}] / [{options_section}]")
print(f"  identifiant     : {BUNDLE_ID}")
print(f"  chemin de sortie: {EXPORT_PATH}")
