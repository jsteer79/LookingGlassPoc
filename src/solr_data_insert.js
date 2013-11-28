var nconf      = require( 'nconf' );
nconf.argv().env().file( { file:  __dirname + '/config.json' } );
var solr       = require( 'solr' );
var solrClient = solr.createClient( nconf.get('solr') );


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

