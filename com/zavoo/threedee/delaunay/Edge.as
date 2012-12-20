package com.zavoo.threedee.delaunay
{
	import org.papervision3d.core.geom.renderables.Vertex3D;
	
	public class Edge
	{		
		public var v0:Vertex3D, v1:Vertex3D; // the two points that form the edge (references key positions in a points array)
		public var tris:Array; // an array of the one or two triangles that share the edge (key)
		public var numTris:uint = 0; // how many tris the edge is a part of (either one or two)
		public var interPoints:Array; // an array of all the interpolated points on this edge
		
		public function Edge(v0:Vertex3D=null, v1:Vertex3D=null) {
			if ((v0 == null) || (v1 == null)) {
				this.v0 = this.v1 = null;
			} else {
				this.v0 = v0;
				this.v1 = v1;
			}
		}

	}
}