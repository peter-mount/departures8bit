package lang

// Remark is a basic line of text which is ignored
type Error string

func (l Error) Compile() []byte {
	return append([]byte{TokenError}, string(l)[:]...)
}
