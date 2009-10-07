package ghostcat.ui.controls
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ghostcat.display.GNoScale;
	import ghostcat.events.TickEvent;
	import ghostcat.manager.DragManager;
	import ghostcat.ui.UIConst;
	
	[Event(name="change",type="flash.events.Event")]
	
	/**
	 * 拖动块
	 * 
	 * 标签规则：子对象中，upArrow,downArrow是上下按钮，thumb是滚动块，background是背景
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class GSilder extends GNoScale
	{
		public var upArrow:GButton;
		public var downArrow:GButton;
		public var thumb:GButton;
		public var background:DisplayObject;
		
		/**
		 * 拖动起点
		 */
		protected var thumbAreaStart:Number;
		/**
		 * 拖动长度
		 */
		protected var thumbAreaLength:Number;
		
		
		private var _target:DisplayObject;
		
		private var _minValue:Number = 0;
		private var _maxValue:Number = 100;
		private var _value:Number = 0;
		
		/**
		 * 旧值 
		 */
		protected var oldValue:Number;
		
		/**
		 * 方向
		 */
		private var _direction:String = UIConst.HORIZONTAL;
		
		public var fields:Object = {upArrowField:"upArrow",downArrowField:"downArrow",
			thumbField:"thumb",backgroundField:"background"}
		
		public function GSilder(skin:*=null,replace:Boolean=true,fields:Object=null)
		{
			if (fields)
				this.fields = fields;
			
			super(skin, replace);
			
			this.enabledTick = true;
		}
		
		/**
		 * 滚动速度
		 */
		public var detra:int = 5;
		
		/**
		 * 快速滚动速度
		 */
		public var pageDetra:int = 25;
		
		/**
		 * 当前值 
		 * @return 
		 * 
		 */
		public function get value():Number
		{
			return _value;
		}

		public function set value(v:Number):void
		{
			if (_value == v)
				return;
			
			oldValue = value;
			_value = v;
			
			dispatchEvent(new Event(Event.CHANGE));
		}

		/**
		 * 最大值
		 * @return 
		 * 
		 */
		public function get maxValue():Number
		{
			return _maxValue;
		}

		public function set maxValue(v:Number):void
		{
			_maxValue = v;
		}

		/**
		 * 最小值
		 * @return 
		 * 
		 */
		public function get minValue():Number
		{
			return _minValue;
		}

		public function set minValue(v:Number):void
		{
			_minValue = v;
		}
		
		/**
		 * 百分比 
		 * @return 
		 * 
		 */
		public function get percent():Number
		{
			return (_value - _minValue) / (_maxValue - _minValue);
		}
		
		public function set percent(v:Number):void
		{
			value = (_maxValue - _minValue) * v + _minValue;
		}

		/**
		 * 方向 
		 * @return 
		 * 
		 */
		public function get direction():String
		{
			return _direction;
		}

		public function set direction(v:String):void
		{
			_direction = v;
			invalidateSize();
		}
		/** @inheritDoc*/
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			
			var upArrowField:String = fields.upArrowField;
			var downArrowField:String = fields.downArrowField;
			var thumbField:String = fields.thumbField;
			var backgroundField:String =  fields.backgroundField;
			
			if (content.hasOwnProperty(upArrowField))
				this.upArrow = new GButton(content[upArrowField]);
			else
				this.upArrow = new GButton(new Shape())
				
			if (content.hasOwnProperty(downArrowField))
				this.downArrow = new GButton(content[downArrowField]);
			else
				this.downArrow = new GButton(new Shape())
				
			if (content.hasOwnProperty(thumbField))
			{
				this.thumb = new GButton(content[thumbField]);
				thumb.addEventListener(MouseEvent.MOUSE_DOWN,thumbMouseDownHandler);
			}
				
			if (content.hasOwnProperty(backgroundField))
			{
				this.background = content[backgroundField];
				this.background.addEventListener(MouseEvent.MOUSE_DOWN,backgroundHandler);
			}
				
			invalidateSize();
		}
		/** @inheritDoc*/
		protected override function updateSize() : void
		{
			super.updateSize();
			
			if (this.downArrow)
			{
				this.downArrow.x = this.width - this.downArrow.width;
				this.downArrow.y = this.height - this.downArrow.height;
			}
			
			if (direction == UIConst.HORIZONTAL)
			{
				thumbAreaStart = upArrow.width;
				thumbAreaLength = this.width - downArrow.width - thumb.width - thumbAreaStart;
				background.width = width;
			}
			else
			{
				thumbAreaStart = upArrow.height;
				thumbAreaLength = this.height - downArrow.height - thumb.height - thumbAreaStart;
				background.height = height;
			}
			
			updateThumb();
		}
		
		/**
		 * 更新滚动条的位置
		 * 
		 */
		public function updateThumb():void
		{
			if (!thumb)
				return;
			
			var v:Number = thumbAreaStart + thumbAreaLength * percent;
			if (direction == UIConst.HORIZONTAL)
				thumb.x = v;
			else
				thumb.y = v;
		}
		
		/**
		 * 滚动块按下
		 * @param event
		 * 
		 */
		protected function thumbMouseDownHandler(event:MouseEvent):void
		{
			var rect:Rectangle;
			if (direction == UIConst.HORIZONTAL)
				rect = new Rectangle(thumbAreaStart,thumb.y,thumbAreaLength,0);
			else
				rect = new Rectangle(thumb.x,thumbAreaStart,0,thumbAreaLength);
				
			DragManager.startDrag(thumb,rect,null,thumbMouseMoveHandler);
		}
		
		/**
		 * 滚动块移动
		 * @param event
		 * 
		 */
		protected function thumbMouseMoveHandler(event:Event=null):void
		{
			if (thumb.position.equals(thumb.oldPosition))
				return;
			
			var currentPos:Number = (direction == UIConst.HORIZONTAL) ? thumb.x : thumb.y;
			percent = (currentPos - thumbAreaStart) / thumbAreaLength;
		}
		
		/**
		 * 时基方法 
		 * @param event
		 * 
		 */
		protected override function tickHandler(event:TickEvent):void
		{
			var p:Number = percent;
			if (upArrow)
			{
				upArrow.enabled = !isNaN(p) && p > 0;
				if (upArrow.mouseDown)
				{
					value -= detra;
					updateThumb();
				}
			}
			
			if (downArrow)
			{
				downArrow.enabled = !isNaN(p) && p < 1;
				if (downArrow.mouseDown)
				{
					value += detra;
					updateThumb();
				}
			}
			
			if (thumb)
			{
				thumb.visible =  !isNaN(p);
			}
		}
		
		/**
		 * 点击背景的方法
		 * @param event
		 * 
		 */
		protected function backgroundHandler(event:MouseEvent):void
		{
			if (isNaN(percent))
				return;
			
			if (direction == UIConst.HORIZONTAL)
			{
				if (thumb.mouseX > pageDetra + thumb.width)
					thumb.x += pageDetra;
				else if (thumb.mouseX < -pageDetra)
					thumb.x -= pageDetra;
				else
					thumb.x += thumb.mouseX;
					
				thumb.x = Math.max(Math.min(downArrow.x - thumb.width,thumb.x),upArrow.x + upArrow.width)
			}
			else
			{
				if (thumb.mouseY > pageDetra + thumb.height)
					thumb.y += pageDetra;
				else if (thumb.mouseY < -pageDetra)
					thumb.y -= pageDetra;
				else
					thumb.y += thumb.mouseY;
					
				thumb.y = Math.max(Math.min(downArrow.y - thumb.height,thumb.y),upArrow.y + upArrow.height)
			}
			thumbMouseMoveHandler();
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			
			if (upArrow) 
				upArrow.destory();
			
			if (downArrow) 
				downArrow.destory();
			
			if (thumb) 
			{
				thumb.destory();
				thumb.removeEventListener(MouseEvent.MOUSE_DOWN,thumbMouseDownHandler);
			}
			
			if (background)
				background.removeEventListener(MouseEvent.MOUSE_DOWN,backgroundHandler);
		
			super.destory();
		}
		
		
	}
}