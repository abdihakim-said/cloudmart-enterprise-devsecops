import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, ScanCommand, GetCommand, UpdateCommand, DeleteCommand, QueryCommand } from '@aws-sdk/lib-dynamodb';
import dotenv from 'dotenv';
import { v4 as uuidv4 } from 'uuid';
import { trackOrder, trackDatabaseOperation } from '../middleware/metrics.js';

dotenv.config();

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = 'cloudmart-orders';

export const createOrder = async (order) => {
  return await trackDatabaseOperation('create', TABLE_NAME, async () => {
    const params = {
      TableName: TABLE_NAME,
      Item: {
        ...order,
        id: uuidv4().split('-')[0],
        createdAt: new Date().toISOString(),
        status: 'pending'
      }
    };

    await docClient.send(new PutCommand(params));
    
    // Track order metrics
    trackOrder(params.Item);
    
    return params.Item;
  });
};

export const getAllOrders = async () => {
  const params = {
    TableName: TABLE_NAME
  };

  const result = await docClient.send(new ScanCommand(params));
  return result.Items;
};

export const getOrderById = async (id) => {
  const params = {
    TableName: TABLE_NAME,
    Key: { id }
  };

  const result = await docClient.send(new GetCommand(params));
  return result.Item;
};

export const getOrdersByUserEmail = async (email) => {
  const params = {
    TableName: TABLE_NAME,
    FilterExpression: 'userEmail = :email',
    ExpressionAttributeValues: {
      ':email': email
    }
  };

  const result = await docClient.send(new ScanCommand(params));
  return result.Items;
};

export const updateOrder = async (id, updates) => {
  const params = {
    TableName: TABLE_NAME,
    Key: { id },
    UpdateExpression: 'set #status = :status, updatedAt = :updatedAt',
    ExpressionAttributeNames: {
      '#status': 'status'
    },
    ExpressionAttributeValues: {
      ':status': updates.status,
      ':updatedAt': new Date().toISOString()
    },
    ReturnValues: 'ALL_NEW'
  };

  const result = await docClient.send(new UpdateCommand(params));
  return result.Attributes;
};

export const deleteOrder = async (id) => {
  const params = {
    TableName: TABLE_NAME,
    Key: { id }
  };

  await docClient.send(new DeleteCommand(params));
};

export const cancelOrder = async (id) => {
  return await updateOrder(id, { status: 'cancelled' });
};
