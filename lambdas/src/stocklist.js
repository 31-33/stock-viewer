exports.handler = function(event, context, callback) {
  
  return {
    'statusCode' : '200',
    'headers': {
      "Access-Control-Allow-Origin" : "*",
      "Content-Type" : "application/json",
    },
    'body': {
      'data': [
        { stockId: 0, name: "Stock0" },
        { stockId: 1, name: "Stock1" },
        { stockId: 2, name: "Stock2" },
        { stockId: 3, name: "Stock3" },
        { stockId: 4, name: "Stock4" },
        { stockId: 5, name: "Stock5" },
      ]
    },
  };
}