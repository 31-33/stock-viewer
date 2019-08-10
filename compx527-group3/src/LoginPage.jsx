import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { Auth } from 'aws-amplify';

import FormGroup from 'react-bootstrap/FormGroup';
import FormControl from 'react-bootstrap/FormControl';
import ButtonGroup from 'react-bootstrap/ButtonGroup';
import Button from 'react-bootstrap/Button';
import FormLabel from 'react-bootstrap/FormLabel';

class LoginPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      email: "",
      password: "",
    };
  }

  login = async (email, password) => {
    try {
      await Auth.signIn(email, password);
      this.props.userHasAuthenticated(true);
    }
    catch (e) {
      console.log("AWS Authentication Error: ", e);
    }
  }

  render() {
    const { email, password } = this.state;

    return (
      <div style={{
        maxWidth: '320px',
        margin: '0 auto',
        padding: '60px 0',
      }}>
        <FormGroup>
          <FormLabel>Email</FormLabel>
          <FormControl
            type="email"
            value={email}
            onChange={(event) => { this.setState({ email: event.target.value }) }}
          />
        </FormGroup>
        <FormGroup>
          <FormLabel>Password</FormLabel>
          <FormControl
            type="password"
            value={password}
            onChange={(event) => { this.setState({ password: event.target.value }) }}
          />
        </FormGroup>
        <ButtonGroup size="lg" className="d-flex" >
          <Button
            disabled={email.length === 0 || password.length === 0}
            onClick={() => this.login(email, password)}
          >
            Login
          </Button>
          <Button
            variant="secondary"
            as={Link}
            to="/register"
          >
            Register
          </Button>
        </ButtonGroup>
      </div>
    );
  }
}

export default LoginPage;
