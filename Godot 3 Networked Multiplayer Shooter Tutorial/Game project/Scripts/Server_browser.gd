extends Control

onready var server_listener = $Server_listener
onready var server_ip_edit_text = $Background_panel/Server_ip_edit_text
onready var server_container = $Background_panel/Server_container
onready var manual_setup = $Background_panel/Manual_setup

func _ready() -> void:
	server_ip_edit_text.hide()
func _on_Server_listener_new_server(serverInfo):
	var server_node = Globals.instance_node(load("res://Game project/Cenas/Server_display.tscn"), server_container)
	server_node.text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	server_node.ip_address = str(serverInfo.ip)
func _on_Server_listener_remove_server(serverIp):
	for serverNode in server_container.get_children():
		if serverNode.is_in_group("server_display"):
			if serverNode.ip_address == serverIp:
				serverNode.queue_free()
				break
func _on_Manual_setup_pressed():
	if manual_setup.text != "exit setup":
		server_ip_edit_text.show()
		manual_setup.text = "exit setup"
		server_container.hide()
		server_ip_edit_text.call_deferred("grab_focus")
	else:
		server_ip_edit_text.text = ""
		server_ip_edit_text.hide()
		manual_setup.text = "manual setup"
		server_container.show()
func _on_Join_server_pressed():
	Network.ip_address = server_ip_edit_text.text
	hide()
	Network.join_server()
func _on_Go_back_pressed():
	get_tree().reload_current_scene()
