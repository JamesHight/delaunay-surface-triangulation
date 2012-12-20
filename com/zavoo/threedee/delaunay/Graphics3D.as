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
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.utils.MaterialsList;
	
	public class Graphics3D {
		
		public static const EPSILON:Number = 0.000001;
		
		/**
		 * Vertex3D points defining object outline
		 **/
		public var _points:Array;
		
		/**
		 * Delaunay triangles referencing _points
		 **/
		public var _triangles:Array;
		
		/**
		 * location of drawing pointer
		 **/		
		private var _currentPoint:Vertex3D = new Vertex3D();
		
		private var _target:TriangleMesh3D;
		
		private var _materialList:MaterialsList;	
		
		private var _polygons:Polygons;	
		private var _polygon:Polygon;
		
		/**
		 * Number of line segments per quadratic bezier curve
		 **/
		public var linesPerCurve:uint = 4; 
		
		/**
		 * Depth of the extrusion along the z-axis
		 **/
		//public var depth:Number = 0;
		
		
		public function Graphics3D(target:TriangleMesh3D) {
			this._target = target;
			this._points = new Array();
		}
				
		public function beginFill(material:MaterialObject3D):void {
			_polygons = new Polygons();			
			this._target.material = material;
		}
		
		
		public function drawRect(x:Number, y:Number, z:Number, width:Number, height:Number):void {
			this.moveTo(x, y, z);
			this.lineTo(x + width, y, z);
			this.lineTo(x + width, y + height, z);
			this.lineTo(x, y + height, z);
		}
		
		public function curveTo(x:Number, y:Number, z:Number, anchorX:Number, anchorY:Number, anchorZ:Number):void {
			var t:Number;
			var currentX:Number = this._currentPoint.x;
			var currentY:Number = this._currentPoint.y;
			var currentZ:Number = this._currentPoint.z;
			
			var nextX:Number;
			var nextY:Number;
			var nextZ:Number;
			
			for (var i:uint = 1; i <= this.linesPerCurve; i++) {
				t = i / this.linesPerCurve;
				
				nextX = (1 - t) * (1 - t) * currentX  + 2 * t * (1 - t) * x + t*t* anchorX;
				nextY = (1 - t) * (1 - t) * currentY  + 2 * t * (1 - t) * y + t*t* anchorY;
				nextZ = (1 - t) * (1 - t) * currentZ  + 2 * t * (1 - t) * z + t*t* anchorZ;
				
				this.lineTo(nextX, nextY, nextZ);
			}			
		}
		
		public function endFill():void {			
			
			this.storeCurrentPoint();
			
			if (this._points.length < 2) {
				return;
			}
			
			this._triangles = Delaunay.triangulate(this._target, this._points);	
				
			trimTriangles();
			
			this._target.geometry.vertices = this._points;
			this._target.geometry.faces = this._triangles;			
			this._target.geometry.ready = true; 
			
			
			for (var i:uint = 0; i < this._triangles.length; i++) {				
				this._triangles[i].createNormal();				
			} 	
							
		}	
		
		/**
		 * Remove trinagles that are outside of a main polygon or inside of a subpolygon
		 **/
		private  function trimTriangles():void {
			//FIXME:  Need a better method for finding holes. Some triangles are missed.
			
			var tmp:Array = new Array();
			
			var i:uint;
			var j:uint;
			var k:uint;
			
			var hole:Boolean;
			var outside:Boolean;
						
			for (i = 0; i < _triangles.length; i++) {
				outside = true;
				for (j = 0; j < _polygons.polygons.length; j++) {
					if (_polygons.polygons[j].containsTriangle3D(_triangles[i])) {
						outside = false;
						hole = false;
						for (k = 0; k < _polygons.polygons[j].subPolygons.length; k++) {
							if (_polygons.polygons[j].subPolygons[k].containsTriangle3D(_triangles[i])) {
								hole = true;
							}
						}
						if (hole) {
							break;
						}
					}
					if (!outside) {
						break;
					}
				}
				
				if (!outside && !hole) {
					tmp.push(_triangles[i]);
				}
			}
			_triangles = tmp;
		}
				
		public function lineTo(x:Number, y:Number, z:Number):void {
			//trace("Line To: " + x.toString() + ", " + y.toString());			
			this.updateCurrentPoint(x, y, z);
			this.storeCurrentPoint();
			//this._points.push(this._currentPoint.clone());
		}
		
		public function updateCurrentPoint(x:Number, y:Number, z:Number):void {
			this._currentPoint.x = x;
			this._currentPoint.y = y;
			this._currentPoint.z = z;
		}
		
		public function moveTo(x:Number, y:Number, z:Number):void {					
			
			//trace("Move: " + x.toString() + ", " + y.toString());
			this.updateCurrentPoint(x, y, z);
			
			_polygon = _polygons.create(this._currentPoint);			
			this.storeCurrentPoint();			
			
		}
		
		private function storeCurrentPoint():void {
			if (this._points.length > 0) {
				var vertex3D:Vertex3D = this._points[this._points.length - 1]; 
				if ((vertex3D.x == this._currentPoint.x)
				&& (vertex3D.y == this._currentPoint.y)
				&& (vertex3D.z == this._currentPoint.z)) {
					//Point already stored
					return;
				}
			}	
			
			var newPoint:Vertex3D = this._currentPoint.clone();
			this._points.push(newPoint);
			_polygon.points.push(newPoint);			
		} 
		
		
		
		
		
		

	}
}