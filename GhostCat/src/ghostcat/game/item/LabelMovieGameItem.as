package ghostcat.game.item
{
	import ghostcat.display.movieclip.GMovieClip;
	
	public class LabelMovieGameItem extends GMovieClip implements IGameItem
	{
		public function LabelMovieGameItem(mc:*=null, paused:Boolean=false)
		{
			super(mc, paused);
			this.enabledDelayUpdate = false;
		}
	}
}