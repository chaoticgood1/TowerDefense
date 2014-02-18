package framework1_0 
{
	/**
	 * My pathfinder version in ActionScript, mostly copied from my java version, there are still a lot of testing to do, 
	 * like setting some nodes to be occupied(blocked path), but there are some type of nodes that is only hard to travel, 
	 * so this pathfinder is still far from being complete
	 * @author Nickan
	 */
	public class AstarPathFinder  {
		public var tileWidth:uint;
		public var tileHeight:uint;
		
		/* The node maps where should the walkable and unwalkable tiles should be addressed*/
		public var nodeMap:Array;
		
		/* Potentially to be included in the closed list */
		public var openList:Array
		
		/* List of nodes that are having a least movement cost from the starting node to goal node */
		public var closedList:Array;
		
		/* List of nodes done being analyzed for potentially the shortest path */
		public var possibleNextNodeList:Array;
		
		public function AstarPathFinder(tileWidth:uint, tileHeight:uint)  {
			this.tileWidth = tileWidth;
			this.tileHeight = tileHeight;
			
			createNodeMap();
		}
		
		public function createNodeMap(): void {
			nodeMap = new Array();
			for (var height:uint = 0; height < tileHeight; ++height) {
				nodeMap.push(new Array());
				for (var width:uint = 0; width < tileWidth; ++width) {
					nodeMap[height].push(new Node(width, height, Node.FREE));
				}
			}
		}
		
		public function getShortestPath(startX:uint, startY:uint, goalX:uint, goalY:uint) : Array {
			setHeuristics(nodeMap[goalY][goalX]);
			nullifyParents();
			possibleNextNodeList = new Array();			
			
			var loop:uint = 0;
			var loopLimit:uint = 20;
			
			var closedList:Array = new Array();
			
			var beingCheckedNode:Node = nodeMap[startY][startX];
			
			/* Potentially to be included in the closed list */
			openList = new Array();
			while (true) {
			//	var beingCheckedNode:Node = closedList[closedList.length - 1];
			//	var beingCheckedNode:Node = getLowestAdjacentFcostNode(
			
				// Get all the free nodes, including those in the open list, but don't belong in the closed list
				closedList.push(beingCheckedNode);
				var adjacentNodes:Array = getAdjacentFreeNodes(beingCheckedNode, closedList);
				
				analyzeAdjacentNodes(beingCheckedNode, adjacentNodes);
				
				// Get the next next that has the lowest f cost from the adjacent nodes
				var nextCheckNode:Node = getLowestAdjacentFcostNode(beingCheckedNode, adjacentNodes);
				
				beingCheckedNode = nextCheckNode;
				//...
			//	trace("2:" + nextCheckNode.x + ": " + nextCheckNode.y);
				
				if (nextCheckNode.same(goalX, goalY)) {
					trace("2:found! "  + loop);
					break;
				}
				
				++loop;
				if (loop > loopLimit) {
				//	trace("2: Loop break: " + loop);
					break;
				}
			}
			
			return trackParentNode(startX, startY, goalX, goalY);
		}
		
		public function getLowestAdjacentFcostNode(node:Node, list:Array): Node {
			// If there is only one item in the list (more likely in the open list
			if (list.length == 1) { return list.pop(); }
			
			var fCost:uint = uint.MAX_VALUE;
			var lowestFcostNode:Node = null;
			
			for (var index:uint = 0; index < list.length; ++index) {
				var tempNode:Node = list[index];
				
				// If the tempNode being analyzed has the lower f cost compare to the current registed f cost
				// Then save the address of that node to compare against the remaining nodes in the list
				if (tempNode.f < fCost) {
					fCost = tempNode.f;
					lowestFcostNode = tempNode;
				}
			}
			return lowestFcostNode;
		}
		
		/**
		 * Returns the list of nodes adjacent to the node, excluding the node from the closedList and the occupied node
		 * @param	node
		 * @return
		 */
		public function getAdjacentFreeNodes(node:Node, closedList:Array): Array {
			var adjacentNodes:Array = new Array();
			
			var startX:int = node.x - 1;
			var startY:int = node.y - 1;
			
			for (var x:uint = 0; x < 3; ++x) {
				for (var y:uint = 0; y < 3; ++y) {
					
					// Don't include the passed node
					if (x == 1 && y == 1) 
						continue;
					
					// Limits of the node map
					if ( (startX + x >= 0 && startX + x < tileWidth) &&
						(startY + y >= 0 && startY + y < tileHeight) ) {
						
						var tempNode:Node = nodeMap[startY + y][startX + x];
						
						// Is node free and not belong in the closed list
						if (tempNode.type == Node.FREE && !isInArray(tempNode, closedList) ) {
							adjacentNodes.push(tempNode);
						}
					}
					
				}
			}
			
			return adjacentNodes;
		}
		
		public function isInArray(node:Node, nodeList:Array): Boolean {
			for (var index:uint = 0; index < nodeList.length; ++index) {
				if ( nodeList[index].same(node.x, node.y) ) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Analyze and performs needed operation based on the property of the individual adjacent node;
		 * @param	beingCheckedNode
		 * @param	adjacentNodes
		 */
		public function analyzeAdjacentNodes(beingCheckedNode:Node, adjacentNodes:Array): void {
			trace("2:adjacent list length: " + adjacentNodes.length);
			for (var index:uint = 0; index < adjacentNodes.length; ++index) {
				var adjNode:Node = adjacentNodes[index];
				
				var g:uint;
				// The node is not in the open list, set their f cost. Cost of h will be plus 14 if diagonally placed to the
				// being checked node, plus 10 to vertically and horizontally placed
				if (!isInArray(adjNode, openList) ) {
					openList.push(adjNode);
					// Set their parent node
					adjNode.parentNode = beingCheckedNode
					
					// If the beingCheckedNode is diagonally placed, it has to add 14 to the g cost of the adjacent node
					// Otherwise 10
					g = (isPlacedDiagonally(beingCheckedNode, adjNode)) ? 14 : 10;
					adjNode.g = g + beingCheckedNode.g;
					adjNode.f = adjNode.g + adjNode.h;
					
					//...
					trace("2:free list: " + adjNode.x + ": " + adjNode.y + ": " + adjNode.f + " heuristic: " + adjNode.h);
				} else {
					// The tempNode is in the open list, check if the g cost to move to the tempNode from the being checked node
					// is lower than the tempNode's current g cost from the starting node, then change its parent to the being
					// Cheched node and recalculate its g cost
					g = (isPlacedDiagonally(beingCheckedNode, adjNode)) ? 14 : 10;
					if (beingCheckedNode.g + g < adjNode.g) {
						adjNode.g = beingCheckedNode.g + g;
						adjNode.f = adjNode.g + adjNode.h;
						adjNode.parentNode = beingCheckedNode;
						//...
						trace("2:g Cost: " + adjNode.g);
					}
					
					//...
					trace("2:open list: " + adjNode.x + ": " + adjNode.y + ": " + adjNode.f + " heuristic: " + adjNode.h);
				}
			}
		}
		
		public function trackParentNode(startX:uint, startY:uint, goalX:uint, goalY:uint): Array {
			var shortestPath:Array = new Array();
			
			// Add the starting node
			shortestPath.push(nodeMap[goalY][goalX]);
			
			var lastNode:Node = nodeMap[goalY][goalX];
			
			// Loop until the parent is null
			while (true) {
				var parentNode:Node = lastNode.parentNode;
				
				if (parentNode != null) {
					
					shortestPath.push(parentNode);
					lastNode = parentNode;
				} else {
					break;
				}
			}
			
			return shortestPath;
		}
		

		public function setHeuristics(goalNode:Node): void {
			for (var y:uint = 0; y < tileHeight; ++y) {
				for (var x:uint = 0; x < tileWidth; ++x) {
					nodeMap[y][x].h = getHeuristic(x, y, goalNode);
				}
			}
		}
		
		public function nullifyParents(): void {
			for (var y:uint = 0; y < tileHeight; ++y) {
				for (var x:uint = 0; x < tileWidth; ++x) {
					nodeMap[y][x].parentNode = null;
				}
			}
		}
		
		public function getHeuristic(tileX:uint, tileY:uint, goalNode:Node): uint {
			return Math.abs(tileX - goalNode.x) + Math.abs(tileY - goalNode.y);
		}
		
		/**
		 * Returns if the two adjacent nodes if placed diagonally from each other, but make sure that they are really adjacent to each other
		 * @param	basedNode
		 * @param	testNode
		 * @return
		 */
		public function isPlacedDiagonally(basedNode:Node, testNode:Node): Boolean {
			return ( (basedNode.x != testNode.x) && (basedNode.y != testNode.y) ) ? true : false;
		}
		
		public function clear(): void {
			for (var height:uint = 0; height < tileHeight; ++height) {
				for (var width:uint = 0; width < tileWidth; ++width) {
					nodeMap[height][width].type = Node.FREE;
				}
			}
		}
		
	}

}