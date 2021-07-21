extends VBoxContainer
class_name Chat

const CHAT_MSG = preload("res://Menu/ChatMessage.tscn");

func _ready():
	pass # Replace with function body.

func pushMessage(msg):
	$ChatMessages.add_child(msg);
	
	if($ChatMessages.get_children().size() > 5):
		$ChatMessages.get_child(0).queue_free();
	pass

remote func pushMessageFromPeer(user, text):
	var msg = CHAT_MSG.instance();
	msg.create(user, text);
	pushMessage(msg)
	pass
	
func sendMessage():
	var textFieldContent = $TextField.text;
	textFieldContent.erase(textFieldContent.length() - 1, 1);
	
	var msg = CHAT_MSG.instance();
	msg.create(Network.self_data.name, textFieldContent)
	
	if($TextField.text != ""):
		pushMessage(msg)
		rpc_unreliable("pushMessageFromPeer", msg.user, msg.message);
	
	$TextField.text = "";
	$TextField.hide();
	pass

func getFocus():
	$TextField.grab_focus()
	$TextField.show();
	pass

func _on_TextField_focus_exited():
	$TextField.hide();
	pass

func isOpen():
	return $TextField.visible;
	pass

func sendConsoleMessage(info):
	var msg = CHAT_MSG.instance();
	msg.create("CONSOLE", info)
	pushMessage(msg);
	rpc_unreliable("pushMessageFromPeer", msg.user, msg.message);
	pass
