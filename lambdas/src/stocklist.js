exports.handler = function (event, context, callback) {
  var response = {
    stocklist: [
      { stockId: 0, name: "Stock0" },
      { stockId: 1, name: "Stock1" },
      { stockId: 2, name: "Stock2" },
      { stockId: 3, name: "Stock3" },
      { stockId: 4, name: "Stock4" },
      { stockId: 5, name: "Stock5" },
    ]
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