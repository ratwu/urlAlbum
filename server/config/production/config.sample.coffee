module.exports =
  port: 8080
  mysql:
    max_connections: 100
    host: 'localhost'
    port: '3306'
    db_name: 'master'
    user: 'root'
    passwd: ''
  totalDB: 1
  open_master_url: 'http://open.admaster.com.cn'
  CORS:
    headers: [ 'link', 'X-Content-Record-Total']
