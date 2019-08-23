exports.handler = function (event, context, callback) {
  var response = {
    subscriptions: [0, 1, 3]
  }
  callback(null, {
    "statusCode": 200,
    "headers": {
      "Access-Control-Allow-Origin" : "*",
      "Content-Type" : "application/json",
    },
    "body": JSON.stringify(response)
  })
}