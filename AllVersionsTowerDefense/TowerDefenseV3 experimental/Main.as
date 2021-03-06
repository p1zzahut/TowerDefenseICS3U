﻿package 
{


	//Import code:
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;


	public class Main extends MovieClip
	{
		//declare constants
		const enemyStartX:int = 78;
		const enemyStartY:int = 23;

		//declare variables
		var numberEnemies:int = 15;//number of enemies in level
		var moveSpeed:int = 5; //how fast the enemies go (NOTE 5 IS THE MAX SPEED)
		var currentGold:int = 100;//how much gold you have
		var isDragging:Boolean = false; //true when object is being dragged (not yet dropped)
		var currTile: Tile1; //current tile
		var currTower: Tower; //current tower
		var currGold: int; //current gold

		//declare arrays
		var level:Array = new Array();//2D array for tiles on the map
		var enemies:Array = new Array();//1D array for enemies 
		var wayPointsX:Array = new Array();//points on the path where the enemies turn
		var wayPointsY:Array = new Array();//points on the path where the enemies turn
		var nonPlaceableTiles = new Array(); //where towers cannot be placed
		var towers = new Array(); //array of placed towers
		
		public function Main()
		{
				//intiialize function is called in the level's keyframe
		}

		//INITIALIZE FUNCTION: starts the game
		function init():void
		{
			
			//add the event listeners
			stage.addEventListener(Event.ENTER_FRAME,onEnterFrameHandler);
			btnTower1.addEventListener(MouseEvent.MOUSE_UP, btnTowerHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler); //listens for when mouse clicks stage
			
			//NOTE: The size of the level background has been changed to 850 by 600 to make room for shop
			//1 represents tiles where enemies walk, 0 represents tiles where towers are built
			level = [
		   //0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
			[0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],//0
			[0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],//1
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0],//2
			[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],//3
			[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0],//4
			[0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],//5
			[0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0],//6
			[0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0],//7
			[0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0],//8
			[0,1,0,0,0,0,1,0,0,1,1,1,1,1,1,1,0],//9
			[0,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0],//10
			[0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1] //11
			];

			//set waypoints
			wayPointsX = [1,15,15,1,1,6,6,15,15,9,9,16];
			wayPointsY = [2,2,4,4,10,10,6,6,9,9,11,11];

			//set all waypoints to actual coordinates on the stage
			for (var i: int = 0; i < wayPointsX.length; i ++)
			{
				wayPointsX[i] = wayPointsX[i] * 50 + 25;
				wayPointsY[i] = wayPointsY[i] * 50 + 25;
			}
			//Create the tile structure of the map
			BuildMap();

			//Spawn enemies for however many there are in the level
			
			
			for (var i:int = 0; i < numberEnemies; i++)
			{
				//send the coordiantes of starting position to the function
				//the y coordinate that is sent spawns each enemy slightly furthre back
				SpawnEnemy(enemyStartX, enemyStartY * i- 1000); 
			}
		
			
		}

		//function that uses the preset tiles in the array to actually create the map
		function BuildMap():void
		{
			for (var i:int =0; i < level.length; ++i)
			{//nested for loop to go through entire index of level array
				for (var j:int =0; j < level[i].length; ++j)
				{
					var tmpTile:Tile1 = new Tile1();
					tmpTile.x = j * 50;//set the x and y coordinates of the tiles
					tmpTile.y = i * 50;

					addChild(tmpTile);//add the tile to the stage  //REMOVE THIS LATER AS IT INTERFERES WITH THE ACTUAL BACKGROUND
					tmpTile.gotoAndStop(level[i][j]+1);
					//set the frame of the tile according to the value in the 2D array;
					// + 1 is because the frames values start as 1 whereas array values start at 0
					
					//add nonplaceable tiles to an array (all non placeable tiles lie on the path where the monsters walk, this path is set as 1 in the 2D level array)
					if(level[i][j] == 1)
					{
						nonPlaceableTiles.push(tmpTile); //add to array of nonPlaceableTiles
						
					}
					tmpTile.addEventListener(MouseEvent.ROLL_OVER, turnOnTile); // create event listeners for these tiles
					tmpTile.addEventListener(MouseEvent.ROLL_OUT, turnOffTile);
				}
				
			}
		}

		//function that creates enemies
		function SpawnEnemy(xpos:int, ypos:int)
		{
			var tmpEnemy:Enemy = new Enemy();
			tmpEnemy.x = xpos;//set coordiantes of enemy spawn
			tmpEnemy.y = ypos;
			addChild(tmpEnemy);//add enemy to stage
			enemies.push(tmpEnemy); //add newly created enemy to array of enemies;
		}
		
		//function that moves ONE enemy
		function moveEnemy(tmpEnemy:Enemy,i:int):void
		{
			var dist_x:Number = wayPointsX[tmpEnemy.nextWayPoint] - tmpEnemy.x;//distance between the monster
			var dist_y:Number = wayPointsY[tmpEnemy.nextWayPoint] - tmpEnemy.y;//and the nextWayPoint
			//when monster collides with a waypoint, increase next way point
			if (Math.abs(dist_y) + Math.abs(dist_x) < 3)
			{
				tmpEnemy.nextWayPoint += 1;
			}
			var angle:Number = Math.atan2(dist_y,dist_x);//compute the angle of the monster
			tmpEnemy.x +=  moveSpeed * Math.cos(angle);//update the x position
			tmpEnemy.y +=  moveSpeed * Math.sin(angle);//update the y position
			tmpEnemy.rotation = angle / Math.PI * 180;//rotate the monster
			
			//remove the enemy if it touches the last wayPoint
			if (tmpEnemy.x >= 850)
			{
				removeChild(tmpEnemy);
				enemies.splice(i,1);
			}
			
			//remove the enemy if its hp becomes 0
			if (tmpEnemy.hp <= 0)
			{
				currentGold +=  tmpEnemy.gold; //add to current gold for howmuch the enemy is worth
				removeChild(tmpEnemy); //remove the enemy from the stage
				enemies.splice(i,1); //remove the enemy from the array
			}
		}

		//ON ENTER FRAME (refreshes each frame
		function onEnterFrameHandler(event:Event)
		{
			//move each enemy every frame 
			for (var i:int =0; i< enemies.length; ++i)
			{
				moveEnemy(enemies[i],i);
			}
			
			if(currTower != null)
			{
				currTower.x = mouseX;
				currTower.y = mouseY;
			}
		}
		
		//function that is called when mouse rolls over a tile
		function turnOnTile(event:MouseEvent)
		{

			//stores the current target of the mouse in a variable called currTile
			currTile = event.currentTarget as Tile1;
			//if the targeted tile is placeable (see canPlace function), and it exists on the stage, change the tile to grey ---------------------------~
			if (canPlace(currTile) == true  && currTile != null)
				{
					currTile.gotoAndStop(3);	
				}
				
			
		}
		
		//function that is caleld when mouse rolls off a tile
		function turnOffTile(event:MouseEvent)
		{
			//when the mouse is rolled off a tile, set it back to its original frame
			var prevTile = event.currentTarget as Tile1;

			if (prevTile.currentFrame == 3)
			{
				prevTile.gotoAndStop(1);
			}
		}
	
		//this function checks if a tower can be placed, returns true if it can, false if it cannot THIS IS THE ERROR 
		function canPlace(tmpTile:Tile1):Boolean
		{
			for (var i:int = 0; i < nonPlaceableTiles.length; i++)
				 {
					 if (nonPlaceableTiles[i] == tmpTile)
					 {
						 return false;
					 }
				 }
			return true;
			
		}
		
		//this function is called when the tower button is pressed
		function btnTowerHandler(event:MouseEvent)
		{
			//check if there is already a current tower
			if (currTower == null)
			{
				//create a new current tower
				currTower = new Tower();
				addChild(currTower); //add current tower to stage
			}
			
		}
		
		//this function is called when the mouse is clicked on the stage
		function onMouseDownHandler(event:MouseEvent)
		{
			trace(canPlace(currTile));
			trace(currTile);
				  
				  
			if (currTile != null)
			{
				if (canPlace(currTile))
				{
					currTower = null;
				nonPlaceableTiles.push(currTile);
				currTower.x = currTile.x + currTile.width /2;
				currTower.y = currTile.y + currTile.width /2;
				towers.push(currTower); 
				}
			}
			
		}
	}
}