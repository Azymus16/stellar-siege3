# Installer sur iPhone sans aucun Mac (via GitHub Actions + Sideloadly)

Cette voie compile l'app dans le cloud (Mac virtuel gratuit fourni par
GitHub) puis l'installe sur ton iPhone depuis ton PC Windows, sans jamais
toucher un Mac physique.

⚠️ **Ce pipeline n'a pas pu être testé de bout en bout** (pas de Mac ni de
compte GitHub disponibles pour le valider). Le workflow fourni est un point
de départ solide, mais une ou deux corrections après le premier essai sont
probables — c'est normal pour ce genre de configuration. Si une étape
échoue, copie-moi le message d'erreur du log GitHub Actions, je corrige le
fichier concerné.

## Partie 1 — Compiler le .ipa dans le cloud (GitHub Actions)

1. **Crée un compte GitHub** (gratuit) sur https://github.com si tu n'en as
   pas, puis crée un **nouveau dépôt** (repository), par exemple nommé
   `stellar-siege`. Choisis-le **public** (les dépôts publics ont des
   minutes de build macOS illimitées et gratuites ; en privé, GitHub offre
   un quota gratuit mensuel qui se consomme plus vite sur macOS).

2. **Envoie le contenu de ce dossier `StellarSiege/` dans ce dépôt.** Le plus
   simple sans ligne de commande : sur la page du dépôt GitHub, utilise
   **"Add file" → "Upload files"**, puis glisse-dépose tout le contenu du
   dossier (y compris le dossier caché `.github/`, à envoyer séparément si
   l'upload web le masque — dans ce cas, utilise plutôt GitHub Desktop,
   application gratuite, qui gère correctement les dossiers cachés).

3. **Lance le build** : va dans l'onglet **"Actions"** du dépôt GitHub, tu
   dois voir un workflow nommé **"Build iOS (non signé)"**. Clique dessus,
   puis bouton **"Run workflow"** (menu déroulant en haut à droite) → **"Run
   workflow"** à nouveau pour confirmer.

4. **Attends la fin du build** (10 à 20 minutes). Une coche verte ✅ apparaît
   si tout s'est bien passé. En cas de croix rouge ❌, clique sur le job pour
   voir le log détaillé et copie-le-moi.

5. **Télécharge le résultat** : en bas de la page du run terminé, section
   **"Artifacts"**, télécharge `StellarSiege-ipa-non-signe.zip`. Dézippe-le :
   tu obtiens `StellarSiege-unsigned.ipa`.

## Partie 2 — Installer le .ipa sur ton iPhone depuis Windows (Sideloadly)

1. **Active le mode développeur sur l'iPhone** (nécessaire depuis iOS 16) :
   `Réglages → Confidentialité et sécurité → Mode développeur` → active,
   puis redémarre le téléphone quand demandé.

2. **Installe iTunes officiel** (⚠️ pas celui du Microsoft Store — désinstalle-le
   s'il est présent) : https://www.apple.com/itunes/download/win64
   Lance-le une fois pour qu'il installe les pilotes USB nécessaires.

3. **Installe Sideloadly** : https://sideloadly.io (version Windows). Lance
   l'app.

4. **Branche ton iPhone en USB**, déverrouille-le, accepte "Faire confiance
   à cet ordinateur". Il doit apparaître dans le menu déroulant "iDevice" de
   Sideloadly.

5. **Glisse `StellarSiege-unsigned.ipa`** dans la fenêtre de Sideloadly (zone
   prévue à cet effet, ou bouton avec l'icône de fichier).

6. **Renseigne un Apple ID** dans le champ "Apple Account" (ton Apple ID
   habituel fonctionne ; par prudence certains préfèrent en créer un dédié
   sur https://appleid.apple.com — gratuit, 2 minutes). Le mot de passe est
   envoyé uniquement aux serveurs Apple pour générer le certificat de
   signature, jamais à Sideloadly.

7. **Clique sur "Start"**. Sideloadly resigne l'app avec ton Apple ID et
   l'installe automatiquement sur le téléphone. La première fois, il peut
   demander un code de vérification à deux facteurs (reçu sur tes autres
   appareils Apple).

8. **Fais confiance au profil** : sur l'iPhone, `Réglages → Général → VPN et
   gestion de l'appareil`, tape sur ton Apple ID, puis "Faire confiance".

9. **Lance Stellar Siege** depuis l'écran d'accueil.

## Limites à connaître

- Avec un Apple ID gratuit, l'app cesse de fonctionner au bout de **7 jours**
  — il suffit de refaire l'étape "Start" dans Sideloadly pour la
  réinstaller (Sideloadly propose aussi une option de rafraîchissement
  automatique en tâche de fond).
- Un Apple ID gratuit est limité à environ **10 identifiants d'app** sur une
  fenêtre de quelques jours et **3 apps sideloadées simultanément** — largement
  suffisant pour ce test.
- Chaque fois que tu modifies le code du jeu, il faut relancer le workflow
  GitHub Actions (Partie 1) puis réinstaller via Sideloadly (Partie 2).
