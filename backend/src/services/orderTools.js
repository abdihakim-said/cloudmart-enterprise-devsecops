// Tools the support assistant may call, and the deterministic checks around them.
// The model only proposes an action; this code decides whether it happens.
//
// - No destructive tools: the model can cancel (a reversible status change),
//   never delete.
// - Ownership: the order must belong to the customer on the conversation.
//   That email is supplied by the caller, not by the model, so a prompt like
//   "cancel order abc123" cannot reach someone else's order.
// - State: only orders that haven't shipped can be cancelled.

export const ORDER_ID_PATTERN = /^[a-f0-9]{8}$/;
export const CANCELLABLE_STATUSES = new Set(["pending", "processing"]);

export const cancelOrderTool = {
  name: "cancel_order",
  description:
    "Cancel one of the current customer's own orders that has not shipped yet. " +
    "Always confirm the order ID with the customer before calling.",
  parameters: {
    type: "object",
    properties: {
      orderId: {
        type: "string",
        description: "The ID of the customer's order to cancel",
      },
    },
    required: ["orderId"],
    additionalProperties: false,
  },
};

export const executeOrderTool = async (toolName, rawArgs, customerEmail, deps) => {
  if (toolName !== cancelOrderTool.name) {
    return `Tool ${toolName} is not available.`;
  }
  if (!customerEmail) {
    return "I can't change orders in this conversation because the customer isn't identified.";
  }

  let orderId;
  try {
    ({ orderId } = JSON.parse(rawArgs));
  } catch {
    return "Invalid tool arguments.";
  }
  if (typeof orderId !== "string" || !ORDER_ID_PATTERN.test(orderId)) {
    return "That doesn't look like a valid order ID.";
  }

  const order = await deps.getOrderById(orderId);
  // Same answer for "not found" and "not yours", so the tool can't be used to
  // probe which order IDs exist.
  if (!order || order.userEmail !== customerEmail) {
    return `I couldn't find order ${orderId} on your account.`;
  }
  if (!CANCELLABLE_STATUSES.has(order.status)) {
    return `Order ${orderId} is ${order.status} and can no longer be cancelled here. A support agent can help.`;
  }

  const updated = await deps.cancelOrder(orderId);
  return `Order ${orderId} has been cancelled. New status: ${updated.status}.`;
};
