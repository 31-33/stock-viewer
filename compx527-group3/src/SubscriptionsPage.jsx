import React, { Component } from 'react';
import ListGroup from 'react-bootstrap/ListGroup';
import FormCheck from 'react-bootstrap/FormCheck';

class SubscriptionsPage extends Component {

  renderListGroupItem = (item) => {

    return (
      <ListGroup.Item>
        <FormCheck
          type="checkbox"
          label={item}
        />
      </ListGroup.Item>
    );
  }
  render() {
    return (
      <div>
        <h3>Manage Subscriptions</h3>
        {this.renderListGroupItem('ABC')}
        {this.renderListGroupItem('DEF')}
        {this.renderListGroupItem('GHI')}
        {this.renderListGroupItem('JKL')}
      </div>
    );
  }
}

export default SubscriptionsPage;
