import { test } from "node:test";
import assert from "node:assert/strict";
import { executeOrderTool, cancelOrderTool } from "../orderTools.js";

const ORDERS = {
  aaaa1111: { id: "aaaa1111", userEmail: "alice@example.com", status: "pending" },
  bbbb2222: { id: "bbbb2222", userEmail: "bob@example.com", status: "pending" },
  cccc3333: { id: "cccc3333", userEmail: "alice@example.com", status: "shipped" },
};

const makeDeps = () => {
  const cancelled = [];
  return {
    cancelled,
    getOrderById: async (id) => ORDERS[id],
    cancelOrder: async (id) => {
      cancelled.push(id);
      return { ...ORDERS[id], status: "cancelled" };
    },
  };
};

const args = (orderId) => JSON.stringify({ orderId });

test("cancels the customer's own pending order", async () => {
  const deps = makeDeps();
  const out = await executeOrderTool("cancel_order", args("aaaa1111"), "alice@example.com", deps);
  assert.match(out, /has been cancelled/);
  assert.deepEqual(deps.cancelled, ["aaaa1111"]);
});

test("refuses another customer's order, without revealing it exists", async () => {
  const deps = makeDeps();
  const out = await executeOrderTool("cancel_order", args("bbbb2222"), "alice@example.com", deps);
  const missing = await executeOrderTool("cancel_order", args("dddd4444"), "alice@example.com", deps);
  assert.equal(out, "I couldn't find order bbbb2222 on your account.");
  assert.equal(missing, "I couldn't find order dddd4444 on your account.");
  assert.deepEqual(deps.cancelled, []);
});

test("refuses orders that have shipped", async () => {
  const deps = makeDeps();
  const out = await executeOrderTool("cancel_order", args("cccc3333"), "alice@example.com", deps);
  assert.match(out, /can no longer be cancelled/);
  assert.deepEqual(deps.cancelled, []);
});

test("does nothing without an identified customer", async () => {
  const deps = makeDeps();
  const out = await executeOrderTool("cancel_order", args("aaaa1111"), undefined, deps);
  assert.match(out, /isn't identified/);
  assert.deepEqual(deps.cancelled, []);
});

test("delete_order and unknown tools are not executable", async () => {
  const deps = makeDeps();
  for (const name of ["delete_order", "drop_table"]) {
    const out = await executeOrderTool(name, args("aaaa1111"), "alice@example.com", deps);
    assert.equal(out, `Tool ${name} is not available.`);
  }
  assert.deepEqual(deps.cancelled, []);
});

test("rejects malformed arguments and IDs", async () => {
  const deps = makeDeps();
  assert.equal(await executeOrderTool("cancel_order", "not json", "alice@example.com", deps), "Invalid tool arguments.");
  assert.match(await executeOrderTool("cancel_order", args("../../x"), "alice@example.com", deps), /valid order ID/);
  assert.deepEqual(deps.cancelled, []);
});

test("only cancel_order is offered to the model", () => {
  assert.equal(cancelOrderTool.name, "cancel_order");
});
