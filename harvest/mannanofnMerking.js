var jsdom = require('jsdom'),
	sqlite3 = require('sqlite3').verbose();

var db = new sqlite3.Database('nofn.sqlite');

jsdom.env({
	html: 'mannanofn.html',
	 scripts: [
	 	'http://code.jquery.com/jquery-1.7.2.min.js'
	]
}, function( err, window ) {

	var $ = window.jQuery;

	var nafn = "Björn"

	db.each("SELECT * FROM names", function( err, row ){
		console.log( "leita að " + row.name );

		$( 'p' ).each(function( index, value ){
			var onePText = $(value).text().trim();

			if( onePText.match(new RegExp("^"+row.name+"\\s")) ) {

				var description = onePText.substring( onePText.indexOf("-")+1 ).trim();

				description = description.charAt(0).toUpperCase() + description.slice(1);

				console.log( row.name + " hefur merkingu: " + description );

				db.run( "UPDATE names SET descriptionIcelandic = ? WHERE name = ?", 
					[description, row.name], 
					function(err){
						console.log( row.name 
							+ ", descriptionIcelandic: " + description );
				});
			}
		});		
	});


});