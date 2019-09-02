import React, { Component } from 'react';
import { API } from 'aws-amplify';
import StockViewComponent from './StockViewComponent';

import Spinner from 'react-bootstrap/Spinner';

class StockViewPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      subscriptions: [],
    };
  }

  async componentDidMount() {
    API.get(
      'awsApiGateway',
      '/subscriptions',
      {},
    ).then(({ subscriptions }) => {
      this.setState({
        loading: false,
        subscriptions
      });
    });
  }

  render() {
    const { loading, subscriptions } = this.state;
    return loading
      ? <Spinner animation='border' />
      : subscriptions.map(stockId => <StockViewComponent stockId={stockId} key={stockId} />);
  }
}

export default StockViewPage;
