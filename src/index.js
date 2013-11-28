var express    = require('express');
var app        = express();
var nconf      = require( 'nconf' );
nconf.argv().env().file( { file:  __dirname + '/config.json' } );
var solr       = require( 'solr' );
var solrClient = solr.createClient( nconf.get('solr') );

app.use( express.static( __dirname + '/public' ) );

var getResults = function( req, res ) {
    var query = req.params.solr_query;
    if( !query ) {
        query = req.query.solr_query;
    }
    console.log( query );
    solrClient.query(query, function(err, response) {
        if (err) {
            console.log(err);
            res.status( 500 );
            return;
        }
        console.log( response );
        res.set( 'Content-Type', 'application/json' );
        res.send( 200, response );
    });
}
console.log( 'Listening on: ' + nconf.get('port') );
app.get( '/query/:solr_query', getResults );
app.get( '/query', getResults );
app.listen( nconf.get('port') );