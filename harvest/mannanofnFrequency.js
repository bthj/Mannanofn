var request = require('request'),
	jsdom = require('jsdom'),
	iconv = require('iconv'),
	sqlite3 = require('sqlite3').verbose(),
	timers = require('timers');

var db = new sqlite3.Database('nofn.sqlite');

function getNameFrequencyAndUpdateDB( name, delay ) {
	setTimeout(
		function(){
			request.post(
				{
					headers: {
						'content-type' : 'application/x-www-form-urlencoded',
						'User-Agent': 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)'
					},
					uri:'http://www.hagstofa.is/Pages/21',
					body: "nafn="+escape(name),
					encoding:'binary'
				},
				function( error, response, body){
					if( error && response.statusCode !== 200 ) {
						console.log( 'Villa kom upp við tengingu við hagstofa.is' );
					}

				    body = new Buffer(body, 'binary');
				    conv = new iconv.Iconv('iso-8859-1', 'utf8');
				    body = conv.convert(body).toString();

					jsdom.env({
						html: body,
						 scripts: [
						 	'http://code.jquery.com/jquery-1.7.2.min.js'
						],
					  done: function( err, window ) {
						var $ = window.jQuery;

						var $table = $('body table:first');
						var countFirstName = $table.find('tr:nth-child(1) td:nth-child(2) strong:first').text();
						var countSecondName = $table.find('tr:nth-child(2) td:nth-child(2) strong:first').text();
						updateDBWithFrequencyValues( 
							name, 
							{ 
								"countFirstName" : countFirstName, 
								"countSecondName" : countSecondName  
							}
						);
					  }
					});

				}
			);
		},
		delay
	);
}
function updateDBWithFrequencyValues( name, nameFrequency ) {
	db.run( "UPDATE names SET countAsFirstName = ?, countAsSecondName = ? WHERE name = ?", 
		[nameFrequency.countFirstName, nameFrequency.countSecondName, name], 
		function(err){
			console.log( name 
				+ ", countFirstName: " + nameFrequency.countFirstName 
				+ ", countSecondName: " + nameFrequency.countSecondName );
	});
}


function setFrequencyInfoToAllDBRows( insertOnly ) {
	delay = 1;
	db.all("SELECT * FROM names", function( err, rows ){
		console.log( rows.length );

		for (var i = 0; i < rows.length; i++) {
			if( false == insertOnly || (insertOnly && null == rows[i].countAsFirstName && null == rows[i].countAsSecondName) ) {
				delay += ((Math.floor(Math.random() * 10) + 1 ) * 1000);
				getNameFrequencyAndUpdateDB( rows[i].name, delay );
			}
			
		};

	});	
}

setFrequencyInfoToAllDBRows( true );
