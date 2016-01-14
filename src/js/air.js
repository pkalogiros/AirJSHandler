/*****************************
* AIR - 01 / 03 / 2012
*
* A Simple "bridge" between ActionScript and Javascript
* for Adobe AIR ( iOS, Android, Desktop )
*
* Author : Pantelis Kalogiros
* Contact: pkalogiros [at] live.com
*****************************/
(function( win ) {
	var _air = {
		_buffer : null,		//holds the message to be send in a string
		_bufferS: [],		//holds the previous messages and changes to it
		
		/*****************************
		* message( STRING, ARRAY ), chainable  - Added on vI
		* ----------------------------
		* - Sends a swift message to the server,
		*	no delay, no buffer clearance.
		*
		*	funcName (string) - name of the AIR function to be called
		*	args	(array) - arguments to be passed to air
		*****************************/
		message : function( funcName, args ) {
			!args && ( args = [] );
	
			if( !funcName )
				return false;
	
			win.location = 'data://' + funcName + "?~=" + args.join(',');
			return this;
		},
		/*****************************
		* clearBuffer(), chainable  - Added on vI
		* ----------------------------
		* - Clears the buffer
		*****************************/
		clearBuffer	: function() {
			this._buffer = null;
			this._bufferS = [];
			
			return this;
		},
		/*****************************
		* add( STRING, ARRAY ), chainable  - Added on vI
		* ----------------------------
		* - Pushes a function to the buffer
		*****************************/
		add : function( funcName, args ) {
			!args && ( args = [] );
	
			if( !funcName )
				return this;
	
			if( !this._buffer )
				this._buffer = funcName + "?~=" + args.join(',');
			else
				this._buffer += '}{' + funcName + "?~=" + args.join(',');
			
			this._bufferS.push( this._buffer );
			
			return this;
		},
		/*****************************
		* send( INT, STR ), chainable  - Added on vI
		* ----------------------------
		* - Sends the message and clears the buffer.
		*
		*	time (int) - milisseconds to qeue the message
		*	_message(string) - custom message to be sent (won't clear the buffer)
		*	forceClear	- clears the buffer, regardless of the message (buffered or not)
		*****************************/
		send : function( time, _message, forceClear ) {
			var q = this;
			if( time )
			{
				if( !_message )
				{
					_message = this._buffer;
					this.clearBuffer();
				}
				//scope augmentation
				(function( q, _message ) {
					setTimeout( function() {
						win.location = 'data://' + _message;
						return false;
					}, time );
				})( q, _message );
			}
			else if( _message )
			{
				win.location = 'data://' + _message;
			}
			else if( this._buffer && this._buffer.length > 0 )
			{
				win.location = 'data://' + this._buffer;
				this.clearBuffer();
			}
			
			if( forceClear )
				this.clearBuffer();
			
			return this;
		},
		/*****************************
		* undo( INT ), chainable  - Added on vI
		* ----------------------------
		* - Reverts the buffer to previous steps
		*
		* steps (int) - steps to go back
		*****************************/
		undo : function( steps ) {
			steps = steps < 0 ? -steps : steps;
			
			while( steps-- )
				this._bufferS.pop();
				
			this.setLatest();

			return this;
		},
		/*****************************
		* setLatest(), chainable  - Added on vI
		* ----------------------------
		* - Takes the last entry in the buffer array, and 
		*	loads it in the buffer.
		*****************************/
		setLatest : function() {
			this._buffer = this._bufferS[ ( this._bufferS.length - 1 ) ];
			
			return this;
		}
		
	};
	win.air = _air;
})( window );
