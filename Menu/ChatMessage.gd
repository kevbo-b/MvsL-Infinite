extends Label
class_name ChatMessage

var user = "";
var message = "";

func _ready():
	pass # Replace with function body.

func create(user, msg):
	self.user = user;
	self.message = msg;
	self.text = str(user + ": " + msg);
	pass
	
func _on_deleteTimer_timeout():
	$deleteTimer.stop();
	queue_free();
	pass
