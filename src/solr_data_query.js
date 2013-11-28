var nconf      = require( 'nconf' );
nconf.argv().env().file( { file:  __dirname + '/config.json' } );
var solr       = require( 'solr' );
var solrClient = solr.createClient( nconf.get('solr') );


var query = 'id:1'
solrClient.query(query, function(err, response) {
    if (err) {
        console.log(err);

    }
    console.log( response );
});

