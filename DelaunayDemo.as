package {
	import flash.display.Sprite;

	[SWF(width="500", height="200", backgroundColor="#ffffff", frameRate="60")]
	public class DelaunayDemo extends Sprite {		
		public function DelaunayDemo() {
			this.addChild(new DelaunayBasicView());
		}
	}
}
