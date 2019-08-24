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
      datapoints: null,
      name: false,
      dateRange: 'q', // [w, m, q, y]
    };
  }

  componentDidMount() {
    this.refreshData();
  }


  refreshData = () => {
    const { stockId } = this.props;
    const { dateRange } = this.state;

    API.get(
      'awsApiGateway',
      '/stockdata',
      {
        queryStringParameters: {
          stockId,
          dateRange,
        }
      }
    ).then(({ name, datapoints }) => {
      this.setState({
        loading: false,
        name,
        datapoints,
      });
    });
  }

  render() {
    const { loading, datapoints, name, dateRange } = this.state;

    return (
      <Card>
        <Card.Header>{name}</Card.Header>
        <Card.Body style={{ width: '100%', height: '300px' }}>
          {loading
            ? <Spinner animation='border' />
            : (
              <ResponsiveContainer>
                <LineChart
                  margin={{ top: 10, right: 10, bottom: 20, left: 0 }}
                  data={datapoints}
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
