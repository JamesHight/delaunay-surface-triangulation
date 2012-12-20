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
	import com.zavoo.threedee.Letter3D;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.typography.Font3D;
	
	public class Font3DManager {
		
		private var _fonts:Object = new Object();
		private var _defaultFont:String = null;
		
		private var _charCache:Object = new Object();
		
		private var _fontDepth:Number;
		private var _bevel:Boolean;
		
		private var _material:MaterialObject3D;
		
		public function Font3DManager(material:MaterialObject3D, fontDepth:Number = 0, bevel:Boolean = false) {
			_material = material;
			_fontDepth = fontDepth;
			_bevel = bevel;
		}
		
		public function registerFont(fontName:String, font:Font3D):void {
			_fonts[fontName] = font;
			
			if (_defaultFont == null) {	
				_defaultFont = fontName;	
			}			
		}
		
		public function setDefaultFont(fontName:String):void {
			_defaultFont = fontName;
		}
		
		public function getLetterMesh(char:String, fontName:String = null):Letter3D {
			var mesh:Letter3D;			
			var commands:Array = null;
			var height:Number;
			var width:Number;
				
				
			//See if we already have the letter cached
			if (_charCache.hasOwnProperty(fontName)
				&& _charCache[fontName].hasOwnProperty(char)) {								
				return _charCache[fontName][char].duplicate();												
			}
			
			if (_fonts.hasOwnProperty(fontName)
				&& _fonts[fontName].motifs.hasOwnProperty(char)) {
				commands = _fonts[fontName].motifs[char];
				height = _fonts[fontName].height;
				width = _fonts[fontName].widths[char];
			}			
			else if (_fonts.hasOwnProperty(_defaultFont)
				&& _fonts[_defaultFont].motifs.hasOwnProperty(char)) {
				commands = _fonts[_defaultFont].motifs[char];
				height = _fonts[_defaultFont].height;
				width = _fonts[_defaultFont].widths[char];
			}
			else {
				return null;
			}
			
			mesh = new Letter3D(_material, commands, height, width);
			
			return mesh;
		}

	}
}