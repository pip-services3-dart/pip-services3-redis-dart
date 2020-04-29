# Configuration Guide <br/>

Configuration structure follows the 
[standard configuration](https://github.com/pip-services/pip-services3-container-node/doc/Configuration.md) 
structure. 

### <a name="redis"></a> Redis

Redis modules has the following configuration properties:

- connection(s):
  - discovery_key:         (optional) a key to retrieve the connection from IDiscovery
  - host:                  host name or IP address
  - port:                  port number
  - uri:                   resource URI or connection string with all parameters in it
- credential(s):
  - store_key:             key to retrieve parameters from credential store
  - password:              user password
- options:
  - timeout:               default caching timeout in milliseconds (default: 1 minute)
  - db_num:                database number in Redis (default 0)


Example:
```yaml
- descriptor: "pip-services-test:cache:redis:default:1.0"
  connection:
    host: "localhost"
    port: 6379
  options:
    timeout: 10000
     
```

For more information on this section read 
[Pip.Services Configuration Guide](https://github.com/pip-services/pip-services3-container-node/doc/Configuration.md#deps)