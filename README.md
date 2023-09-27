# Ludum Dare 54
Our project for [Ludum Dare 54](https://ldjam.com/).

# Conventions
## Folder and Project structure
The project is split into separate modular features and themes in folders.

Absolutely all file names and all directory names with no exception are written in lowercase `snake_case`. File extensions are without exception lowercase. If an asset file extensions is available in multiple variants, we use the shortest: `jpeg` -> `jpg`.

Graphics, sounds and further assets are put directly besides the code in the matching folder. New subfolders are normally not needed, except when there is an extraordinary amount of new assets, that can't be organised otherwise.
*Rule of thumb: Fewer than 3 asset files? No subfolder needed.*

### Example
If the project has multiple monsters (a Zombie, a Dragon, a pink and a red elephant) we have a folder "monster" and matching subfolders for the monster types. The project structure could look like this:

```
godot
|   world.gd
|   world.tscn
├───monster
│   │   monster.gd
│   ├───dragon
│   │   │   dragon.gd
│   │   │   dragon.png
│   │   │   dragon.tscn
│   │   ├───sounds
│   │   │       dragon_angry.ogg
│   │   │       dragon_howl.ogg
│   │   │       dragon_wing_flap.ogg
│   │   └───states
│   │           fire_breath.gd
│   │           hovering.gd
│   │           howl.gd
│   │           idle.gd
│   ├───elephant
│   │   │   elephant_colorless.png
│   │   │   elephant.gd
│   │   │   elephant.tscn
│   │   │   elephant_horn.ogg
│   │   ├───pink_elephant
│   │   │       pink_elephant.tscn
│   │   │       pink_elephant.gd
│   │   └───red_elephant
│   │           red_elephant.tscn
│   │           red_elephant.gd
│   └───zombie
│           zombie.gd
│           zombie.tscn
│           zombie_death.png
│           zombie_drooling.png
│           zombie_growl.ogg
└───shared
        fire_burn.ogg
```

## Branching
New branches follow the following conventions:
- If a new feature starts development we create a new branch which starts with the prefix `dev-` and the English feature name in `kebab-case`
- **Examples:** `dev-main-menu` or `dev-dragon-monster`

## Commits
1. Have a commit message – white space or no characters at all can’t be a good description for any code change.
2. Keep a short subject line – long subjects won’t look good when executing some git commands. Limit the subject line to 50 characters.
3. Don’t end the subject line with a period – it’s unnecessary. Especially when you are trying to keep the commit title to under 50 characters.
4. Start with a capital letter – straight from the source: “this is as simple as it sounds. Begin all subject lines with a capital letter”.

Taken from [here](https://www.datree.io/resources/git-commit-message).

## Code conventions
We are following the [GDScript Guidelines from the Godot Documentation](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html)

Please take the time to familiarize yourself with them before contributing.