import React, { Component } from 'react';
import { API } from 'aws-amplify';

import ListGroup from 'react-bootstrap/ListGroup';
import FormCheck from 'react-bootstrap/FormCheck';
import Spinner from 'react-bootstrap/Spinner';

class SubscriptionsPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      stocklist: [],
      subscriptions: new Set(),
    };
  }

  async componentDidMount() {
    API.get(
      'awsApiGateway',
      '/stocklist',
      {},
    ).then(({ stocklist }) => {
      this.setState({
        stocklist,
        loading: false,
      });
    });

    API.get(
      'awsApiGateway',
      '/subscriptions',
      {},
    ).then(({ subscriptions }) => {
      this.setState({ subscriptions: new Set(subscriptions) });
    });
  }

  updateSubscription = async (stockId, subscribe) => {
    const { subscriptions } = this.state;
    subscribe ? subscriptions.add(stockId) : subscriptions.delete(stockId);
    this.setState({ subscriptions });
    API.post(
      'awsApiGateway',
      '/subscribe',
      {
        queryStringParameters: {
          stockId,
          subscribe,
        }
      }
    ).then(({ res }) => {
      const updatedSubscriptions = this.state.subscriptions;
      if (res) {
        updatedSubscriptions.add(stockId);
      } else {
        updatedSubscriptions.delete(stockId);
      }
      this.setState({ subscriptions: updatedSubscriptions });
    });
  }

  renderListGroupItem = (item) => {
    const { subscriptions } = this.state;

    return (
      <ListGroup.Item key={item.stockId}>
        <FormCheck
          type="checkbox"
          label={item.name}
          checked={subscriptions.has(item.stockId)}
          onChange={({target}) => this.updateSubscription(item.stockId, target.checked)}
        />
      </ListGroup.Item>
    );
  }

  render() {
    const { loading, stocklist } = this.state;

    return (
      <div>
        <h3>Manage Subscriptions</h3>
        {loading
          ? <Spinner animation='border' />
          : stocklist.map(stock => this.renderListGroupItem(stock))}
      </div>
    );
  }
}

export default SubscriptionsPage;
