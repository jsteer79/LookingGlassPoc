var solr       = require( 'solr' )
  , solrClient = solr.createClient( { host:'192.168.254.11', port:8090, core:'testcore', path:'/' } );


var query = 'id:1'
solrClient.query(query, function(err, response) {
    if (err) {
        console.log(err);

    }
    console.log( response );
});

