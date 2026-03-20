extends Area3D

@export var title : String
@export_multiline var description : String
@export var image : Texture2D

func show_info(panel):
	panel.show_info(title, description, image)
