import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

const client = new SecretsManagerClient({ region: process.env.AWS_REGION || "us-east-1" });

let cachedSecrets = {};

export const getSecret = async (secretName) => {
  if (cachedSecrets[secretName]) {
    return cachedSecrets[secretName];
  }

  try {
    const command = new GetSecretValueCommand({ SecretId: secretName });
    const response = await client.send(command);
    const secrets = JSON.parse(response.SecretString);
    cachedSecrets[secretName] = secrets;
    return secrets;
  } catch (error) {
    console.error('Error fetching secret:', secretName, error);
    throw error;
  }
};

export const loadAISecrets = async () => {
  try {
    const secrets = await getSecret("cloudmart/production/ai-services");
    
    // Set environment variables from secrets
    process.env.BEDROCK_AGENT_ID = secrets.BEDROCK_AGENT_ID;
    process.env.BEDROCK_AGENT_ALIAS_ID = secrets.BEDROCK_AGENT_ALIAS_ID;
    process.env.OPENAI_API_KEY = secrets.OPENAI_API_KEY;
    process.env.OPENAI_ASSISTANT_ID = secrets.OPENAI_ASSISTANT_ID;
    
    console.log("AI secrets loaded successfully from AWS Secrets Manager");
  } catch (error) {
    console.error("Failed to load AI secrets:", error);
    // Don't throw - let app continue with existing env vars
  }
};
