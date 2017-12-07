# Transience

## Game vision

Transience is a top-down action RPG that follows the player, a transient being
of unknown origin that has a form of time-travel. Themes include temporal
nature, the desire for existence, and inner struggle.

## Mechanics

In addition to normal movement and attacks, the player character will have the
ability to "throwback" to an earlier state. This may include changing position,
restoring health, or otherwise dodging attacks.

- The player will be able to move around the environment
- The player will be able to perform normal attacks
- The player will be able to use throwbacks in battles to dodge, and perhaps
  move in other interesting ways
- Attacks and throwbacks will consume "flux", a continuously-regenerating stat,
  similar to stamina

### Explicit stats

- Health: decreases when damage is taken, increases when healed
- Flux: decreases when attacking or using a throwback, regenerates when moving

### Abilities

Gameplay consists of fast-paced action sequences, with predictable and
responsive controls.

Attacks:

- Short-range, sweeping (180 degree) attack
- Mid-range, quicker lance attack

Movement:

- Throwback: jump back to a previous location; cost and "throwback length"
  determined by length button is held down (with a max). Cannot go back further
  than a certain amount (even if there is enough flux). Short cooldown after
  each throwback (to prevent spamming).

## Enemies

Enemies are beings that live in the visited world. Most battle gameplay is
melee based. Enemies release health-particles upon defeat that the player can
absorb.

Enemies:

- Jumper
  Spider-like mob enemy, little health, swarms in numbers
  Winds-up and jumps at the player

- Fighter
  Humanoid enemy, stronger, more health, similar attacks as player

Boss:

- Id
  TODO

## Ambience

To reinforce the transient/temporal vibe of the world, there will be certain
instances where other transient beings (similar to the player) phase in and out
of the game. This can be used either for ambience, or strategically in order to
point out perhaps a hidden section or secret.

### Network features

The above mechanism can be extended to work over the network, and introduce a
player-controlled transient avatar in another player's world. This will briefly
allow the two to see each other, but not interact otherwise.

## Scenes / Levels

The game shall be broken up into 2 major types of scenes:

- Main menu
- Game level

Notably, there is no pause menu. >:)

### Main menu

The main menu will be a simple logo of the game name, with a start button.  Due
to the game length, it will be designed to be played in one sitting, and will
not have save states.

Idea: add fuzzy/static-y shader effect to main menu (and while transitioning scenes?).

### Game level design

TODO

### In-game UI

The UI will include the following:

- Health bar (red)
- Flux bar (thin, blue)

Enemies have no health bar. Boss might...?

## Story

Up for interpretation. :)

### Cutscenes

TODO
