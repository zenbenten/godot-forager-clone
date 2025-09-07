class_name RecipeData
extends Resource

@export var output_item: ItemData
@export var output_quantity: int = 1

# key: ItemData resource
# value: quantity as int
@export var ingredients: Dictionary

# the building required to craft this recipe
# if null, can be crafted by hand in the inventory
@export var crafting_station: BuildingData
