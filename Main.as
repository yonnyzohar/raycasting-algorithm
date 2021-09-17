package {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.Event;

	public class Main extends MovieClip {

		var grid: Array = [
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
			[1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		];

		var colors: Array = [0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00, 0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00, 0x0000FF, 0xFF0000, 0xFFFF00, 0x33FF00];

		var TILE_SIZE: int = 50;

		var inc: int = 1;
		var layers: Array = [];

		//var point: Point;
		var bob: Bob;
		var gLayer: Sprite = new Sprite();



		public function Main() {
			// constructor code


			for (var i: int = 0; i < grid.length; i++) {
				for (var j: int = 0; j < grid[i].length; j++) {
					var tileMC: TileMC = new TileMC();
					addChild(tileMC);
					tileMC.width = TILE_SIZE;
					tileMC.height = TILE_SIZE;
					tileMC.x = TILE_SIZE * j;
					tileMC.y = TILE_SIZE * i;
					if (grid[i][j] == 1) {
						tileMC.alpha = 0.5;
					}
				}
			}

			bob = new Bob();
			addChild(bob);
			bob.x = TILE_SIZE * grid[0].length / 2;
			bob.y = TILE_SIZE * grid.length / 2;
			bob.x += TILE_SIZE / 2;
			bob.y += TILE_SIZE / 2;
			addChild(gLayer);


			stage.addEventListener(Event.ENTER_FRAME, update);
			//update();
		}



		function update(e: Event = null): void {

			if (e != null) {
				bob.x = mouseX;
				bob.y = mouseY;
			}


			bob.rotation += inc;
			var totalRadius: int = 0;
			var row: int = bob.y / TILE_SIZE;
			var col: int = bob.x / TILE_SIZE;
			gLayer.graphics.clear();
			var ray: Number = 0;
			for (var i: int = 0; i < 1000; i++) {
				//trace(bob.rotation + ray);
				rayCast(0, totalRadius, bob.rotation + ray, new Point(bob.x, bob.y), gLayer, row, col);
				ray += 0.1;
			}


		}

		function rayCast(color: int, totalRadius: int, _rotation: Number, point: Point, gLayer: Sprite, row: int, col: int): void {
			var found: Boolean = false;
			while (!found) {
				var degAngle: Number = rotFromDeg(_rotation);
				var radAngle: Number = radRotationFromRad((Math.PI / 180) * degAngle);
				var right: Boolean = (radAngle > (Math.PI * 2) * 0.75 || radAngle < (Math.PI * 2) * 0.25);
				var up: Boolean = (radAngle < 0 || radAngle > Math.PI);
				var angleSin: Number = Math.sin(radAngle);
				var angleCos: Number = Math.cos(radAngle);
				var angleTan: Number = Math.tan(radAngle);
				var xPos: int;
				var yPos: int;
				var distToNextX: int;
				var distToNextY: int;
				var destCol: int;
				var destRow: int;

				if (right) {

					destCol = (TILE_SIZE * (col + 1));
					distToNextX = destCol - point.x;
					if (!up) {
						//trace("right down");
						destRow = (TILE_SIZE * (row + 1));
						distToNextY = destRow - point.y;

					} else {
						//trace("right up");
						destRow = (TILE_SIZE * (row));
						distToNextY = point.y - destRow;
					}

				} else {
					destCol = (TILE_SIZE * (col));
					distToNextX = point.x - destCol;

					if (!up) {
						//trace("left down");
						destRow = (TILE_SIZE * (row + 1));
						distToNextY = destRow - point.y;
					} else {
						//trace("left up");
						destRow = (TILE_SIZE * (row));
						distToNextY = point.y - (destRow);
					}
				}
				//trace("distToNextX", distToNextX, "destCol", destCol);
				//trace("distToNextY", distToNextY, "destRow", destRow);

				//if x is closer, we need to figure out how long y needs to be
				var tempDistY: int = angleTan * distToNextX;
				var tempDistX: int = distToNextY / Math.tan(radAngle);

				//now that i have x and y i can get the radius
				var radius1: Number = Math.sqrt(tempDistX * tempDistX + distToNextY * distToNextY);
				var radius2: Number = Math.sqrt(distToNextX * distToNextX + tempDistY * tempDistY);
				var radius: Number;


				radius = Math.min(radius1, radius2);

				//going to hit a row
				var goingToRow: Boolean = radius == radius1;



				xPos = distToNextX; // * angleCos;
				yPos = distToNextY; // * angleSin;

				var newX: Number = Math.ceil((radius * angleCos) + point.x);
				var newY: Number = Math.ceil((radius * angleSin) + point.y);




				if (right) {
					xPos += bob.x;
				} else {
					//newX -= 2;
					xPos = (bob.x - xPos);
				}

				if (up) {
					//newY -= 2;
					yPos = (bob.y - yPos);
				} else {
					yPos += bob.y;
				}


				gLayer.graphics.moveTo(point.x, point.y);
				gLayer.graphics.lineStyle(1, colors[color], 1);
				gLayer.graphics.lineTo(newX, newY);

				var newRow: int = newY / TILE_SIZE;
				var newCol: int = newX / TILE_SIZE;

				if (up) {
					newRow = (newY - 2) / TILE_SIZE;
				}
				if (!right) {
					newCol = (newX - 2) / TILE_SIZE;
				}

				//trace(newY, newX, newRow, newCol);
				if (grid[newRow][newCol] != 1) {
					if (goingToRow) {
						if (up) {
							row--;
						} else {
							row++;
						}
					} else {
						if (right) {
							col++;
						} else {
							col--;
						}
					}

					point = new Point(newX, newY);
					color++;
					totalRadius += radius;
				} else {
					found = true;
					if (goingToRow) {
						newY = newY - (newY % TILE_SIZE);
					} else {
						newX = newX - (newX % TILE_SIZE);
					}

					//trace("found!", (totalRadius + radius), newX, newY, goingToRow);
				}
			}


		}

		function degFromRad(p_radInput: Number): Number {
			var degOutput: Number = (180 / Math.PI) * p_radInput;
			return degOutput;
		}

		function rotFromDeg(p_degInput: Number): Number {
			var rotOutput: Number = p_degInput;
			while (rotOutput > 180) {
				rotOutput -= 360;
			}
			while (rotOutput < -180) {
				rotOutput += 360;
			}
			return rotOutput;
		}

		function radRotationFromRad(radAngle: Number): Number {
			while (radAngle < 0) {
				radAngle += Math.PI * 2;
			}
			while (radAngle > Math.PI * 2) {
				radAngle -= Math.PI * 2;
			}
			return radAngle;
		}

	}

}






//update();