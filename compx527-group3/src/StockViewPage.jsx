import React, { Component } from 'react';
import StockViewComponent from './StockViewComponent';
import CardColumns from 'react-bootstrap/CardColumns';

class StockViewPage extends Component {
  render() {
    return (
      <CardColumns>
        <StockViewComponent stockId={0} />
        <StockViewComponent stockId={1} />
        <StockViewComponent stockId={2} />
        <StockViewComponent stockId={3} />
        <StockViewComponent stockId={4} />
        <StockViewComponent stockId={5} />
        <StockViewComponent stockId={6} />
        <StockViewComponent stockId={7} />
        <StockViewComponent stockId={8} />
        <StockViewComponent stockId={9} />
      </CardColumns>
    );
  }
}

export default StockViewPage;
