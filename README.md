# Stellar Siege — Prototype jouable (Godot 4)

Survivor spatial en vue de dessus. Vagues d'ennemis, montées de niveau,
améliorations, boss de fin de run, 4 personnages jouables. Ambiance sci-fi
cosmique originale (aucun élément de League of Legends repris).

## 1. Prérequis

- **Godot Engine 4.3** (ou plus récent en 4.x), édition **Standard** (GDScript,
  pas besoin de la version .NET). Téléchargement gratuit : https://godotengine.org/download
- Pour exporter sur téléphone : un câble USB + un appareil Android en mode
  développeur, ou un Mac + Xcode pour iOS (détails plus bas).

## 2. Ouvrir et tester le projet

1. Lance Godot 4, clique sur **Importer**, sélectionne le fichier
   `project.godot` à la racine de ce dossier.
2. Une fois le projet ouvert, appuie sur **F5** (ou le bouton ▶️ en haut à
   droite) pour lancer le jeu. La scène de démarrage est `MainMenu.tscn`.
3. **Commandes clavier/souris (test dans l'éditeur)** :
   - Déplacement : clique-glisse dans la moitié gauche de l'écran (simule le
     joystick tactile), ou touches **ZQSD/WASD** fonctionnent aussi car les
     actions d'input clavier sont pré-configurées.
   - Compétence active : bouton rond en bas à droite (clic gauche dessus),
     ou touche **Espace**.
4. Choisis un personnage dans le menu, clique sur **JOUER**.

### Commandes exactes en jeu (version tactile finale)

| Action | Contrôle |
|---|---|
| Se déplacer | Joystick virtuel flottant en bas à gauche (n'importe quel doigt posé dans la moitié gauche de l'écran) |
| Attaque principale | Automatique, aucune action requise |
| Compétence active | Bouton rond en bas à droite (se grise pendant le temps de recharge) |
| Choisir une amélioration | Toucher une des 3 cartes affichées à la montée de niveau (jeu en pause pendant ce choix) |

## 3. Vérification manuelle (je n'ai pas pu compiler Godot dans mon environnement)

Comme précisé, je n'ai pas accès à Godot ni à un appareil pour exécuter le
projet moi-même. Voici la checklist à suivre dans l'éditeur pour valider
chaque système :

1. **Le projet s'ouvre sans erreur de script** : au premier lancement, regarde
   le panneau "Sortie" (Output) en bas — il ne doit pas y avoir d'erreurs
   rouges de type "Parse Error" ou "Cannot find node path". Des warnings
   jaunes (ex. sur des appels dynamiques `weapon.setup()`) sont normaux et
   sans danger, ils viennent de l'attache dynamique de scripts aux armes.
2. **Menu principal** : les 4 cartes personnages s'affichent avec sprite,
   nom, description. Cliquer sur une carte la sélectionne (surbrillance).
   "JOUER" lance la partie.
3. **Déplacement** : le vaisseau suit le joystick, la caméra suit le joueur.
4. **Attaque automatique** : selon le personnage, des tirs/ondes partent
   seuls en continu.
5. **Ennemis** : des Éclaireurs (roses, rapides) apparaissent en cercle hors
   champ après quelques secondes, puis des Foreurs (verts, tirent à
   distance) et des Brutes (rouges, chargent) après ~25s.
6. **XP et niveau** : tuer un ennemi laisse tomber une gemme verte attirée
   vers le joueur ; à un certain total d'XP, popup de choix d'amélioration
   (jeu en pause), le choix modifie visiblement le comportement (plus de
   projectiles, zone plus grande, etc.).
7. **Compétence active** : appuyer sur le bouton dédié déclenche l'effet
   spectaculaire du personnage (météores, trou noir, constellation, dash).
8. **Boss** : après 4 minutes (configurable dans `GameManager.BOSS_SPAWN_TIME`),
   le Titan du Vide apparaît, sa barre de vie s'affiche en haut. Le vaincre
   déclenche l'écran de victoire ; mourir avant déclenche l'écran de défaite.
9. **Rejouer / Menu** : les boutons de l'écran de fin fonctionnent.

Si une étape échoue, le message d'erreur dans l'Output de Godot indique
précisément le fichier et la ligne en cause — n'hésite pas à me le copier-coller,
je pourrai corriger le script concerné.

