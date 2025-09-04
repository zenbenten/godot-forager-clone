extends CharacterBody2D

const SPEED = 130.0

@onready var interaction_area: Area2D = $InteractionArea

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

func _physics_process(_delta):
	if Input.is_action_just_pressed("interact"):
		interact_with_nearby_object()
	
	if multiplayer.is_server():
		_apply_movement_from_input()

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
