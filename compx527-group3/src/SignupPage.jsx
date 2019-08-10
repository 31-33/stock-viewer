import React, { Component } from 'react';
import { Auth } from 'aws-amplify';

import FormGroup from 'react-bootstrap/FormGroup';
import FormControl from 'react-bootstrap/FormControl';
import FormLabel from 'react-bootstrap/FormLabel';
import FormText from 'react-bootstrap/FormText'
import Button from 'react-bootstrap/Button';
import Spinner from 'react-bootstrap/Spinner';
import Modal from 'react-bootstrap/Modal';

class SignupPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isSigningUp: false,
      isVerifying: false,
      email: '',
      password: '',
      confirmPassword: '',
      confirmationCode: '',
      user: false,
      passwordErrorMessage: '',
    };
  }

  handleChange = (event) => { 
    this.setState({ [event.target.id]: event.target.value });
  }

  validate() {
    const { email, password, confirmPassword } = this.state;
    return email.length > 0
      && password.length > 0
      && password === confirmPassword;
  }

  handleSubmit = async () => {
    const { email, password } = this.state;
    this.setState({ isSigningUp: true });

    try {
      const user = await Auth.signUp({
        username: email,
        password,
      });
      this.setState({ user });
    } catch (e) {
      this.setState({ passwordErrorMessage: e.message });
    }

    this.setState({ isSigningUp: false });
  }

  handleConfirmationSubmit = async () => {
    const { email, password, confirmationCode } = this.state;
    this.setState({ isVerifying: true });

    try {
      await Auth.confirmSignUp(email, confirmationCode);
      await Auth.signIn(email, password);

      this.props.userHasAuthenticated(true);
    } catch (e) {
      console.log("AWS Registration Confirmation Error: ", e);
      this.setState({ isVerifying: false });
    }
  }

  render() {
    const {
      email, password, confirmPassword, confirmationCode,
      user, isSigningUp, isVerifying, passwordErrorMessage,
    } = this.state;
    return (
      <>
        <Modal show={!!user}>
          <Modal.Header>
            <Modal.Title>
              Complete Registration
            </Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <FormGroup controlId="confirmationCode">
              <FormLabel>Enter Confirmation Code</FormLabel>
              <FormControl
                autoFocus
                type="tel"
                value={confirmationCode}
                onChange={this.handleChange}
              />
              <FormText>Please check your email for the code.</FormText>
            </FormGroup>
            <Button
              block
              size="lg"
              disabled={confirmationCode.length === 0 || isVerifying}
              onClick={this.handleConfirmationSubmit}
            >
              {isVerifying
                ? (
                  <>
                    <Spinner animation="border" /> Verifying...
                  </>
                )
                : "Verify"
              }
            </Button>
          </Modal.Body>
        </Modal>
        <div style={{
          maxWidth: '320px',
          margin: '0 auto',
          padding: '60px 0',
        }}>
          <FormGroup controlId="email">
            <FormLabel>Email</FormLabel>
            <FormControl
              autoFocus
              type="email"
              value={email}
              onChange={this.handleChange}
            />
          </FormGroup>
          <FormGroup controlId="password">
            <FormLabel>Password</FormLabel>
            <FormControl
              type="password"
              value={password}
              onChange={this.handleChange}
            />
            {passwordErrorMessage && (
              <FormText>{passwordErrorMessage}</FormText>
            )}
          </FormGroup>
          <FormGroup controlId="confirmPassword">
            <FormLabel>Confirm Password</FormLabel>
            <FormControl
              type="password"
              value={confirmPassword}
              onChange={this.handleChange}
            />
          </FormGroup>
          <Button
            block
            size="lg"
            disabled={!this.validate() || isSigningUp}
            onClick={this.handleSubmit}
          >
            {isSigningUp
              ? (
                <>
                  <Spinner animation="border" /> Signing up...
                </>
              )
              : "Signup"
            }
          </Button>
        </div>
      </>
    );
  }
}

export default SignupPage;
