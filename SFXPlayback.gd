extends AudioStreamPlayer

var standardDB;

func _ready():
	standardDB = get_volume_db();
	pass # Replace with function body.

func playSound(soundFile, db_add = 0):
	set_volume_db(db_add + standardDB);
	stream = soundFile;
	play();
	pass
	
func setSound(soundFile, db_add = 0): #not playing it yet
	set_volume_db(db_add + standardDB);
	stream = soundFile;
	pass
