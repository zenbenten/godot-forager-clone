extends CharacterBody2D

const SPEED = 150.0

@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite = $Sprite2D

func _physics_process(_delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# set velocity from input
	velocity = input_vector * SPEED
	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		interact_with_nearby_object()

	# Update visuals
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func interact_with_nearby_object():
	# Get a list of all physics bodies inside detection bubble
	var nearby_objects = interaction_area.get_overlapping_bodies()

	# if the list isnt empty interact with the first object found
	if not nearby_objects.is_empty():
		var target = nearby_objects[0]

		#check if the object has the interact function before calling it
		if target.has_method("interact"):
			print("Found nearby object:", target.name, ". Interacting!")
			target.interact(self) #call the interact function 
