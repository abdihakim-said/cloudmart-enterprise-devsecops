import * as aiService from "../services/aiService.js";
import { trackAIRequest, updateCustomerSatisfaction } from "../middleware/metrics.js";

export const startOpenAIConversationController = async (req, res) => {
  try {
    const result = await trackAIRequest('openai', 'gpt-4', 'start_conversation', async () => {
      return await aiService.createOpenAIConversation();
    });
    
    res.json({ threadId: result });
  } catch (error) {
    console.error("Error starting OpenAI conversation:", error);
    res
      .status(500)
      .json({ error: "Error starting conversation", details: error.message });
  }
};

export const sendOpenAIMessageController = async (req, res) => {
  try {
    const { threadId, message } = req.body;
    if (!threadId || !message) {
      return res
        .status(400)
        .json({ error: "ThreadId and message are required" });
    }
    
    const result = await trackAIRequest('openai', 'gpt-4', 'send_message', async () => {
      return await aiService.sendOpenAIMessage(threadId, message);
    });
    
    res.json({ response: result });
  } catch (error) {
    console.error("Error sending message to OpenAI:", error);
    res
      .status(500)
      .json({ error: "Error processing message", details: error.message });
  }
};

export const startBedrockConversationController = async (req, res) => {
  try {
    const result = await trackAIRequest('bedrock', 'claude-3', 'start_conversation', async () => {
      return await aiService.createBedrockConversation();
    });
    
    res.json({ conversationId: result });
  } catch (error) {
    console.error("Error starting Bedrock conversation:", error);
    res
      .status(500)
      .json({ error: "Error starting conversation", details: error.message });
  }
};

export const sendBedrockMessageController = async (req, res) => {
  try {
    const { conversationId, message } = req.body;
    if (!conversationId || !message) {
      return res
        .status(400)
        .json({ error: "ConversationId and message are required" });
    }
    
    const result = await trackAIRequest('bedrock', 'claude-3', 'send_message', async () => {
      return await aiService.sendBedrockMessage(conversationId, message);
    });
    
    res.json({ response: result });
  } catch (error) {
    console.error("Error sending message to Bedrock:", error);
    res
      .status(500)
      .json({ error: "Error processing message", details: error.message });
  }
};

export const analyzeSentimentAndSaveController = async (req, res) => {
  try {
    const { thread } = req.body;
    if (!thread || !thread.messages) {
      return res
        .status(400)
        .json({ error: "Thread with messages is required" });
    }
    
    const result = await trackAIRequest('azure', 'text-analytics', 'sentiment_analysis', async () => {
      return await aiService.analyzeSentimentAndSave(thread);
    });
    
    // Update customer satisfaction metric based on sentiment
    if (result && result.sentiment) {
      const satisfactionScore = result.sentiment === 'positive' ? 0.9 :
                               result.sentiment === 'neutral' ? 0.6 : 0.3;
      updateCustomerSatisfaction(satisfactionScore, 'ai-sentiment');
    }
    
    res.json(result);
  } catch (error) {
    console.error("Error analyzing sentiment:", error);
    res
      .status(500)
      .json({ error: "Error analyzing sentiment", details: error.message });
  }
};
