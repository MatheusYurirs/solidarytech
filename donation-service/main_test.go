package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
)

func newApp(t *testing.T) (*App, sqlmock.Sqlmock) {
	t.Helper()
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { db.Close() })
	return &App{DB: db}, mock
}

func TestHealth(t *testing.T) {
	app, _ := newApp(t)
	w := httptest.NewRecorder()
	app.HealthHandler(w, httptest.NewRequest(http.MethodGet, "/health", nil))
	if w.Code != http.StatusOK || !strings.Contains(w.Body.String(), "donation-service") {
		t.Fatalf("health inesperado: %d %s", w.Code, w.Body.String())
	}
}

func TestCreateDonationInvalidPayload(t *testing.T) {
	app, _ := newApp(t)
	w := httptest.NewRecorder()
	app.DonationHandler(w, httptest.NewRequest(http.MethodPost, "/donations", strings.NewReader("{")))
	if w.Code != http.StatusBadRequest {
		t.Fatalf("esperava 400, veio %d", w.Code)
	}
}

func TestCreateDonationOK(t *testing.T) {
	app, mock := newApp(t)
	mock.ExpectQuery("INSERT INTO donations").
		WithArgs(1, 50.0, "Maria", "APPROVED").
		WillReturnRows(sqlmock.NewRows([]string{"id", "created_at"}).AddRow(7, time.Now()))
	body := `{"ngo_id":1,"amount":50,"donor_name":"Maria"}`
	w := httptest.NewRecorder()
	app.DonationHandler(w, httptest.NewRequest(http.MethodPost, "/donations", strings.NewReader(body)))
	if w.Code != http.StatusCreated || !strings.Contains(w.Body.String(), `"status":"APPROVED"`) {
		t.Fatalf("esperava 201 APPROVED, veio %d %s", w.Code, w.Body.String())
	}
}

func TestCreateDonationDBError(t *testing.T) {
	app, mock := newApp(t)
	mock.ExpectQuery("INSERT INTO donations").WillReturnError(http.ErrAbortHandler)
	w := httptest.NewRecorder()
	app.DonationHandler(w, httptest.NewRequest(http.MethodPost, "/donations",
		strings.NewReader(`{"ngo_id":1,"amount":5,"donor_name":"A"}`)))
	if w.Code != http.StatusInternalServerError {
		t.Fatalf("esperava 500, veio %d", w.Code)
	}
}

func TestListDonations(t *testing.T) {
	app, mock := newApp(t)
	mock.ExpectQuery("SELECT id, ngo_id").WillReturnRows(
		sqlmock.NewRows([]string{"id", "ngo_id", "amount", "donor_name", "status", "created_at"}).
			AddRow(1, 1, 10.5, "Ana", "APPROVED", time.Now()))
	w := httptest.NewRecorder()
	app.DonationHandler(w, httptest.NewRequest(http.MethodGet, "/donations", nil))
	if w.Code != http.StatusOK || !strings.Contains(w.Body.String(), "Ana") {
		t.Fatalf("listagem inesperada: %d %s", w.Code, w.Body.String())
	}
}

func TestMethodNotAllowed(t *testing.T) {
	app, _ := newApp(t)
	w := httptest.NewRecorder()
	app.DonationHandler(w, httptest.NewRequest(http.MethodDelete, "/donations", nil))
	if w.Code != http.StatusMethodNotAllowed {
		t.Fatalf("esperava 405, veio %d", w.Code)
	}
}
