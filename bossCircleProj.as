/* Created by Daniel Elliott 
 * On 2/06/21
 * Last edited 17/06/21
 * Mechanics are functionally same as 'playerProj'
 * See playerProj for comments
 */

package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.utils.getTimer;
	import flash.geom.Point;

	public class bossCircleProj extends MovieClip {
		private var stageObject: Object;

		private var initialXPos: Number;
		private var initialYPos: Number;
		private var xVel: Number;
		private var yVel: Number;
		private var angleToFire: Number;
		private var spawnTime: Number;
		private var projLifeTime: Number;


		public function bossCircleProj(xPos: Number, yPos: Number, shootAngle: Number, projSpeed: Number, lifeTime: Number): void {
			projLifeTime = lifeTime;
			xVel = projSpeed * Math.cos(shootAngle);
			yVel = projSpeed * Math.sin(shootAngle);
			initialXPos = xPos;
			initialYPos = yPos;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded ,false,0,true);
		}

		public function onAdded(e: Event): void {
			stageObject = MovieClip(root);
			spawnTime = getTimer();
			this.x = initialXPos;
			this.y = initialYPos;
			this.width = 25;
			this.height = 25;
			addEventListener(Event.ENTER_FRAME, updateProj ,false,0,true);
			removeEventListener(Event.ENTER_FRAME, onAdded);
		}

		public function updateProj(e: Event): void {



			if (spawnTime + projLifeTime < getTimer()) {
				parent.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, updateProj);
			} else {
				this.x += xVel;
				this.y -= yVel;
				this.x -= stageObject.xVel;
				this.y -= stageObject.yVel;
			}
			if (this.hitTestObject(stageObject.playersChar)) {
				stageObject.playersChar.subtractHeart();
				removeEventListener(Event.ENTER_FRAME, updateProj);
				parent.removeChild(this);
			}
		}
	}
}