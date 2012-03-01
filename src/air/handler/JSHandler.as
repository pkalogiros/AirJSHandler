package handler
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.LocationChangeEvent;
	import flash.external.ExternalInterface;
	import flash.media.StageWebView;
	import flash.utils.Timer;
	
	/*********************
	 * Acts as a bridge between actionscript and
	 * javascript that runs in a StageWebView
	 * *******************/
	public class JSHandler
	{
		public var web_view:StageWebView;			//instance of affected webview
		
		private var interfaceReady:Array = [];		//contains names of functions
		private var message_string:String = "";		//prefix of the messages
		private var message_str_len:int = 0;		//and its length
		
		/************************************
		 * Cosntructor JSHandler( arg:StageWebView )
		 * ----------------------------
		 * Accepts a stageWebView (browser instance)
		 * as its sole argument and creates a bridge between AIR and 
		 * that browser
		 ************************************/
		public function JSHandler( arg:StageWebView )
		{
			//grabbing the stageWebView
			this.web_view = arg;
			
			//setting up the listeners
			arg.addEventListener( Event.COMPLETE, ExternalInterface );
			arg.addEventListener( ErrorEvent.ERROR, ExternalInterface );
			arg.addEventListener( FocusEvent.FOCUS_IN, ExternalInterface );  
			arg.addEventListener( FocusEvent.FOCUS_OUT, ExternalInterface );
			arg.addEventListener( LocationChangeEvent.LOCATION_CHANGE, ExternalInterface );
			arg.addEventListener( LocationChangeEvent.LOCATION_CHANGING, ExternalInterface );
			
			this.message_string = "data://";
			this.message_str_len = this.message_string.length;
		}
		
		/************************************
		 * Calls JavaScript function
		 ************************************/
		public function call( func:String = "alert(1)") : void
		{
			func = func.replace( /\s+/g, '%20' );
			this.web_view.loadURL( "javascript:" + func );
		}
		/************************************
		 * Adds a listener for a function called through javascript,
		 * and calls the "func" argument when that specific function is called
		 ************************************/
		public function listen( name:String, func:Function ) : void
		{
			if( !this.interfaceReady[name] )
				 this.interfaceReady[name] = func;
			else
			{
				this.interfaceReady[name] = null;
				this.interfaceReady[name] = func;
			}
		}
		
		/************************************
		 * Removes JS listener (of flex)
		 ************************************/
		public function unlisten( name:String, func:Function ) : void
		{
			this.interfaceReady[name] = null;
		}
		/************************************
		 * Listens for URL change / Javascript Functions 
		 * and acts accordingly
		 ************************************/
		private function ExternalInterface( e:Event ) : void
		{
			if( e.type == "locationChanging" )
			{
				var currLocation:String = unescape( (e as LocationChangeEvent).location ),
					tagIndex:int = currLocation.indexOf( this.message_string ) + this.message_str_len;
				
				if( tagIndex >= this.message_str_len )
				{
					e.preventDefault();
					currLocation = currLocation.substr( tagIndex );
					
					var function_array:Array = currLocation.split('}{'),
						function_array_length:int = function_array.length;
					
					var name:Array,
						args:Array = [];
					
					var tmp_arr:Array = [ null, null ],
						while_int:int = 0;
					
					//default Arguments (shared between the function array)
					//to utilize this, set the first function as CORE
					name = function_array[ 0 ].split('?~=');
					if( name[ 0 ] === "CORE" ) {
						tmp_arr = name[ 1 ].split(',');
						while_int = 1;
					}
					
					while( function_array_length-- > while_int )
					{
						name = function_array[ function_array_length ].split('?~=');
						if( name.length > 1 )
							args = name[ 1 ].split(',');
						else
							args = [];
						
						args['default'] = tmp_arr;
						
						if( this.interfaceReady[ name[ 0 ] ] )
							this.interfaceReady[ name[ 0 ] ].call( this, args );
					}
				}
			}
		}
		//END
	}
}