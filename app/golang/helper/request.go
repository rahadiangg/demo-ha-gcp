package helper

import (
	"encoding/json"
	"net/http"
)

func Decode(r *http.Request, result interface{}) {
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&result)
	PanicIfError(err)
}

func Encode(w http.ResponseWriter, result interface{}) {
	w.Header().Add("Content-Type", "application/json")
	encoder := json.NewEncoder(w)
	err := encoder.Encode(&result)
	PanicIfError(err)
}
