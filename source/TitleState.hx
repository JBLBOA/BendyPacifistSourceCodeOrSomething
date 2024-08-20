package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public static var initializedPressed:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:FlxText;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];
	var mustUpdate:Bool = false;
	var titleJSON:TitleData;
	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		PlayerSettings.init();

		// DEBUG BULLSHIT
		
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates && !closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		#if TITLE_SCREEN_EASTER_EGG
		if (FlxG.save.data.psychDevsEasterEgg == null) FlxG.save.data.psychDevsEasterEgg = ''; //Crash prevention
		switch(FlxG.save.data.psychDevsEasterEgg.toUpperCase())
		{
			case 'SHADOW':
				titleJSON.gfx += 210;
				titleJSON.gfy += 40;
			case 'RIVER':
				titleJSON.gfx += 100;
				titleJSON.gfy += 20;
			case 'SHUBS':
				titleJSON.gfx += 160;
				titleJSON.gfy -= 10;
			case 'BBPANZU':
				titleJSON.gfx += 45;
				titleJSON.gfy += 100;
		}
		#end

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekBendyCompleted != null)
		{
			BendyStoryMenuState.weekCompleted = FlxG.save.data.weekBendyCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	public var spiral:FlxSprite;
	public var ground:FlxSprite;
	public var blackTop:FlxSprite;
	public var curtain1:FlxSprite;
	public var curtain2:FlxSprite;
	public var light:FlxSprite;
	public var reel1:FlxSprite;
	public var reel2:FlxSprite;
	public var logo:FlxSprite;
	public var enter:FlxSprite;
	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		spiral = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		spiral.frames = Paths.getSparrowAtlas('BendyMenus/title/menuspiral', 'shared');
		spiral.antialiasing = ClientPrefs.globalAntialiasing;
		spiral.animation.addByPrefix('idle', 'BG', 24, true);
		spiral.animation.play('idle');
		spiral.scale.set(1.5, 1.5);
		spiral.screenCenter();
		add(spiral);

		ground = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/floor', 'shared'));
        ground.antialiasing = ClientPrefs.globalAntialiasing;
		ground.setGraphicSize(Std.int(ground.width * 0.5168));
		ground.y += 41;
        ground.updateHitbox();
        add(ground);

		blackTop = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/peru', 'shared'));
        blackTop.antialiasing = ClientPrefs.globalAntialiasing;
		blackTop.setGraphicSize(Std.int(blackTop.width * 0.5168));
        blackTop.updateHitbox();
        add(blackTop);

		curtain1 = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/curtain 1', 'shared'));
        curtain1.antialiasing = ClientPrefs.globalAntialiasing;
		curtain1.setGraphicSize(Std.int(curtain1.width * 0.542));
        curtain1.updateHitbox();
        add(curtain1);

		curtain2 = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/curtain 2', 'shared'));
        curtain2.antialiasing = ClientPrefs.globalAntialiasing;
		curtain2.setGraphicSize(Std.int(curtain2.width * 0.522));
        curtain2.updateHitbox();
        add(curtain2);

		light = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/light', 'shared'));
        light.antialiasing = ClientPrefs.globalAntialiasing;
		light.setGraphicSize(Std.int(light.width * 0.5168));
        light.updateHitbox();
		light.blend = ADD;
		light.x -= 100;
        add(light);

		reel1 = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/reels', 'shared'));
        reel1.antialiasing = ClientPrefs.globalAntialiasing;
		reel1.setGraphicSize(Std.int(reel1.width * 0.5168));
        reel1.updateHitbox();
        add(reel1);

		reel2 = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/reels2', 'shared'));
        reel2.antialiasing = ClientPrefs.globalAntialiasing;
		reel2.setGraphicSize(Std.int(reel2.width * 0.5168));
        reel2.updateHitbox();
		reel2.y += 41;
        add(reel2);

		logo = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/logo', 'shared'));
        logo.antialiasing = ClientPrefs.globalAntialiasing;
		logo.setGraphicSize(Std.int(logo.width * 0.5168));
        logo.updateHitbox();
		logo.x = FlxG.width - logo.width - 25;
		logo.y = 50;
        add(logo);

		enter = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/enter', 'shared'));
        enter.antialiasing = ClientPrefs.globalAntialiasing;
		enter.setGraphicSize(Std.int(enter.width * 0.5168));
        enter.updateHitbox();
		enter.x = FlxG.width - enter.width - 40;
		enter.y = FlxG.height - enter.height - 40;
        add(enter);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();
		blackScreen = new FlxSprite().loadGraphic(Paths.image('BendyMenus/title/negro', 'shared'));
		credGroup.add(blackScreen);

		credTextShit = new FlxText(0, 0, FlxG.width, "", 64);
		credTextShit.font = Paths.font('DK Black Bamboo.ttf');
		credTextShit.color = FlxColor.WHITE;
		credTextShit.alignment = CENTER;
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	var floatLogo:Float = 41.82;
	public static var allowPress:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		if(initialized && skippedIntro)
		{
			floatLogo += 0.03;
			logo.setPosition(logo.x + Math.sin(floatLogo) * 0.5, logo.y + Math.cos(floatLogo) * 0.5);
			logo.angle = Math.sin(floatLogo) * 2.8;
		}

		if (initialized && !transitioning && skippedIntro && allowPress)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
			}
			
			if(pressedEnter)
			{
				FlxG.camera.flash(0xFFFFFFFF, 0.8);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				FlxTween.tween(enter, {x: enter.x - 1500}, 1, {ease: FlxEase.quadInOut});
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 1.5, alpha: 0.0001}, 1.5, {ease: FlxEase.quadInOut, startDelay: (initializedPressed ? 0 : 0.8)});

				transitioning = true;
				// FlxG.sound.music.stop();
				if(!initializedPressed) {
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						new FlxTimer().start(1.4, function(tmr:FlxTimer)
						{
							if (mustUpdate) {
								MusicBeatState.switchState(new OutdatedState());
							} else {
								MusicBeatState.switchState(new MainMenuState());
							}
							closedState = true;
						});
					});
					initializedPressed = true;
				} else {
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						if (mustUpdate) {
							MusicBeatState.switchState(new OutdatedState());
						} else {
							MusicBeatState.switchState(new MainMenuState());
						}
						closedState = true;
					});
				}
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntroPressed();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:FlxText = new FlxText(0, 0, FlxG.width, textArray[i], 64);
			money.font = Paths.font('DK Black Bamboo.ttf');
			money.color = FlxColor.WHITE;
			money.screenCenter(X);
			money.alignment = CENTER;
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:FlxText = new FlxText(0, 0, FlxG.width, text, 64);
			coolText.font = Paths.font('DK Black Bamboo.ttf');
			coolText.color = FlxColor.WHITE;
			coolText.alignment = CENTER;
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(['Joey Drew Studios'], 15);
				case 4:
					addMoreText('Presents', 15);
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['In associated', 'with'], -20);
				case 8:
					addMoreText('BAENDI', -20);
					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					createCoolText(['Lalalalalalala'], -20);
				case 11:
					deleteCoolText();
				case 12:
					createCoolText(['Insert a shitty joke here'], -20);
				case 13:
					deleteCoolText();
				case 14:
					createCoolText(['Bendy was a little devil'], -20);
				case 15:
					addMoreText('Thing', -20);
				case 16:
					deleteCoolText();
				case 17:
					createCoolText(['ooh', 'mighty ink demon'], -40);
				case 18:
					deleteCoolText();
				case 19:
					createCoolText(['We offer', 'you this sacrifice'], -40);
				case 20:
					deleteCoolText();
				case 21:
					createCoolText(['We offer', 'you this sack of rice'], -40);
				case 22:
					deleteCoolText();
				case 23:
					createCoolText(['FNF'], -40);
				case 24:
					addMoreText("Bendy's", -40);
				case 25:
					addMoreText("Genocide", -40);
				case 26:
					addMoreText("FULL DEMO!", -40);
				case 27:
					addMoreText("LETS GO!!!!!!!!!!!!", -40);
				case 28:
					skipIntro();
				case 33:
					FlxG.camera.flash(0xFFFFFFFF, 0.8);
					spiral.alpha = 1;
					curtain1.alpha = 1;
					curtain2.alpha = 1;
					light.alpha = 1;
					reel1.alpha = 1;
					reel2.alpha = 1;
					logo.alpha = 1;
					enter.alpha = 1;
					allowPress = true;
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(credGroup);
			skippedIntro = true;
			if(!allowPress) {
				FlxG.camera.alpha = 0.0001;
				FlxG.camera.zoom = 2;
				spiral.alpha = 0.0001;
				curtain1.alpha = 0.0001;
				curtain2.alpha = 0.0001;
				light.alpha = 0.0001;
				reel1.alpha = 0.0001;
				reel2.alpha = 0.0001;
				logo.alpha = 0.0001;
				enter.alpha = 0.0001;
				reel1.y += 400;
				reel2.y += 400;
				FlxTween.tween(FlxG.camera, {zoom: 1, alpha: 1}, 1, {ease: FlxEase.quadInOut, startDelay: 0.2, onComplete: function (twn:FlxTween) {
					FlxTween.tween(reel1, {y: reel1.y - 400, alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
					FlxTween.tween(reel2, {y: reel2.y - 400, alpha: 1}, 0.4, {ease: FlxEase.quadInOut, onComplete: function (twn:FlxTween) {
						//allowPress = true;
					}});
				}});
			} else {
				FlxG.camera.flash(0xFF000000, 0.8);
			}
		}
	}

	function skipIntroPressed():Void
	{	
		if (!skippedIntro)
		{
			closedState = true;
			remove(ngSpr);
			remove(credGroup);
			skippedIntro = true;
			FlxG.camera.flash(0xFFFFFFFF, 0.8);
			spiral.alpha = 1;
			curtain1.alpha = 1;
			curtain2.alpha = 1;
			light.alpha = 1;
			reel1.alpha = 1;
			reel2.alpha = 1;
			logo.alpha = 1;
			enter.alpha = 1;
			allowPress = true;		
		}
	}
}