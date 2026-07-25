extends Control

# Menu pages
@onready var main_page = $CenterContainer/Main
@onready var credits_page = $CenterContainer/Credits

# Main page buttons

@onready var start_button = main_page.get_node("Start")
@onready var settings_button = main_page.get_node("Settings")
@onready var credits_button = main_page.get_node("Credits")
@onready var quit_button = main_page.get_node("Quit")



func select_page(page):
	for child in $CenterContainer.get_children():
		child.hide()
	page.show()
	$FadeOut/AnimationPlayer.animation_finished.connect(func(_a): get_tree().change_scene_to_file("res://scenes/main/main.tscn"))

func _ready() -> void:
	
	quit_button.press_finished.connect(func(): get_tree().quit())
	credits_button.press_finished.connect(select_page.bind(credits_page))
	start_button.press_finished.connect(_on_start)
	
	
	for back_button in get_tree().get_nodes_in_group("Back_Button"):
		back_button.press_finished.connect(select_page.bind(main_page))
	
	select_page(main_page)

func _on_start():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$FadeOut/AnimationPlayer.play("fade_out")
