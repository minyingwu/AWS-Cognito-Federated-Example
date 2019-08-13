package db

import (
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

type U struct {
	AWS_ID string `json:"aws_id" form:"aws_id"`
	Name string `json:"name" form:"name"`
}

type User struct {
	ID string `json:"id" form:"id"`
	U
}

const (
	tableName = "User"
)

var (
	dbConfig = DBConfig{
		table: tableName,
		input: &dynamodb.CreateTableInput{
			AttributeDefinitions: []*dynamodb.AttributeDefinition{
				{
					AttributeName: aws.String("aws_id"),
					AttributeType: aws.String("S"),
				},
			},
			KeySchema: []*dynamodb.KeySchemaElement{
				{
					AttributeName: aws.String("aws_id"),
					KeyType:       aws.String("HASH"),
				},
			},
			ProvisionedThroughput: &dynamodb.ProvisionedThroughput{
				ReadCapacityUnits:  aws.Int64(10),
				WriteCapacityUnits: aws.Int64(10),
			},
			TableName: aws.String(tableName),
		},
	}
)

func CreateTableUser() {
	getDBInstance().createTable(dbConfig)
}

func CreateUser(user *User) error {
	return getDBInstance().create(dbConfig, user)
}

func RetrieveUser(aws_id string) (*U, error) {
	input := &dynamodb.GetItemInput{
        TableName: aws.String(dbConfig.table),
        Key: map[string]*dynamodb.AttributeValue{
            "aws_id": {
				S: aws.String(aws_id),
            },
        },
	}

	item, err := getDBInstance().retrieve(dbConfig, input)

	u := new(U)
	err = dynamodbattribute.UnmarshalMap(item, &u)

	return u, err
}

func UpdateUser(u *U) error {
	input := &dynamodb.UpdateItemInput{
		ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{
			":n": {
				S: aws.String(u.Name),
			},
		},
		TableName: aws.String(dbConfig.table),
		Key: map[string]*dynamodb.AttributeValue{
			"aws_id": {
				S: aws.String(u.AWS_ID),
			},
		},
		ReturnValues:     aws.String("ALL_NEW"),
		UpdateExpression: aws.String("set #name = :n"),
		ExpressionAttributeNames: map[string]*string{
			"#name": aws.String("name"),
		},
	}

	_, err := getDBInstance().update(dbConfig, input)

	return err
}

func DeleteUser(aws_id string) error {
	input := &dynamodb.DeleteItemInput{
		Key: map[string]*dynamodb.AttributeValue{
			"aws_id": {
				S: aws.String(aws_id),
			},
		},
		TableName: aws.String(dbConfig.table),
	}

	_, err := getDBInstance().delete(dbConfig, input)

	return err
}