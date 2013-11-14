var solr       = require( 'solr' )
  , solrClient = solr.createClient( { host:'192.168.254.11', port:8090, core:'testcore', path:'/' } );


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

