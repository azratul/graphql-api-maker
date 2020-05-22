package healthchecks

import (
    "log"
    "time"

    health "github.com/AppsFlyer/go-sundheit"
    "github.com/AppsFlyer/go-sundheit/checks"
)

func Register(h health.Health, urls map[string]map[string]string, d int, t int, ep int) {
    delay := time.Duration(d)
    timeout := time.Duration(t)
    executionPeriod := time.Duration(ep)
    for name, service := range urls {
        h.RegisterCheck(&health.Config{
            Check:           serviceCheck(name, service, timeout),
            InitialDelay:    delay * time.Second,
            ExecutionPeriod: executionPeriod * time.Second,
        })
    }
}

func serviceCheck(name string, service map[string]string, timeout time.Duration) (checks.Check) {
    if service["type"] == "db" {
        db := checks.NewDialPinger("tcp", service["endpoint"])
        c, err := checks.NewPingCheck(name, db, timeout * time.Second)
        if err != nil {
            log.Println(err)
        }
        return c
    }

    conf := checks.HTTPCheckConfig{
        CheckName:    name,
        Timeout:      timeout * time.Second,
        URL:          service["endpoint"],
        ExpectedBody: "OK",
    }

    c, err := checks.NewHTTPCheck(conf)
    if err != nil {
        log.Println(err)
    }

    return c
}