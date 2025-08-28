# features/player/player.gd
extends CharacterBody2D

@export var speed: float = 250.0

@onready var interaction_area = $Area2D

func _physics_process(delta: float) -> void:
	#get input direction 
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	#set velocity based on input and speed
	velocity = direction * speed

	# godot function to move character and handle collisions
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# check if interact button is pressed
	if event.is_action_pressed("interact_button"):
		var bodies = interaction_area.get_overlapping_bodies()
		if not bodies.is_empty():
			# grabs the first one. TODO: grab the closest one
			var target = bodies[0]
			
			# Check if the target has the standard "interact" function and call it.
			if target.has_method("interact"):
				target.interact(self)
