import React, { Component } from 'react';
import Alert from 'react-bootstrap/Alert';

class NotFoundPage extends Component {
  render() {
    return (
      <Alert variant="danger">
        <Alert.Heading>
            404 Page Not Found
        </Alert.Heading>
      </Alert>
    );
  }
}

export default NotFoundPage;
