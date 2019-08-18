import React, { Component } from 'react';
import { API } from 'aws-amplify';
import StockViewComponent from './StockViewComponent';

import CardColumns from 'react-bootstrap/CardColumns';
import Spinner from 'react-bootstrap/Spinner';

class StockViewPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      subscriptions: [],
    };
  }

  componentDidMount() {
    API.get(
      'awsApiGateway',
      '/subscriptions',
      {},
    ).then((subscriptions) => {
      this.setState({
        loading: false,
        subscriptions
      });
    });
  }

  render() {
    const { loading, subscriptions } = this.state;
    return (
      <CardColumns>
        {loading
          ? <Spinner animation='border' />
          : subscriptions.map(stockId => <StockViewComponent stockId={stockId} />)}
      </CardColumns>
    );
  }
}

export default StockViewPage;
