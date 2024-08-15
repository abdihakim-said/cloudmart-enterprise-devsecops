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
        
        const rows = [];
        
        // Process each record from DynamoDB stream
        for (const record of event.Records) {
            if (record.eventName === 'INSERT' || record.eventName === 'MODIFY') {
                const dynamoRecord = record.dynamodb.NewImage;
                
                // Transform DynamoDB record to BigQuery format
                const row = {
                    order_id: dynamoRecord.id?.S || '',
                    user_id: dynamoRecord.user_id?.S || '',
                    total_amount: parseFloat(dynamoRecord.total_amount?.N || '0'),
                    status: dynamoRecord.status?.S || '',
                    created_at: dynamoRecord.created_at?.S || new Date().toISOString(),
                    updated_at: new Date().toISOString(),
                    event_type: record.eventName,
                    items: JSON.stringify(dynamoRecord.items?.L || [])
                };
                
                rows.push(row);
            }
        }
        
        if (rows.length > 0) {
            // Insert rows into BigQuery
            await table.insert(rows);
            console.log(`Successfully inserted ${rows.length} rows into BigQuery`);
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                success: true,
                processedRecords: rows.length
            })
        };
        
    } catch (error) {
        console.error('Error processing DynamoDB stream:', error);
        throw error;
    }
};
