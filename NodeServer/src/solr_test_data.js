var solr       = require( 'solr' )
  , solrClient = solr.createClient( { host:'192.168.254.12', port:8091, core:'testcore', path:'/' } );

//solrClient.autoCommit = true;


solrClient.del(null, '*:*', function(err, response) {
    if (err) throw err;
    console.log('Deleted all docs matching query "' + query + '"');
    solrClient.commit();
});

solrClient.add( { name:'some name'
                , id: 1
                , data: 'some data'
                }
              , function( err ) {
        if( err ) {
            console.error( err );
        }
        solrClient.commit();
    });


var query = 'id:1'
solrClient.query(query, function(err, response) {
    if (err) {
        console.log(err);

    }
    console.log( response );
});

