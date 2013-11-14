var express    = require('express');
var app        = express();
var solr       = require( 'solr' );
var solrClient = solr.createClient( { host:'192.168.254.11', port:8090, core:'lookingglass', path:'/' } );

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

app.get( '/query/:solr_query', getResults );
app.get( '/query', getResults );



app.listen( 8080 );