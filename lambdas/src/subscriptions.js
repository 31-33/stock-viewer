exports.handler = function(event, context, callback) {
  
  return {
    statusCode: 200,
    body: {
      subscriptions: [0, 1, 3],
    },
  }
}