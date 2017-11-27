extends YSort

func _ready():
	var music = get_node("/root/music")
	music.play_level1()
