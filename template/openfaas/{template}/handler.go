package function

import (
	"net/http"
	"log"
	"os"
	"strconv"

	health "github.com/AppsFlyer/go-sundheit"
    healthhttp "github.com/AppsFlyer/go-sundheit/http"
	"github.com/99designs/gqlgen/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"{git_repo}/{template}.git/graph"
	"{git_repo}/{template}.git/graph/generated"
	"{git_repo}/{template}.git/healthchecks"
)

func Handle(w http.ResponseWriter, r *http.Request) {
    delay, _ := strconv.Atoi(os.Getenv("HC_DELAY"))
    timeout, _ := strconv.Atoi(os.Getenv("HC_TIMEOUT"))
    executionPeriod, _ := strconv.Atoi(os.Getenv("HC_EXECUTION_PERIOD"))

    h := health.New()

    db := map[string]string{
                "endpoint": os.Getenv("DB_HOST")+":"+os.Getenv("DB_PORT"),
                "type": "db",
            }

    services := map[string]map[string]string{
		        "DB.Check": db,
		    }
    go healthchecks.Register(h, services, delay, timeout, executionPeriod)

	w.WriteHeader(http.StatusOK)

	srv := handler.GraphQL(generated.NewExecutableSchema(generated.Config{Resolvers: &graph.Resolver{}}))

	http.Handle("/graphql", playground.Handler("GraphQL playground", "/query"))
	http.Handle("/query", srv)
	http.Handle("/healthcheck", healthhttp.HandleHealthJSON(h))
}
