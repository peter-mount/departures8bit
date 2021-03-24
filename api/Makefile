# ======================================================================
# API server to support 8bit clients
# ======================================================================

API=$(BUILDS)/nrefeeds8bit

all: $(API)

clean:
	$(RM) $(API)

$(API): bin/main.go ApiCore.go Boards.go Helo.go response.go TelnetLogger.go TelnetServer.go
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) GOARM=$(GOARM) $(GO) build -o $(API) bin/main.go
