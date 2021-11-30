# ======================================================================
# API server to support 8bit clients
# ======================================================================

API=$(BUILDS)/nrefeeds8bit

all: $(API)

clean:
	@$(RM) $(API)

$(API): bin/main.go *.go command/*.go fifo/*.go telnet/*.go record/*.go
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) GOARM=$(GOARM) $(GO) build -o $(API) bin/main.go
