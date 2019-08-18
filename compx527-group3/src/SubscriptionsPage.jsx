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
    ).then((stocklist) => {
      this.setState({
        stocklist,
        loading: false,
      });
    });

    API.get(
      'awsApiGateway',
      '/subscriptions',
      {},
    ).then((response) => {
      this.setState({ subscriptions: new Set(response) });
    });
  }

  updateSubscription = async (stockId, subscribe) => {
    API.post(
      'awsApiGateway',
      '/subscribe',
      {
        queryStringParameters: {
          stockId,
          subscribe,
        }
      }
    ).then((subscribed) => {
      const updatedSubscriptions = this.state.subscriptions;
      if (subscribed) {
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
      <ListGroup.Item>
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
