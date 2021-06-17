/* Created by Daniel Elliott 
 * On 17/06/21
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

	public class smallProj extends MovieClip {
		private var stageObject: Object;
		
		private var initialXPos: Number;
		private var initialYPos: Number;
		private var xVel: Number;
		private var yVel: Number;
		private var angleToFire: Number;
		private var spawnTime: Number;
		private var projLifeTime: Number;

		public function smallProj(xPos: Number, yPos: Number, shootAngle: Number, projSpeed: Number, lifeTime: Number): void {
			angleToFire = shootAngle;
			projLifeTime = lifeTime;
			xVel = projSpeed * Math.cos(angleToFire);
			yVel = projSpeed * Math.sin(angleToFire);
			initialXPos = xPos;
			initialYPos = yPos;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
		}

		public function onAdded(e: Event): void {
			stageObject = MovieClip(root);
			spawnTime = getTimer();
			xVel = xVel * stageObject.difficultyModifier;
			yVel = yVel * stageObject.difficultyModifier;
			this.x = initialXPos;
			this.y = initialYPos;
			this.rotation = -angleToFire / Math.PI * 180;
			this.width = 15;
			this.height = 35;
			addEventListener(Event.ENTER_FRAME, updateProj, false, 0, true);
			removeEventListener(Event.ENTER_FRAME, onAdded);
		}

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
			if (this.hitTestObject(stageObject.playersChar)) {
				stageObject.playersChar.subtractHeart();
				removeEventListener(Event.ENTER_FRAME, updateProj);
				parent.removeChild(this);
			}
		}
	}
}