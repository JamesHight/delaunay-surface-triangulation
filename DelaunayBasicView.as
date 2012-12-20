/*
Copyright (c) 2008 James Hight

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package
{
	import com.zavoo.threedee.fonts.Font3DManager;
	import com.zavoo.threedee.Letter3D;
	import com.zavoo.threedee.Surface3D;
	import com.zavoo.threedee.fonts.Font3DLoader;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.typography.Font3D;
	import org.papervision3d.view.BasicView;

	public class DelaunayBasicView extends BasicView
	{
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
}