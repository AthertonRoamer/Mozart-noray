extends Control


func _on_button_pressed():
	var ip = $VBoxContainer/LineEdit.text
	GameState.player_name = $"../Menu1/NameInput".text
	Network.initiate_client(ip)
