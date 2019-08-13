package db

import (
	"errors"
	"log"
	"sync"
    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/aws/aws-sdk-go/service/dynamodb"
    "github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

type DBConfig struct {
	table string
	input *dynamodb.CreateTableInput
}

type dbHelper struct{}

var dbInstance *dbHelper
var once sync.Once
var db *dynamodb.DynamoDB

func getDBInstance() *dbHelper {
	once.Do(func() {
		// AWS server
		sess, err := session.NewSession(&aws.Config{
			Region: aws.String("us-east-2"),
		})

		// For local testing
		// sess, err := session.NewSession(&aws.Config{
		// 	Region: aws.String("us-east-2"),
		// 	Endpoint: aws.String("http://localhost:8000")})
		if err != nil {
			log.Print("Connect DB error: ", err)
			panic(err)
		}
		if sess != nil {
			db = dynamodb.New(sess)
			dbInstance = new(dbHelper)
		}
	})
	return dbInstance
}

func (h *dbHelper) createTable(config DBConfig) {
	input := config.input

	_, err := db.CreateTable(input)
	if err != nil {
		log.Print("Create table failed: ", err)
		return
	}
	log.Print("Create table success")
}

func (h *dbHelper) create(config DBConfig, i interface{}) error {
	av, err := dynamodbattribute.MarshalMap(i)
	if err != nil {
		log.Print("Marshal error: ", err)
		return err
	}
	input := &dynamodb.PutItemInput {
		TableName: aws.String(config.table),
        Item: av,
	}

	log.Printf("Put item: %+v", input)
	if _, err := db.PutItem(input); err != nil {
		log.Print("Put item error: ", err)
		return err
	}else {
		log.Printf("Put item success: %+v", av)
		return nil
	}
}

func (h *dbHelper) retrieve(config DBConfig, input *dynamodb.GetItemInput) (map[string]*dynamodb.AttributeValue, error) {
	result, err := db.GetItem(input)

	if err != nil {
		log.Print(err)
		return nil, err
	}

	if result.Item == nil {
		log.Printf("Get item empty %+v", input)
		return nil, errors.New("Delete item doesn't exist in database")
	}

	log.Print("Get item success")
	return result.Item, nil
}

func (h *dbHelper) update(config DBConfig, input *dynamodb.UpdateItemInput) (map[string]*dynamodb.AttributeValue, error) {
	result, err := db.UpdateItem(input)

	if err != nil {
		log.Print(err)
		return nil, err
	}

	if result.Attributes == nil {
		log.Printf("Update item failed %+v", input)
		return nil, nil
	}

	log.Print("Update item success")
	return result.Attributes, nil
}

func (h *dbHelper) delete(config DBConfig, input *dynamodb.DeleteItemInput) (map[string]*dynamodb.AttributeValue, error) {
	result, err := db.DeleteItem(input)

	if err != nil {
		log.Print(err)
		return nil, err
	}

	// log.Printf("Attribute: %+v", result.Attributes)
	// if result.Attributes == nil {
	// 	log.Printf("Delete item failed %+v", input)
	// 	return nil, errors.New("Delete item doesn't exist in database")
	// }

	log.Print("Delete item success")
	return result.Attributes, nil
}