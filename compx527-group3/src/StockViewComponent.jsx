import React, { Component } from 'react';
import { API } from 'aws-amplify';

import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import ButtonToolbar from 'react-bootstrap/ButtonToolbar';
import Button from 'react-bootstrap/Button';

import {
  ResponsiveContainer, LineChart, XAxis, YAxis, Tooltip, Line,
} from 'recharts';

class StockViewComponent extends Component {
  constructor(props) {
    super(props);
    
    this.state = {
      loading: true,
      data: null,
      dateRange: 'q', // [w, m, q, y]
    };
  }

  componentDidMount() {
    this.refreshData();
  }


  refreshData = async () => {
    const { stockId } = this.props;
    const { dateRange } = this.state;

    // await API.get(
    //   'awsApiGateway',
    //   '/stockdata',
    //   {
    //     queryStringParameters: {
    //       stockId,
    //       dateRange,
    //     }
    //   }
    // ).then((response) => {
    //   this.setState({ data: response });
    // });


    this.setState({
      loading: false,
      data: {
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
    });
  }

  render() {
    const { loading, data, dateRange } = this.state;

    return (
      <Card>
        <Card.Header>{data && data.name}</Card.Header>
        <Card.Body style={{ width: '100%', height: '300px' }}>
          {loading
            ? <Spinner animation='border' />
            : (
              <ResponsiveContainer>
                <LineChart
                  margin={{ top: 10, right: 10, bottom: 20, left: 0 }}
                  data={data.datapoints}
                >
                  <XAxis
                    label={{
                      value: "Date",
                      dy: 20,
                    }}
                    dataKey="dateTime"
                  />
                  <YAxis
                    label={{
                      value: "Stock Price",
                      dx: -20,
                      angle: -90,
                    }}
                    dataKey="price"
                  />
                  <Tooltip />
                  <Line type='monotone' dataKey='price' />
                </LineChart>
              </ResponsiveContainer>
            )
          }
        </Card.Body>
        <Card.Footer as={ButtonToolbar}>
          <Button
            size='sm'
            variant={dateRange === 'y' ? 'dark' : 'outline-dark'}
            onClick={() => {
              this.setState({ dateRange: 'y' });
              this.refreshData();
            }}
          >
            1 Year
          </Button>
          <Button
            size='sm'
            variant={dateRange === 'q' ? 'dark' : 'outline-dark'}
            onClick={() => {
              this.setState({ dateRange: 'q' });
              this.refreshData();
            }}
          >
            3 Months
          </Button>
          <Button
            size='sm'
            variant={dateRange === 'm' ? 'dark' : 'outline-dark'}
            onClick={() => {
              this.setState({ dateRange: 'm' });
              this.refreshData();
            }}
          >
            1 Month
          </Button>
          <Button
            size='sm'
            variant={dateRange === 'w' ? 'dark' : 'outline-dark'}
            onClick={() => {
              this.setState({ dateRange: 'w' });
              this.refreshData();
            }}
          >
            1 Week
          </Button>
        </Card.Footer>
      </Card>
    );
  }
}

export default StockViewComponent;
