package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

using StringTools;

class BendyStoryMenuState extends MusicBeatState
{
    public static var weekCompleted:Map<Int, Bool> = new Map<Int, Bool>();
    public static var curSelected:Int = 0;
    var weekImg:FlxSprite;
    var highScoreTxt:FlxText;
    var titleTxt:FlxText;
    var title2Txt:FlxText;
    var infoTxt:FlxText;
    var arrows:FlxTypedGroup<FlxSprite>;
    var textsGroup:FlxTypedGroup<FlxText>;
    var weekImage:FlxTypedGroup<FlxSprite>;
    var weekInfoList:Array<Array<String>> = [// songs in order
        ["Funkin' Pictures", "Every good story begins with a mystery, everything begins with a pencil and a \ndream, the dancing demon knows it, he's waiting to give you a show, \nwould you enter?"] // Chapter 0 Info list
    ];

    var weekSongList:Array<Array<String>> = [// songs in order
        ['test', 'pico'] // Chapter 0
    ];

    override function create()
    {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;

        weekImage = new FlxTypedGroup<FlxSprite>();
        textsGroup = new FlxTypedGroup<FlxText>();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/Background_menu', 'shared'));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.screenCenter();
        bg.updateHitbox();
        add(bg);

        var gear2:FlxSprite = new FlxSprite();
        gear2.frames = Paths.getSparrowAtlas('BendyMenus/Story/gear_2', 'shared');
        gear2.animation.addByPrefix('gear2Dance', "gear b instance 1", 24, true);
        gear2.animation.play('gear2Dance', true);
        gear2.antialiasing = ClientPrefs.globalAntialiasing;
        gear2.updateHitbox();
        gear2.screenCenter(Y);
        gear2.x -= 50;
        gear2.y += 200;
        add(gear2);

        for(i in 0...2)
        {
            var gear1:FlxSprite = new FlxSprite();
            gear1.frames = Paths.getSparrowAtlas('BendyMenus/Story/gear_1', 'shared');
            gear1.animation.addByPrefix('gear1Dance', "gear s instance 1", 24, true);
            gear1.animation.play('gear1Dance', true);
            gear1.antialiasing = ClientPrefs.globalAntialiasing;
            gear1.updateHitbox();
            gear1.screenCenter(Y);
            add(gear1);
            switch(i) {
                case 0:
                    gear1.x += 150;
                    gear1.y += 300;
                case 1:
                    gear1.x += FlxG.width - gear1.width + 100;
                    gear1.y -= 200;
            }
        }

        var pipe:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/PIPE', 'shared'));
        pipe.antialiasing = ClientPrefs.globalAntialiasing;
        pipe.updateHitbox();
        pipe.y = FlxG.height - pipe.height - 50;
        add(pipe);    

        var heart:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/HEART', 'shared'));
        heart.antialiasing = ClientPrefs.globalAntialiasing;
        heart.updateHitbox();
        heart.y = FlxG.height - heart.height - 45;
        heart.x = FlxG.width - heart.width - 200;
        add(heart);

        var screen:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/screen', 'shared'));
        screen.antialiasing = ClientPrefs.globalAntialiasing;
        screen.updateHitbox();
        screen.screenCenter(X);
        screen.y += 40;
        screen.x -= 25;
        add(screen);

        var barmenu:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/barmenu', 'shared'));
        barmenu.antialiasing = ClientPrefs.globalAntialiasing;
        barmenu.updateHitbox();
        barmenu.screenCenter(X);
        barmenu.y = FlxG.height - barmenu.height - 50;
        barmenu.x -= 20;
        add(barmenu);

        var quotebox:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/quotebox', 'shared'));
        quotebox.antialiasing = ClientPrefs.globalAntialiasing;
        quotebox.updateHitbox();
        quotebox.screenCenter();
        quotebox.x -= 25;
        quotebox.y += 140;
        add(quotebox);

        for(i in 0...weekSongList.length)
        {
            weekImg = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/screenArts/artmenu' + i, 'shared'));
            weekImg.antialiasing = ClientPrefs.globalAntialiasing;
            weekImg.updateHitbox();
            weekImg.ID = i;
            weekImg.setPosition(screen.x + 119, screen.y + 56);
            weekImage.add(weekImg);

            add(weekImage);
        }

        add(textsGroup);
        for( i in 0...weekInfoList.length)
        {
            titleTxt = new FlxText(barmenu.x, barmenu.y + 10, 300, "-Chapter " + (i+1) + "-", 22);
            titleTxt.setFormat(Paths.font("CaviarDreams.ttf"), 22, FlxColor.BLACK, CENTER);
            titleTxt.antialiasing = ClientPrefs.globalAntialiasing;
            titleTxt.scrollFactor.set();
            titleTxt.updateHitbox();
            titleTxt.ID = i;
            titleTxt.x += 115;
            textsGroup.add(titleTxt);

            infoTxt = new FlxText(quotebox.x, quotebox.y + 20, 800, "" + weekInfoList[i][1], 20);
            infoTxt.setFormat(Paths.font("CaviarDreams_Bold.ttf"), 20, FlxColor.fromRGB(200, 100, 30), CENTER);
            infoTxt.antialiasing = ClientPrefs.globalAntialiasing;
            infoTxt.scrollFactor.set();
            infoTxt.updateHitbox();
            infoTxt.x += 60;
            infoTxt.ID = i;
            textsGroup.add(infoTxt);

            title2Txt = new FlxText(titleTxt.x, titleTxt.y, 300, "\n" + weekInfoList[i][0], 32);
            title2Txt.setFormat(Paths.font("CaviarDreams_Bold.ttf"), 32, FlxColor.BLACK, CENTER);
            title2Txt.antialiasing = ClientPrefs.globalAntialiasing;
            title2Txt.scrollFactor.set();
            title2Txt.updateHitbox();
            title2Txt.y -= 10;
            title2Txt.ID = i;
            textsGroup.add(title2Txt);
        }

        var scoreBox:FlxSprite = new FlxSprite(-5, 45).loadGraphic(Paths.image('BendyMenus/Story/Score_Box', 'shared'));
        scoreBox.antialiasing = ClientPrefs.globalAntialiasing;
        scoreBox.updateHitbox();
        add(scoreBox);

        highScoreTxt = new FlxText(scoreBox.x + 10, scoreBox.y + 10, 300, "", 32);
        highScoreTxt.setFormat(Paths.font("soupofjustice.ttf"), 32, FlxColor.fromRGB(200, 100, 30), LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        highScoreTxt.antialiasing = ClientPrefs.globalAntialiasing;
        highScoreTxt.scrollFactor.set();
        highScoreTxt.updateHitbox();
        highScoreTxt.borderSize = 1.3;
        add(highScoreTxt);

        arrows = new FlxTypedGroup<FlxSprite>();
		add(arrows);
		for(i in 0...2) 
        {
			var arrow:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/arrowThing', 'shared'));
			arrow.antialiasing = ClientPrefs.globalAntialiasing;
			arrow.screenCenter(Y);
			arrow.y = arrow.y - 100;
			arrows.add(arrow);
			switch(i) {
				case 0:
					arrow.x = screen.x - 240;
				case 1:
					arrow.x = screen.x + screen.width + 100;
					arrow.flipX = true;
			}
		}

        var black:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/blackVig', 'shared'));
        black.antialiasing = ClientPrefs.globalAntialiasing;
        black.screenCenter();
        black.updateHitbox();
        black.alpha = 0.8;
        add(black);

        var light:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BendyMenus/Story/light', 'shared'));
        light.antialiasing = ClientPrefs.globalAntialiasing;
        light.screenCenter();
        light.updateHitbox();
        light.x += 46;
        add(light);

        var barUp:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 50, FlxColor.BLACK);
        barUp.updateHitbox();
        barUp.scrollFactor.set();
        add(barUp);
    
        var barDown:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 50, FlxColor.BLACK);
        barDown.updateHitbox();
        barDown.scrollFactor.set();
        barDown.y = FlxG.height - barDown.height;
        add(barDown);

