/* Created by Daniel Elliott 
 * On 28/05/21
 * Last edited 17/06/21
 */

package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.utils.getTimer;

	public class bossOne extends MovieClip {
		private var stageObject: Object;

		private var bossHealth: Number = 500;
		private var difficultyMod: Number;

		//relative angles and distances
		private var roomCentreFromBoss: Number;
		private var charRelToBossX: Number;
		private var charRelToBossY: Number;
		private var charAngleFromBoss: Number;
		private var charDistaceFromBossSquared: Number;

		//phase checkers
		private var lastHealthCheck: Number = 500;
		private var phaseOneEnd: Number = 300;
		private var phaseTwoEnd: Number = 100;

		private var inPhaseOne: Boolean = false;
		private var inPhaseTwo: Boolean = false;
		private var inPhaseThree: Boolean = false;
		private var hasReset: Boolean = false;

		//phase one vars
		private var circularAngleToFire: Number;
		private var circularShotAmount: Number = 10;
		private var circularShotLifetime: Number = 3000;
		private var circularShotSpeed: Number = 10;
		private var circularLastShot: Number = 0;
		private var circularShotWait: Number = 750;
		private var circularShotOffSet: Number = 0;
		private var circularShotGap: Number = 1.5; //higher is a tighter spread

		private var archProjLifetime: Number = 1500;
		private var archProjSpeed: Number = 20;
		private var playersAngleFromBoss: Number;

		//phase two vars
		private var phaseTwoAngleToFire: Number;
		private var phaseTwoShotAmount: Number = 20;
		private var phaseTwoShotLifetime: Number = 5000;
		private var phaseTwoShotSpeed: Number = 5;
		private var phaseTwoLastShot: Number = 0;
		private var phaseTwoShotWait: Number = 750;
		private var phaseTwoArchProjLifetime: Number = 500;
		private var phaseTwoArchProjSpeed: Number = 15;
		private var chasePhaseVelMod: Number = 1.5;

		//phase three vars
		private var phaseThreeReady: Boolean = false;
		private var phaseThreeAngle: Number = 0;

		private var phaseThreeAngleToFire: Number;
		private var phaseThreeShotgunAmount: Number = 4;
		private var phaseThreeShotgunLifetime: Number = 3000;
		private var phaseThreeBigSpeed: Number = 25;
		private var phaseThreeMedSpeed: Number = 20;
		private var phaseThreeSmallSpeed: Number = 15;
		private var phaseThreeLastShotgun: Number = 0;
		private var phaseThreeShotgunWait: Number = 1500;
		private var phaseThreeShotgunGap: Number = 4; //higher is a tighter spread

		private var phaseThreeTentacleSpeed: Number = 4;
		private var phaseThreeTentacleLifetime: Number = 8000;
		private var phaseThreeLastTentacleShot: Number = 0;
		private var phaseThreeTentacleWait: Number = 150;
		private var phaseThreeShotAmount: Number = 4;
		private var phaseThreeTentacleAngle: Number;
		private var tentacleOffset: Number = 0;

		private var bossDead: Boolean = false;

		//listens for when added to stage
		public function bossOne(): void {
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
		}

		//sets initial conditions
		public function onAdded(e: Event): void {
			stageObject = MovieClip(root);
			this.x = 0;
			this.y = 0;
			this.width = 100;
			this.height = 100;
			this.alpha = 1;
			this.addEventListener(Event.ENTER_FRAME, updateBoss, false, 0, true);
			difficultyMod = stageObject.difficultyModifier;
			bossHealth = 500;
			bossDead = false;
		}

		//runs the bosses phases
		public function updateBoss(e: Event): void {
			//resets if nessecarys
			if (hasReset) {
				//manages what phase to be in
				if (bossHealth >= phaseOneEnd) {
					attackPatternOne();
				} else if (bossHealth >= phaseTwoEnd) {
					inPhaseTwo = true;
					attackPatternTwo();
				} else if (bossHealth > 0) {
					inPhaseThree = true;
					if (inPhaseTwo && inPhaseThree) {
						inPhaseTwo = false;
						hasReset = false;
					}
					attackPatternThree();
				} else {
					//removes boss and listeners
					bossDead = true;
					removeEventListener(Event.ENTER_FRAME, onAdded);
					removeEventListener(Event.ENTER_FRAME, updateBoss);
					parent.removeChild(this);
				}
				lastHealthCheck = bossHealth;
			} else {
				// for resetting
				roomCentreFromBoss = getAngle(stageObject.circle.x, stageObject.circle.y);
				this.x += 5 * Math.cos(roomCentreFromBoss);
				this.y -= 5 * Math.sin(roomCentreFromBoss);
				if (Math.pow(stageObject.circle.x - this.x, 2) + Math.pow(stageObject.circle.y - this.y, 2) < 10) {
					hasReset = true;
				}
			}
			//stops boss if player dies
			if (stageObject.playersChar.isCharDead()) {
				removeEventListener(Event.ENTER_FRAME, updateBoss);
			}


		}

		//attack pattern one, shoots rings of projectiles
		//with one tracking projectile
		public function attackPatternOne(): void {
			if (circularLastShot + circularShotWait < getTimer()) {
				circularLastShot = getTimer();
				playersAngleFromBoss = getAngle(stageObject.playersChar.x, stageObject.playersChar.y);

				var archProjectile: MovieClip = new bossArchProjectile(stageObject.firstBoss.x, stageObject.firstBoss.y, playersAngleFromBoss, archProjSpeed, archProjLifetime);
				stageObject.bulletholder.addChild(archProjectile);
				for (var i: Number = 0; i < circularShotAmount * difficultyMod; i++) {
					circularAngleToFire = playersAngleFromBoss - Math.PI / 2 + i * 2 * Math.PI / (circularShotAmount * circularShotGap * difficultyMod);
					var projectile: MovieClip = new bossCircleProj(stageObject.firstBoss.x, stageObject.firstBoss.y, circularAngleToFire, circularShotSpeed, circularShotLifetime);
					stageObject.bulletholder.addChild(projectile);
				}
			}
		}

		//chases player, shoots rings of projectiles
		//with one tracking projectile
		public function attackPatternTwo(): void {
			charDistaceFromBossSquared = Math.pow(512 - this.x, 2) + Math.pow(384 - this.y, 2);
			charAngleFromBoss = getAngle(stageObject.playersChar.x, stageObject.playersChar.y);
			if (charDistaceFromBossSquared > 9000) {
				this.x += chasePhaseVelMod * Math.cos(charAngleFromBoss) * Math.pow(charDistaceFromBossSquared, 1 / 6);
				this.y -= chasePhaseVelMod * Math.sin(charAngleFromBoss) * Math.pow(charDistaceFromBossSquared, 1 / 6);
			}
			if (phaseTwoLastShot + phaseTwoShotWait < getTimer()) {
				phaseTwoLastShot = getTimer();

				for (var j: Number = 0; j < phaseTwoShotAmount * difficultyMod; j++) {
					phaseTwoAngleToFire = j * 2 * Math.PI / (phaseTwoShotAmount * difficultyMod);
					var projectile: MovieClip = new bossCircleProj(stageObject.firstBoss.x, stageObject.firstBoss.y, phaseTwoAngleToFire, difficultyMod * phaseTwoShotSpeed, phaseTwoShotLifetime);
					stageObject.bulletholder.addChild(projectile);
				}
				var shortRangeProj: MovieClip = new bossArchProjectile(stageObject.firstBoss.x, stageObject.firstBoss.y, charAngleFromBoss, phaseTwoArchProjSpeed / difficultyMod, phaseTwoArchProjLifetime);
				stageObject.bulletholder.addChild(shortRangeProj);
			}
		}

		//circles room firing shotgun of tracking projectiles
		//tenacles spawn in the centre and rotate anticlockwise
		public function attackPatternThree(): void {
			if (phaseThreeReady) {
				phaseThreeAngle -= Math.PI / 69;
				if (phaseThreeAngle == 2 * Math.PI) {
					phaseThreeAngle = 0;
				}
				this.x = MovieClip(root).circle.x + 300 * Math.cos(phaseThreeAngle);
				this.y = MovieClip(root).circle.y + 300 * Math.sin(phaseThreeAngle);

			} else {
				if (Math.pow(MovieClip(root).circle.x - this.x + 300, 2) + Math.pow(MovieClip(root).circle.y - this.y, 2) < 20) {
					phaseThreeReady = true;
				}
				this.x += 10;
			}

			if (phaseThreeLastTentacleShot + phaseThreeTentacleWait < getTimer()) {
				phaseThreeLastTentacleShot = getTimer();
				tentacleOffset += Math.PI / 100;
				for (var i: Number = 0; i < phaseThreeShotAmount * difficultyMod; i++) {
					phaseThreeTentacleAngle = tentacleOffset + i * 2 * Math.PI / (phaseThreeShotAmount * difficultyMod);
					var projectile: MovieClip = new bossCircleProj(stageObject.circle.x, stageObject.circle.y, phaseThreeTentacleAngle, phaseThreeTentacleSpeed, phaseThreeTentacleLifetime);
					stageObject.bulletholder.addChild(projectile);
				}
			}

			if (phaseThreeLastShotgun + phaseThreeShotgunWait < getTimer()) {
				playersAngleFromBoss = getAngle(stageObject.playersChar.x, stageObject.playersChar.y);
				phaseThreeLastShotgun = getTimer();

				for (var j: Number = 0; j < phaseThreeShotgunAmount * difficultyMod; j++) {
					phaseThreeAngleToFire = playersAngleFromBoss + j * 2 * Math.PI / (phaseThreeShotgunAmount * difficultyMod * phaseThreeShotgunGap);
					var bigArch: MovieClip = new bossArchProjectile(stageObject.firstBoss.x, stageObject.firstBoss.y, phaseThreeAngleToFire, phaseThreeBigSpeed / difficultyMod, phaseThreeShotgunLifetime);
					stageObject.bulletholder.addChild(bigArch);
					var medArch: MovieClip = new bossArchProjMed(stageObject.firstBoss.x, stageObject.firstBoss.y, phaseThreeAngleToFire, phaseThreeMedSpeed / difficultyMod, phaseThreeShotgunLifetime);
					stageObject.bulletholder.addChild(medArch);
					var smallArch: MovieClip = new bossArchProjSmall(stageObject.firstBoss.x, stageObject.firstBoss.y, phaseThreeAngleToFire, phaseThreeSmallSpeed / difficultyMod, phaseThreeShotgunLifetime);
					stageObject.bulletholder.addChild(smallArch);
				}
			}
		}

		//subtracts health accounting for difficulty modifier
		public function subtractHealth(): void {
			bossHealth -= (2 - difficultyMod);
		}

		//will return angle of something from boss
		public function getAngle(xPos: Number, yPos: Number): Number {
			xPos = xPos - this.x;
			yPos = -(yPos - this.y);
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
		
		//returns if the boss is dead
		public function isBossDead(): Boolean {
			return bossDead;
		}

	}
}