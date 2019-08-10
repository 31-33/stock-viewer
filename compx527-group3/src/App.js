import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Switch, Redirect } from 'react-router-dom';
import { Auth } from 'aws-amplify';

import { FaChartLine } from 'react-icons/fa';

import Navbar from 'react-bootstrap/Navbar';
import Nav from 'react-bootstrap/Nav';
import NavDropdown from 'react-bootstrap/NavDropdown';
import Container from 'react-bootstrap/Container';

import LoginPage from './LoginPage';
import SignupPage from './SignupPage';
import StockViewPage from './StockViewPage';
import SubscriptionsPage from './SubscriptionsPage';
import NotFoundPage from './NotFoundPage';

const AuthenticatedRoute = ({ component: Component, props: childProps, ...rest }) => (
  <Route
    {...rest}
    render={props => childProps.isAuthenticated
      ? <Component {...props} {...childProps} />
      : <Redirect to='/login' />
    }
  />
);

const UnauthenticatedRoute = ({ component: Component, props: childProps, ...rest }) => (
  <Route
    {...rest}
    render={props => !childProps.isAuthenticated
      ? <Component {...props} {...childProps} />
      : <Redirect to='/' />
    }
  />
);

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isAuthenticated: false,
      isAuthenticating: true,
    };
  }

  async componentDidMount() {
    try {
      await Auth.currentSession();
      this.userHasAuthenticated(true);
    }
    catch (e) {
      if (e !== 'No current user') {
        console.log("AWS Authentication Error: ", e);
      }
    }
    
    this.setState({ isAuthenticating: false });
  }

  userHasAuthenticated = (authenticated) => { this.setState({ isAuthenticated: authenticated }); }

  handleLogout = async (event) => {
    await Auth.signOut();
    this.userHasAuthenticated(false);
  }

  render() {
    const { isAuthenticated, isAuthenticating } = this.state;
    const childProps = {
      isAuthenticated,
      userHasAuthenticated: this.userHasAuthenticated,
    };

    return (
      <Router>
        <Navbar collapseOnSelect expand="lg" bg="dark" variant="dark">
          <Container>
            <Navbar.Brand href="/"><FaChartLine /> Stock Data Viewer</Navbar.Brand>
            <Navbar.Toggle aria-controls="responsive-navbar-nav" />
            <Navbar.Collapse id="responsive-navbar-nav">
              <Nav className="mr-auto">
                {isAuthenticated && (
                  <Nav.Link href="/subscriptions">Subscriptions</Nav.Link>
                )}
              </Nav>
              <Nav>
                {isAuthenticated
                  ? (
                    <NavDropdown title="Account" id="basic-nav-dropdown">
                      <NavDropdown.Item onClick={this.handleLogout}>Logout</NavDropdown.Item>
                    </NavDropdown>
                  )
                  : (
                    <>
                      <Nav.Link href="/register">Signup</Nav.Link>
                      <Nav.Link href="/login">Login</Nav.Link>
                    </>
                  )
                }
              </Nav>
            </Navbar.Collapse>
          </Container>
        </Navbar>
        {!isAuthenticating && (
          <Container style={{ paddingTop: '1em' }}>
            <Switch>
              <AuthenticatedRoute path="/" exact component={StockViewPage} props={childProps} />
              <AuthenticatedRoute path="/subscriptions" exact component={SubscriptionsPage} props={childProps} />
              <AuthenticatedRoute path="/" exact component={StockViewPage} props={childProps} />
              <UnauthenticatedRoute path="/login" component={LoginPage} props={childProps} />
              <UnauthenticatedRoute path="/register" component={SignupPage} props={childProps} />
              <Route component={NotFoundPage} />
            </Switch>
          </Container>
        )}
      </Router>
    );
  }
}

export default App;
