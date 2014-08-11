module.exports =
  port: 8080
  mysql:
    max_connections: 100
    host: 'localhost'
    port: '3306'
    db_name: 'website'
    user: 'root'
    passwd: '123456'
  dbs: [{
    key: 'test'
    max_connections: 100
    host: 'localhost'
    port: '3306'
    db_name: 'test'
    user: 'root'
    passwd: '123456'
  }]
  open_master_url: 'http://open.admaster.com.cn'
  CORS:
    headers: [ 'link', 'X-Content-Record-Total']

