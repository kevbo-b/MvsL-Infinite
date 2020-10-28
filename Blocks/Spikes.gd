extends StaticBody2D

export var triggeringSpike = false;
export(int, "Upside","Downside","Right","Left") var spikeDirection = 0;
var triggered = false;
var outside = true;
var movX = 0;
var movY = 0;

var destinationPosition;
var pulledBackPosition;
var riseSteps = 4;
var pullBackSteps = 1;


func _ready():
	initialize();
	pass # Replace with function body.

func initialize():
	if(spikeDirection == 0):
		movY = -1;
	elif(spikeDirection == 1):
		movY = 1;
		rotation_degrees = 180;
		$SpikeArea/Sprite.flip_h = true;
	elif(spikeDirection == 2):
		movX = 1;
		rotation_degrees = 90;
	else:
		movX = -1;
		rotation_degrees = 270;
		$SpikeArea/Sprite.flip_h = true;
	
	if(triggeringSpike):
		destinationPosition = position;
		pulledBackPosition = Vector2(position.x + (-16) * movX,position.y + (-16) * movY);
		position = pulledBackPosition;
		outside = false;
	pass


func _on_SpikeArea_area_entered(area):
	if("player_hitbox" in area.name && outside):
		if(!area.get_parent().have_star && !area.get_parent().isMega):
			area.get_parent().damaged(self);
	pass

func _on_TriggerArea_body_entered(body):
	if(triggeringSpike):
		if "player" in body.name:
			if(!triggered):
				$TimeToTrigger.start();
				triggered = true;
	pass
	
func _on_TimeToTrigger_timeout():
	$TimeToTrigger.stop();
	moveOutSpikes();
	pass

func moveOutSpikes():
	outside = true;
	$Rise.start();
	pass
	
func _on_Rise_timeout():
	if(position == destinationPosition):
		$Rise.stop();
		$TimeTillReset.start();
	else:
		position = Vector2(position.x + riseSteps * movX,position.y + riseSteps * movY);
	pass

func _on_TimeTillReset_timeout():
	$TimeTillReset.stop();
	resetSpikes();
	pass
	
func resetSpikes():
	$PullBack.start();
	pass

func _on_PullBack_timeout():
	if(position == pulledBackPosition):
		$PullBack.stop();
		triggered = false;
		outside = false;
		refreshAreaInMaskBits($TriggerArea,[1]);
	else:
		position = Vector2(position.x + (-1) * pullBackSteps * movX,position.y + (-1) * pullBackSteps * movY);
	pass
	
func got_hit_from_block(): #unused
	pass
	
func restore(): #unused
	pass
	
func refreshAreaInMaskBits(area, maskBits : Array):
	for bit in maskBits:
		area.set_collision_mask_bit(bit, false);
		pass

	var t = Timer.new()
	t.set_wait_time(0.02)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	yield(t, "timeout")
	t.queue_free();	
	
	for bit in maskBits:
		area.set_collision_mask_bit(bit, true);
		pass
	pass



