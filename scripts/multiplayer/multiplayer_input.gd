extends MultiplayerSynchronizer

var input_vector = Vector2.ZERO

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		return

func _physics_process(delta):
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
