import React, { Component } from 'react';
import { API } from 'aws-amplify';

import Card from 'react-bootstrap/Card';
import Spinner from 'react-bootstrap/Spinner';
import ButtonToolbar from 'react-bootstrap/ButtonToolbar';
import Button from 'react-bootstrap/Button';
import moment from 'moment';

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
      dateRange: '7d', // [1d, 3d, 7d]
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
                    tickFormatter={(tick) => moment(tick).format("DD-MMM")}
                    dataKey="dateTime"
                  />
                  <YAxis
                    label={{
                      value: "Stock Price",
                      dx: -20,
                      angle: -90,
                    }}
                    dataKey="price"
                    domain={['auto', 'auto']}
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
            variant={dateRange === '1d' ? 'dark' : 'outline-dark'}
            onClick={() => this.setState({ dateRange: '1d' }, () => this.refreshData())}
          >
            1 Day
          </Button>
          <Button
            size='sm'
            variant={dateRange === '3d' ? 'dark' : 'outline-dark'}
            onClick={() => this.setState({ dateRange: '3d' }, () => this.refreshData())}
          >
            3 Days
          </Button>
          <Button
            size='sm'
            variant={dateRange === '7d' ? 'dark' : 'outline-dark'}
            onClick={() => this.setState({ dateRange: '7d' }, () => this.refreshData())}
          >
            7 Days
          </Button>
        </Card.Footer>
      </Card>
    );
  }
}

export default StockViewComponent;
