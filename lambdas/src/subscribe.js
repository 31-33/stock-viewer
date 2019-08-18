exports.handler = function(event, context, callback) {
  const { body } = event;
  const a = JSON.parse(body);

  return {
    statusCode: 200,
    body: {
      res: true,
    }
  }
}