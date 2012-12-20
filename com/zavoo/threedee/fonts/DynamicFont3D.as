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

package com.zavoo.threedee.fonts
{
	import org.papervision3d.typography.Font3D;

	public class DynamicFont3D extends Font3D
	{
		
		private var __motifs:Object = new Object();
		private var __widths:Object = new Object();
		private var __height:Number = 0;
		
		public function DynamicFont3D() {
			super();
		}
		
		override public function get motifs():Object {
			return __motifs;
		}

		override public function get widths():Object { 
			return __widths;
		}
		
		override public function get height():Number {
			return __height;
		}
		
		public function setWidth(char:String, value:Number):void {
			__widths[char] = value;
		}
		
		public function setMotif(char:String, value:Array):void {
			__motifs[char] = value;
		}
		
		public function setHeight(value:Number):void {
			__height = value;
		}
		
	}
}