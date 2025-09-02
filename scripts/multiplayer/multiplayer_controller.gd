extends CharacterBody2D

const SPEED = 130.0

var alive = true # This is for your respawn system

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready():
	print("PLAYER SPAWNED on this machine for player_id: ", player_id)
	if multiplayer.get_unique_id() == player_id:
		print("This player is MINE. Enabling camera.")
		$Camera2D.make_current()
	else:
		print("This is a remote player. Disabling camera.")
		$Camera2D.enabled = false

func _apply_movement_from_input():
	# Get the synced input vector from the InputSynchronizer
	var input_vector = %InputSynchronizer.input_vector
	
	# Set velocity from the input vector
	# .normalized() prevents faster diagonal movement
	velocity = input_vector.normalized() * SPEED
	move_and_slide()

func _physics_process(delta):
	# The server is the authority and calculates all movement.
	if multiplayer.is_server():
		# This 'alive' logic is for your respawn system.
		# It no longer needs to check 'is_on_floor'.
		if not alive:
			# You might want a different condition to set alive to true,
			# but for now, we'll just apply movement.
			pass
		
		_apply_movement_from_input()

# --- Respawn functions remain unchanged, but note that the gravity/floor logic is gone ---
func mark_dead():
	print("Mark player dead!")
	alive = false
	velocity = Vector2.ZERO # Stop movement when dead
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()

func _respawn():
	print("Respawned!")
	position = MultiplayerManager.respawn_point
	$CollisionShape2D.set_deferred("disabled", false)
	# You might want to call _set_alive() here instead
	
func _set_alive():
	print("alive again!")
	alive = true
	# Engine.time_scale is no longer needed here if you removed it previously