        super.create();
        changeItem();
    }

    var selectedSomthin:Bool = false;
    var songWeekArray:Array<String> = [];
    var lerpScore:Int = 0;
    override function update(elapsed:Float)
    {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if(!selectedSomthin)
        {
			if (controls.UI_LEFT_P)
				changeItem(-1);
			if (controls.UI_RIGHT_P)
				changeItem(1);

            if(controls.UI_LEFT)
                arrows.members[0].scale.set(0.9, 0.9);
            else
                arrows.members[0].scale.set(1, 1);
    
            if(controls.UI_RIGHT)
                arrows.members[1].scale.set(0.9, 0.9);
            else
                arrows.members[1].scale.set(1, 1);
            
            lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
            if (Math.abs(lerpScore - intendedScore) <= 10)
                lerpScore = intendedScore;

            highScoreTxt.text = "SCORE: " + lerpScore;

			if (controls.BACK)
			{
				selectedSomthin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new MainMenuState());
			}

            weekImage.forEach(function(spr:FlxSprite)
            {
                if (spr.ID == curSelected) {
                    spr.alpha = 1;
                } 
                else 
                    spr.alpha = 0.0001;
            });

            textsGroup.forEach(function(text:FlxText)
            {
                if (text.ID == curSelected) {
                    text.alpha = 1;
                } 
                else 
                    text.alpha = 0.0001;
            });

            if(controls.ACCEPT)
            {
                selectedSomthin = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                new FlxTimer().start(1.25, function(tmr:FlxTimer)
                {
                    for(putThemIn in weekSongList[curSelected])
                    {
                        songWeekArray.push(putThemIn);
                        weekSelect();
                    }
                });
            }
        }

        super.update(elapsed);
    }

    function weekSelect()
    {
        WeekData.reloadWeekFiles(true);
        var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[0]);
        WeekData.setDirectoryFromWeek(weekFile);

        PlayState.storyPlaylist = songWeekArray;
        PlayState.storyDifficulty = 0;
        PlayState.isStoryMode = true;

        PlayState.storyWeek = curSelected;
        PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + "", PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;

        LoadingState.loadAndSwitchState(new PlayState(), true);
        FreeplayState.destroyFreeplayVocals();
    }

    var intendedScore:Int = 0;
    function changeItem(huh:Int = 0)
	{
        intendedScore = 0;
        if(huh != 0)
		    FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += huh;
		if (curSelected >= weekSongList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = weekSongList.length - 1;

        trace(weekCompleted.get(curSelected));
        if(weekCompleted.get(curSelected) == null)
        {
            weekCompleted.set(curSelected, false);
        }

        for(i in 0...weekSongList[curSelected].length)
        {
            if((weekCompleted.get(curSelected) == true))
            {
                #if !switch
                intendedScore += Highscore.getScore(weekSongList[curSelected][i], 1);
                #end
            }
        }
        trace("Current Week Score is: " + intendedScore);
	}
}