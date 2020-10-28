extends ParallaxBackground

export (bool) var useBackground = false;
export (bool) var useSkyColor = true;

export (Texture) var Background;
export (Color) var BackgroundColor;


export var constantMotion = Vector2(0.0,0.0);

export var adjustScrollMotionAutomatically = true;
export var repetitionsAmount = Vector2(1,1);

export var backgroundScale = Vector2(1.0,1.0);

export var additionalOffset = Vector2(0,0);

export var repeatY = true;

export var scrollMotion = Vector2(1.0,0.0);

export var deleteInInfiniteVecticalSetting = false;

var multiplicator;

func _ready():
	
	if(Background == null):
		useBackground = false;
	if(BackgroundColor != null):
		$ColorRect.color = BackgroundColor;
	
	$ParallaxLayer/BackgroundSprite.scale = Vector2(backgroundScale.x, backgroundScale.y);

	if(!useSkyColor):
		$ColorRect.hide();

	if(useBackground):
		$ParallaxLayer/BackgroundSprite.texture = Background;
		if(adjustScrollMotionAutomatically):
			adjustScrollMotion();
		setScrollMotion();
		setConstantBackgroundMotion();
		var scrollYMultiplier = 1;
		if(scrollMotion.y != 0):
			scrollYMultiplier = abs(scrollMotion.y) + 1;
		$ParallaxLayer/BackgroundSprite.offset.y = ($ParallaxLayer/BackgroundSprite.region_rect.size.y / multiplicator.y / 2 + additionalOffset.y) * scrollYMultiplier;
		$ParallaxLayer/BackgroundSprite.offset.x = ($ParallaxLayer/BackgroundSprite.region_rect.size.x / multiplicator.x / 2 + additionalOffset.x);
	
	if(deleteInInfiniteVecticalSetting && Global.level_infinite_vertical_scroll):
		$ParallaxLayer/BackgroundSprite.queue_free();
	pass
	
func adjustScrollMotion():
	var level_lengths = Global.level_boundary_rect;
	
	scrollMotion.x = ($ParallaxLayer/BackgroundSprite.texture.get_width() * backgroundScale.x / level_lengths.size.x) * repetitionsAmount.x;
	scrollMotion.y = ($ParallaxLayer/BackgroundSprite.texture.get_height() * backgroundScale.y / level_lengths.size.y) * repetitionsAmount.y;
	pass
	
func setScrollMotion():
	$ParallaxLayer.motion_scale = Vector2(scrollMotion.x, scrollMotion.y);
	pass
	
func setConstantBackgroundMotion():
	
	var scrollMultiplicator = Vector2(1,1); #If fast scroll, the BG might need to be bigger, like with 3
	
	if(abs(scrollMotion.x) > 2):
		scrollMultiplicator.x = abs(scrollMotion.x) - 1;
	if(abs(scrollMotion.y) > 2):
		scrollMultiplicator.y = abs(scrollMotion.y) - 1;
	
	multiplicator = Vector2();
	multiplicator.x = Global.level_boundary_rect.size.x * 2 * pow(backgroundScale.x, -1) * scrollMultiplicator.x / $ParallaxLayer/BackgroundSprite.texture.get_size().x;
	multiplicator.y = Global.level_boundary_rect.size.y * 2 * pow(backgroundScale.y, -1) * scrollMultiplicator.y / $ParallaxLayer/BackgroundSprite.texture.get_size().y;
	multiplicator = Vector2(round(multiplicator.x) * 2, round(multiplicator.y) * 2);  #*2 cuz levels can be pretty small 
	
	if(!repeatY):
		multiplicator.y = 2;
	
	var bgsize = Vector2($ParallaxLayer/BackgroundSprite.texture.get_size().x * multiplicator.x, $ParallaxLayer/BackgroundSprite.texture.get_size().y * multiplicator.y);

	$ParallaxLayer/BackgroundSprite.set_region_rect(Rect2(0,0,bgsize.x,bgsize.y));
	pass

func _process(delta):
	if(useBackground):
		if(constantMotion.x != 0):
			
			$ParallaxLayer.motion_offset.x += constantMotion.x;
			
			if(constantMotion.x > 0):
				if($ParallaxLayer.motion_offset.x >= $ParallaxLayer/BackgroundSprite.region_rect.size.x * backgroundScale.x / multiplicator.x):
					$ParallaxLayer.motion_offset.x = $ParallaxLayer.motion_offset.x - $ParallaxLayer/BackgroundSprite.region_rect.size.x * backgroundScale.x / multiplicator.x;
			else:	
				if($ParallaxLayer.motion_offset.x <= -$ParallaxLayer/BackgroundSprite.region_rect.size.x * backgroundScale.x / multiplicator.x):
					$ParallaxLayer.motion_offset.x = $ParallaxLayer.motion_offset.x + $ParallaxLayer/BackgroundSprite.region_rect.size.x * backgroundScale.x / multiplicator.x;
	
		if(constantMotion.y != 0):
			
			$ParallaxLayer.motion_offset.y += constantMotion.y;
			
			if(constantMotion.y > 0):
				if($ParallaxLayer.motion_offset.y >= $ParallaxLayer/BackgroundSprite.region_rect.size.y * backgroundScale.y / multiplicator.y):
					$ParallaxLayer.motion_offset.y = $ParallaxLayer.motion_offset.y - $ParallaxLayer/BackgroundSprite.region_rect.size.y * backgroundScale.y / multiplicator.y;
			else:	
				if($ParallaxLayer.motion_offset.y <= -$ParallaxLayer/BackgroundSprite.region_rect.size.y * backgroundScale.y / multiplicator.y):
					$ParallaxLayer.motion_offset.y = $ParallaxLayer.motion_offset.y + $ParallaxLayer/BackgroundSprite.region_rect.size.y * backgroundScale.y / multiplicator.y;
	pass
