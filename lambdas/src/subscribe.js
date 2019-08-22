exports.handler = function(event, context, callback) {
  const { body } = event;
  const a = JSON.parse(body);

  return {
    statusCode: 200,
    headers: JSON.stringify({
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
    }),
    body: JSON.stringify({
      res: true,
    }),
  };
}