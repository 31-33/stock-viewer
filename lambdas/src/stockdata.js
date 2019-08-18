exports.handler = function(event, context, callback) {
  
  return {
    statusCode: 200,
    body: {
      name: 'Aardvark Trading LLC',
      datapoints: [
        {
          dateTime: new Date(2019, 7, 1),
          price: 100,
        },
        {
          dateTime: new Date(2019, 7, 2),
          price: 102.5,
        },
        {
          dateTime: new Date(2019, 7, 3),
          price: 104.3,
        },
        {
          dateTime: new Date(2019, 7, 4),
          price: 106.4,
        },
        {
          dateTime: new Date(2019, 7, 5),
          price: 105.2,
        },
        {
          dateTime: new Date(2019, 7, 6),
          price: 105.2,
        },
        {
          dateTime: new Date(2019, 7, 7),
          price: 97.3,
        },
        {
          dateTime: new Date(2019, 7, 8),
          price: 98.8,
        },
        {
          dateTime: new Date(2019, 7, 9),
          price: 99.2,
        },
        {
          dateTime: new Date(2019, 7, 10),
          price: 101.4,
        },
      ],
    },
  }
}