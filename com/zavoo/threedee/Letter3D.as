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

package com.zavoo.threedee {
	import org.papervision3d.core.proto.MaterialObject3D;

	public class Letter3D extends Surface3D {
		
		public var width:Number;
		public var height:Number;
		
		public function Letter3D(material:MaterialObject3D = null, commands:Array = null, height:Number = 0, width:Number = 0) {
			super(material, null, null);
			
			if ((material == null)
				|| (commands == null)) {
				return;
			}
			
			this.width = width;
			this.height = height;
			
			this.material = material;
			drawLetter(commands);
			
		}
		
		private function drawLetter(commands:Array):void {
			this.graphics3D.beginFill(this.material);
			for (var i:uint = 0; i < commands.length; i++) {					
				switch (commands[i][0]) {
					case "M":					
						this.graphics3D.moveTo(commands[i][1][0], height - commands[i][1][1], 0);
						break;
						
					case "L":
						this.graphics3D.lineTo(commands[i][1][0], height - commands[i][1][1], 0);
						break;
						
					case "C":
						this.graphics3D.curveTo(commands[i][1][0], height - commands[i][1][1], 0,
															commands[i][1][2], height - commands[i][1][3], 0);
						break;
				} 
			}
			this.graphics3D.endFill();
		}
		
		public function duplicate():Letter3D {
			var letter3D:Letter3D = new Letter3D();
			
			letter3D.geometry.faces = this.geometry.faces;
			letter3D.geometry.vertices = this.geometry.vertices;			
			letter3D.width = this.width;
			
			letter3D.geometry.ready = true;
						
			return letter3D;
		}
		
	}
}