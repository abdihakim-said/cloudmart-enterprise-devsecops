const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, GetCommand } = require('@aws-sdk/lib-dynamodb');
const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');

const dynamoClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(dynamoClient);
const bedrockClient = new BedrockRuntimeClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
    console.log('AI Support Event:', JSON.stringify(event, null, 2));
    
    try {
        const body = JSON.parse(event.body || '{}');
        const { message, userId, ticketId } = body;
        
        if (!message) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    success: false,
                    error: 'Message is required'
                })
            };
        }
        
        // Prepare prompt for Bedrock
        const prompt = `You are a helpful customer support assistant for CloudMart, an e-commerce platform. 
        Please provide a helpful, professional response to the following customer inquiry:
        
        Customer Message: ${message}
        
        Guidelines:
        - Be friendly and professional
        - Provide specific solutions when possible
        - If you need more information, ask clarifying questions
        - Keep responses concise but helpful
        - For order issues, suggest checking order status or contacting billing
        - For product questions, provide general guidance
        
        Response:`;
        
        // Call Bedrock AI model
        const modelParams = {
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
            contentType: 'application/json',
            accept: 'application/json',
            body: JSON.stringify({
                anthropic_version: "bedrock-2023-05-31",
                max_tokens: 500,
                messages: [
                    {
                        role: "user",
                        content: prompt
                    }
                ]
            })
        };
        
        const command = new InvokeModelCommand(modelParams);
        const response = await bedrockClient.send(command);
        
        const responseBody = JSON.parse(new TextDecoder().decode(response.body));
        const aiResponse = responseBody.content[0].text;
        
        // Save ticket to DynamoDB if ticketId provided
        if (ticketId && userId) {
            const ticketParams = {
                TableName: process.env.TICKETS_TABLE || '${tickets_table}',
                Item: {
                    id: ticketId,
                    user_id: userId,
                    message: message,
                    ai_response: aiResponse,
                    status: 'resolved',
                    created_at: new Date().toISOString(),
                    updated_at: new Date().toISOString()
                }
            };
            
            await docClient.send(new PutCommand(ticketParams));
        }
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            body: JSON.stringify({
                success: true,
                response: aiResponse,
                ticketId: ticketId
            })
        };
        
    } catch (error) {
        console.error('Error in AI support:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                error: error.message
            })
        };
    }
};
