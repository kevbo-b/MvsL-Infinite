extends Camera2D
class_name SplitscreenCam1

var target = null;
var cameraActive = true;

var useDragMargin = false;
var moveToDirection = false;
var smoothingNormal = 30;
var followLength = 32;
"../../../../unusedCam"
var customMargin = true
var currentMarginOffset = Vector2(0,0);

var marginHSize = Vector2(32,32);
var marginH = Vector2(0,0);

var marginVSize = Vector2(72,72);
var marginV = Vector2(0,0);

var followTargetX = true;
var followTargetY = true;

var followRight = true;
var followRightOLD = true;

var followDown = true;
var followDownOLD = true;

var oldPosition = Vector2(0,0);

func _ready():
	if(moveToDirection):
		smoothing_enabled = true
		smoothing_speed = smoothingNormal
	if(!useDragMargin):
		drag_margin_h_enabled = false;
		drag_margin_v_enabled = false;
	drag_margin_left = 0.2
	drag_margin_right = 0.2
	
	if(Global.playing_splitscreen && Global.player_amount > 2):
		marginVSize = Vector2(32,32);
	#position = target.position
	#drag_margin_h_enabled = false
	pass

func _physics_process(delta):
	if(target && cameraActive):
		var posX = target.position.x;
		var posY = target.position.y;
				
		if(moveToDirection):
			if(target.motion.x > 16 * target.MASS_MULTIPLICATOR):
				followLength = abs(followLength);
			elif(target.motion.x < -16 * target.MASS_MULTIPLICATOR):
				followLength = abs(followLength) * -1;
				
			posX += followLength;
		
		
		if(customMargin && followTargetX):
			if(posX > oldPosition.x):
				followRight = true;
			elif(posX < oldPosition.x):
				followRight = false;
				
		if(customMargin && followTargetY):
			if(posY > oldPosition.y - 1):
				followDown = true;
			elif(posY < oldPosition.y + 1):
				followDown = false;

		
		if(followRight != followRightOLD && followRight != null && followRightOLD != null && followTargetX):
			if(followRightOLD):
				marginH = Vector2(posX - marginHSize.x,posX);
			else:
				marginH = Vector2(posX,posX + marginHSize.x);
			followTargetX = false;
		
		if(followDown != followDownOLD && followDown != null && followDownOLD != null && followTargetY):
			if(followDownOLD):
				marginV = Vector2(posY - marginVSize.x,posY);
			else:
				marginV = Vector2(posY,posY + marginVSize.x);
			followTargetY = false;
					
		var finalPosX = posX;
		var finalPosY = posY;

		if(followTargetX):
			finalPosX = posX + currentMarginOffset.x;
			followRightOLD = followRight;
			oldPosition.x = target.position.x;
		else:
			finalPosX = position.x;
			checkIfTargetInXMargin();
			
		if(followTargetY):
			finalPosY = posY + currentMarginOffset.y;
			followDownOLD = followDown;
			oldPosition.y = target.position.y;
		else:
			finalPosY = position.y;
			checkIfTargetInYMargin();
	
		position = Vector2(finalPosX,finalPosY);
	
	pass
	
func checkIfTargetInXMargin():
	if(target.position.x >= marginH.x && target.position.x <= marginH.y):
		pass
	else:
		followTargetX = true;
		if(target.position.x <= marginH.x && followRightOLD):
			followRight = false;
			followRightOLD = false;
			currentMarginOffset.x = marginHSize.x;
		elif(target.position.x <= marginH.x && !followRightOLD):	
			followRight = false;
			followRightOLD = false;
			currentMarginOffset.x = marginHSize.y;
		elif(target.position.x >= marginH.y && followRightOLD):
			followRight = true;
			followRightOLD = true;
			currentMarginOffset.x = 0;
		else:	
			followRight = true;
			followRightOLD = true;
			currentMarginOffset.x = 0;
	pass
	
func checkIfTargetInYMargin():
	if(target.position.y >= marginV.x && target.position.y <= marginV.y):
		pass
	else:
		followTargetY = true;
		if(target.position.y <= marginV.y && followDownOLD):
			followDown = false;
			followDownOLD = false;
			currentMarginOffset.y = marginVSize.x;
		elif(target.position.y <= marginV.y && !followDownOLD):	
			followDown = false;
			followDownOLD = false;
			currentMarginOffset.y = marginVSize.y;
		elif(target.position.y >= marginV.x && followDownOLD):
			followDown = true;
			followDownOLD = true;
			currentMarginOffset.y = 0;
		else:	
			followDown = true;
			followDownOLD = true;
			currentMarginOffset.y = 0;
	pass
	
func checkForMarginDisable():
	if(position.x >= Global.level_boundary_rect.size.x - 32 || position.x <= 32):
		drag_margin_h_enabled = false;
		drag_margin_v_enabled = false;
	else:
		drag_margin_h_enabled = true;
		drag_margin_v_enabled = true;
	pass
	
func adjustInfiniteWorldWarp(value):
	customMargin = false;

	if(value == 1): #0 to limit y
		marginV.x = marginV.x + Global.level_boundary_rect.size.y;
		marginV.y = marginV.y + Global.level_boundary_rect.size.y;
		oldPosition.y = oldPosition.y + Global.level_boundary_rect.size.y;
		position.y = position.y + Global.level_boundary_rect.size.y;	
	elif(value == 2): #limit to 0 y
		marginV.x = marginV.x - Global.level_boundary_rect.size.y;
		marginV.y = marginV.y - Global.level_boundary_rect.size.y;
		oldPosition.y = oldPosition.y - Global.level_boundary_rect.size.y;
		position.y = position.y - Global.level_boundary_rect.size.y;		
	elif(value == 3): #0 to limit x
		marginH.x = marginH.x + Global.level_boundary_rect.size.x;
		marginH.y = marginH.y + Global.level_boundary_rect.size.x;
		oldPosition.x = oldPosition.x + Global.level_boundary_rect.size.x;
		position.x = position.x + Global.level_boundary_rect.size.x;
	elif(value == 4): #limit to 0 x
		marginH.x = marginH.x - Global.level_boundary_rect.size.x;
		marginH.y = marginH.y - Global.level_boundary_rect.size.x;
		oldPosition.x = oldPosition.x - Global.level_boundary_rect.size.x;
		position.x = position.x - Global.level_boundary_rect.size.x;

	var t = Timer.new()
	t.set_wait_time(0.05)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

	yield(t, "timeout")
	t.queue_free();	

	customMargin = true;
	pass
	
func resetCamera():
	cameraActive = true;
	position = target.position;
	oldPosition = target.position;
	followRight = true;
	followRightOLD = true;
	followDown = true;
	followDownOLD = true;
	currentMarginOffset = Vector2(0,0);
	pass
	
func stopCamera():
	cameraActive = false;
	pass
