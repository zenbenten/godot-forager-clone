# src/game_events.gd
extends Node

## global event bus for decoupled communication
## systems can emit signals here without needing to know who is listening

signal player_took_damage
signal resource_gathered(resource_data, quantity)
signal enemy_defeated(enemy_data)
