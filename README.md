(Resource Collection)

Two resource types: Wood and Gold

- Wood: Collected by interacting with the Wood Collector (prop manipulator).

- Gold: Automatically generated when standing in the Gold Zone (1 per second).

(Base Claiming System)

- Initial State: All building triggers are hidden.

- Claim Zone Interaction: When player enters the claim zone, first building button is revealed.

(Progressive Building Mechanics)

8 Building Phases: Each phase has its own:

- Trigger device (the "buy button")

- Resource cost (customizable per phase)

- Resource type (Wood or Gold, configurable per phase)

(Purchase Flow)

- Player approaches an active trigger/button

- System checks if player has enough of the required resource

- If insufficient resources: Nothing happens (no feedback, no purchase)

- If sufficient resources:
	- Required resources are deducted.
	- Current trigger disappears.
	- Next trigger in sequence reveals.

(Progressive Visibility)

- Phase 1: Only visible after claim zone activation.

- Phases 2-8: Each becomes visible only after previous phase is purchased.
