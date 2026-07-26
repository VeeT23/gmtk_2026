extends Control


func _restart():
	OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
	get_tree().change_scene_to_file("res://scenes/ui/menus/main/menu_scene.tscn")
	
func _quit():
	OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
	get_tree().change_scene_to_file("res://scenes/ui/menus/main/menu_scene.tscn")