## 4. Exporter une version Android installable (.apk / .aab)

1. Dans Godot : **Editeur → Gérer les modules d'export (Export Templates
   Manager)** → télécharge les modules correspondant à ta version de Godot
   (bouton "Download and Install").
2. Installe **Android Studio** (pour le SDK Android + un JDK 17) ou au minimum
   les *command line tools* Android + un JDK 17.
3. Dans Godot : **Éditeur → Paramètres de l'éditeur → Export → Android**,
   renseigne les chemins vers le SDK Android, `adb`, `jarsigner` (fournis par
   le JDK) et Java. Godot les détecte souvent automatiquement si Android
   Studio est installé au bon endroit.
4. Génère un **keystore de debug** (Godot peut le faire automatiquement au
   premier export si tu coches "Debug Keystore" dans les paramètres export).
5. Menu **Projet → Exporter…** → **Ajouter…** → **Android**. Vérifie :
   - Package name (ex. `com.tonstudio.stellarsiege`)
   - Orientation : **Landscape** (déjà réglée dans `project.godot`)
   - Version min SDK ≈ 24 (Android 7+), cible la plus récente disponible
6. **Pour tester sur ton téléphone branché en USB (débogage activé)** :
   bouton **"Exporter en un clic" (icône téléphone)** en haut à droite de
   Godot installe et lance directement l'APK sur l'appareil connecté.
7. **Pour une version installable partageable** : dans la fenêtre d'export,
   clique **Exporter le projet**, choisis `.apk` (installation directe) ou
   `.aab` (format requis pour publier sur le Google Play Store, nécessite
   alors un keystore de release signé, différent du keystore de debug).

## 5. Exporter vers iOS

L'export iOS nécessite un **Mac** avec **Xcode** installé (obligation d'Apple,
aucune solution de contournement) :

1. Sur le Mac, installe Godot 4 + les modules d'export iOS (Export Templates
   Manager, comme pour Android).
2. **Projet → Exporter… → Ajouter… → iOS**. Renseigne un **Bundle Identifier**
   unique (ex. `com.tonstudio.stellarsiege`).
3. Exporte : Godot génère un **projet Xcode** (dossier `.xcodeproj`), pas
   directement un `.ipa`.
