extends Control

onready var multiplayer__configure = $Multiplayer_Configure
onready var user_ip_address = $Multiplayer_Configure/User_ip_address
onready var device_ip_address = $ui/Device_ip_address
onready var start_game_button = $ui/Start_game_button
const PLAYER:PackedScene=preload("res://Game project/Cenas/Player.tscn")
var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

func _on_Create_server_pressed():
	if user_ip_address.text != "":
		Network.current_player_username = user_ip_address.text
		multiplayer__configure.hide()
		Network.create_server()
		instance_player(get_tree().get_network_unique_id())
func _on_Join_server_pressed():
	if user_ip_address.text:
		multiplayer__configure.hide()
		user_ip_address.hide()
		Globals.instance_node(load("res://Game project/Cenas/Server_browser.tscn"),self)
func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	device_ip_address.text = Network.ip_address
	if get_tree().network_peer != null:
		multiplayer__configure.hide()
		current_spawn_location_instance_number = 1
		for player in Persistent_nodes.get_children():
			if player.is_in_group("Player"):
				for spawn_location in $Spawn_locations.get_children():
					if int(spawn_location.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
						player.rpc("update_position", spawn_location.global_position)
						player.rpc("enable")
						current_spawn_location_instance_number += 1
						current_player_for_spawn_location_number = player
	else:
		start_game_button.hide()
func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	instance_player(id)
func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	if Persistent_nodes.get_node(str(id)):
		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_nodes.get_node(str(id)).queue_free()
func _connected_to_server() -> void:
	print("Successfully connected to the server")
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())
func instance_player(id) -> void:
	var player_instance = Globals.instance_node_at_location(PLAYER, Persistent_nodes, get_node("Spawn_locations/" + str(current_spawn_location_instance_number)).global_position)
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	player_instance.username = user_ip_address.text
func _on_Start_game_button_pressed():
	rpc("switch_to_game")
func _process(_delta: float) -> void:
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			start_game_button.show()
		else:
			start_game_button.hide()
sync func switch_to_game() -> void:
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Player"):
			child.update_shoot_mode(true)
	var _reload=get_tree().change_scene("res://Game project/Cenas/Game.tscn")
