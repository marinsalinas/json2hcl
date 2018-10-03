package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/hashicorp/hcl"
	"github.com/hashicorp/hcl/hcl/printer"
	jsonParser "github.com/hashicorp/hcl/json/parser"
)

// Version is what is returned by the `-v` flag
var Version = "development"

func main() {
	version := flag.Bool("version", false, "Prints current app version")
	reverse := flag.Bool("reverse", false, "Input HCL, output JSON")
	flag.Parse()
	if *version {
		fmt.Println(Version)
		return
	}

	var err error
	if *reverse {
		err = toJSON()
	} else {
		//err = toHCL()
		input, err := ioutil.ReadAll(os.Stdin)
		if err != nil {
			log.Fatalf("unable to read from stdin: %s", err)
		}
		hclString, err2 := ToHCLFromJSONString(string(input))
		if err2 != nil {
			log.Fatalf("unable to convert to HCL String: %s", err2)
		}
		fmt.Println(hclString)

	}

	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func toJSON() error {
	input, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		return fmt.Errorf("unable to read from stdin: %s", err)
	}

	var v interface{}
	err = hcl.Unmarshal(input, &v)
	if err != nil {
		return fmt.Errorf("unable to parse HCL: %s", err)
	}

	json, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return fmt.Errorf("unable to marshal json: %s", err)
	}

	fmt.Println(string(json))

	return nil
}

func toHCL() error {
	input, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		return fmt.Errorf("unable to read from stdin: %s", err)
	}

	ast, err := jsonParser.Parse([]byte(input))
	if err != nil {
		return fmt.Errorf("unable to parse JSON: %s", err)
	}

	err = printer.Fprint(os.Stdout, ast)
	if err != nil {
		return fmt.Errorf("unable to print HCL: %s", err)
	}

	return nil
}

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
