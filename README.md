Delaunay Surface Triangulation
------------------------------

Create a 3D surface using Delaunay triangulation

![delaunay demo](https://raw.github.com/JamesHight/delaunay-surface-triangulation/master/example.png)

````actionscript
public class DelaunayBasicView extends BasicView {
	private var holder:DisplayObject3D;		
	private var urlLoader:URLLoader;
	
	public function DelaunayBasicView() {	
		urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(new URLRequest("assets/fonts/ACTIONIS.TTF"));
		urlLoader.addEventListener(Event.COMPLETE, onComplete);
	}
			
	private function onComplete(event:Event):void {
		var i:uint;
		
		var font3D:Font3D = Font3DLoader.load(urlLoader.data);
		urlLoader = null;
							
		holder = new DisplayObject3D();
		this.scene.addChild(holder);
		
		var textHolder:Surface3D = new Surface3D();
		holder.addChild(textHolder);
		
		var light:PointLight3D = new PointLight3D();
		this.scene.addChild(light);
		light.x = 100;
		light.y = 100;
		light.z = 2000;
		
		var redColor:FlatShadeMaterial = new FlatShadeMaterial(light, 0xff0000);
		redColor.doubleSided = true; 
		
		var blueColor:FlatShadeMaterial = new FlatShadeMaterial(light, 0x0000ff);
		blueColor.doubleSided = true;
		
		var font3DManager:Font3DManager = new Font3DManager(redColor);
		font3DManager.registerFont("Action IS", font3D);
		
		var len:Number = 0;				
		var letter3D:Letter3D;
		var string:String = "Delaunay Demo";
		
		for (i = 0; i < string.length; i++) {
			var char:String = string.charAt(i);
			if (char == " ") {
				len += 28;	
			}
			else {
				letter3D = font3DManager.getLetterMesh(char);
				letter3D.x = len;
				len += letter3D.width;
				textHolder.addChild(letter3D);
			}
		}
		
		textHolder.graphics3D.beginFill(blueColor);
		textHolder.graphics3D.drawRect(0,35, 0, len, 4);			
		textHolder.graphics3D.drawRect(0,25, 0, len, 4);			
		textHolder.graphics3D.endFill();
		
		
		textHolder.x = -(len / 2);
		
		holder.scale = 4;
		holder.y = -200;
		
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(event:Event):void {
		holder.rotationY += (this.viewport.containerSprite.mouseX - holder.rotationY) * .01;
		this.singleRender();
	}
	
}
````
