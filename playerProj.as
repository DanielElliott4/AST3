/* Created by Daniel Elliott 
 * On 10/06/21
 * Last edited 17/06/21
 */


package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.utils.getTimer;

	public class playerProj extends MovieClip {
		private var stageObject: Object;

		//variables for movement of proj
		private var xVel: Number;
		private var yVel: Number;
		private var angleToFire: Number;
		private var spawnTime: Number;
		private var projLifeTime: Number = 2000;
		private var projSpeed: Number = 20;
		
		//constructor code,takes in parsed variables
		public function playerProj(shootAngle: Number): void {
			angleToFire = shootAngle;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
		}

		//called when proj is added, sets initial conditions
		public function onAdded(e: Event): void {
			stageObject = MovieClip(root);
			spawnTime = getTimer();
			xVel = projSpeed * Math.cos(angleToFire);
			yVel = projSpeed * Math.sin(angleToFire);

			this.x = stageObject.stage.stageWidth / 2;
			this.y = stageObject.stage.stageHeight / 2 - 20;
			this.width = 30;
			this.height = 30;
			this.rotation = -angleToFire / Math.PI * 180;
			addEventListener(Event.ENTER_FRAME, updateProj, false, 0, true);
			removeEventListener(Event.ENTER_FRAME, onAdded);

		}

		//moves the the projectile and checks for collision with player
		public function updateProj(e: Event): void {
			if (spawnTime + projLifeTime < getTimer()) {
				parent.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, updateProj);
			} else {
				this.x += xVel;
				this.y -= yVel;
				this.x -= MovieClip(root).xVel;
				this.y -= MovieClip(root).yVel;
			}

			if (this.hitTestObject(stageObject.firstBoss)) {
				stageObject.firstBoss.subtractHealth();
				removeEventListener(Event.ENTER_FRAME, updateProj);
				parent.removeChild(this);
			}
		}
	}

}