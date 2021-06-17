/* Created by Daniel Elliott 
 * On 25/05/21
 * Last edited 17/06/21
 */

package {

	import flash.ui.Keyboard;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.MouseEvent;

	public class charAllSprites extends MovieClip {
		private var stageObject: Object;

		public var heartsLeft: Number = 3;
		public var charDead: Boolean = false;

		private var leftClickDown: Boolean = false;
		private var lastShot: Number = 0;
		private var shotWait: Number = 50;

		public function charAllSprites() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		//sets initial conditions
		public function onAdded(e: Event): void {
			heartsLeft = 3;
			charDead = false;
			stageObject = MovieClip(root);
			this.x = stageObject.stage.stageWidth / 2;
			this.y = stageObject.stage.stageHeight / 2;
			this.width = 25;
			this.height = 25;
			this.alpha = 1;
			addEventListener(Event.ENTER_FRAME, updateChar);
			stageObject.stage.addEventListener(MouseEvent.MOUSE_DOWN, leftClickHeld);
		}
		
		//controls shooting and if the char dies
		public function updateChar(e: Event): void {
			if (heartsLeft < 0) {
				charDead = true;
				removeEventListener(Event.ENTER_FRAME, onAdded);
				removeEventListener(Event.ENTER_FRAME, updateChar);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, leftClickHeld);
				stage.removeEventListener(MouseEvent.MOUSE_UP, leftClickReleased);
				parent.removeChild(this);
			}
			if (leftClickDown && lastShot + shotWait < getTimer()) {
				lastShot = getTimer();
				var playersShot: MovieClip = new playerProj(getAngle(mouseX, mouseY));
				stageObject.bulletholder.addChild(playersShot);
			}
		}

		public function subtractHeart(): void {
			heartsLeft--;
		}

		public function isCharDead(): Boolean {
			return charDead;
		}

		function leftClickHeld(mouseEvent: Event): void {
			leftClickDown = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, leftClickReleased);
		}

		function leftClickReleased(mouseEvent: Event) {
			leftClickDown = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, leftClickReleased);
		}

		public function getAngle(xPos: Number, yPos: Number): Number {
			yPos = -yPos;
			if (xPos == 0) {
				xPos = 0.1;
			}
			var relatedAngle = Math.atan(yPos / xPos);
			if (xPos >= 0 && yPos >= 0) {
				return relatedAngle;
			} else if (xPos <= 0 && yPos >= 0) {
				return Math.PI + relatedAngle;
			} else if (xPos <= 0 && yPos <= 0) {
				return Math.PI + relatedAngle;
			} else {
				return 2 * Math.PI + relatedAngle;
			}
		}
	}
}