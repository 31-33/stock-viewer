# COMPX529-19B Cloud Computing and Security
## Assignment 1, Team 3 - "Stock Data Viewer"
Created using data from the [`Deutsche Börse Public Dataset (DBG PDS)`](https://github.com/Deutsche-Boerse/dbg-pds).

--- 
## Setup
Ensure the required packages are installed: `terraform`, `awscli`, `npm`, ...

Initialize terraform
> terraform init

Deploy
> terraform apply

Destroy / clean-up resources when finished
> terraform destroy


---
## API Routes
Client uses the following routes, configured using AWS API Gateway

  - `/stockdata`

    Request Type: `GET`

    Query Parameters:
    - stockId : the ISIN of the requested stock
    - dateRange : one of `'w', 'm', 'q', 'y'`- requesting the last week, month, quarter, or year of data

    Returns:
    - Stock name
    - Array of datapoints within the requested date range (each point consists of date/time and stockprice)

  - `/stocklist`
    
    Request Type: `GET`

    Returns:
    - Array of stocks (each entry includes the stock name and ISIN)

  - `/subscriptions`

    Request Type: `GET`

    Returns:
    - Array of stockIds that the current user has subscribed to

  - `/subscribe`
  
    Request Type: `POST`

    Query Parameters:
    - stockId: the stock ISIN
    - subscribe: boolean value (true to subscribe, false to unsubscribe)
  
    Returns
    - Boolean indicating current subscription state for the stock, after applying this operation