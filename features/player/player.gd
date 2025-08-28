# features/player/player.gd
extends CharacterBody2D

@export var speed: float = 150.0

func _physics_process(delta: float) -> void:
	#get input direction 
	var direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")

	#set velocity based on input and speed
	velocity = direction * speed

	# godot function to move character and handle collisions
	move_and_slide()
