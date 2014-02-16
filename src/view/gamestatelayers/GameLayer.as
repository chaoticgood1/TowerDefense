package view.gamestatelayers 
{
	import citrus.utils.objectmakers.ObjectMakerStarling;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import model.Cannon;
	import model.Zombie;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.TextureAtlas;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Nickan
	 */
	public class GameLayer extends Sprite {
		private var cannon:Cannon;
		private var zombie:Zombie;
		
		[Embed(source="../../../assets/images.png")]
		private var BitmapAtlas:Class;
		private var bitmapAtlas:Bitmap = new BitmapAtlas();
		
		[Embed(source="../../../assets/images.xml", mimeType="application/octet-stream")]
		private var BitmapAtlasXml:Class;
	
		private var textureAtlas:TextureAtlas;
		
		[Embed(source="../../../assets/allgameimages.png")]
		private var AllBmp:Class;
		private var allBmp:Bitmap = new AllBmp();
		
		{	// The background
		[Embed(source="../../../assets/tiledmap.png")]
		private var TiledMapImage:Class;
		
		[Embed(source="../../../assets/tiledmap.tmx", mimeType="application/octet-stream")]
		private var TiledMapTmx:Class;
		
		[Embed(source="../../../assets/tiledmap.xml", mimeType="application/octet-stream")]
		private var TiledMapXml:Class;
		}
		
		public function GameLayer()  {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(): void {
			initializeBackground();
			
			bitmapAtlas = new BitmapAtlas();
			textureAtlas = new TextureAtlas(Texture.fromBitmap(new BitmapAtlas()), XML(new BitmapAtlasXml()));
			cannon = new Cannon(textureAtlas.getTexture("normalcannon"));
			cannon.setPosition(3, 3);
			
			var aniRect:Rectangle = new Rectangle(0, 192, 480, 32);
			var zomAniBmpData:BitmapData = new BitmapData(480, 32); 
			zomAniBmpData.copyPixels(allBmp.bitmapData, aniRect, new Point());
			
			zombie = Zombie.newInstance(zomAniBmpData, new Rectangle(5, 5, 32, 32));
			
			addChild(cannon);
			addChild(zombie);
			
			//...
			trace("2: " + zombie.x);
			trace("2: " + zombie.y);
		}
		
		private function initializeBackground(): void {
			var tiledMapAtlas:TextureAtlas = new TextureAtlas(Texture.fromBitmap(new TiledMapImage()), XML(new TiledMapXml()));
			ObjectMakerStarling.FromTiledMap(XML(new TiledMapTmx()), tiledMapAtlas);
		}
		
		public function update(timeDelta:Number): void {
			zombie.update(timeDelta);
		}
		
	}

}