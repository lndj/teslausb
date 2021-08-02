#!/bin/bash

# shellcheck disable=SC1091
source env.sh

create_table() {
  sql=$(cat <<EOF
  CREATE TABLE IF NOT EXISTS 'user_info' (
  'id' INTEGER PRIMARY KEY NOT NULL,
  'username' varchar(64) NOT NULL DEFAULT '',
  'password' varchar(255) DEFAULT NULL,
  'nickname' varchar(255) DEFAULT NULL,
  'icon' varchar(255) DEFAULT NULL,
  'status' tinyint(4) NOT NULL DEFAULT '0'
);
EOF
)
  sqlite3 "$DB_FILE_PATH" "$sql"
}

initial_user() {
  sql=$(cat <<EOF
  INSERT INTO 'user_info' ('id', 'username', 'password', 'nickname', 'icon', 'status') 
  VALUES (NULL, 'admin', '123456', "管理员", 'icon', '1');
);
EOF
)
  sqlite3 "$DB_FILE_PATH" "$sql"
}

create_table
initial_user
