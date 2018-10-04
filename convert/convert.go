package convert

import (
	"bytes"
	"fmt"

	"github.com/hashicorp/hcl"
	"github.com/hashicorp/hcl/hcl/printer"
)

//ToHCLFromJSONString ...
func ToHCLFromJSONString(jsonString string) (string, error) {
	ast, err := hcl.Parse(jsonString)

	if err != nil {
		return "", fmt.Errorf("unable to parse JSON: %s", err)
	}

	writer := bytes.NewBuffer([]byte(""))

	err = printer.Fprint(writer, ast)
	if err != nil {
		return "", fmt.Errorf("unable to print HCL: %s", err)
	}
	//result := writer.String()
	// result, e := hclStrconv.Unquote(writer.String())
	// if e != nil {
	// 	return "", e
	// }
	res, errrr := printer.Format(writer.Bytes())
	if errrr != nil {
		return "", errrr
	}
	return string(res), nil
}