4. Ouvre ce projet dans Xcode, renseigne ton **compte développeur Apple**
   (gratuit pour tester sur ton propre iPhone via câble, payant — 99$/an —
   pour publier sur l'App Store ou distribuer via TestFlight).
5. Branche ton iPhone, sélectionne-le comme cible dans Xcode, clique ▶️ pour
   installer et lancer le jeu dessus.
6. Pour l'App Store : **Product → Archive** dans Xcode, puis passe par
   **App Store Connect** pour la soumission (processus Apple standard).

## 6. Ressources visuelles : ce qui est provisoire

**Tous les visuels du projet sont des placeholders SVG faits à la main**
(dégradés + formes géométriques), pensés pour être cohérents visuellement
(palette cosmique, contrastes lisibles) mais **pas destinés à être le rendu
final**. Ils se trouvent dans `assets/sprites/`.

Pour chaque catégorie, voici un prompt prêt à l'emploi pour un générateur
d'images (Midjourney, DALL·E, Stable Diffusion...) afin de produire les
visuels définitifs. Style demandé partout : **2D top-down game asset, clean
vector-style shading, vibrant sci-fi colors, transparent background, no
text, no watermark**.

### Personnages (`assets/sprites/characters/`)
- **nova.svg** → *"Top-down 2D sprite of a small sleek orange-red starfighter
  ship with a glowing plasma engine core, sci-fi cosmic style, dynamic angular
  design, vibrant orange and molten-gold energy accents, transparent
  background, game asset"*
- **orion.svg** → *"Top-down 2D sprite of a compact indigo-blue starfighter
  surrounded by a subtle gravitational ring, sci-fi cosmic style, sleek
  geometric hull, glowing blue energy core, transparent background, game
  asset"*
- **lyra.svg** → *"Top-down 2D sprite of a purple star-shaped starfighter with
  crystalline wing tips, sci-fi cosmic style, magical constellation theme,
  glowing violet and pink energy, transparent background, game asset"*
- **comete.svg** → *"Top-down 2D sprite of a cyan icy comet-shaped starfighter
  with frosted crystalline hull and a trailing frozen wake, sci-fi cosmic
  style, glowing cyan-white energy, transparent background, game asset"*

### Ennemis (`assets/sprites/enemies/`)
- **swarmling.svg** → *"Top-down 2D sprite of a small fast pink-red alien
  swarm creature, insectoid silhouette, glowing core, menacing but readable
  game asset, transparent background"*
- **drone.svg** → *"Top-down 2D sprite of a teal hexagonal robotic sentry
  drone with a single glowing eye lens, sci-fi cosmic style, transparent
  background, game asset"*
- **brute.svg** → *"Top-down 2D sprite of a large jagged orange-red rocky
  alien brute creature, imposing silhouette, glowing cracks of energy,
  transparent background, game asset"*
- **boss.svg** → *"Top-down 2D sprite of a massive dark purple cosmic void
  entity boss, four crystalline spike limbs, glowing magenta core eye,
  imposing epic sci-fi boss design, transparent background, game asset"*

### Projectiles & effets (`assets/sprites/projectiles/`, `effects/`)
- **plasma_bolt.svg** → *"Small glowing orange plasma energy bolt, elongated
  oval shape, bright hot core fading to transparent edges, game VFX sprite,
  transparent background"*
- **ice_shard.svg** → *"Small sharp glowing cyan ice crystal shard projectile,
  game VFX sprite, transparent background"*
- **stellar_orb.svg** → *"Small glowing pink-purple star orb projectile with
  soft radiant glow, game VFX sprite, transparent background"*
- **meteor.svg** → *"Small glowing orange-red rocky meteor with cracked
  molten surface, game VFX sprite, transparent background"*
- **gravity_wave.svg / blackhole.svg** → *"Circular blue gravitational energy
  ring shockwave, glowing edges, game VFX sprite, transparent background"*
  and *"Swirling dark purple black hole vortex with glowing magenta event
  horizon, game VFX sprite, transparent background"*
- **explosion.svg** → *"Bright radial explosion burst, orange-yellow-white
  gradient, game VFX sprite, transparent background"*
- **xp_gem.svg** → *"Small glowing green crystal gem, faceted, game item
  sprite, transparent background"*

### Environnement (`assets/sprites/environment/`)
- **nebula_bg.svg** → *"Wide cosmic nebula background, deep purple and blue
  gas clouds with scattered stars, dense starfield, sci-fi space backdrop,
  seamless, no characters, no text"*

### UI (`assets/sprites/ui/`)
- **joystick_base.svg / joystick_knob.svg / skill_button.svg** → *"Circular
  sci-fi mobile game UI button, holographic blue glowing rim, clean minimal
  design, transparent background"*

## 7. Structure du projet

```
StellarSiege/
├── project.godot
├── icon.svg
├── assets/sprites/           ← tous les visuels (voir section 6)
├── scenes/
│   ├── main_menu/MainMenu.tscn
│   ├── game/Game.tscn         ← scène de gameplay principale
│   ├── player/Player.tscn
│   ├── enemies/*.tscn         ← 3 ennemis + boss
│   ├── projectiles/*.tscn     ← projectiles + effets de compétence
│   ├── pickups/XpGem.tscn
│   └── ui/*.tscn              ← HUD, joystick, popup upgrade, écran de fin
└── scripts/
    ├── autoload/              ← EventBus, GameManager (globaux)
    ├── data/                  ← CharacterData/Database, UpgradeData/Database
    ├── player/player.gd
    ├── weapons/                ← 1 script par arme (plasma/gravity/stellar/ice)
    ├── skills/                 ← 1 script par compétence active
    ├── projectiles/
    ├── enemies/
    ├── systems/                ← spawner de vagues, gemme d'XP
    └── ui/
```

## 8. Pistes d'amélioration pour la suite

- Remplacer les SVG provisoires par les visuels finaux (prompts ci-dessus).
- Joystick "flottant" réellement centré sous le doigt (actuellement zone fixe).
- Ajouter des sons/musique (aucun son n'est présent dans ce prototype).
- Ajuster l'équilibrage (dégâts, PV, cadences) après premiers tests.
- Ajouter plus de types d'ennemis et une 2ᵉ arène pour varier les runs.
- Sauvegarde de progression / méta-progression entre les parties.
