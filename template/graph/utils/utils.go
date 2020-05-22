package utils

import (
	"regexp"
	"strconv"
	"strings"
	"time"
	"{git_repo}/{template}.git/graph/model"
)

func JoinStringpSlice(src []*string, str string) string {
	dst := ""
	for i := 0; i < len(src); i++ {
		if src[i] != nil {
			dst += *(src[i]) + str
		}
	}
	return dst[:len(dst)-len(str)]
}

func JoinFloatpSlice(src []*float64, str string) string {
	dst := ""
	for i := 0; i < len(src); i++ {
		if src[i] != nil {
			dst += strconv.FormatFloat(*(src[i]), 'f', 6, 64) + str
		}
	}
	return dst[:len(dst)-len(str)]
}

func JoinIntpSlice(src []*int, str string) string {
	dst := ""
	for i := 0; i < len(src); i++ {
		if src[i] != nil {
			dst += strconv.Itoa(*(src[i])) + str
		}
	}
	return dst[:len(dst)-len(str)]
}

func JoinBoolpSlice(src []*bool, str string) string {
	dst := ""
	for i := 0; i < len(src); i++ {
		if src[i] != nil {
			dst += strconv.FormatBool(*(src[i])) + str
		}
	}
	return dst[:len(dst)-len(str)]
}

func JoinTimepSlice(src []*time.Time, str string) string {
	dst := ""
	for i := 0; i < len(src); i++ {
		if src[i] != nil {
			dst += (*(src[i])).String() + str
		}
	}
	return dst[:len(dst)-len(str)]
}

func QueryPagination(query string, pagination *model.Pagination) string {
	if pagination == nil {
		return query
	}

	type Data struct {
		Fields string
		Query  string
		Lower  string
		Upper  string
	}

	var (
		pageNumber int = pagination.PageNumber
		pageSize   int = pagination.PageSize
	)

	re := regexp.MustCompile(`SELECT (.*?) FROM `)
	fields := re.FindStringSubmatch(query)

	data := Data{
		Fields: fields[1],
		Query:  query,
		Lower:  strconv.Itoa(((pageNumber - 1) * pageSize) + 1),
		Upper:  strconv.Itoa((pageNumber * pageSize) + 1),
	}

	queryWithPagination := `
    SELECT {{.Fields}} FROM
    (
        SELECT rownum ROW_ID, aux.*
        FROM
        ({{.Query}}) aux
        WHERE rownum < {{.Upper}}
    )
    WHERE ROW_ID >= {{.Lower}}
    `

	r := strings.NewReplacer(
		"{{.Fields}}", data.Fields,
		"{{.Query}}", data.Query,
		"{{.Upper}}", data.Upper,
		"{{.Lower}}", data.Lower)

	result := r.Replace(queryWithPagination)

	return result
}
