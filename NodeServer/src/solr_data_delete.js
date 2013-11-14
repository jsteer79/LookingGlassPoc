var solr       = require( 'solr' )
  , solrClient = solr.createClient( { host:'192.168.254.11', port:8090, core:'testcore', path:'/' } );


solrClient.del(null, '*:*', function(err, response) {
    if (err) throw err;
    console.log('Deleted all docs');
    solrClient.commit();
});
