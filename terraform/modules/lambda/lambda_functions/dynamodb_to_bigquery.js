const { BigQuery } = require('@google-cloud/bigquery');

exports.handler = async (event) => {
    console.log('DynamoDB Stream Event:', JSON.stringify(event, null, 2));
    
    try {
        // Initialize BigQuery client
        const bigquery = new BigQuery({
            projectId: process.env.GOOGLE_CLOUD_PROJECT_ID || '${google_project_id}',
            keyFilename: process.env.GOOGLE_APPLICATION_CREDENTIALS
        });
        
        const dataset = bigquery.dataset(process.env.BIGQUERY_DATASET_ID || '${bigquery_dataset}');
        const table = dataset.table(process.env.BIGQUERY_TABLE_ID || '${bigquery_table}');
        
        const rowsToInsert = [];
        
        // Process each record from DynamoDB stream
        for (const record of event.Records) {
            if (record.eventName === 'INSERT' || record.eventName === 'MODIFY') {
                const dynamoRecord = record.dynamodb.NewImage;
                
                // Transform DynamoDB record to BigQuery format
                // Using exact field names from your source code
                const row = {
                    id: dynamoRecord.id?.S || '',
                    userEmail: dynamoRecord.userEmail?.S || '',
                    status: dynamoRecord.status?.S || '',
                    createdAt: dynamoRecord.createdAt?.S || new Date().toISOString(),
                    updatedAt: new Date().toISOString(),
                    eventType: record.eventName,
                    // Add any other fields that might be in your orders
                    totalAmount: parseFloat(dynamoRecord.totalAmount?.N || '0'),
                    items: JSON.stringify(dynamoRecord.items?.L || [])
                };
                
                rowsToInsert.push(row);
            }
        }
        
        if (rowsToInsert.length > 0) {
            // Insert rows into BigQuery
            await table.insert(rowsToInsert);
            console.log('Successfully inserted ' + rowsToInsert.length + ' rows into BigQuery');
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                success: true,
                processedRecords: rowsToInsert.length
            })
        };
        
    } catch (error) {
        console.error('Error processing DynamoDB stream:', error);
        throw error;
    }
};
