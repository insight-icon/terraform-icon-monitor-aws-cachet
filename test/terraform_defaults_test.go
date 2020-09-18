package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"io/ioutil"
	"log"
	"path"
	"testing"
)

func TestDefault(t *testing.T) {
	t.Parallel()

	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/defaults")

	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		terraform.Destroy(t, terraformOptions)

		keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)
		aws.DeleteEC2KeyPair(t, keyPair)
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions, keyPair := configureTerraformOptions(t, exampleFolder)
		test_structure.SaveTerraformOptions(t, exampleFolder, terraformOptions)
		test_structure.SaveEc2KeyPair(t, exampleFolder, keyPair)

		terraform.InitAndApply(t, terraformOptions)
	})
}


func configureTerraformOptions(t *testing.T, exampleFolder string) (*terraform.Options, *aws.Ec2Keypair) {

	uniqueID := random.UniqueId()

	keyPairName := fmt.Sprintf("ci-node-%s", uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPair(t, "us-east-1", keyPairName)

	privateKeyPath := path.Join(exampleFolder, keyPairName)
	publicKeyPath := path.Join(exampleFolder, fmt.Sprintf("%s.pub", uniqueID))

	err := ioutil.WriteFile(privateKeyPath, []byte(keyPair.PrivateKey), 0600)
	if err != nil {
		panic(err)
	}

	err := ioutil.WriteFile(publicKeyPath, []byte(keyPair.PublicKey), 0644)
	if err != nil {
		panic(err)
	}

	log.Printf("Key saved to: %s", privateKeyPath)

	terraformOptions := &terraform.Options{
		TerraformDir: exampleFolder,
		Vars: map[string]interface{}{
			"public_key_path": publicKeyPath,
			"private_key_path": privateKeyPath,
		},
	}

	return terraformOptions, keyPair
}

