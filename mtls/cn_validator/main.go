package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	headerY := r.Header.Get("X-Forwarded-Tls-Client-Cert-Info")
	if headerY == "Subject%3D%22CN%3Dgood-client%22" {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "OK")
	} else {
		w.WriteHeader(http.StatusForbidden)
		fmt.Fprintln(w, "Forbidden")
	}
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Printf("Server failed: %s\n", err)
	}
}
