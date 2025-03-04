locals {
  api_image = (var.database_type == "mysql" ? "gcr.io/sic-container-repo/todo-api" : "gcr.io/sic-container-repo/todo-api-postgres:latest")
  fe_image  = "gcr.io/sic-container-repo/todo-fe"
  api_env_vars_postgresql = {
    redis_host = google_redis_instance.main.host
    db_host    = google_sql_database_instance.main.ip_address[0].ip_address
    db_user    = google_service_account.runsa.email
    db_conn    = google_sql_database_instance.main.connection_name
    db_name    = "todo"
    redis_port = "6379"
  }
  api_env_vars_mysql = {
    REDISHOST = google_redis_instance.main.host
    todo_host = google_sql_database_instance.main.ip_address[0].ip_address
    todo_user = "foo"
    todo_pass = "bar"
    todo_name = "todo"
    REDISPORT = "6379"
  }
}
