package lang

// Remark is a basic line of text which is ignored
type Error string

func (l Error) Compile(address uint16) []byte {
	var r []byte
	r = AppendHeader(r, TokenError)
	r = append(r, string(l)[:]...)
	return append(r, 0)
}
