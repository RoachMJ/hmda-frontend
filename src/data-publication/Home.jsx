import React, { Component } from 'react'
import Heading from '../common/Heading.jsx'
import YearSelector from '../common/YearSelector'
import { withAppContext } from '../common/appContextHOC.jsx'
import publicationsByYear from './constants/publications-by-year'
import NotFound from '../common/NotFound.jsx'

class Home extends Component {
  render() {
    const { year } = this.props.match.params
    const { shared } = this.props.config.dataPublicationYears
    
    if (shared.indexOf(year) === -1) return <NotFound />

    return (
      <div className="home">
        <div className="intro">
          <Heading type={1} headingText="HMDA Data Publication">
            <p className="lead">
              The HMDA data and reports are the most comprehensive publicly
              available information on mortgage market activity. The data and
              reports can be used along with the{' '}
              <a href="https://www.ffiec.gov/censusproducts.htm">Census</a>{' '}
              demographic information for data analysis purposes. Available
              below are the data and reports for HMDA data collected in or after
              2017. For HMDA data and reports for prior years, visit{' '}
              <a href="https://www.ffiec.gov/hmda/hmdaproducts.htm">
                https://www.ffiec.gov/hmda/hmdaproducts.htm
              </a>
              .
            </p>
          </Heading>
        </div>

        <YearSelector 
          year={year}
          years={shared}
          url='/data-publication'
        />

        <div className="card-container">
          {publicationsByYear[year].map((pub, idx) => (
            <div className="card" key={`${year}-${idx}`}>
              <Heading
                type={4}
                {...pub}
              />
            </div>
          ))}
        </div>
      </div>
    )
  }
}

export default withAppContext(Home)
