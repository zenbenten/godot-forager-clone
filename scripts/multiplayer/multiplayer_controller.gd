extends CharacterBody2D

const SPEED = 130.0

var alive = true 

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
	
	var input_vector = %InputSynchronizer.input_vector
	
	velocity = input_vector.normalized() * SPEED
	move_and_slide()

func _physics_process(delta):
	
	if multiplayer.is_server():
		
		if not alive:
			pass
		
		_apply_movement_from_input()

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
	# might want to call _set_alive() here instead
	
func _set_alive():
	print("alive again!")
	alive = true
