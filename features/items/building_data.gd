class_name BuildingData
extends Resource

@export var building_name: String
# The scene to instance when this is built
@export var building_scene: PackedScene
#A dictionary of required items and quantities
#key= itemdata resource value= int quantity
@export var ingredients: Dictionary
