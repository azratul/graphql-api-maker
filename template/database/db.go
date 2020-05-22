package database

import (
	"fmt"
	"io/ioutil"
	"os"

	_ "github.com/godror/godror"
	"github.com/jmoiron/sqlx"
)

func Con() (*sqlx.DB, error) {
	pwd, e := getSecret(os.Getenv("SECRET_NAME"))

	if e != nil {
		pwd = os.Getenv("DB_PASSWORD")
	}

	dsn := fmt.Sprintf("%s/%s@(DESCRIPTION=(LOAD_BALANCE=ON)(FAILOVER=ON)(ADDRESS=(PROTOCOL=%s)(HOST=%s)(PORT=%s))(CONNECT_DATA=(SERVER=DEDICATED)(%s=%s)))",
		os.Getenv("DB_USER"),
		pwd,
		os.Getenv("DB_PROTO"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_SID_OR_SN"),
		os.Getenv("DB_SERVICE_NAME"),
	)

	schema := fmt.Sprintf("ALTER SESSION SET current_schema=%s", os.Getenv("DB_SCHEMA"))

	db, err := sqlx.Open("godror", dsn)
	db.Exec(schema)

	return db, err
}

func getSecret(name string) (string, error) {
	secretBytes, err := ioutil.ReadFile("/var/openfaas/secrets/" + name)
	if err != nil {
		secretBytes, err = ioutil.ReadFile("/run/secrets/" + name)
	}

	return string(secretBytes), err
}
