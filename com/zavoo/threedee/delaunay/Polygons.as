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
	import org.papervision3d.core.geom.renderables.Vertex3D;
	
	public class Polygons {
		public var polygons:Array = new Array();
		
		public function Polygons() {
			
		}
		
		public function create(startPoint:Vertex3D):Polygon {
			var polygon:Polygon = new Polygon();
			//FIXME:  Add recursion support for nested polygons 
			for (var i:uint = 0; i < polygons.length; i++) {
				if (polygons[i].containsVertex3D(startPoint)) {
					polygons[i].subPolygons.push(polygon);
					return polygon;
				}
			}
			polygons.push(polygon);
			return polygon;
		}
	}
}