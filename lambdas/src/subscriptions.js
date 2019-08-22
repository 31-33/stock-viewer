exports.handler = function(event, context, callback) {
  
  return {
    statusCode: 200,
    headers: JSON.stringify({
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
    }),
    body: JSON.stringify({
      subscriptions: [0, 1, 3],
    }),
  };
}