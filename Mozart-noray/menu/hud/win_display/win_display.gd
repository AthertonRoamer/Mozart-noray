class_name WinDisplay
extends Control

var display_name : String
var message : String = " won!"

func _ready() -> void:
	visible = false
	

func set_display_name(n : String) -> void:
	$NameDisplay.text = n + message
	display_name = n
	

func set_display_visible(b : bool) -> void:
	visible = b
