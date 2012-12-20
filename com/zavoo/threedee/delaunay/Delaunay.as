/****
	* ported from Florian Jenett's triangulate.java (http://local.wasp.uwa.edu.au/~pbourke/papers/triangulate/triangulate.java)
	* which was ported from Paul Bourke's triangulate.c (http://local.wasp.uwa.edu.au/~pbourke/papers/triangulate/triangulate.c)
	*
	* ported fairly directly, so plenty of room to optimize / utilize AS3-specific syntax
	*
	* @author Zachary Forest Johnson (indiemaps.com/blog or zach.f.johnson@gmail.com)
	* @date May 2008
	*
	* Usage:
	*
	* use the public method triangulate(points) to use your own data
	* points is an array of XYZ instances
	*
****/
package com.zavoo.threedee.delaunay {
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.NumberUV;
		
	public class Delaunay {
		
		public static const EPSILON:Number = 0.000001;
		
		/*
		Return TRUE if a point (xp,yp) is inside the circumcircle made up
		of the points (x1,y1), (x2,y2), (x3,y3)
		The circumcircle centre is returned in (xc,yc) and the radius r
		NOTE: A point on the edge is inside the circumcircle
		*/
		public static function CircumCircle(xp:Number, yp:Number, x1:Number, y1:Number, 
			x2:Number, y2:Number, x3:Number, y3:Number,circle:Vertex3D):Boolean {
				
			var m1:Number, m2:Number, mx1:Number, mx2:Number, my1:Number, my2:Number;
			var dx:Number, dy:Number, rsqr:Number, drsqr:Number;
			var xc:Number, yc:Number, r:Number;
			
			/* Check for coincident points */
			
			if ( Math.abs(y1-y2) < EPSILON && Math.abs(y2-y3) < EPSILON )
			{
				trace("CircumCircle: Points are coincident.");
				return false;
			}
			
			if ( Math.abs(y2-y1) < EPSILON )
			{
				m2 = - (x3-x2) / (y3-y2);
				mx2 = (x2 + x3) / 2.0;
				my2 = (y2 + y3) / 2.0;
				xc = (x2 + x1) / 2.0;
				yc = m2 * (xc - mx2) + my2;
			}
			else if ( Math.abs(y3-y2) < EPSILON )
			{
				m1 = - (x2-x1) / (y2-y1);
				mx1 = (x1 + x2) / 2.0;
				my1 = (y1 + y2) / 2.0;
				xc = (x3 + x2) / 2.0;
				yc = m1 * (xc - mx1) + my1;	
			}
			else
			{
				m1 = - (x2-x1) / (y2-y1);
				m2 = - (x3-x2) / (y3-y2);
				mx1 = (x1 + x2) / 2.0;
				mx2 = (x2 + x3) / 2.0;
				my1 = (y1 + y2) / 2.0;
				my2 = (y2 + y3) / 2.0;
				xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
				yc = m1 * (xc - mx1) + my1;
			}
			
			dx = x2 - xc;
			dy = y2 - yc;
			rsqr = dx*dx + dy*dy;
			r = Math.sqrt(rsqr);
			
			dx = xp - xc;
			dy = yp - yc;
			drsqr = dx*dx + dy*dy;
			
			circle.x = xc;
			circle.y = yc;
			circle.z = r;
			
			return ( drsqr <= rsqr ? true : false );
		}
		
		/*
		Triangulation subroutine
		
		Takes as input, an array of vertices in pxyz
		each vertex should be an instance of the XYZ class
		
		Returned is an array of triangular faces in the array v
		These triangles are arranged in a consistent clockwise order.
		The triangle array 'v' should be malloced to 3 * nv
		The vertex array pxyz must be big enough to hold 3 more points
		The vertex array must be sorted in increasing x values say
		*/
		public static function triangulate(triangleMesh3D:TriangleMesh3D, pxyz:Array):Array {
						
			var v:Array=new Array();
			var nv:uint = pxyz.length;
			
			for (i=0; i < (nv*3); i++) {
				v[i] = new Triangle3D(triangleMesh3D, new Array(), triangleMesh3D.material, [new NumberUV(0,0),new NumberUV(0,0),new NumberUV(0,0)]);
				v[i].renderCommand.create = triangleMesh3D.createRenderTriangle;
			}
			
			// the points must be sorted on the x dimension for the rest to work
			pxyz.sortOn("x", Array.NUMERIC);
			var complete:Array 		= null;
			var 	edges:Array 		= null;
			var 	nedge:int 			= 0;
			var 	trimax:int, emax:int 	= 200;
			var 	status:int 			= 0;
			
			var	inside:Boolean;
			var 	xp:Number, yp:Number, x1:Number, y1:Number, x2:Number, y2:Number; 
			var		x3:Number, y3:Number, xc:Number, yc:Number, r:Number;
			var 	xmin:Number, xmax:Number, ymin:Number, ymax:Number, xmid:Number, ymid:Number;
			var 	dx:Number, dy:Number, dmax:Number;
			
			var		ntri:Number = 0;
			
			/* Allocate memory for the completeness list, flag for each triangle */
			trimax = 4*nv;
			complete = new Array();
			for (var ic:uint=0; ic<trimax; ic++) complete[ic] = false;
			
			/* Allocate memory for the edge list */
			edges = new Array();
			for (var ie:uint=0; ie<emax; ie++) edges[ie] = new Edge();
			
			/*
			Find the maximum and minimum vertex bounds.
			This is to allow calculation of the bounding triangle
			*/
			xmin = pxyz[0].x;
			ymin = pxyz[0].y;
			xmax = xmin;
			ymax = ymin;
			for (var i:uint=1;i<nv;i++)
			{
				if (pxyz[i].x < xmin) xmin = pxyz[i].x;
				if (pxyz[i].x > xmax) xmax = pxyz[i].x;
				if (pxyz[i].y < ymin) ymin = pxyz[i].y;
				if (pxyz[i].y > ymax) ymax = pxyz[i].y;
			}
			dx = xmax - xmin;
			dy = ymax - ymin;
			dmax = (dx > dy) ? dx : dy;
			xmid = (xmax + xmin) / 2.0;
			ymid = (ymax + ymin) / 2.0;
			
			/*
				Set up the supertriangle
				This is a triangle which encompasses all the sample points.
				The supertriangle coordinates are added to the end of the
				vertex list. The supertriangle is the first triangle in
				the triangle list.
			*/
			pxyz[nv] = new Vertex3D();
			pxyz[nv+1] = new Vertex3D();
			pxyz[nv+2] = new Vertex3D();
			
			pxyz[nv+0].x = xmid - 2.0 * dmax;
			pxyz[nv+0].y = ymid - dmax;
			pxyz[nv+0].z = 0.0;
			pxyz[nv+1].x = xmid;
			pxyz[nv+1].y = ymid + 2.0 * dmax;
			pxyz[nv+1].z = 0.0;
			pxyz[nv+2].x = xmid + 2.0 * dmax;
			pxyz[nv+2].y = ymid - dmax;
			pxyz[nv+2].z = 0.0;
			
			v[0].v0 = pxyz[nv];
			v[0].v1 = pxyz[nv+1];
			v[0].v2 = pxyz[nv+2];
			
			//UV mapping, Ignoring z-axis for now
			Triangle3D(v[0]).uv0.u = (v[0].v0.x - xmin) / dx;
			Triangle3D(v[0]).uv0.v = (v[0].v0.y - ymin) / dy;
			Triangle3D(v[0]).uv1.u = (v[0].v1.x - xmin) / dx;
			Triangle3D(v[0]).uv1.v = (v[0].v1.y - ymin) / dy;
			Triangle3D(v[0]).uv2.u = (v[0].v2.x - xmin) / dx;
			Triangle3D(v[0]).uv2.v = (v[0].v2.y - ymin) / dy;
			
			complete[0] = false;
			ntri = 1;
			
			/*
				Include each point one at a time into the existing mesh
			*/
			for (i=0;i<nv;i++) {
				
				xp = pxyz[i].x;
				yp = pxyz[i].y;
				nedge = 0;
				
				/*
					Set up the edge buffer.
					If the point (xp,yp) lies inside the circumcircle then the
					three edges of that triangle are added to the edge buffer
					and that triangle is removed.
				*/
				var circle:Vertex3D = new Vertex3D();
				for (var j:uint=0;j<ntri;j++)
				{
					if (complete[j])
						continue;
						
					x1 = v[j].v0.x;
					y1 = v[j].v0.y;
					x2 = v[j].v1.x;
					y2 = v[j].v1.y;
					x3 = v[j].v2.x;
					y3 = v[j].v2.y;
					
					inside = CircumCircle( xp, yp,  x1, y1,  x2, y2,  x3, y3,  circle );
					xc = circle.x; yc = circle.y; r = circle.z;
					if (xc + r < xp) complete[j] = true;
					if (inside)
					{
						/* Check that we haven't exceeded the edge list size */
						if (nedge+3 >= emax)
						{
							trace("crazy if statement");
							emax += 100;
							var edges_n:Array = new Array();
							for (ie=0; ie<emax; ie++) edges_n[ie] = new Edge();
							for (var zfj:uint=0; zfj<edges.length; zfj++) {
								edges_n[zfj] = edges[zfj];
							}
							edges = edges_n;
						}
						edges[nedge+0].v0 = v[j].v0;
						edges[nedge+0].v1 = v[j].v1;
						edges[nedge+1].v0 = v[j].v1;
						edges[nedge+1].v1 = v[j].v2;
						edges[nedge+2].v0 = v[j].v2;
						edges[nedge+2].v1 = v[j].v0;
						
						nedge += 3;
						v[j].v0 = v[ntri-1].v0;
						v[j].v1 = v[ntri-1].v1;
						v[j].v2 = v[ntri-1].v2;
						
						Triangle3D(v[j]).uv0.u = (v[j].v0.x - xmin) / dx;
						Triangle3D(v[j]).uv0.v = (v[j].v0.y - ymin) / dy;
						Triangle3D(v[j]).uv1.u = (v[j].v1.x - xmin) / dx;
						Triangle3D(v[j]).uv1.v = (v[j].v1.y - ymin) / dy;
						Triangle3D(v[j]).uv2.u = (v[j].v2.x - xmin) / dx;
						Triangle3D(v[j]).uv2.v = (v[j].v2.y - ymin) / dy; 
						
						complete[j] = complete[ntri-1];
						ntri--;
						j--;
					}
				}
				
				/*
					Tag multiple edges
					Note: if all triangles are specified anticlockwise then all
					interior edges are opposite pointing in direction.
				*/
				for (j=0;j<nedge-1;j++)
				{
					//if ( !(edges[j].p1 < 0 && edges[j].p2 < 0) )
						for (var k:uint=j+1;k<nedge;k++)
						{
							if ((edges[j].v0 === edges[k].v1) && (edges[j].v1 === edges[k].v0))
							{
								edges[j].v0 = null;
								edges[j].v1 = null;
								edges[k].v0 = null;
								edges[k].v1 = null;
							}
							/* Shouldn't need the following, see note above */
							if ((edges[j].v0 === edges[k].v0) && (edges[j].v1 === edges[k].v1))
							{
								edges[j].v0 = null;
								edges[j].v1 = null;
								edges[k].v0 = null;
								edges[k].v1 = null;
							}
						}
				}
				
				/*
					Form new triangles for the current point
					Skipping over any tagged edges.
					All edges are arranged in clockwise order.
				*/
				for (j=0;j<nedge;j++)
				{
					if (edges[j].v0 == null || edges[j].v1 == null)
						continue;
					if (ntri >= trimax) return null;
					v[ntri].v0 = edges[j].v0;
					v[ntri].v1 = edges[j].v1;
					v[ntri].v2 = pxyz[i];		
					
					Triangle3D(v[ntri]).uv0.u = (v[ntri].v0.x - xmin) / dx;
					Triangle3D(v[ntri]).uv0.v = (v[ntri].v0.y - ymin) / dy;
					Triangle3D(v[ntri]).uv1.u = (v[ntri].v1.x - xmin) / dx;
					Triangle3D(v[ntri]).uv1.v = (v[ntri].v1.y - ymin) / dy;
					Triangle3D(v[ntri]).uv2.u = (v[ntri].v2.x - xmin) / dx;
					Triangle3D(v[ntri]).uv2.v = (v[ntri].v2.y - ymin) / dy;	 
					complete[ntri] = false;
					ntri++;
				}
			}
			
			/*
				Remove triangles with supertriangle vertices
				These are triangles which have a vertex number greater than nv
			*/
			for (i=0;i<ntri;i++)
			{
				if (pxyz.indexOf(v[i].v0) >= nv || pxyz.indexOf(v[i].v1) >= nv || pxyz.indexOf(v[i].v2) >= nv)
				{
					v[i] = v[ntri-1];
					ntri--;
					i--;
				}
			}
			
			while (v.length > ntri) {
				v.pop();
			}
			v.length = ntri;
			pxyz.length -= 3;
			
			/* pxyz.pop();
			pxyz.pop();
			pxyz.pop();
 			*/
 						
			return v;
		}		
	}
}