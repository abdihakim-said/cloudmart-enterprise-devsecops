import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, ScanCommand, GetCommand, UpdateCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import dotenv from 'dotenv';
import { v4 as uuidv4 } from 'uuid';

dotenv.config();

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = 'cloudmart-tickets';

export const createTicket = async (ticket) => {
  const params = {
    TableName: TABLE_NAME,
    Item: {
      ...ticket,
      id: uuidv4().split('-')[0],
      createdAt: new Date().toISOString(),
      status: 'open'
    }
  };

  await docClient.send(new PutCommand(params));
  return params.Item;
};

export const getAllTickets = async () => {
  const params = {
    TableName: TABLE_NAME
  };

  const result = await docClient.send(new ScanCommand(params));
  return result.Items;
};

export const getTicketById = async (id) => {
  const params = {
    TableName: TABLE_NAME,
    Key: { id }
  };

  const result = await docClient.send(new GetCommand(params));
  return result.Item;
};

export const getTicketsByStatus = async (status) => {
  const params = {
    TableName: TABLE_NAME,
    FilterExpression: '#status = :status',
    ExpressionAttributeNames: {
      '#status': 'status'
    },
    ExpressionAttributeValues: {
      ':status': status
    }
  };

  const result = await docClient.send(new ScanCommand(params));
  return result.Items;
};

export const updateTicket = async (id, updates) => {
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

export const deleteTicket = async (id) => {
  const params = {
    TableName: TABLE_NAME,
    Key: { id }
  };

  await docClient.send(new DeleteCommand(params));
};

export const closeTicket = async (id) => {
  return await updateTicket(id, { status: 'closed' });
};
