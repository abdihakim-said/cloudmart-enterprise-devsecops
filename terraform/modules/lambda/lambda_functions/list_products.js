const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    try {
        const params = {
            TableName: process.env.PRODUCTS_TABLE || 'cloudmart-products'
        };
        
        const command = new ScanCommand(params);
        const result = await docClient.send(command);
        
        // Bedrock agent response format
        const response = {
            messageVersion: "1.0",
            response: {
                actionGroup: event.actionGroup,
                apiPath: event.apiPath,
                httpMethod: event.httpMethod,
                httpStatusCode: 200,
                responseBody: {
                    "application/json": {
                        body: JSON.stringify({
                            success: true,
                            products: result.Items || [],
                            count: result.Count || 0
                        })
                    }
                }
            }
        };
        
        console.log('Response:', JSON.stringify(response, null, 2));
        return response;
        
    } catch (error) {
        console.error('Error:', error);
        
        // Bedrock agent error response format
        return {
            messageVersion: "1.0",
            response: {
                actionGroup: event.actionGroup,
                apiPath: event.apiPath,
                httpMethod: event.httpMethod,
                httpStatusCode: 500,
                responseBody: {
                    "application/json": {
                        body: JSON.stringify({
                            success: false,
                            error: error.message
                        })
                    }
                }
            }
        };
    }
};
