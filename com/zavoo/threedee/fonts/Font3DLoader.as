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

package com.zavoo.threedee.fonts {
	import flash.utils.ByteArray;
	
	import org.papervision3d.typography.Font3D;
	import org.sepy.fontreader.TFont;
	import org.sepy.fontreader.TFontCollection;
	import org.sepy.fontreader.geom.Glyph;
	import org.sepy.fontreader.geom.GlyphPoint;
	import org.sepy.fontreader.table.CmapFormat;
	import org.sepy.fontreader.table.CmapIndexEntry;
	import org.sepy.fontreader.table.CmapTable;
	
	public class Font3DLoader {		
		public static const TWIPS:uint = 20;
		
		/**
		 * @param bytes ByteArray of TrueType font
		 * 
		 * @param fontRange Range of unicode font characters to load (32 - fontRange)
		 **/
		public static function load(bytes:ByteArray, fontRange:uint = 256):Font3D {
			var i:int;
			var glyph:Glyph;
			var cmapIndexEntry:CmapIndexEntry;
			var char:String;
			
			var dynamicFont3D:DynamicFont3D = new DynamicFont3D();
			
			var tFontCollection:TFontCollection = new TFontCollection();
			tFontCollection.readBytes(bytes);
			
			//There can be more than one font in a file.
			//This just retrieves the first font in the file		
			var tFont:TFont = tFontCollection.getFont(0);
			
			var cmapTable:CmapTable = tFont.getCmapTable();			
			var cmapFormat:CmapFormat = cmapTable.getCmapFormat(3, 1); //Microsoft, Unicode
			
			dynamicFont3D.setHeight((tFont.getHeadTable().getYMax() - tFont.getHeadTable().getYMin()) / TWIPS);
						
			var numGlyphs:int = tFont.getNumGlyphs();
			
			for (i = 32; i < fontRange; i++) { 
				var glyphIndex:int = cmapFormat.mapCharCode(i);
				if (glyphIndex >= 0) {
					glyph = tFont.getGlyph(glyphIndex);
					if (glyph != null) {
						char = String.fromCharCode(i);
						createFont3DGlyphs(char, glyph, dynamicFont3D);						
					}						
				}
			}	
			
			//Create space
			dynamicFont3D.setMotif(" ", []);
			//Bad hack, char(32) glyph is null, tFont.getHeadTable().getXMax() - tFont.getHeadTable().getXMin() is way to large
			if (dynamicFont3D.widths.hasOwnProperty("e")) {
				dynamicFont3D.setWidth(" ", dynamicFont3D.widths["e"]); 	
			}
			else {  
				dynamicFont3D.setWidth(" ", 28); 
			}
			
			return dynamicFont3D;
			
		}
		
		private static function createFont3DGlyphs(char:String, glyph:Glyph, dynamicFont3D:DynamicFont3D):void {
			
			//The Glyph y-axis is flipped from that of papervision. papervisionY = dynamicFont3D.height - glyphY;
			 
			//Points in the fonts are stored as integers (the same as a SWF)
			//so we need to divide all numbers by TWIPS to get the floating point equivalent.	
					
			
			dynamicFont3D.setWidth(char, glyph.getAdvanceWidth() / TWIPS);
			
			var commands:Array = new Array();
			
			var points:Array = glyph._points;
			
			//Start Point Parser
			
			var pointPos:uint = 0;
			
			var point:GlyphPoint;
			var nextPoint:GlyphPoint;
			var nextPoint2:GlyphPoint;
			
			var first:Boolean = true;
			var firstPoint:GlyphPoint;
			
			
			for (pointPos = 0; pointPos < (points.length - 1); pointPos++) {				
				
				point = GlyphPoint(points[pointPos]);
				nextPoint = GlyphPoint(points[pointPos + 1]);
				
				if (nextPoint.endOfContour
					|| ((pointPos + 2) == points.length)) {
					nextPoint2 = firstPoint;		
				}
				else {
					nextPoint2 = GlyphPoint(points[pointPos + 2]);
				}
				
				
				if (first) {
					//this.moveTo(point.x, point.y);
					commands.push(['M', [point.x / TWIPS, (dynamicFont3D.height - point.y) / TWIPS]]);
					firstPoint = point;
					first = false;
				}		
				
				if (point.endOfContour) {
					///Should happen on straight line segments
					//end of curved segments should be handled below
					first = true;
					//this.lineTo(firstPoint.x, firstPoint.y);
					commands.push(['L', [firstPoint.x / TWIPS, (dynamicFont3D.height - firstPoint.y) / TWIPS]]);
				}
				
				if (point.onCurve && nextPoint.onCurve) {
					//this.lineTo(nextPoint.x, nextPoint.y);
					commands.push(['L', [nextPoint.x / TWIPS, (dynamicFont3D.height - nextPoint.y) / TWIPS]]);
				}
				else if (!nextPoint.onCurve && !nextPoint2.onCurve) {
					//this.curveTo(nextPoint.x, nextPoint.y, mid(nextPoint2.x, nextPoint.x), mid(nextPoint2.y, nextPoint.y));
					commands.push(['C', [nextPoint.x / TWIPS, (dynamicFont3D.height - nextPoint.y) / TWIPS,
								mid(nextPoint2.x, nextPoint.x) / TWIPS, mid((dynamicFont3D.height - nextPoint2.y), (dynamicFont3D.height - nextPoint.y)) / TWIPS]]);					
				}
				else if (!nextPoint.onCurve && nextPoint2.onCurve) {
					//this.curveTo(nextPoint.x, nextPoint.y, nextPoint2.x, nextPoint2.y);
					commands.push(['C', [nextPoint.x / TWIPS, (dynamicFont3D.height - nextPoint.y) / TWIPS, 
								nextPoint2.x / TWIPS, (dynamicFont3D.height - nextPoint2.y) / TWIPS]]);	
					if (nextPoint.endOfContour) {
						first = true;
					}
					pointPos++;					
				}	
				else if (nextPoint.onCurve) {
					//This is probably wrong
					commands.push(['L', [nextPoint.x / TWIPS, (dynamicFont3D.height - nextPoint.y) / TWIPS]]);
				}		
				else {
					trace ("Font3DLoader: Shouldn't be here!");	
				}			
			}
			
			dynamicFont3D.setMotif(char, commands);			 
		}
		
		static private function mid(a:Number, b:Number):Number {
			return (a + b) / 2;
		}
		
	}
}