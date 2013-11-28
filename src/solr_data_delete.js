var nconf      = require( 'nconf' );
nconf.argv().env().file( { file:  __dirname + '/config.json' } );
var solr       = require( 'solr' );
var solrClient = solr.createClient( nconf.get('solr') );


solrClient.del(null, '*:*', function(err, response) {
    if (err) throw err;
    console.log('Deleted all docs');
    solrClient.commit();
});
