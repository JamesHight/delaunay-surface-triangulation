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

package com.zavoo.threedee.delaunay {
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	
	public class Polygon {
		
		public var points:Array = new Array();
		public var subPolygons:Array = new Array();
		
		
		public function Polygon() {
			
		}
		
		public function containsVertex3D(vertext3D:Vertex3D):Boolean {
			var i:uint;
			var j:uint = points.length - 1; //Number of sides
			var odd:Boolean = false
						
			for (i=0; i < points.length; i++) {
				if ( (points[i].y < vertext3D.y) && (points[j].y >= vertext3D.y)
					||  points[j].y < vertext3D.y && points[i].y >= vertext3D.y) {
					if ((points[i].x + (vertext3D.y - points[i].y)/ (points[j].y - points[i].y) *(points[j].x - points[i].x)) < vertext3D.x) {
						odd =!odd;
					}
				}
			    j=i; 
			}
			
			return odd;
		}
				
		public function containsTriangle3D(triangle3D:Triangle3D):Boolean {
			var vertex3D:Vertex3D = new Vertex3D();
			vertex3D.x = (triangle3D.v0.x + triangle3D.v1.x + triangle3D.v2.x) / 3;
			vertex3D.y = (triangle3D.v0.y + triangle3D.v1.y + triangle3D.v2.y) / 3; 
			return containsVertex3D(vertex3D);			
		}
	}
}