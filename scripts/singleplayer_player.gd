# res://scripts/single_player_controller.gd
extends CharacterBody2D

const SPEED = 150.0

@onready var sprite = $Sprite2D

func _physics_process(delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Set velocity from input
	velocity = input_vector * SPEED
	move_and_slide()

	# Update visuals
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
