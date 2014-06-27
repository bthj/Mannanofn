var /*request = require('request'),*/
	httpAgent = require('http-agent');
	jsdom = require('jsdom'),
	iconv = require('iconv')
	sqlite3 = require('sqlite3').verbose(),
	jquery = require('jquery');

var db = new sqlite3.Database('nofn.sqlite');

var alphabet = ['a', 'á', 'b', 'c', 'd', 'e', 'é', 'f', 'g', 'h', 'i', 'í', 'j', 'k', 'l', 'm', 'n', 'o', 'ó', 'p', 'q', 'r', 's', 't', 'u', 'ú', 'v', 'w', 'x', 'y', 'ý', 'z', 'þ', 'æ', 'ö'];
var httpAgentOptions = new Array();
var baseQueryString = "?Nafn=&Stulkur=on&Drengir=on&Millinofn=off&Samthykkt=yes&Stafrof=";

jquery.each(alphabet, function(index, value){
	httpAgentOptions.push( 
	{
		method: 'GET', 
		uri: '/mannanofn/leit/' + baseQueryString+value, 
		encoding:'binary',
		headers: {
			'User-Agent': 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)'
		}
	});
});

var agent = httpAgent.create('www.island.is', httpAgentOptions);

agent.addListener('next', function( e, agent ) {

	console.log( agent.url );

    var body = new Buffer(agent.body, 'binary');
//    conv = new iconv.Iconv('iso-8859-1', 'utf8');
//    body = conv.convert(body).toString();


	jsdom.env({
		html: body,
		 scripts: [
		 	'http://code.jquery.com/jquery-1.9.1.min.js'
		], 
		done: function( err, window ) {
			var $ = window.jQuery;

			var printFromGenderTitle = function ( $h3, genderString ) {
				$h3.nextUntil("h3").each(function(){
					$(this).find("li").each(function(){
						var $oneNameLi = $(this);
						var $alternativeSpan = $oneNameLi.find("span:first");
						if( $alternativeSpan.length ) {
							$alternativeSpan = $($alternativeSpan);
							console.log( $alternativeSpan.text() + ", annar rith: " + $alternativeSpan.attr("title") + genderString );
						} else {
							console.log( $oneNameLi.text() + genderString );
						}
					});
				});
			};

			var insertOrUpdateNameInDB = function function_name( name, gender, comment ) {
				db.get('SELECT name FROM names WHERE name = ?', name, function( err, row ){
					if( !row ) {
						db.run("INSERT INTO names (name, gender, comment, dateAdded, dateModified) VALUES (?,?,?,?,?)", [name, gender, (comment ? comment : ""), new Date().toISOString(), new Date().toISOString()], function(err){
							console.log( "insert " + name + ": " + err );
						});
					}
				});
			};
			var addNamesToDB = function( $h3, gender ) {
				console.log( "h3: " + $h3.text() );
				$h3.nextUntil("h3").each(function(){
					$(this).find("li").each(function(){
						var $oneNameLi = $(this);
						var $verdictI = $oneNameLi.find("i:first");
						if( $verdictI.length ) {
							var $nameElement = $.trim( $verdictI.map(function(){ return this.previousSibling.nodeValue })[0] );
						} else {
							var $nameElement = $.trim( $oneNameLi.text() );
						}
						var $alternativeSpan = $oneNameLi.find("span:first");
						if( $alternativeSpan.length ) {
							var name = $alternativeSpan.text().trim();
							var comment = $alternativeSpan.attr("title");

						} else {
							var name = $nameElement;
						}
						insertOrUpdateNameInDB( name, gender, comment );
					});
				});
			};

			var count = 0;
			var $nofn = $('div.boxbody');
			$nofn.find('h3').each(function(){
				var $thisH3 = $(this);
				if( $thisH3.text().substring(0,7) == "Drengir" ) {
	//					printFromGenderTitle( $thisH3, " -drengir" );
					
					addNamesToDB( $thisH3, "Y" );

				} else if( $thisH3.text().substring(0,7) == "Stúlkur" ) {					
	//					printFromGenderTitle( $thisH3, " -stúlkur" );

					addNamesToDB( $thisH3, "X" );
				}
			});
		}
	});

	agent.next();
});

agent.addListener('stop', function (e, agent) {
	console.log('Agent has completed visiting all urls');
});

agent.start();
